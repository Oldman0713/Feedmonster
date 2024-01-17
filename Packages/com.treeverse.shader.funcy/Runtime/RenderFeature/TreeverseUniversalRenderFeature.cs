using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using System.Reflection;
using System.Linq;
using Unity.Mathematics;

#if UNITY_EDITOR
using UnityEditor;
#endif

public class TreeverseUniversalRenderFeature : ScriptableRendererFeature
{
    Blit.BlitPass toonBlitPass = null;
    CustomPass.Pass toonBufferPass = null;

    public static TreeverseUniversalRenderFeature asset;

    public static void ModifyActiveVolumesLayer(string layerName)
    {
        foreach (var v in FindObjectsOfType<Volume>())
        {
            v.gameObject.layer = LayerMask.NameToLayer(layerName);
        }
    }



    [System.Serializable]
    public class ToonSettings
    {
        public Material blitMaterial;
        [Range(1, 4)]
        public int downSample = 1;
        public string toonBufferPassName = "ToonPostProcessing";
        [Space(15)]

        [Header("Post Processing")]
        public float contrast = 1.1f;
        [Space(15)]

        [Header("Environment")]
        public Vector2 ditherStep = new float2(1.0f, 4.5f);
        public Vector2 ditherStepShadowmask = new float2(-0.5f, 4f);
        [Space(15)]
        [Header("Global Volume Profile")]
        public VolumeProfile universalVolume;
    }

    [System.Serializable]
    public class RadiusBlurSettings
    {
        [System.NonSerialized] public float blurStrength = 0;
        [System.NonSerialized] public float blurWidth = 0f;
        [System.NonSerialized] public Vector3 worldPosition;
    }

    static RadiusBlurSettings m_RadiusBlurSettings;
    public static RadiusBlurSettings GetRadiusBlurSettings()
    {
        if (m_RadiusBlurSettings != null)
        {
            return m_RadiusBlurSettings;
        }

        TreeverseUniversalRenderFeature urf = rootRenderer.rendererFeatures.Find(x => x.GetType() == typeof(TreeverseUniversalRenderFeature)) as TreeverseUniversalRenderFeature;
        m_RadiusBlurSettings = urf.radiusBlurSettings;
        return m_RadiusBlurSettings;
    }

    public ToonSettings toonSettings = new ToonSettings();
    [HideInInspector] public Blit.BlitSettings psotSettings = new Blit.BlitSettings();
    [HideInInspector] public CustomPass.Settings toonBuffSettings = new CustomPass.Settings();

    public static UniversalRendererData rootRenderer;
    public static List<RadialBlurControl> radialBlurControls = new List<RadialBlurControl>();
    public RadiusBlurSettings radiusBlurSettings = new RadiusBlurSettings();

    public override void Create()
    {
        UniversalRenderPipelineAsset pipelineAsset = QualitySettings.GetRenderPipelineAssetAt(QualitySettings.GetQualityLevel()) as UniversalRenderPipelineAsset;
        FieldInfo fieldInfo = pipelineAsset.GetType().GetField("m_RendererDataList", BindingFlags.Instance | BindingFlags.NonPublic);
        ScriptableRendererData[] rendererDatas = fieldInfo.GetValue(pipelineAsset) as UnityEngine.Rendering.Universal.ScriptableRendererData[];
        rootRenderer = rendererDatas.ToList().Find(x => x.name == "RendererData_Default") as UniversalRendererData;

        asset = this;

        noneDrawingPass = new NoneDrawingPass(name, toonSettings, radiusBlurSettings);

        //Toon Buffer Settings
        string[] passName = new string[] { toonSettings.toonBufferPassName };
        toonBuffSettings.Event = RenderPassEvent.AfterRenderingTransparents;
        toonBuffSettings.filterSettings = new FilterSettings()
        {
            LayerMask = -1,
            PassNames = passName,
            RenderObjectType = RenderObjectType.All
        };
        toonBuffSettings.limitQueueRange = new Vector2Int(0, 5000);
        toonBuffSettings.renderQueueRange.lowerBound = toonBuffSettings.limitQueueRange.x;
        toonBuffSettings.renderQueueRange.upperBound = toonBuffSettings.limitQueueRange.y;
        toonBuffSettings.dstType = Target.Texture;
        toonBuffSettings.dstName = "_ToonPPSBuffer";
        toonBuffSettings.writeDefaultDepth = true;
        toonBufferPass = new CustomPass.Pass(name, toonBuffSettings);

        //Toon Blit Settings
        psotSettings.blitMaterial = toonSettings.blitMaterial;
        psotSettings.downSample = toonSettings.downSample;
        psotSettings.Event = RenderPassEvent.AfterRenderingTransparents;
        toonBlitPass = new Blit.BlitPass(psotSettings.Event, psotSettings, name);
        
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (psotSettings.blitMaterial == null)
        {
            Debug.LogWarningFormat("Missing Blit Material. {0} blit pass will not execute. Check for missing reference in the assigned renderer.", GetType().Name);
            return;
        }

        renderer.EnqueuePass(toonBufferPass);
        renderer.EnqueuePass(noneDrawingPass);
        toonBlitPass.Setup(renderer);
        renderer.EnqueuePass(toonBlitPass);
    }

    public System.Action<CommandBuffer, RenderingData> onCameraSetup;
    public System.Action<CommandBuffer, RenderingData, ScriptableRenderContext> execute;
    public System.Action<CommandBuffer> frameCleanup;

    #region None Drawing Pass
    NoneDrawingPass noneDrawingPass = null;
    class NoneDrawingPass : ScriptableRenderPass
    {
        string tag;
        ToonSettings toonSettings;
        TreeverseUniversalRenderFeature.RadiusBlurSettings radiusBlurSettings;
        public NoneDrawingPass(string tag, ToonSettings toonSettings,TreeverseUniversalRenderFeature.RadiusBlurSettings radiusBlurSettings)
        {
            this.tag = tag;
            this.radiusBlurSettings = radiusBlurSettings;
            this.toonSettings = toonSettings;
        }

        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            var desc = renderingData.cameraData.cameraTargetDescriptor;
            TreeverseUniversalRenderFeature.m_currentPixels = math.float2(desc.width, desc.height);

            asset.onCameraSetup?.Invoke(cmd, renderingData);
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmd = CommandBufferPool.Get(tag);

            var cameraData = renderingData.cameraData;

            asset.execute?.Invoke(cmd, renderingData, context);
            
            cmd.SetGlobalFloat("_ToonAdjustContrast", toonSettings.contrast);
            cmd.SetGlobalVector("_DitherStep", toonSettings.ditherStep);
            cmd.SetGlobalVector("_DitherStepShadow", toonSettings.ditherStepShadowmask);
            /*
            if (cameraData.isSceneViewCamera)
            {
                cmd.SetGlobalFloat("_DitherMask", 0.0f);
            }
            */
            if (TreeverseUniversalRenderFeature.radialBlurControls.Count > 0)
            {
                cmd.EnableShaderKeyword("_RadiusBlur");
                Camera camera = renderingData.cameraData.camera;
                Matrix4x4 viewMatrix = camera.worldToCameraMatrix;
                Matrix4x4 VP = GL.GetGPUProjectionMatrix(camera.projectionMatrix, true) * viewMatrix;
                cmd.SetGlobalMatrix("_VPMatrix", VP);
                cmd.SetGlobalFloat("_BlurStrength", radiusBlurSettings.blurStrength);
                cmd.SetGlobalFloat("_BlurWidth", radiusBlurSettings.blurWidth);
                cmd.SetGlobalVector("_BlurWorldPosition", radiusBlurSettings.worldPosition);
            }
            else
            {
                cmd.DisableShaderKeyword("_RadiusBlur");
            }

            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();
            CommandBufferPool.Release(cmd);
        }

        public override void FrameCleanup(CommandBuffer cmd)
        {
            base.FrameCleanup(cmd);
            asset.frameCleanup?.Invoke(cmd);
        }
    }
    #endregion

    #region Prepare Data to Other Script
    public static float2 currentPixels { get { return m_currentPixels; } }
    static float2 m_currentPixels;
    #endregion

#if UNITY_EDITOR
    // IngredientDrawerUIE
    [CustomPropertyDrawer(typeof(TreeverseUniversalRenderFeature.RadiusBlurSettings))]
    public class RadiusBlurSettings_Editor : PropertyDrawer
    {
        const string toggleKeyword = "ZDUniversalRenderFeature.RadiusBlurSettings";
        public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
        {
            var data = TreeverseUniversalRenderFeature.GetRadiusBlurSettings();

            bool isExpanded = EditorGUILayout.Foldout(EditorPrefs.GetBool(toggleKeyword), "Radius Blur Settings(NonSerialized)");
            if (isExpanded != EditorPrefs.GetBool(toggleKeyword))
            {
                EditorPrefs.SetBool(toggleKeyword, isExpanded);
            }
            if (isExpanded)
            {
                EditorGUI.indentLevel = 1;
                data.blurStrength = EditorGUILayout.FloatField("Strength", data.blurStrength);
                data.blurWidth = EditorGUILayout.FloatField("Width", data.blurWidth);
                EditorGUI.indentLevel = 0;
            }
        }
    }
#endif
}




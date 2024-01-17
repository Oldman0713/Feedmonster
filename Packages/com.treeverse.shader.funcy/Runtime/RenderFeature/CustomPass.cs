using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.UIElements;
using UnityEngine.UIElements;
#endif
public class CustomPass : ScriptableRendererFeature
{
    public Settings settings = new Settings();

    [System.Serializable]
    public class Settings : PassRenderSettings
    {

    }

    Pass? pass;
    public class Pass : ScriptableRenderPass
    {
        Settings settings;
        RenderObjectType renderObjectType;
        FilteringSettings m_FilteringSettings;
        string m_ProfilerTag;
        ProfilingSampler m_ProfilingSampler;
        List<ShaderTagId> m_ShaderTagIdList = new List<ShaderTagId>();
        RenderStateBlock m_RenderStateBlock;

        RenderTargetHandle customColor;

        public void SetDetphState(bool writeEnabled, CompareFunction function = CompareFunction.Less)
        {
            m_RenderStateBlock.mask |= RenderStateMask.Depth;
            m_RenderStateBlock.depthState = new DepthState(writeEnabled, function);
        }

        public Pass(string name, Settings settings)
        {
            this.settings = settings;

            base.profilingSampler = new ProfilingSampler(nameof(Pass));

            m_ProfilerTag = name;
            m_ProfilingSampler = new ProfilingSampler(name);

            this.renderPassEvent = settings.Event;
            this.renderObjectType = settings.filterSettings.RenderObjectType;

            m_FilteringSettings = new FilteringSettings(settings.renderQueueRange, settings.filterSettings.LayerMask);

            foreach (var passName in settings.filterSettings.PassNames)
            {
                m_ShaderTagIdList.Add(new ShaderTagId(passName));
            }

            m_RenderStateBlock = new RenderStateBlock(RenderStateMask.Nothing);

            if (settings.dstType == Target.Texture)
            {
                customColor.Init(settings.dstName);
            }
        }


        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            RenderTextureDescriptor desc = renderingData.cameraData.cameraTargetDescriptor;
            desc.width /= settings.downSample;
            desc.height /= settings.downSample;
            desc.depthBufferBits = 0;
            desc.colorFormat = settings.dstFormat;
            cmd.GetTemporaryRT(customColor.id, desc, settings.filterMode);

            if (settings.dstType == Target.Texture)
            {
                if(settings.writeDefaultDepth)
                {
                    ConfigureTarget(customColor.id, renderingData.cameraData.renderer.cameraDepthTarget);
                }
                else
                {
                    ConfigureTarget(customColor.id);
                }
                
            }
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            SortingCriteria sortingCriteria = (renderObjectType == RenderObjectType.Transparent)
                ? SortingCriteria.CommonTransparent
                : renderingData.cameraData.defaultOpaqueSortFlags;

            DrawingSettings drawingSettings = CreateDrawingSettings(m_ShaderTagIdList, ref renderingData, sortingCriteria);

            ref CameraData cameraData = ref renderingData.cameraData;
            Camera camera = cameraData.camera;

            // NOTE: Do NOT mix ProfilingScope with named CommandBuffers i.e. CommandBufferPool.Get("name").
            // Currently there's an issue which results in mismatched markers.
            CommandBuffer cmd = CommandBufferPool.Get();

            using (new ProfilingScope(cmd, m_ProfilingSampler))
            {
                if (settings.dstType == Target.Texture)
                {
                    cmd.ClearRenderTarget(false, true, Color.clear);
                }
                // Ensure we flush our command-buffer before we render...
                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();

                // Render the objects...
                context.DrawRenderers(renderingData.cullResults, ref drawingSettings, ref m_FilteringSettings, ref m_RenderStateBlock);
            }
            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }


        public override void OnCameraCleanup(CommandBuffer cmd)
        {
            if (settings.dstType == Target.Texture)
            {
                cmd.ReleaseTemporaryRT(customColor.id);
            }
        }
    }
    public override void Create()
    {
        FilterSettings filter = settings.filterSettings;

        // Render Objects pass doesn't support events before rendering prepasses.
        // The camera is not setup before this point and all rendering is monoscopic.
        // Events before BeforeRenderingPrepasses should be used for input texture passes (shadow map, LUT, etc) that doesn't depend on the camera.
        // These events are filtering in the UI, but we still should prevent users from changing it from code or
        // by changing the serialized data.
        if (settings.Event < RenderPassEvent.BeforeRenderingPrePasses)
        {
            settings.Event = RenderPassEvent.BeforeRenderingPrePasses;
        }

        switch (settings.filterSettings.RenderObjectType)
        {
            case RenderObjectType.Transparent:
                settings.renderQueueRange = RenderQueueRange.transparent;
                break;
            case RenderObjectType.Opaque:
                settings.renderQueueRange = RenderQueueRange.opaque;
                break;
            default:
                settings.renderQueueRange = RenderQueueRange.all;
                break;
        }
        settings.renderQueueRange.lowerBound = settings.limitQueueRange.x;
        settings.renderQueueRange.upperBound = settings.limitQueueRange.y;
        pass = new Pass(name, settings);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (settings.sceneViewOnly)
        {
            if (!renderingData.cameraData.isSceneViewCamera)
            {
                return;
            }
        }
        if (settings.gameViewOnly)
        {
            if (renderingData.cameraData.isSceneViewCamera)
            {
                return;
            }
        }

        renderer.EnqueuePass(pass);
    }

}

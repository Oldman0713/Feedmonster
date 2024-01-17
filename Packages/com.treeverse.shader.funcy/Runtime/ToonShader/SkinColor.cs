using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
#if UNITY_EDITOR
using UnityEditor;
#endif
[ExecuteInEditMode]
public class SkinColor : MonoBehaviour
{
    Renderer ren;
    MaterialPropertyBlock block = null;
    public int materialIndex = 0;
    public SkinContainer.SkinStyle targetStyle = new SkinContainer.SkinStyle(Color.white, Color.white, Color.white, Color.white, Color.white);

    public Texture2D areaMask;

    public SkinContainer targetContainer;

    [HideInInspector][SerializeField]ComputeShader cs;
    ToonShaderOverrideWriteOutline parent;


    [HideInInspector]public RenderTexture replaceAlbedo = null;

    [HideInInspector]public Texture2D origAlbedo;

    public Color albedoColor { get { return targetStyle.albedoColor; } }
    public Color areaR { get { return targetStyle.areaR; } }
    public Color areaG { get { return targetStyle.areaG; } }
    public Color areaB { get { return targetStyle.areaB; } }
    public Color areaA { get { return targetStyle.areaA; } }

    public Texture2D bakedMap { get { return targetStyle.bakedMap; } }

    static RenderTexture clearTexture = null;
    private void OnEnable()
    {
        parent = GetComponentInParent<ToonShaderOverrideWriteOutline>();
#if UNITY_EDITOR
        if (cs == null)
        {
            cs = AssetDatabase.LoadAssetAtPath<ComputeShader>(AssetDatabase.GUIDToAssetPath("3919246949454f44599ab69ab9506284"));
        }
        if(clearTexture == null)
        {
            clearTexture = new RenderTexture(1, 1, 0, RenderTextureFormat.ARGBHalf);
            var a = RenderTexture.active;
            RenderTexture.active = clearTexture;
            GL.Clear(true, true, Color.clear);
            RenderTexture.active = a;
        }
#endif
        ren = GetComponent<Renderer>();

        origAlbedo = ren.sharedMaterials[materialIndex].GetTexture("_AlbedoMap") as Texture2D;
        replaceAlbedo = TextureExtension.CreateRenderTexture(origAlbedo.name, new Vector2(origAlbedo.width, origAlbedo.height), RenderTextureFormat.ARGBHalf, Color.clear, false);

        block = new MaterialPropertyBlock();
        block.Clear();
        

        UpdateSkin();
    }

    void UpdateSkin()
    {
        if(parent != null)
        {
            block.SetFloat("_OutlineNearWidth", parent.outlineNearWidth);
            block.SetFloat("_OutlineFarWidth", parent.outlineFarWidth);
        }

        if (!bakedMap)
        {
            int kernel = cs.FindKernel("SkinColor");
            cs.GetKernelThreadGroupSizes(kernel, out uint x, out uint y, out uint z);
            cs.SetVector("areaR", areaR.ToVector());
            cs.SetVector("areaG", areaG.ToVector());
            cs.SetVector("areaB", areaB.ToVector());
            cs.SetVector("areaA", areaA.ToVector());
            cs.SetTexture(kernel, "origAlbedo", origAlbedo);
            cs.SetTexture(kernel, "areaMask", areaMask ? areaMask : clearTexture);
            cs.SetTexture(kernel, "Result", replaceAlbedo);
            cs.Dispatch(kernel, Mathf.CeilToInt(replaceAlbedo.width / (float)x), Mathf.CeilToInt(replaceAlbedo.height / (float)y), 1);
        }

        block.SetColor("_AlbedoColor", albedoColor);
        block.SetTexture("_AlbedoMap", bakedMap ? bakedMap : replaceAlbedo);

        for (int i = 0; i < ren.sharedMaterials.Length; i++)
        {
            if (materialIndex == i)
            {
                ren.SetPropertyBlock(block, materialIndex);
            }
            else
            {
                ren.SetPropertyBlock(parent ? parent.GetBlock() : null, i);
            }
        }
    }
#if UNITY_EDITOR
    private void OnValidate()
    {
        if (origAlbedo != ren.sharedMaterials[materialIndex].GetTexture("_AlbedoMap"))
        {
            origAlbedo = ren.sharedMaterials[materialIndex].GetTexture("_AlbedoMap") as Texture2D;
            if (replaceAlbedo != null)
            {
                replaceAlbedo.Release();
                DestroyImmediate(replaceAlbedo);
            }
            replaceAlbedo = TextureExtension.CreateRenderTexture(origAlbedo.name, new Vector2(origAlbedo.width, origAlbedo.height), RenderTextureFormat.ARGBHalf, Color.clear, false);

        }



        if (block != null)
        {
            UpdateSkin();
        }
    }
#endif
    private void Update()
    {
#if UNITY_EDITOR
        if (!Application.isPlaying)
        {
            UpdateSkin();
        }
#endif
    }
    private void OnDisable()
    {
        if (ren != null)
        {
            if (parent != null)
            {
                ren.SetPropertyBlock(parent.GetBlock(), materialIndex);
            }
            else
            {
                for (int i = 0; i < ren.sharedMaterials.Length; i++)
                {
                    ren.SetPropertyBlock(null, i);
                }
            }
            block.Clear();
            block = null;
        }
        if(replaceAlbedo != null)
        {
            replaceAlbedo.Release();
            replaceAlbedo = null;
        }
    }
}
#if UNITY_EDITOR
[CustomEditor(typeof(SkinColor))]
public class SkinColor_Editor : Editor
{
    SkinColor data;
    
    private void OnEnable()
    {
        data = target as SkinColor;
    }
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        if (data.targetContainer == null) return;
        GUILayout.Space(10);

        if(GUILayout.Button("Save Style"))
        {
            data.targetContainer.styles.Add(new SkinContainer.SkinStyle(data.albedoColor, data.areaR, data.areaG, data.areaB, data.areaA, data.targetStyle.styleName, data.bakedMap));
            EditorUtility.SetDirty(data.targetContainer);
        }

        if (data.targetContainer && GUILayout.Button("Save Current Map"))
        {
            Texture2D color = new Texture2D(data.replaceAlbedo.width, data.replaceAlbedo.height, TextureFormat.RGBAHalf, false, true);
            data.replaceAlbedo.CopyToTex2D(color);
            byte[] dataColor = color.EncodeToEXR(Texture2D.EXRFlags.CompressPIZ);
            string path = Path.GetDirectoryName(AssetDatabase.GetAssetPath(data.targetContainer)) + "/" + data.origAlbedo.name + "_" + data.targetStyle.styleName + ".exr";
            System.IO.File.WriteAllBytes(Application.dataPath.Replace("/Assets", "/" + path), dataColor);
            dataColor = null;
            DestroyImmediate(color);
            color = null;

            AssetDatabase.Refresh();
            color = AssetDatabase.LoadAssetAtPath<Texture2D>(path);
            data.targetStyle.bakedMap = color;
        }
        List<GUIContent> contents = new List<GUIContent>();
        
        foreach(var style in data.targetContainer.styles)
        {
            contents.Add(new GUIContent(style.styleName));
        }

        if (contents.Count > 0)
        {
            GUILayout.Space(10);
            GUILayout.Label("Select Styles", EditorStyles.boldLabel);
        }
        var cid = GUILayout.Toolbar(-1, contents.ToArray());

        if (cid >= 0)
        {
            if (data.targetStyle != null) { data.targetStyle = null; }
            data.targetStyle = new SkinContainer.SkinStyle(data.targetContainer.styles[cid]);
        }
    }
    private void OnDisable()
    {
        
    }
}
#endif

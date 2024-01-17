using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;
using ToonShaderCombineMapInstance = ToonShaderCombiner.ToonShaderCombineMapInstance;

#if UNITY_EDITOR
using UnityEditor;
using System.IO;
#endif
[CreateAssetMenu(fileName = "Toon Shader Atlas", menuName = "Treeverse/Toon Shader/Atlas")]
public class ToonShaderMaterialAtlaser : ScriptableObject
{
    [SerializeField] List<Material> includeMaterials;
    [HideInInspector]public ToonShaderCombiner.ToonShaderCombineMapInstance combinedMap;

#if UNITY_EDITOR
    public static ComputeShader cs;
    public static Shader toonShader;
    public void OnUpdateAsset(string directory, string assetPath)
    {
        DestoryObj(combinedMap.material);
        DestoryObj(combinedMap.albedoMap);
        DestoryObj(combinedMap.metallicGlossMap);
        DestoryObj(combinedMap.normalMap);

        TryGetUnityObjectsOfTypeFromPath<Material>(directory, out var materials);
        includeMaterials = materials.FindAll(m => m.shader == toonShader);

        List<ToonShaderCombineMapInstance> tcmi = new List<ToonShaderCombineMapInstance>();
        foreach (var m in includeMaterials)
        {
            tcmi.Add(new ToonShaderCombineMapInstance(m));
        }
        ;
        combinedMap = tcmi.CombineMaps(cs);

        tcmi.Clear();
        tcmi = null;
    }

    public static int TryGetUnityObjectsOfTypeFromPath<T>(string path, out List<T> assetsFound) where T : UnityEngine.Object
    {
        string[] filePaths = System.IO.Directory.GetFiles(path);

        int countFound = 0;
        assetsFound = new List<T>();
        if (filePaths != null && filePaths.Length > 0)
        {
            for (int i = 0; i < filePaths.Length; i++)
            {
                UnityEngine.Object obj = UnityEditor.AssetDatabase.LoadAssetAtPath(filePaths[i], typeof(T));
                if (obj is T asset)
                {
                    countFound++;
                    if (assetsFound.IndexOf(asset) == -1)
                    {
                        assetsFound.Add(asset);
                    }
                }
            }
        }

        return countFound;
    }
    void DestoryObj(Object o)
    {
        if (UnityEngine.Application.isPlaying)
        {
            Destroy(o);
        }
        else
        {
            DestroyImmediate(o);
        }
    }
#endif
}
#if UNITY_EDITOR
[InitializeOnLoad, CustomEditor(typeof(ToonShaderMaterialAtlaser))]
public class ToonShaderMaterialAltaser_Editor : Editor
{
    public static List<ToonShaderMaterialAtlaser> allAltas;

    ToonShaderMaterialAtlaser data;
    static ToonShaderMaterialAltaser_Editor()
    {
        EditorApplication.delayCall += () => {

            UpdateAltasInfo();
            EditorApplication.projectChanged += UpdateAltasInfo;
        };
    }

    static void UpdateAltasInfo()
    {
        if (ToonShaderMaterialAtlaser.cs == null)
        {
            ToonShaderMaterialAtlaser.cs = UnityEditor.AssetDatabase.LoadAssetAtPath<ComputeShader>(UnityEditor.AssetDatabase.GUIDToAssetPath("4f940f85a3f2e224abfcf8c1a86734cc"));
            ToonShaderMaterialAtlaser.toonShader = UnityEditor.AssetDatabase.LoadAssetAtPath<Shader>(UnityEditor.AssetDatabase.GUIDToAssetPath("9c272431d7173f54bae01582b2c7caed"));
        }

        allAltas = Resources.FindObjectsOfTypeAll<ToonShaderMaterialAtlaser>().ToList();
        foreach(var a in allAltas) 
        {
            string path = AssetDatabase.GetAssetPath(a);
            a.OnUpdateAsset(Path.GetDirectoryName(path), path);
        }
    }

    private void OnEnable()
    {
        data = target as ToonShaderMaterialAtlaser;
    }

    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        var rect = GUILayoutUtility.GetLastRect();

        rect.width = rect.height = 64;
        rect.y += 128;
        if (data.combinedMap.albedoMap)
        {
            GUI.Label(new Rect(rect.position - new Vector2(0.0f, 15.0f), new Vector2(100, 10)), "Albedo", EditorStyles.boldLabel);
            EditorGUI.DrawPreviewTexture(rect, data.combinedMap.albedoMap);

        }

        if (data.combinedMap.metallicGlossMap)
        {
            rect.x += 75;
            GUI.Label(new Rect(rect.position - new Vector2(0.0f, 15.0f), new Vector2(100, 10)), "MSAE", EditorStyles.boldLabel);
            EditorGUI.DrawPreviewTexture(rect, data.combinedMap.metallicGlossMap);
        }

        if (data.combinedMap.normalMap)
        {
            rect.x += 75;
            GUI.Label(new Rect(rect.position - new Vector2(0.0f, 15.0f), new Vector2(100, 10)), "Normal", EditorStyles.boldLabel);
            EditorGUI.DrawPreviewTexture(rect, data.combinedMap.normalMap);
        }
    }

    private void OnDisable()
    {

    }
}
#endif
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

#if UNITY_EDITOR
using UnityEditor;
[CreateAssetMenu(fileName = "SkinContainer", menuName = "Treeverse/Toon Shader/Skin Container Data")]
#endif

public class SkinContainer : ScriptableObject
{
    #region    Reference
#if UNITY_EDITOR
    [HideInInspector] public Texture2D previewGradient = null;
#endif
    #endregion Reference

    public List<SkinStyle> styles = new List<SkinStyle>();
    [System.Serializable]
    public class SkinStyle
    {
        public string styleName = "New Style";
        public int SettingID;
        [HideInInspector] public Gradient previewGradient = new Gradient();
        [Header("Albedo")]
        [ColorUsage(false, true)] public Color albedoColor = Color.white;
        [Header("Areas")]
        [ColorUsage(false, true)] public Color areaR = Color.white;
        [ColorUsage(false, true)] public Color areaG = Color.white;
        [ColorUsage(false, true)] public Color areaB = Color.white;
        [ColorUsage(false, true)] public Color areaA = Color.white;

        public Texture2D bakedMap = null;

        public SkinStyle(Color albedoColor, Color areaR, Color areaG, Color areaB, Color areaA, string name = "", Texture2D bakedMap = null)
        {
            this.styleName = name;
            this.albedoColor = albedoColor;
            this.areaR = areaR;
            this.areaG = areaG;
            this.areaB = areaB;
            this.areaA = areaA;
            this.bakedMap = bakedMap;
            var colors = new Color[] { areaR, areaG, areaB, areaA };
            var keys = new GradientColorKey[4];
            for (int i = 0; i < 4; i++)
            {
                var colorKey = new GradientColorKey();
                colorKey.color = colors[i];
                colorKey.time = (i + 1.0f) * 0.25f;
                keys[i] = colorKey;
            }
            previewGradient.colorKeys = keys;
        }
        public SkinStyle(SkinStyle data)
        {
            this.styleName = data.styleName;
            this.albedoColor = data.albedoColor;
            this.areaR = data.areaR;
            this.areaG = data.areaG;
            this.areaB = data.areaB;
            this.areaA = data.areaA;
            this.bakedMap = data.bakedMap;
            var colors = new Color[] { areaR, areaG, areaB, areaA };
            var keys = new GradientColorKey[4];
            for (int i = 0; i < 4; i++)
            {
                var colorKey = new GradientColorKey();
                colorKey.color = colors[i];
                colorKey.time = (i + 1.0f) * 0.25f;
                keys[i] = colorKey;
            }
            previewGradient.colorKeys = keys;
        }
    }
}
#if UNITY_EDITOR
[InitializeOnLoad]
[CustomEditor(typeof(SkinContainer))]
public class SkinContainerEditorManager : Editor
{
    static List<SkinContainer> containers = null;

    static SkinContainerEditorManager()
    {
        EditorApplication.delayCall += () => {
            containers = Resources.FindObjectsOfTypeAll<SkinContainer>().ToList();
            EditorApplication.update += () => {
                foreach (var c in containers)
                {
                    if (c.previewGradient == null)
                    {

                    }
                }
            };
        };
    }

    public static SkinContainer GetContainer(SkinColor skin)
    {
        return null;
    }

    SkinContainer data;
    private void OnEnable()
    {
        data = target as SkinContainer;
    }
    string GetStyleTemplate(string name, string textureGUID, Color albedoColor)
    {

        string format = "";
        /*
        for (int i = 1; i < 16; i++)
        {
            format += "{" + i.ToString() + "}" + "{0}";
        }
        */
        return string.Format("{1}{0}{2}{0}{3}{0}{4}{0}{5}{0}{6}{0}{7}{0}{8}{0}{9}{0}{10}{0}{11}{0}{12}{0}{13}{0}{14}{0}{15}{0}", "\n",
        "%YAML 1.1",
        "%TAG !u! tag:unity3d.com,2011:",
        "--- !u!114 &11400000",
        "MonoBehaviour:",
        "  m_ObjectHideFlags: 0",
        "  m_CorrespondingSourceObject: {fileID: 0}",
        "  m_PrefabInstance: {fileID: 0}",
        "  m_PrefabAsset: {fileID: 0}",
        "  m_GameObject: {fileID: 0}",
        "  m_Enabled: 1",
        "  m_Script: {fileID: 11500000, guid: 869336318082cac49983b7d752a12050, type: 3}",
        "  m_Name: " + name,
        "  m_EditorClassIdentifier: ",
        "  albedoColor: {r: " + albedoColor.r + ", g: " + albedoColor.g + ", b: " + albedoColor.b + ", a: " + albedoColor.a + "}",
        "  albedoMap: {fileID: 2800000, guid: " + textureGUID + ", type: 3}"
        );

    }

    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        if (GUILayout.Button("Create Style Data"))
        {
            string localPath = "/ArtAssets/Scripts/ScriptableObject/Data/CharacterStyleData/";
            string IOPath = Application.dataPath + localPath;
            foreach (var style in data.styles)
            {
                string name = data.name + "_" + style.styleName;
                System.IO.File.WriteAllText(IOPath + name + ".asset", GetStyleTemplate(name, AssetDatabase.AssetPathToGUID(AssetDatabase.GetAssetPath(style.bakedMap)), style.albedoColor));
            }
            AssetDatabase.Refresh();
        }
    }
    private void OnDisable()
    {

    }
}
#endif

using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Threading;
using System.Threading.Tasks;
using UnityEditor;
using UnityEngine;

public class FindMaterialWithReferenceShader : EditorWindow
{
    [MenuItem("Assets/Treverse Tools/Find Reference Material with Shader")]
    public static void OpenFromProjectMenu()
    {
        Open();
    }

    static void Open()
    {
        var window = CreateInstance<FindMaterialWithReferenceShader>();
        window.minSize = new Vector2(300, 500);
        window.titleContent = new GUIContent("Material Finder");
        window.isEnable = true;
        window.onDisable += () => { window.isEnable = false; };
        window.Show();
        window.Focus();

        if (Selection.activeObject)
        {
            foreach (var o in Selection.objects)
            {
                if (o.GetType() == typeof(DefaultAsset))
                {
                    window.floders.Add(AssetDatabase.GetAssetPath(o));
                }
                if (o.GetType() == typeof(Shader))
                {
                    window.referenceShader = o as Shader;
                }
            }
        }
        else
        {
            window.floders.Add(@"Assets");
        }

        window.InitSerializedProperty();

    }
    bool isEnable = true;
    bool finding = false;
    float currentRate = 1.0f;
    string status = "Waiting...";
    System.Action? onDisable;

    private async void OnGUI()
    {
        int index = 0;
        GUILayout.Label("root floders", EditorStyles.boldLabel);
        GUILayout.BeginHorizontal("Box");
        if (Selection.activeObject && GUILayout.Button("Add Selected", EditorStyles.miniButton, GUILayout.MaxWidth(100)))
        {
            floders.Add(AssetDatabase.GetAssetPath(Selection.activeObject));
            floders = new HashSet<string>(floders).ToList();
            InitSerializedProperty();
        }
        GUILayout.EndHorizontal();

        EditorGUILayout.PropertyField(floders_Prop);
        floders_SO.ApplyModifiedProperties();

        referenceShader = (Shader)EditorGUILayout.ObjectField(referenceShader, typeof(Shader), false);

        if (finding)
        {
            EditorGUI.ProgressBar(new Rect(3, position.height - 20, position.width - 6, 15), currentRate, status);
        }

        EditorGUI.BeginDisabledGroup(finding || !referenceShader);
        if (GUILayout.Button("Find"))
        {
            status = "Waiting...";
            finding = true;
            list = new List<Material>();
            pathlist = new List<string>();
            AssetDatabase.TryGetGUIDAndLocalFileIdentifier<Shader>(referenceShader, out var shaderHash, out var localID);
            List<string> paths = new List<string>();
            foreach (var floder in floders)
            {
                paths.AddRange(Directory.GetFiles(
                    Path.Combine(Application.dataPath.Replace("/Assets", "/"), floder), "*", SearchOption.AllDirectories)
                    .ToList()
                    .FindAll(f => Path.GetExtension(f).ToLower() == ".mat"));
            }

            index = 0;
            foreach (var file in paths)
            {
                if (!isEnable)
                {
                    return;
                }

                var path = file.Replace(Application.dataPath, "Assets");
                if (Check(path, shaderHash))
                {
                    list.Add(AssetDatabase.LoadAssetAtPath<Material>(path));
                    pathlist.Add(path);
                }
                Repaint();
                await Task.Delay(10);
                index++;
                currentRate = (float)index / (float)paths.Count;
                status = string.Format("{0}/{1}", index, paths.Count);
            }

            status = "Finished!!";
            Repaint();
            await Task.Delay(2000);
            finding = false;
            Repaint();
            return;
        }
        if (GUILayout.Button("Select"))
        {
            List<Object> goList = new List<Object>();
            foreach (var m in list)
            {
                goList.Add(m);
            }
            Selection.objects = goList.ToArray();
        }

        EditorGUI.EndDisabledGroup();
        scrollPos = EditorGUILayout.BeginScrollView(scrollPos, GUILayout.Height(position.height - 195 - 20 * floders.Count));
        index = 0;
        foreach (var o in list)
        {
            index++;
            GUILayout.BeginHorizontal();
            GUILayout.Label(index.ToString(), GUILayout.Width(30));
            EditorGUILayout.ObjectField(o, typeof(Material), false);
            GUILayout.EndHorizontal();
        }
        EditorGUILayout.EndScrollView();

    }


    public static bool Check(string path, string shaderHash)
    {
        try
        {
            var t = File.ReadAllText(path);

            return t.Contains(shaderHash);
        }
        catch
        {
            return false;
        }
    }
    private void OnEnable()
    {
        InitSerializedProperty();
    }

    void InitSerializedProperty()
    {
        floders_SO = new SerializedObject(this);
        floders_Prop = floders_SO.FindProperty("floders");
    }

    private void OnDestroy()
    {
        list.Clear();
        pathlist.Clear();
        onDisable?.Invoke();
    }

    #region Props
    [SerializeField] Shader referenceShader;
    [SerializeField] List<string> floders = new List<string>();
    [SerializeField] List<Material> list = new List<Material>();
    [SerializeField] List<string> pathlist = new List<string>();
    #endregion

    #region Editor
    Vector2 scrollPos = Vector2.zero;
    SerializedObject floders_SO;
    SerializedProperty floders_Prop;
    #endregion
}

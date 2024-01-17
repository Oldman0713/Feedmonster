using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEditor.Build;
using UnityEditor.Build.Reporting;
using UnityEngine;

[InitializeOnLoad]
public class NomalSmoothSolver : AssetPostprocessor, IPreprocessBuildWithReport, IPostprocessBuildWithReport
{
    public int callbackOrder => 0;

    static NomalSmoothSolver()
    {
        EditorApplication.delayCall += () =>
        {
            RefreshOutline();
        };
    }


    public void OnPreprocessBuild(BuildReport report)
    {
        var fbxGUIDs = AssetDatabase.FindAssets("t:mesh", new string[] { "Assets/ArtAssets/Models" });
        List<string>? toFixPaths = new List<string>();
        foreach (var guid in fbxGUIDs)
        {
            EditorUtility.DisplayProgressBar("Refreshing Outline ", "", 0);
            var path = AssetDatabase.GUIDToAssetPath(guid);
            if (Path.GetExtension(path).ToLower() != ".fbx")
            {
                continue;
            }

            var assetImporter = AssetImporter.GetAtPath(path);
            if (assetImporter.userData.IndexOf("CharacterOutlineSolver:1") == -1)
            {
                continue;
            }

            toFixPaths.Add(path);
        }
        int index = 1;
        foreach (var path in toFixPaths)
        {
            AssetDatabase.ImportAsset(path);
            EditorUtility.DisplayProgressBar("Refreshing Outline " + string.Format("{0}/{1}", index, toFixPaths.Count), path, (float)index / toFixPaths.Count);
            index++;
        }
        toFixPaths.Clear();
        toFixPaths = null;
    }

    public void OnPostprocessBuild(BuildReport report)
    {

    }

    static void RefreshOutline()
    {
        var fbxGUIDs = AssetDatabase.FindAssets("t:mesh", new string[] { "Assets/ArtAssets/Models" });
        int index = 1;
        foreach (var guid in fbxGUIDs)
        {
            var assetPath = AssetDatabase.GUIDToAssetPath(guid);

            if (Path.GetExtension(assetPath).ToLower() != ".fbx")
            {
                continue;
            }

            var assetImporter = AssetImporter.GetAtPath(assetPath);
            if (assetImporter.userData.IndexOf("CharacterOutlineSolver:1") != -1)
            {
                SmoothFBXNormalInUV4(assetPath);
            }
            index++;
        }
    }

    [MenuItem("Assets/Treverse Tools/Mesh/Smooth Outline", true)]
    public static bool SmoothOutline_Validate()
    {
        bool hasMesh = Selection.activeObject is GameObject && AssetDatabase.LoadAllAssetRepresentationsAtPath(AssetDatabase.GetAssetPath(Selection.activeObject)).ToList().Find(m => m.GetType() == typeof(Mesh)) != null;
        return hasMesh;
    }
    [MenuItem("Assets/Treverse Tools/Mesh/Smooth Outline", false, 1001)]
    public static void SmoothOutline()
    {
        foreach (var o in Selection.objects)
        {
            var fbxPath = AssetDatabase.GetAssetPath(o);
            var assetImporter = AssetImporter.GetAtPath(fbxPath);
            if (assetImporter.userData.IndexOf("CharacterOutlineSolver:1") == -1)
            {
                assetImporter.userData += ";CharacterOutlineSolver:1";
                assetImporter.SaveAndReimport();
            }
        }
    }

    [MenuItem("Assets/Treverse Tools/Mesh/Cancel Smooth Outline", true)]
    public static bool CancelSmoothOutline_Validate()
    {
        var fbxPath = AssetDatabase.GetAssetPath(Selection.activeObject);
        var assetImporter = AssetImporter.GetAtPath(fbxPath);

        return assetImporter.userData.IndexOf("CharacterOutlineSolver:1") != -1;
    }
    [MenuItem("Assets/Treverse Tools/Mesh/Cancel Smooth Outline", false, 1001)]
    public static void CancelSmoothOutline()
    {
        foreach (var o in Selection.objects)
        {
            var fbxPath = AssetDatabase.GetAssetPath(o);
            var assetImporter = AssetImporter.GetAtPath(fbxPath);
            assetImporter.userData = assetImporter.userData.Replace(";CharacterOutlineSolver:1", "");
            assetImporter.SaveAndReimport();
        }
    }

    /*
    [MenuItem("Assets/Treverse Tools/Mesh/Smooth Outline(In SubFolder)", true)]
    public static bool SmoothOutlineInSubFolder_Validate()
    {
        return Selection.activeObject is DefaultAsset;
    }
    [MenuItem("Assets/Treverse Tools/Mesh/Smooth Outline(In SubFolder)", false, 1001)]
    public static void SmoothOutlineInSubFolder()
    {
        var files = Directory.GetFiles(AssetDatabase.GetAssetPath(Selection.activeObject).Replace("Assets/", Application.dataPath + "/"), "*", SearchOption.AllDirectories).ToList().FindAll(x => Path.GetExtension(x).ToLower() == ".fbx");
        foreach (var path in files)
        {
            var fbxPath = path.toAssetsPath();
            var assetImporter = AssetImporter.GetAtPath(fbxPath);
            if (assetImporter.userData.IndexOf("CharacterOutlineSolver:1") == -1)
            {
                assetImporter.userData += ";CharacterOutlineSolver:1";
                assetImporter.SaveAndReimport();
            }
        }
    }
    */
    public void OnPreprocessModel()
    {
        bool needToFixMesh = false;
        if (Path.GetExtension(this.assetPath).ToLower() != ".fbx")
        {
            return;
        }

        if (assetImporter.userData.IndexOf("CharacterOutlineSolver:1") != -1)
        {
            needToFixMesh = true;
        }

        if (needToFixMesh)
        {
            EditorApplication.CallbackFunction loadFunction = null;
            loadFunction = () =>
            {
                SmoothFBXNormalInUV4(this.assetPath);
                EditorApplication.delayCall -= loadFunction;
            };
            EditorApplication.delayCall += loadFunction;
        }
    }

    static void SmoothFBXNormalInUV4(string assetPath)
    {
        var mhs = AssetDatabase.LoadAllAssetRepresentationsAtPath(assetPath).ToList().FindAll(m => m.GetType() == typeof(Mesh));
        foreach (var mh in mhs)
        {
            RecalculateNormals((Mesh)mh, 179);
        }
    }

    public static void RecalculateNormals(Mesh mesh, float angle)
    {
        var cosineThreshold = Mathf.Cos(angle * Mathf.Deg2Rad);

        var vertices = mesh.vertices;
        var normals = new Vector4[vertices.Length];

        // Holds the normal of each triangle in each sub mesh.
        var triNormals = new Vector3[mesh.subMeshCount][];

        var dictionary = new Dictionary<VertexKey, List<VertexEntry>>(vertices.Length);

        for (var subMeshIndex = 0; subMeshIndex < mesh.subMeshCount; ++subMeshIndex)
        {

            var triangles = mesh.GetTriangles(subMeshIndex);

            triNormals[subMeshIndex] = new Vector3[triangles.Length / 3];

            for (var i = 0; i < triangles.Length; i += 3)
            {
                int i1 = triangles[i];
                int i2 = triangles[i + 1];
                int i3 = triangles[i + 2];

                // Calculate the normal of the triangle
                Vector3 p1 = vertices[i2] - vertices[i1];
                Vector3 p2 = vertices[i3] - vertices[i1];
                Vector3 normal = Vector3.Cross(p1, p2).normalized;
                int triIndex = i / 3;
                triNormals[subMeshIndex][triIndex] = normal;

                List<VertexEntry> entry;
                VertexKey key;

                if (!dictionary.TryGetValue(key = new VertexKey(vertices[i1]), out entry))
                {
                    entry = new List<VertexEntry>(4);
                    dictionary.Add(key, entry);
                }
                entry.Add(new VertexEntry(subMeshIndex, triIndex, i1));

                if (!dictionary.TryGetValue(key = new VertexKey(vertices[i2]), out entry))
                {
                    entry = new List<VertexEntry>();
                    dictionary.Add(key, entry);
                }
                entry.Add(new VertexEntry(subMeshIndex, triIndex, i2));

                if (!dictionary.TryGetValue(key = new VertexKey(vertices[i3]), out entry))
                {
                    entry = new List<VertexEntry>();
                    dictionary.Add(key, entry);
                }
                entry.Add(new VertexEntry(subMeshIndex, triIndex, i3));
            }
        }

        // Each entry in the dictionary represents a unique vertex position.

        foreach (var vertList in dictionary.Values)
        {
            for (var i = 0; i < vertList.Count; ++i)
            {

                var sum = new Vector3();
                var lhsEntry = vertList[i];

                for (var j = 0; j < vertList.Count; ++j)
                {
                    var rhsEntry = vertList[j];

                    if (lhsEntry.VertexIndex == rhsEntry.VertexIndex)
                    {
                        sum += triNormals[rhsEntry.MeshIndex][rhsEntry.TriangleIndex];
                    }
                    else
                    {
                        // The dot product is the cosine of the angle between the two triangles.
                        // A larger cosine means a smaller angle.
                        var dot = Vector3.Dot(
                            triNormals[lhsEntry.MeshIndex][lhsEntry.TriangleIndex],
                            triNormals[rhsEntry.MeshIndex][rhsEntry.TriangleIndex]);
                        if (dot >= cosineThreshold)
                        {
                            sum += triNormals[rhsEntry.MeshIndex][rhsEntry.TriangleIndex];
                        }
                    }
                }

                normals[lhsEntry.VertexIndex] = sum.normalized;
            }
        }

        mesh.SetUVs(3, normals);
    }


    private struct VertexKey
    {
        private readonly long _x;
        private readonly long _y;
        private readonly long _z;

        // Change this if you require a different precision.
        private const int Tolerance = 100000;

        // Magic FNV values. Do not change these.
        private const long FNV32Init = 0x811c9dc5;
        private const long FNV32Prime = 0x01000193;

        public VertexKey(Vector3 position)
        {
            _x = (long)(Mathf.Round(position.x * Tolerance));
            _y = (long)(Mathf.Round(position.y * Tolerance));
            _z = (long)(Mathf.Round(position.z * Tolerance));
        }

        public override bool Equals(object obj)
        {
            var key = (VertexKey)obj;
            return _x == key._x && _y == key._y && _z == key._z;
        }

        public override int GetHashCode()
        {
            long rv = FNV32Init;
            rv ^= _x;
            rv *= FNV32Prime;
            rv ^= _y;
            rv *= FNV32Prime;
            rv ^= _z;
            rv *= FNV32Prime;

            return rv.GetHashCode();
        }
    }

    private struct VertexEntry
    {
        public int MeshIndex;
        public int TriangleIndex;
        public int VertexIndex;

        public VertexEntry(int meshIndex, int triIndex, int vertIndex)
        {
            MeshIndex = meshIndex;
            TriangleIndex = triIndex;
            VertexIndex = vertIndex;
        }
    }
}


using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEditor.Build;
using UnityEditor.Build.Reporting;
using UnityEngine;

[InitializeOnLoad]
public class SkinnedMeshRootBoneSolver : AssetPostprocessor, IPreprocessBuildWithReport, IPostprocessBuildWithReport
{
    public int callbackOrder => 0;

    static SkinnedMeshRootBoneSolver()
    {
        EditorApplication.delayCall += () =>
        {
            Solve();
        };
    }


    public void OnPreprocessBuild(BuildReport report)
    {
        var fbxGUIDs = AssetDatabase.FindAssets("t:mesh", new string[] { "Assets/" });
        List<string> toFixPaths = new List<string>();
        foreach (var guid in fbxGUIDs)
        {
            EditorUtility.DisplayProgressBar("Refreshing SMR RootBone ", "", 0);
            var path = AssetDatabase.GUIDToAssetPath(guid);
            if (Path.GetExtension(path).ToLower() != ".fbx")
            {
                continue;
            }

            var mo = (ModelImporter)AssetImporter.GetAtPath(path);
            if (mo.animationType == ModelImporterAnimationType.None)
            {
                continue;
            }

            toFixPaths.Add(path);
        }
        int index = 1;
        foreach (var path in toFixPaths)
        {
            AssetDatabase.ImportAsset(path);
            EditorUtility.DisplayProgressBar("Refreshing SMR RootBone " + string.Format("{0}/{1}", index, toFixPaths.Count), path, (float)index / toFixPaths.Count);
            index++;
        }
        toFixPaths.Clear();
        toFixPaths = null;
    }

    public void OnPostprocessBuild(BuildReport report)
    {

    }

    static void Solve()
    {
        var fbxGUIDs = AssetDatabase.FindAssets("t:mesh", new string[] { "Assets/ArtAssets/Models/SkinnedMeshes" });
        int index = 1;
        foreach (var guid in fbxGUIDs)
        {
            var assetPath = AssetDatabase.GUIDToAssetPath(guid);

            if (Path.GetExtension(assetPath).ToLower() != ".fbx")
            {
                continue;
            }

            var mo = (ModelImporter)AssetImporter.GetAtPath(assetPath);
            if (mo.animationType != ModelImporterAnimationType.None)
            {
                Solve(assetPath);
            }
            index++;
        }
    }

    public void OnPreprocessModel()
    {
        bool needToFixMesh = false;
        if (Path.GetExtension(this.assetPath).ToLower() != ".fbx")
        {
            return;
        }

        var mo = assetImporter as ModelImporter;
        if (mo != null && mo.animationType != ModelImporterAnimationType.None)
        {
            needToFixMesh = true;
        }

        if (needToFixMesh)
        {
            EditorApplication.CallbackFunction loadFunction = null;
            loadFunction = () =>
            {
                Solve(this.assetPath);
                EditorApplication.delayCall -= loadFunction;
            };
            EditorApplication.delayCall += loadFunction;
        }
    }

    static void Solve(string assetPath)
    {
        var gos = AssetDatabase.LoadAllAssetRepresentationsAtPath(assetPath).ToList().FindAll(m => m.GetType() == typeof(GameObject));
        Object ro = gos.Find(x => x.name == "DeformationSystem");
        if (ro == null) return;
        Transform replaceRootBone = (ro as GameObject).transform;
        foreach (var o in gos)
        {
            var go = o as GameObject;
            foreach(var smr in go.GetComponentsInChildren<SkinnedMeshRenderer>())
            {
                smr.rootBone = replaceRootBone;
                //Debug.Log(smr.name + ":" + smr.localBounds);
                smr.updateWhenOffscreen = true;
                //Debug.Log(smr.name + ":" + smr.localBounds);
                var b = smr.localBounds;
                smr.updateWhenOffscreen = false;
                smr.localBounds = b;
            }
        }
    }
}


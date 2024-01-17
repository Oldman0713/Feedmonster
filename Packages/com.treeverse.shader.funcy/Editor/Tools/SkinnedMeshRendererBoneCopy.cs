using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Threading;
using System.Threading.Tasks;
using UnityEditor;
using UnityEngine;

public class SkinnedMeshRendererBoneCopy
{
    static List<string> paths = new List<string>();
    [MenuItem("GameObject/Skinned Mesh Renderer/Copy Bones Path", true)]
    public static bool DoCopy_Validate()
    {
        return Selection.activeGameObject && Selection.activeGameObject.GetComponent<SkinnedMeshRenderer>();
    }
    [MenuItem("GameObject/Skinned Mesh Renderer/Copy Bones Path", false, 0)]
    public static void DoCopy()
    {
        var smr = Selection.activeGameObject.GetComponent<SkinnedMeshRenderer>();
        var bones = smr.bones;
        paths.Clear();
        foreach (var bone in bones)
        {
            paths.Add(AnimationUtility.CalculateTransformPath(bone, smr.rootBone));
        }
    }

    [MenuItem("GameObject/Skinned Mesh Renderer/Paste Bones Path", true)]
    public static bool DoPaste_Validate()
    {
        return Selection.activeGameObject && Selection.activeGameObject.GetComponent<SkinnedMeshRenderer>() && paths.Count > 0;
    }
    [MenuItem("GameObject/Skinned Mesh Renderer/Paste Bones Path", false, 0)]
    public static void DoPaste()
    {
        var smr = Selection.activeGameObject.GetComponent<SkinnedMeshRenderer>();

        List<Transform> bones = new List<Transform>();
        foreach(var p in paths)
        {
            Transform target = null;
            if(string.IsNullOrEmpty(p))
            {
                target = smr.rootBone;
            }
            else
            {
                target = smr.rootBone.Find(p);
            }

            bones.Add(target);
        }
        smr.bones = bones.ToArray();
    }
}


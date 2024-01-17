using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Threading;
using System.Threading.Tasks;
using UnityEditor;
using UnityEngine;

public class AreaFogCreator
{
    [MenuItem("GameObject/Effects/Area Fog")]
    public static void Create()
    {
        GameObject fogTemplate = AssetDatabase.LoadAssetAtPath<GameObject>(AssetDatabase.GUIDToAssetPath("635498062bea9094d8fd5a9e9c531d93"));
        //var o = PrefabUtility.InstantiatePrefab(fogTemplate, Selection.activeGameObject ? Selection.activeGameObject.transform : null);

        // Create new undo group
        Undo.IncrementCurrentGroup();
        
        // Create GameObject hierarchy
        GameObject go = GameObject.Instantiate(fogTemplate);
        if(Selection.activeGameObject)
        {
            go.transform.parent = Selection.activeGameObject.transform;
        }
        go.name = "Area Fog";

        Undo.RegisterCreatedObjectUndo(go, "Fog Template Create");

        Selection.activeGameObject = go;
        // Name undo group
        Undo.SetCurrentGroupName("Create Fog Template");
    }

    

}

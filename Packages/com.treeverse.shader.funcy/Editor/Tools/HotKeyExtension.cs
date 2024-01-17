using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.Linq;
using System.Reflection;
public class HotKeyExtension : Editor
{
    [MenuItem("Window/Toggle Lock Selected Window #%L", true)]
    public static bool LockSelectedWindow_Validate()
    {
        return EditorWindow.focusedWindow != null;
    }
    [MenuItem("Window/Toggle Lock Select Window #%L", false, 0)]
    public static void LockSelectedWindow()
    {
        var w = EditorWindow.focusedWindow;
        var editorType = EditorWindow.focusedWindow.GetType();
        
        var lockTrackerAttr = editorType.GetField("m_LockTracker", BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic);
        
        if (lockTrackerAttr != null)
        {
            var trackerObj = lockTrackerAttr.GetValue(w);
            var trackerType = trackerObj.GetType();
            
            var lockAttr = trackerType.GetProperty("isLocked", BindingFlags.Instance | BindingFlags.NonPublic);
            if(lockAttr != null)
            {
                bool toggle = (bool)lockAttr.GetValue(trackerObj);
                lockAttr.SetValue(trackerObj, !toggle);

                EditorWindow.focusedWindow.Repaint();
            }
        }
    }
}


using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class IOPathExtension
{
    public static string toAssetsPath(this string path)
    {
        return path.Replace(Application.dataPath, "Assets").Replace(@"\", "/");
    }
}

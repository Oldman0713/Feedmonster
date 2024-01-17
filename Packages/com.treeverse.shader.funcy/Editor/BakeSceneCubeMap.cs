using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEditor;
using System;
using UnityEngine.Networking;
using System.IO;
using UnityEngine.U2D;
using System.Reflection;
using UnityEngine.Experimental.Rendering;
public class BakeSceneCubeMap
{

    [MenuItem("GameObject/CubeMap/Save", true, 10)]
    public static bool SaveCubeMap_Validator()
    {
        return Selection.activeGameObject ? Selection.activeGameObject.GetComponent<Camera>() : null;
    }

    [MenuItem("GameObject/CubeMap/Save", false, 10)]
    public static void SaveCubeMap()
    {
        var cam = Selection.activeGameObject.GetComponent<Camera>();
        RenderTexture rt = new RenderTexture(4096, 2048, 0, RenderTextureFormat.ARGBFloat,RenderTextureReadWrite.sRGB);

        RenderTexture RT = new RenderTexture(4096, 4096, 24, RenderTextureFormat.DefaultHDR, RenderTextureReadWrite.sRGB);
        
        RT.dimension = UnityEngine.Rendering.TextureDimension.Cube;        


        cam.RenderToCubemap(RT, 63, Camera.MonoOrStereoscopicEye.Mono);
        RT.ConvertToEquirect(rt, Camera.MonoOrStereoscopicEye.Mono);

        try
        {
            RenderTexture.active = rt;

            Texture2D tex = new Texture2D(rt.width, rt.height, TextureFormat.RGBAFloat, false);
            tex.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0);            
            RenderTexture.active = null;

            byte[] bytes;
            bytes = tex.EncodeToPNG();
            tex.Compress(true);
            string path = cam.gameObject.scene.path.Replace(".unity", "/" + cam.gameObject.scene.name) + "_CubeMap" + ".png";
            System.IO.File.WriteAllBytes(path, bytes);
            AssetDatabase.ImportAsset(path);
            TextureImporter importer = AssetImporter.GetAtPath(path) as TextureImporter;
            importer.textureShape = TextureImporterShape.TextureCube;

            string[] platforms = new string[] { "Standalone", "iPhone", "Android" };
            foreach (var p in platforms)
            {
                var settings = importer.GetPlatformTextureSettings(p);
                settings.overridden = true;
                switch (p)
                {
                    case "Standalone":
                        settings.format = TextureImporterFormat.DXT5Crunched;
                        break;
                    case "iPhone":
                        settings.format = TextureImporterFormat.ASTC_12x12;
                        break;
                    case "Android":
                        settings.format = TextureImporterFormat.ASTC_12x12;
                        break;
                }
                importer.SetPlatformTextureSettings(settings);
            }
            importer.SaveAndReimport();
        }

        catch(System.Exception ex)
        {
            Debug.LogError(ex);
        }

        cam.targetTexture = null;
        UnityEngine.Object.DestroyImmediate(RT);
        UnityEngine.Object.DestroyImmediate(rt);
    }
}

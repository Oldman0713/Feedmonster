using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using Unity.Mathematics;
public static class TextureExtension
{
    public static RenderTexture CreateRenderTexture(string name, Vector2 size, RenderTextureFormat format, Color defalutFillColor, bool sRGB, TextureWrapMode wrapMode = TextureWrapMode.Repeat)
    {
        RenderTextureDescriptor rtd = new RenderTextureDescriptor(Mathf.CeilToInt(size.x), Mathf.CeilToInt(size.y), format);
        rtd.sRGB = sRGB;
        var map = new RenderTexture(rtd);
        map.enableRandomWrite = true;
        map.wrapMode = wrapMode;
        map.Create();

        RenderTexture.active = map;
        GL.Clear(true, true, defalutFillColor);
        RenderTexture.active = null;

        return map;
    }

    public static Texture2D DeCompress(this Texture2D source)
    {
        RenderTexture renderTex = RenderTexture.GetTemporary(
                    source.width,
                    source.height,
                    0,
                    RenderTextureFormat.Default,
                    RenderTextureReadWrite.Linear);

        Graphics.Blit(source, renderTex);
        RenderTexture previous = RenderTexture.active;
        RenderTexture.active = renderTex;
        Texture2D readableText = new Texture2D(source.width, source.height);
        readableText.ReadPixels(new Rect(0, 0, renderTex.width, renderTex.height), 0, 0);
        readableText.Apply();
        RenderTexture.active = previous;
        RenderTexture.ReleaseTemporary(renderTex);
        return readableText;
    }
#if UNITY_EDITOR
    public static int2 GetOrignalSize(this TextureImporter importer)
    {
        object[] args = new object[2] { 0, 0 };
        System.Reflection.MethodInfo mi = typeof(TextureImporter).GetMethod("GetWidthAndHeight", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
        mi.Invoke(importer, args);

        var width = (int)args[0];
        var height = (int)args[1];

        return math.int2(width, height);

    }
#endif
    public static void CopyToTex2D(this RenderTexture src, Texture2D dst)
    {
        Graphics.SetRenderTarget(src);
        dst.ReadPixels(new Rect(0, 0, src.width, src.height), 0, 0);
        dst.Apply();
    }

    public static Vector4 ToVector(this Color c)
    {
        var v = Vector4.one;
        v.x = c.r; v.y = c.g; v.z = c.b; v.w = c.a;
        return v;
    }
}


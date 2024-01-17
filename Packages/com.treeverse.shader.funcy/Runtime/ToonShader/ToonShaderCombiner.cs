using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using ToonShaderCombineMapInstance = ToonShaderCombiner.ToonShaderCombineMapInstance;
public class ToonShaderCombiner
{
    [System.Serializable]
    public class ToonShaderCombineMapInstance
    {
        public Material material;
        public Texture2D albedoMap;
        public Texture2D metallicGlossMap;
        public Texture2D normalMap;

        public ToonShaderCombineMapInstance(Material material = null)
        {
            if (material)
            {
                this.material = material;

                this.albedoMap = (Texture2D)material.GetTexture("_AlbedoMap");
                if (!this.albedoMap) {
                    this.albedoMap = new Texture2D(16, 16);
                    Color albedoColor = material.GetColor("_AlbedoColor");
                    this.albedoMap = new Texture2D(16, 16);
                    
                    for (int x = 0; x < 16; x++)
                    {
                        for (int y = 0; y < 16; y++)
                        {
                            this.albedoMap.SetPixel(x, y, albedoColor);
                        }
                    }
                    this.albedoMap.Apply();
                }


                this.metallicGlossMap = (Texture2D)material.GetTexture("_MetallicGlossMap"); 
                if (!this.metallicGlossMap) {
                    this.metallicGlossMap = new Texture2D(16, 16);
                    
                    Color metallicGloss = new Color(material.GetFloat("_Metallic"), material.GetFloat("_Smoothness"), material.GetFloat("_OcclusionStrength"), 0);
                    for (int x = 0; x < 16; x++)
                    {
                        for (int y = 0; y < 16; y++)
                        {
                            this.metallicGlossMap.SetPixel(x, y, metallicGloss);
                        }
                    }
                    this.metallicGlossMap.Apply();
                }

                this.normalMap = (Texture2D)material.GetTexture("_NormalMap"); 
                if (!this.normalMap) {
                    this.normalMap = new Texture2D(16, 16);
                    Color normalColor = Texture2D.normalTexture.GetPixel(1, 1);
                    for (int x = 0; x <16; x++)
                    {
                        for (int y = 0; y < 16; y++)
                        {
                            this.normalMap.SetPixel(x, y, normalColor);
                        }
                    }
                    this.normalMap.Apply();
                }
                
            }
        }
    }

}
public static class Extension
{
    public static ToonShaderCombineMapInstance CombineMaps(this List<ToonShaderCombineMapInstance> tcmi, ComputeShader cs, string name = "Combined_Material")
    {
        var m = Object.Instantiate(tcmi[0].material);
        
        m.SetColor("_AlbedoColor", Color.white);
        m.SetFloat("_Metallic", 1.0f);
        m.SetFloat("_Smoothness", 1.0f);
        m.SetFloat("_OcclusionStrength", 1.0f);

        m.name = name;
        var textureSize = tcmi[0].albedoMap.width * 4;
        RenderTexture albedo_RT = TextureExtension.CreateRenderTexture(m.name + "_Albedo", Vector2.one * textureSize, RenderTextureFormat.ARGBHalf, Color.clear, false);
        RenderTexture metallic_RT = TextureExtension.CreateRenderTexture(m.name + "_Metallic", Vector2.one * textureSize, RenderTextureFormat.ARGBHalf, Color.clear, false);
        RenderTexture normal_RT = TextureExtension.CreateRenderTexture(m.name + "_Normal", Vector2.one * textureSize, RenderTextureFormat.ARGBHalf, Color.clear, false);


        RenderTexture[] rts = new RenderTexture[] { albedo_RT, metallic_RT, normal_RT };
        int rtIndex = 0;

        int kernel = cs.FindKernel("CombineMaps");
        uint x, y, z;
        cs.GetKernelThreadGroupSizes(kernel, out x, out y, out z);

        float s_0_25 = textureSize * 0.25f;
        float s_0_50 = textureSize * 0.5f;
        float s_0_75 = textureSize * 0.75f;
        Vector2[] rects = new Vector2[] {
        new Vector2(0,0), new Vector2(s_0_25,0), new Vector2(s_0_50,0),new Vector2(s_0_75,0),
        new Vector2(0,s_0_25), new Vector2(s_0_25,s_0_25), new Vector2(s_0_50,s_0_25),new Vector2(s_0_75,s_0_25),
        new Vector2(0,s_0_50), new Vector2(s_0_25,s_0_50), new Vector2(s_0_50,s_0_50),new Vector2(s_0_75,s_0_50),
        new Vector2(0,s_0_75), new Vector2(s_0_25,s_0_75), new Vector2(s_0_50,s_0_75),new Vector2(s_0_75,s_0_75),
        };

        foreach (var rt in rts)
        {
            for (int i = 1; i <= tcmi.Count; i++)
            {
                var maps = new Texture2D[] { tcmi[i - 1].albedoMap, tcmi[i - 1].metallicGlossMap, tcmi[i - 1].normalMap };
                Vector4 rect = Vector4.one;

                var map = maps[rtIndex];
                var texelSize = new Vector4(rt.width / 4, rt.height / 4, 4.0f / rt.width, 4.0f / rt.height);

                cs.SetTexture(kernel, string.Format("Map_{0}", i.ToString("00")), map);
                cs.SetVector(string.Format("Map_{0}_Rect", i.ToString("00")), rects[i - 1]);
                cs.SetVector(string.Format("Map_{0}_TexelSize", i.ToString("00")), texelSize);
            }

            for (int i = tcmi.Count + 1; i <= 16; i++)
            {
                var map = Texture2D.grayTexture;
                var texelSize = new Vector4(map.width, map.height, 1.0f / map.width, 1.0f / map.height);

                cs.SetTexture(kernel, string.Format("Map_{0}", i.ToString("00")), map);
                cs.SetVector(string.Format("Map_{0}_Rect", i.ToString("00")), rects[i - 1]);
                cs.SetVector(string.Format("Map_{0}_TexelSize", i.ToString("00")), texelSize);
            }

            cs.SetFloat("mapCount", tcmi.Count);
            cs.SetVector("_Combined_TexelSize", new Vector4(rt.width, rt.height, 1.0f / rt.width, 1.0f / rt.height));
            cs.SetTexture(kernel, "Combined", rt);
            cs.Dispatch(kernel, Mathf.CeilToInt(rt.width / x), Mathf.CeilToInt(rt.height / y), Mathf.CeilToInt(z));

            rtIndex++;
        }

        TextureFormat albedoFormat = TextureFormat.BC6H;
        TextureFormat metallicFormat = TextureFormat.DXT5;
        TextureFormat normalFormat = TextureFormat.DXT5;

        Texture2D albedo = new Texture2D(albedo_RT.width, albedo_RT.height, TextureFormat.RGBAHalf, false, true);
        Texture2D metallic = new Texture2D(metallic_RT.width, metallic_RT.height, TextureFormat.RGBAHalf, false, false);
        Texture2D normal = new Texture2D(normal_RT.width, normal_RT.height, TextureFormat.RGBAHalf, false, true);

        m.SetTexture("_AlbedoMap", albedo);
        m.SetTexture("_MetallicGlossMap", metallic);
        m.SetTexture("_NormalMap", normal);

        var result = new ToonShaderCombineMapInstance(m);

        albedo_RT.CopyToTex2D(albedo);
        metallic_RT.CopyToTex2D(metallic);
        normal_RT.CopyToTex2D(normal);

        albedo.Compress(true); albedo.Apply();
        metallic.Compress(true); metallic.Apply();
        normal.Compress(true); normal.Apply();


        RenderTexture.active = null;


        albedo.name = albedo_RT.name;
        metallic.name = metallic_RT.name;
        normal.name = normal_RT.name;


        albedo_RT.Release(); albedo_RT = null;
        metallic_RT.Release(); metallic_RT = null;
        normal_RT.Release(); normal_RT = null;

        return result;
    }
}

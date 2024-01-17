Shader "Hidden/Renderfeature/KawaseBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
    }
    
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" }
        
        LOD 100
        Pass
        {
            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
            };
            
            struct v2f
            {
                float2 uv: TEXCOORD0;
                float4 vertex: SV_POSITION;
                half2 pushUV[12]: TEXCOORD1;
            };
            
            TEXTURE2D(_MainTex);        SAMPLER(sampler_MainTex);
            
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_TexelSize;
            float4 _MainTex_ST;
            
            CBUFFER_END
            
            v2f vert(appdata v)
            {
                v2f o = (v2f)0;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv.xy = v.uv;
                
                half s1 = 3.0;
                half s2 = 5.5;
                half s3 = 7.9;
                
                half samples[3] = {
                    s1, s2, s3
                };
                
                float2 res = normalize(_ScreenParams.yx) * .0005;
                for (int n = 0; n < 3; n ++)
                {
                    int cn = 4 * n;
                    half i = samples[n];
                    o.pushUV[cn + 0] = v.uv.xy + float2(i, i) * res;
                    o.pushUV[cn + 1] = v.uv.xy + float2(i, -i) * res;
                    o.pushUV[cn + 2] = v.uv.xy + float2(-i, i) * res;
                    o.pushUV[cn + 3] = v.uv.xy + float2(-i, -i) * res;
                }
                return o;
            }
            
            half4 frag(v2f input): SV_Target
            {
                
                half4 col = 0;
                col.rgb = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv.xy).rgb;
                
                /*
                col.rgb += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv.xy + float2(i, i) * res).rgb;
                col.rgb += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv.xy + float2(i, -i) * res).rgb;
                col.rgb += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv.xy + float2(-i, i) * res).rgb;
                col.rgb += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv.xy + float2(-i, -i) * res).rgb;
                
                i = 5.5;
                col.rgb += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv.xy + float2(i, i) * res).rgb;
                col.rgb += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv.xy + float2(i, -i) * res).rgb;
                col.rgb += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv.xy + float2(-i, i) * res).rgb;
                col.rgb += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv.xy + float2(-i, -i) * res).rgb;
                
                i = 7.9;
                col.rgb += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv.xy + float2(i, i) * res).rgb;
                col.rgb += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv.xy + float2(i, -i) * res).rgb;
                col.rgb += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv.xy + float2(-i, i) * res).rgb;
                col.rgb += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv.xy + float2(-i, -i) * res).rgb;
                */
                for (int n = 0; n < 12; n ++)
                {
                    col += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.pushUV[n]);
                }
                
                col.rgb *= 0.077f;
                
                return col;
            }
            ENDHLSL
            
        }
    }
}

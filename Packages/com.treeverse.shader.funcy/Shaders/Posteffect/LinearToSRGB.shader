// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Hidden/Treeverse/LinearToSRGB"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector]_MainTex("MainTex", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	
	}
	
	SubShader
	{
		LOD 0

		Tags { "RenderPipeline"="UniversalPipeline" "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }

		
		Pass
		{
			Name "Forward"
			Tags { "LightMode"="SRPDefaultUnlit" }
		
			Blend Off
			Cull Off
			ZWrite Off
			ZTest Always
			Offset 0,0
			ColorMask RGBA
			Fog
			{
				Mode off
			}

			HLSLPROGRAM
			
			#define ASE_SRP_VERSION 999999
			#define ASE_USING_SAMPLING_MACROS 1

			
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma target 3.0
			
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			
			
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			struct appdata_t
			{
				float4 vertex: POSITION;
				float2 texcoord: TEXCOORD0;
				
			};
			
			struct v2f
			{
				float4 vertex: SV_POSITION;
				float2 texcoord: TEXCOORD0;
				
			};
			
			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);
			CBUFFER_START( UnityPerMaterial )
			half4 _MainTex_ST;
			CBUFFER_END

			
			
			v2f vert(appdata_t input )
			{
				v2f output = (v2f)0;

				float4 vPosition = TransformObjectToHClip(input.vertex.xyz);
				
				

				output.vertex = vPosition;
				output.texcoord = input.texcoord;

				return output;
			}
			
			half4 frag(v2f IN ): SV_Target
			{
				float2 uv_MainTex = IN.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				half4 tex2DNode6 = SAMPLE_TEXTURE2D( _MainTex, sampler_MainTex, uv_MainTex );
				half3 appendResult583 = (half3(tex2DNode6.rgb));
				half3 linearToGamma582 = LinearToSRGB( appendResult583 );
				half4 appendResult584 = (half4(linearToGamma582 , tex2DNode6.a));
				
				
				half4 color = appendResult584;
				
				return color;
			}

			ENDHLSL
			
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18935
324;80;2047;1088;-683.8887;1148.003;1;True;False
Node;AmplifyShaderEditor.SamplerNode;6;1461,-516;Inherit;True;Property;_MainTex;MainTex;0;1;[HideInInspector];Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;583;1792,-512;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LinearToGammaNode;582;1920,-512;Inherit;False;1;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;584;2176,-512;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;581;2432,-512;Half;False;True;-1;2;ASEMaterialInspector;0;19;Hidden/Treeverse/LinearToSRGB;940fe07787f047847b8fd8aad343b39c;True;Forward;0;0;Forward;1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;False;False;0;True;True;0;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;False;True;True;2;False;-1;True;7;False;-1;True;False;0;False;-1;0;False;-1;True;1;LightMode=SRPDefaultUnlit;True;2;False;0;;0;0;Standard;0;0;1;True;False;;True;0
WireConnection;583;0;6;0
WireConnection;582;0;583;0
WireConnection;584;0;582;0
WireConnection;584;3;6;4
WireConnection;581;1;584;0
ASEEND*/
//CHKSM=1B70BA4DC272711641A4823AE56A6BD2F3EEA938
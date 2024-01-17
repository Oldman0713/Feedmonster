// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Hidden/Treeverse/DepthCookiePost"
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
		
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off
			ZWrite Off
			ZTest Always
			Offset 0 , 0
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
			TEXTURE2D(_DepthCookieTarget);
			SAMPLER(sampler_DepthCookieTarget);
			TEXTURE2D(_DepthCookieObject);
			SAMPLER(sampler_DepthCookieObject);
			CBUFFER_START( UnityPerMaterial )
			half4 _DepthCookieTarget_ST;
			half4 _DepthCookieObject_ST;
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
				half2 uv2 = IN.texcoord.xy;
				half4 tex2DNode5 = SAMPLE_TEXTURE2D( _MainTex, sampler_MainTex, uv2 );
				half3 appendResult6 = (half3(tex2DNode5.rgb));
				half3 baseColor7 = appendResult6;
				float2 uv_DepthCookieTarget = IN.texcoord.xy * _DepthCookieTarget_ST.xy + _DepthCookieTarget_ST.zw;
				half4 tex2DNode10 = SAMPLE_TEXTURE2D( _DepthCookieTarget, sampler_DepthCookieTarget, uv_DepthCookieTarget );
				half3 appendResult11 = (half3(tex2DNode10.rgb));
				float2 uv_DepthCookieObject = IN.texcoord.xy * _DepthCookieObject_ST.xy + _DepthCookieObject_ST.zw;
				half4 tex2DNode13 = SAMPLE_TEXTURE2D( _DepthCookieObject, sampler_DepthCookieObject, uv_DepthCookieObject );
				half temp_output_21_0 = max( ( tex2DNode10.a - tex2DNode13.a ) , 0.0 );
				half3 lerpResult12 = lerp( baseColor7 , appendResult11 , temp_output_21_0);
				half4 appendResult4 = (half4(lerpResult12 , max( temp_output_21_0 , tex2DNode5.a )));
				
				
				half4 color = appendResult4;
				
				return color;
			}

			ENDHLSL
			
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18935
-1741;101;1582;878;2006.714;58.5883;1;True;False
Node;AmplifyShaderEditor.TexCoordVertexDataNode;1;-1955.725,-174.2087;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;2;-1699.725,-174.2087;Inherit;False;uv;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;8;-1408.689,1357.909;Inherit;False;2;uv;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;5;-1152.689,1357.909;Inherit;True;Property;_MainTex;MainTex;0;1;[HideInInspector];Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;6;-768.6895,1357.909;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;10;-1408,256;Inherit;True;Global;_DepthCookieTarget;_DepthCookieTarget;2;0;Create;True;0;0;0;False;0;False;-1;None;;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;13;-1408,512;Inherit;True;Global;_DepthCookieObject;_DepthCookieObject;1;0;Create;True;0;0;0;False;0;False;-1;None;;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;7;-640.6895,1357.909;Inherit;False;baseColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;15;-898.1301,447.2576;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;21;-758.7145,324.4117;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;9;-1024,0;Inherit;False;7;baseColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;11;-1024,128;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;12;-654.6769,75.39691;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;20;-584.3899,335.4875;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;4;-387.0905,135.2991;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;18;-1007.13,372.2576;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;0,0;Half;False;True;-1;2;ASEMaterialInspector;0;19;Hidden/Treeverse/DepthCookiePost;940fe07787f047847b8fd8aad343b39c;True;Forward;0;0;Forward;1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;False;False;0;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;2;False;-1;True;7;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=SRPDefaultUnlit;True;2;False;0;;0;0;Standard;0;0;1;True;False;;True;0
WireConnection;2;0;1;0
WireConnection;5;1;8;0
WireConnection;6;0;5;0
WireConnection;7;0;6;0
WireConnection;15;0;10;4
WireConnection;15;1;13;4
WireConnection;21;0;15;0
WireConnection;11;0;10;0
WireConnection;12;0;9;0
WireConnection;12;1;11;0
WireConnection;12;2;21;0
WireConnection;20;0;21;0
WireConnection;20;1;5;4
WireConnection;4;0;12;0
WireConnection;4;3;20;0
WireConnection;18;0;13;0
WireConnection;0;1;4;0
ASEEND*/
//CHKSM=FC75541AB9EC653CC0DB52C542DE2C906F3A4BC4
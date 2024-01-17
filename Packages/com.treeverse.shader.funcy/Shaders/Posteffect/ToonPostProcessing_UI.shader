// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Hidden/Treeverse/ToonPostProcessingUI"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector]_MainTex("MainTex", 2D) = "white" {}

	
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
			half _ToonAdjustContrast;
			TEXTURE2D(_ToonPPSBuffer);
			SAMPLER(sampler_ToonPPSBuffer);

			
			half3 HSVToRGB( half3 c )
			{
				half4 K = half4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
				half3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
				return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
			}
			

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
				half2 uv415 = IN.texcoord.xy;
				half4 tex2DNode6 = SAMPLE_TEXTURE2D( _MainTex, sampler_MainTex, uv415 );
				half3 appendResult298 = (half3(tex2DNode6.rgb));
				half3 baseColor169 = appendResult298;
				half temp_output_3_0_g4 = _ToonAdjustContrast;
				half3 lerpResult5_g4 = lerp( (0.214).xxx , baseColor169 , ( temp_output_3_0_g4 * temp_output_3_0_g4 ));
				half3 temp_output_412_0 = lerpResult5_g4;
				half3 worldToViewDir335 = mul( UNITY_MATRIX_V, float4( _MainLightPosition.xyz, 0 ) ).xyz;
				half2 normalizeResult367 = normalize( (worldToViewDir335).xy );
				half2 appendResult365 = (half2(( _ScreenParams.y / _ScreenParams.x ) , 1.0));
				half4 tex2DNode304 = SAMPLE_TEXTURE2D( _ToonPPSBuffer, sampler_ToonPPSBuffer, uv415 );
				half RimLightSize360 = tex2DNode304.r;
				half SufraceDepth362 = tex2DNode304.g;
				half temp_output_355_0 = ( SAMPLE_TEXTURE2D( _ToonPPSBuffer, sampler_ToonPPSBuffer, ( IN.texcoord.xy + ( normalizeResult367 * appendResult365 * RimLightSize360 ) ) ).g - SufraceDepth362 );
				half3 hsvTorgb401 = HSVToRGB( half3(tex2DNode304.b,tex2DNode304.a,1.0) );
				half3 lerpResult372 = lerp( baseColor169 , ( temp_output_412_0 + ( temp_output_412_0 * abs( temp_output_355_0 ) * hsvTorgb401 ) ) , ( 1.0 - step( SufraceDepth362 , 0.0 ) ));
				half3 toonPostColor564 = lerpResult372;
				half4 appendResult580 = (half4(toonPostColor564 , tex2DNode6.a));
				
				
				half4 color = appendResult580;
				
				return color;
			}

			ENDHLSL
			
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18935
-1920;0;1920;1059;112.0858;1384.67;1.3;True;False
Node;AmplifyShaderEditor.TexCoordVertexDataNode;13;-1536,-896;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;57;-1046.136,-903.0126;Inherit;False;1832.345;1061.479;SobelOutline;12;357;355;304;303;363;373;387;401;376;413;416;318;SobelOutline;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;415;-1280,-896;Inherit;False;uv;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;334;-2304,-384;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TexturePropertyNode;303;-959,-549;Inherit;True;Global;_ToonPPSBuffer;_ToonPPSBuffer;0;0;Create;True;0;0;0;False;0;False;None;None;False;black;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;416;-896,-864;Inherit;False;415;uv;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;304;-703,-837;Inherit;True;Property;_TextureSample1;Texture Sample 1;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenParams;328;-2304,-128;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformDirectionNode;335;-2048,-384;Inherit;False;World;View;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;360;-256,-1152;Inherit;False;RimLightSize;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;339;-1792,-384;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;366;-2048,-80;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;361;-2048,128;Inherit;False;360;RimLightSize;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;365;-1792,-96;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NormalizeNode;367;-1600,-336;Inherit;False;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;417;1280,-256;Inherit;False;415;uv;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;6;1536,-256;Inherit;True;Property;_MainTex;MainTex;1;1;[HideInInspector];Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;317;-2304,-512;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;333;-1536,-128;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;318;-1040,-544;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;298;1920,-256;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;362;-256,-910;Inherit;False;SufraceDepth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;363;-512,-256;Inherit;False;362;SufraceDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;387;-575,-453;Inherit;True;Property;_TextureSample3;Texture Sample 3;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;169;2048,-256;Inherit;False;baseColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;299;322,-1444;Inherit;False;169;baseColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;406;-288.2674,-1291.249;Inherit;False;Global;_ToonAdjustContrast;_ToonAdjustContrast;2;0;Create;True;0;0;0;False;0;False;1;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;355;-75.40002,-447.8;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;357;193,-453;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;401;-256,-768;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;412;368.6966,-1076.136;Inherit;False;AdjustContrast;-1;;4;ab5193b6daea32241b2f15212fb99963;0;2;1;FLOAT3;0,0,0;False;3;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;373;482,-607;Inherit;False;362;SufraceDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;374;896,-768;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;376;561.2145,-892.4974;Inherit;False;3;3;0;FLOAT3;1,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;375;847.3095,-1132.593;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;407;1024,-896;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;372;1152,-1152;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;564;1408,-1280;Inherit;False;toonPostColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;580;1920,-1280;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SaturateNode;413;174.972,-588.2177;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;582;-1280,-768;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;581;2304,-1280;Half;False;True;-1;2;ASEMaterialInspector;0;19;Hidden/Treeverse/ToonPostProcessingUI;940fe07787f047847b8fd8aad343b39c;True;Forward;0;0;Forward;1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;False;False;0;True;True;0;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;False;True;True;2;False;-1;True;7;False;-1;True;False;0;False;-1;0;False;-1;True;1;LightMode=SRPDefaultUnlit;True;2;False;0;;0;0;Standard;0;0;1;True;False;;True;0
WireConnection;415;0;13;0
WireConnection;304;0;303;0
WireConnection;304;1;416;0
WireConnection;304;7;303;1
WireConnection;335;0;334;0
WireConnection;360;0;304;1
WireConnection;339;0;335;0
WireConnection;366;0;328;2
WireConnection;366;1;328;1
WireConnection;365;0;366;0
WireConnection;367;0;339;0
WireConnection;6;1;417;0
WireConnection;333;0;367;0
WireConnection;333;1;365;0
WireConnection;333;2;361;0
WireConnection;318;0;317;0
WireConnection;318;1;333;0
WireConnection;298;0;6;0
WireConnection;362;0;304;2
WireConnection;387;0;303;0
WireConnection;387;1;318;0
WireConnection;169;0;298;0
WireConnection;355;0;387;2
WireConnection;355;1;363;0
WireConnection;357;0;355;0
WireConnection;401;0;304;3
WireConnection;401;1;304;4
WireConnection;412;1;299;0
WireConnection;412;3;406;0
WireConnection;374;0;373;0
WireConnection;376;0;412;0
WireConnection;376;1;357;0
WireConnection;376;2;401;0
WireConnection;375;0;412;0
WireConnection;375;1;376;0
WireConnection;407;0;374;0
WireConnection;372;0;299;0
WireConnection;372;1;375;0
WireConnection;372;2;407;0
WireConnection;564;0;372;0
WireConnection;580;0;564;0
WireConnection;580;3;6;4
WireConnection;413;0;355;0
WireConnection;581;1;580;0
ASEEND*/
//CHKSM=1F1C7FCC445C33DBB260570BB8190873E23A40B2
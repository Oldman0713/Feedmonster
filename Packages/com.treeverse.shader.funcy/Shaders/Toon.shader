// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Treeverse/Dynamic/Toon"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[ASEBegin][HDR][Header(______Base Preperties______)][Space(10)]_AlbedoColor("Albedo Color", Color) = (1,1,1,1)
		[SingleLineTexture]_AlbedoMap("Albedo Map", 2D) = "white" {}
		[SingleLineTexture][Space(15)]_MetallicGlossMap("Metallic Map", 2D) = "white" {}
		[Normal][SingleLineTexture]_NormalMap("NormalMap", 2D) = "bump" {}
		_NormalMapIntensity("Normal Map Intensity", Float) = 1
		[HDR][Gamma]_EmissionColor("Emission Color", Color) = (0,0,0,1)
		[Toggle]_FlowEmission("FlowEmission", Range( 0 , 1)) = 0
		[Toggle]_EmissionxAlbedo("Emission x Albedo", Range( 0 , 1)) = 1
		[Header(______Toon Properties______)][Space(10)]_LightThreshold("LightThreshold", Range( 0 , 1)) = 0
		[Toggle][ToggleUI]_WrappedLighting("Half Lambert", Float) = 1
		_DiffuseSmoothness("Diffuse Smoothness", Range( 0 , 1)) = 0
		[Header(Specular Settings)][Space(10)]_SpecularBrightness("Specular Brightness", Float) = 1
		_Metallic("Metallic", Range( 0 , 1)) = 1
		_Smoothness("Smoothness", Range( 0 , 1)) = 1
		_OcclusionStrength("AO", Range( 0 , 1)) = 0
		[Header(______Shadow______)][Space(10)]_GoochBrightColor("Shadow Light Color", Color) = (1,1,1,1)
		_GoochDarkColor("Shadow Dark Color", Color) = (0,0,0,1)
		[Header(______Rim Light______)][Space(10)]_RimBrightColor("Rim Color", Color) = (1,1,1,0.5019608)
		_RimLightOffset("RimLightOffset", Range( 0 , 0.1)) = 0.07
		_RimLightIntensity("RimLightIntensity", Range( 0.001 , 10)) = 1
		[Header(______Outline______)][Space(10)]_OutlineColor("Outline Color", Color) = (0,0,0,0)
		_OutlineNearWidth("Near Width", Float) = 25
		_OutlineFarWidth("Far Width", Float) = 50
		_OutlineWidthFadeScale("Width Fade Scale", Float) = 1
		_OutlineAlbedoBlend("Outline Albedo Blend", Range( 0 , 1)) = 0.1
		[Header(______Blend Mode______)][Enum(UnityEngine.Rendering.BlendMode)][Space(15)]_SRC("Src", Float) = 1
		[Enum(UnityEngine.Rendering.BlendMode)]_DST("Dst", Float) = 0
		[Toggle]_CustomizeLightAngle("Customize Light Angle", Float) = 0
		_CustomLightRotate("Custom Light Rotate", Vector) = (45,-45,0,0)
		[HDR]_FlashColor("FlashColor", Color) = (1,1,1,0)
		_Flash("Flash", Float) = 0
		[Header(______Houdini VAT______)][Toggle][Space(10)]_UseHoudiniVAT("Use Houdini VAT", Float) = 0
		[SingleLineTexture][Space(10)]_posTexture("Position Texture", 2D) = "black" {}
		[SingleLineTexture]_rotTexture("Rotation Texture", 2D) = "black" {}
		_houdiniFPS("Houdini FPS", Float) = 30
		_frameCount("Frame Count", Float) = 1
		_playbackSpeed("Playback Speed", Float) = 1
		_LifeTime("LifeTime", Float) = 0
		[ASEEnd][Toggle]_SupportAlbedoMapAlpha("Support Map Alpha", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

		
	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Geometry" }
		
		Cull Back
		AlphaToMask Off
		Stencil
		{
			Ref 128
			Comp Always
			Pass Replace
			Fail Keep
			ZFail Keep
		}
		HLSLINCLUDE
		#pragma target 4.0

		#pragma prefer_hlslcc gles
		#pragma exclude_renderers d3d11_9x 

		ENDHLSL
		
		Pass
		{
			Name "ToonPostProcessing"
			
			Tags { "LightMode"="ToonPostProcessing" }
			
			Blend Off
			Cull Back
			ZWrite On
			ZTest LEqual
			Offset 0,0
			ColorMask RGBA
			

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define TREEVERSE_LINEAR_FOG
			#define ASE_SRP_VERSION 999999
			#define ASE_USING_SAMPLING_MACROS 1

			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#if ASE_SRP_VERSION <= 70108
			#define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
			#endif

			#define ASE_NEEDS_VERT_POSITION
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef ASE_FOG
				float fogFactor : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)

			float4 _EmissionColor;
			float4 _FlashColor;
			float4 _GoochDarkColor;
			float4 _OutlineColor;
			float4 _GoochBrightColor;
			float4 _RimBrightColor;
			float4 _NormalMap_ST;
			float4 _MetallicGlossMap_ST;
			float4 _AlbedoColor;
			float4 _AlbedoMap_ST;
			float3 _CustomLightRotate;
			float _WrappedLighting;
			float _OcclusionStrength;
			float _DiffuseSmoothness;
			float _LightThreshold;
			float _CustomizeLightAngle;
			float _Smoothness;
			float _SpecularBrightness;
			float _Metallic;
			float _NormalMapIntensity;
			float _FlowEmission;
			float _DST;
			float _OutlineAlbedoBlend;
			float _OutlineWidthFadeScale;
			float _OutlineFarWidth;
			float _OutlineNearWidth;
			float _SupportAlbedoMapAlpha;
			float _RimLightIntensity;
			float _RimLightOffset;
			float _UseHoudiniVAT;
			float _playbackSpeed;
			float _frameCount;
			float _houdiniFPS;
			float _LifeTime;
			float _SRC;
			float _EmissionxAlbedo;
			float _Flash;
			CBUFFER_END
			TEXTURE2D(_posTexture);
			SAMPLER(sampler_posTexture);
			TEXTURE2D(_rotTexture);
			SAMPLER(sampler_rotTexture);
			TEXTURE2D(_AlbedoMap);
			SAMPLER(sampler_AlbedoMap);


			float4 Decode_Quaternion120_g55( float3 XYZ, float MaxComponent )
			{
				float w = sqrt(1.0 - pow(XYZ.x, 2) - pow(XYZ.y, 2) - pow(XYZ.z, 2));
				float4 q = float4(0, 0, 0, 1);
				switch(MaxComponent)
				{
				    case 0:
				        q = float4(XYZ.x, XYZ.y, XYZ.z, w);
				        break;
				    case 1:
				        q = float4(w, XYZ.y, XYZ.z, XYZ.x);
				        break;
				    case 2:
				        q = float4(XYZ.x, -w, XYZ.z, -XYZ.y);
				        break;
				    case 3:
				        q = float4(XYZ.x, XYZ.y, -w, -XYZ.z);
				        break;
				    default:
				        q = float4(XYZ.x, XYZ.y, XYZ.z, w);
				        break;
				}
				return q;
			}
			
			float3 RGBToHSV(float3 c)
			{
				float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
				float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
				float d = q.x - min( q.w, q.y );
				float e = 1.0e-10;
				return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float temp_output_82_0_g55 = ( 1.0 - v.ase_texcoord1.y );
				float temp_output_63_0_g55 = _frameCount;
				float temp_output_75_0_g55 = floor( ( frac( ( _LifeTime * ( _houdiniFPS / ( temp_output_63_0_g55 - 0.01 ) ) * _playbackSpeed ) ) * temp_output_63_0_g55 ) );
				float temp_output_78_0_g55 = ( 1.0 / temp_output_63_0_g55 );
				float2 appendResult96_g55 = (float2(v.ase_texcoord1.x , ( 1.0 - ( temp_output_82_0_g55 + ( fmod( ( temp_output_75_0_g55 + 1.0 ) , temp_output_63_0_g55 ) * temp_output_78_0_g55 ) ) )));
				float2 next_frame_UV97_g55 = appendResult96_g55;
				float3 appendResult116_g55 = (float3(SAMPLE_TEXTURE2D_LOD( _posTexture, sampler_posTexture, next_frame_UV97_g55, 0.0 ).rgb));
				float2 appendResult86_g55 = (float2(v.ase_texcoord1.x , ( 1.0 - ( temp_output_82_0_g55 + ( fmod( temp_output_75_0_g55 , temp_output_63_0_g55 ) * temp_output_78_0_g55 ) ) )));
				float2 this_frame_UV87_g55 = appendResult86_g55;
				float3 appendResult107_g55 = (float3(SAMPLE_TEXTURE2D_LOD( _rotTexture, sampler_rotTexture, this_frame_UV87_g55, 0.0 ).rgb));
				float3 XYZ120_g55 = appendResult107_g55;
				float MaxComponent120_g55 = floor( ( SAMPLE_TEXTURE2D_LOD( _posTexture, sampler_posTexture, this_frame_UV87_g55, 0.0 ).a * 4.0 ) );
				float4 localDecode_Quaternion120_g55 = Decode_Quaternion120_g55( XYZ120_g55 , MaxComponent120_g55 );
				float3 appendResult122_g55 = (float3(localDecode_Quaternion120_g55.xyz));
				float3 quatXYZ123_g55 = appendResult122_g55;
				float3 appendResult111_g55 = (float3(-v.ase_texcoord2.x , v.ase_texcoord3.x , ( 1.0 - v.ase_texcoord3.y )));
				float3 pivot114_g55 = ( v.vertex.xyz - appendResult111_g55 );
				float quatW124_g55 = (localDecode_Quaternion120_g55).w;
				float3 VAT_vertex_offset666 = ( ( appendResult116_g55 + ( cross( quatXYZ123_g55 , ( cross( quatXYZ123_g55 , pivot114_g55 ) + ( pivot114_g55 * quatW124_g55 ) ) ) * float3( 2,2,2 ) ) + pivot114_g55 ) - v.vertex.xyz );
				float Houdini_VAT_Active678 = _UseHoudiniVAT;
				
				float3 worldToObj328 = mul( GetWorldToObjectMatrix(), float4( _WorldSpaceCameraPos, 1 ) ).xyz;
				float vertexDist464 = distance( worldToObj328 , float3( 0,0,0 ) );
				float vertexToFrag322 = ( _RimLightOffset / vertexDist464 );
				o.ase_texcoord3.x = vertexToFrag322;
				float3 objectToViewPos = TransformWorldToView(TransformObjectToWorld(v.vertex.xyz));
				float eyeDepth = -objectToViewPos.z;
				float2 uv_AlbedoMap = v.ase_texcoord.xy * _AlbedoMap_ST.xy + _AlbedoMap_ST.zw;
				float4 tex2DNode137 = SAMPLE_TEXTURE2D_LOD( _AlbedoMap, sampler_AlbedoMap, uv_AlbedoMap, 0.0 );
				float lerpResult744 = lerp( 1.0 , tex2DNode137.a , _SupportAlbedoMapAlpha);
				float alpha419 = ( _AlbedoColor.a * lerpResult744 );
				float vertexToFrag331 = ( ( ( eyeDepth + 1.001 ) / vertexDist464 ) * _RimLightIntensity * alpha419 );
				o.ase_texcoord3.y = vertexToFrag331;
				float3 hsvTorgb386 = RGBToHSV( _RimBrightColor.rgb );
				float3 vertexToFrag387 = hsvTorgb386;
				o.ase_texcoord4.xyz = vertexToFrag387;
				
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;
				o.ase_texcoord4.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( VAT_vertex_offset666 * Houdini_VAT_Active678 );
				#ifndef VERTEX_OPERATION_HIDE_PASS_ONLY
					#ifdef ASE_ABSOLUTE_VERTEX_POS
						v.vertex.xyz = vertexValue;
					#else
						v.vertex.xyz += vertexValue;
					#endif
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				#ifdef ASE_FOG
				o.fogFactor = ComputeFogFactor( positionCS.z );
				#endif
				o.clipPos = positionCS;
				return o;
			}

			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}

			half4 frag ( VertexOutput IN
			#ifdef _MRT_GBUFFER0
			,out half4 gbuffer:SV_Target1
			#endif
			 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif
				float vertexToFrag322 = IN.ase_texcoord3.x;
				float vertexToFrag331 = IN.ase_texcoord3.y;
				float3 vertexToFrag387 = IN.ase_texcoord4.xyz;
				float3 break388 = vertexToFrag387;
				float3 appendResult334 = (float3(vertexToFrag322 , vertexToFrag331 , break388.x));
				
				float3 Color = appendResult334;
				float Alpha = break388.y;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif
				#ifdef _MRT_GBUFFER0
				gbuffer = float4(0.0, 0.0, 0.0, 0.0);
				#endif
				return half4( Color, Alpha );
			}

			ENDHLSL
		}

		
		Pass
		{
			Name "Outline"
			
			
			
			Blend [_SRC] [_DST]
			Cull Front
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define TREEVERSE_LINEAR_FOG
			#define ASE_SRP_VERSION 999999
			#define ASE_USING_SAMPLING_MACROS 1

			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#if ASE_SRP_VERSION <= 70108
			#define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
			#endif

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_VERT_POSITION
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				
				float fogFactor : TEXCOORD2;
				
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)

			float4 _EmissionColor;
			float4 _FlashColor;
			float4 _GoochDarkColor;
			float4 _OutlineColor;
			float4 _GoochBrightColor;
			float4 _RimBrightColor;
			float4 _NormalMap_ST;
			float4 _MetallicGlossMap_ST;
			float4 _AlbedoColor;
			float4 _AlbedoMap_ST;
			float3 _CustomLightRotate;
			float _WrappedLighting;
			float _OcclusionStrength;
			float _DiffuseSmoothness;
			float _LightThreshold;
			float _CustomizeLightAngle;
			float _Smoothness;
			float _SpecularBrightness;
			float _Metallic;
			float _NormalMapIntensity;
			float _FlowEmission;
			float _DST;
			float _OutlineAlbedoBlend;
			float _OutlineWidthFadeScale;
			float _OutlineFarWidth;
			float _OutlineNearWidth;
			float _SupportAlbedoMapAlpha;
			float _RimLightIntensity;
			float _RimLightOffset;
			float _UseHoudiniVAT;
			float _playbackSpeed;
			float _frameCount;
			float _houdiniFPS;
			float _LifeTime;
			float _SRC;
			float _EmissionxAlbedo;
			float _Flash;
			CBUFFER_END
			TEXTURE2D(_rotTexture);
			SAMPLER(sampler_rotTexture);
			TEXTURE2D(_posTexture);
			SAMPLER(sampler_posTexture);
			TEXTURE2D(_AlbedoMap);
			SAMPLER(sampler_AlbedoMap);


			float4 Decode_Quaternion120_g55( float3 XYZ, float MaxComponent )
			{
				float w = sqrt(1.0 - pow(XYZ.x, 2) - pow(XYZ.y, 2) - pow(XYZ.z, 2));
				float4 q = float4(0, 0, 0, 1);
				switch(MaxComponent)
				{
				    case 0:
				        q = float4(XYZ.x, XYZ.y, XYZ.z, w);
				        break;
				    case 1:
				        q = float4(w, XYZ.y, XYZ.z, XYZ.x);
				        break;
				    case 2:
				        q = float4(XYZ.x, -w, XYZ.z, -XYZ.y);
				        break;
				    case 3:
				        q = float4(XYZ.x, XYZ.y, -w, -XYZ.z);
				        break;
				    default:
				        q = float4(XYZ.x, XYZ.y, XYZ.z, w);
				        break;
				}
				return q;
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 appendResult612 = (float3(v.ase_texcoord3.xyz));
				float3 lerpResult611 = lerp( appendResult612 , v.ase_normal , v.ase_texcoord3.w);
				float temp_output_82_0_g55 = ( 1.0 - v.ase_texcoord1.y );
				float temp_output_63_0_g55 = _frameCount;
				float temp_output_75_0_g55 = floor( ( frac( ( _LifeTime * ( _houdiniFPS / ( temp_output_63_0_g55 - 0.01 ) ) * _playbackSpeed ) ) * temp_output_63_0_g55 ) );
				float temp_output_78_0_g55 = ( 1.0 / temp_output_63_0_g55 );
				float2 appendResult86_g55 = (float2(v.ase_texcoord1.x , ( 1.0 - ( temp_output_82_0_g55 + ( fmod( temp_output_75_0_g55 , temp_output_63_0_g55 ) * temp_output_78_0_g55 ) ) )));
				float2 this_frame_UV87_g55 = appendResult86_g55;
				float3 appendResult107_g55 = (float3(SAMPLE_TEXTURE2D_LOD( _rotTexture, sampler_rotTexture, this_frame_UV87_g55, 0.0 ).rgb));
				float3 XYZ120_g55 = appendResult107_g55;
				float MaxComponent120_g55 = floor( ( SAMPLE_TEXTURE2D_LOD( _posTexture, sampler_posTexture, this_frame_UV87_g55, 0.0 ).a * 4.0 ) );
				float4 localDecode_Quaternion120_g55 = Decode_Quaternion120_g55( XYZ120_g55 , MaxComponent120_g55 );
				float3 appendResult122_g55 = (float3(localDecode_Quaternion120_g55.xyz));
				float3 quatXYZ123_g55 = appendResult122_g55;
				float quatW124_g55 = (localDecode_Quaternion120_g55).w;
				float3 normalizeResult145_g55 = normalize( ( ( cross( quatXYZ123_g55 , ( ( quatW124_g55 * v.ase_normal ) + cross( quatXYZ123_g55 , v.ase_normal ) ) ) * float3( 2,2,2 ) ) + v.ase_normal ) );
				float3 VAT_normal669 = normalizeResult145_g55;
				float Houdini_VAT_Active678 = _UseHoudiniVAT;
				float3 lerpResult680 = lerp( lerpResult611 , VAT_normal669 , Houdini_VAT_Active678);
				float3 outlineNormal609 = lerpResult680;
				float3 worldToObj328 = mul( GetWorldToObjectMatrix(), float4( _WorldSpaceCameraPos, 1 ) ).xyz;
				float vertexDist464 = distance( worldToObj328 , float3( 0,0,0 ) );
				float lerpResult477 = lerp( _OutlineNearWidth , _OutlineFarWidth , ( _OutlineWidthFadeScale * vertexDist464 * 0.05 ));
				float2 appendResult96_g55 = (float2(v.ase_texcoord1.x , ( 1.0 - ( temp_output_82_0_g55 + ( fmod( ( temp_output_75_0_g55 + 1.0 ) , temp_output_63_0_g55 ) * temp_output_78_0_g55 ) ) )));
				float2 next_frame_UV97_g55 = appendResult96_g55;
				float3 appendResult116_g55 = (float3(SAMPLE_TEXTURE2D_LOD( _posTexture, sampler_posTexture, next_frame_UV97_g55, 0.0 ).rgb));
				float3 appendResult111_g55 = (float3(-v.ase_texcoord2.x , v.ase_texcoord3.x , ( 1.0 - v.ase_texcoord3.y )));
				float3 pivot114_g55 = ( v.vertex.xyz - appendResult111_g55 );
				float3 VAT_vertex_offset666 = ( ( appendResult116_g55 + ( cross( quatXYZ123_g55 , ( cross( quatXYZ123_g55 , pivot114_g55 ) + ( pivot114_g55 * quatW124_g55 ) ) ) * float3( 2,2,2 ) ) + pivot114_g55 ) - v.vertex.xyz );
				float3 temp_output_676_0 = ( ( outlineNormal609 * 0.001 * min( lerpResult477 , _OutlineFarWidth ) * v.ase_color.a ) + ( VAT_vertex_offset666 * Houdini_VAT_Active678 ) );
				
				float3 appendResult487 = (float3(_OutlineColor.rgb));
				float3 appendResult135 = (float3(_AlbedoColor.rgb));
				float2 uv_AlbedoMap = v.ase_texcoord.xy * _AlbedoMap_ST.xy + _AlbedoMap_ST.zw;
				float4 tex2DNode137 = SAMPLE_TEXTURE2D_LOD( _AlbedoMap, sampler_AlbedoMap, uv_AlbedoMap, 0.0 );
				float3 appendResult8 = (float3(tex2DNode137.rgb));
				float3 albedoColor170 = ( appendResult135 * appendResult8 );
				float3 lerpResult486 = lerp( appendResult487 , albedoColor170 , _OutlineAlbedoBlend);
				float3 vertexToFrag488 = lerpResult486;
				o.ase_texcoord3.xyz = vertexToFrag488;
				
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = temp_output_676_0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				
				#ifdef TREEVERSE_LINEAR_FOG
					float fz = UNITY_Z_0_FAR_FROM_CLIPSPACE(positionCS.z);
					real fogFactor =  saturate( fz * unity_FogParams.z + unity_FogParams.w);
					fogFactor = lerp(1.0, fogFactor, unity_FogColor.a * step(0.001, -1.0 / unity_FogParams.z));
				#else
					half fogFactor = 0.0;
				#endif
				
				o.fogFactor = fogFactor;
				
				o.clipPos = positionCS;
				return o;
			}

			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}

			half4 frag ( VertexOutput IN
			#ifdef _MRT_GBUFFER0
			,out half4 gbuffer:SV_Target1
			#endif
			 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif
				float3 vertexToFrag488 = IN.ase_texcoord3.xyz;
				
#ifdef DISCARD_FRAGMENT
				float DiscardValue = 1.0;
				float DiscardThreshold = 0;

				if(DiscardValue < DiscardThreshold)discard;
#endif
				float3 Color = vertexToFrag488;
				float Alpha = 1.0;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#ifdef TREEVERSE_LINEAR_FOG
					Color.rgb = lerp(unity_FogColor.rgb, Color.rgb, IN.fogFactor);
				#endif
				#ifdef _MRT_GBUFFER0
				gbuffer = float4(0.0, 0.0, 0.0, 0.0);
				#endif
				return half4( Color, Alpha );
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "Forward"
			
			Tags { "LightMode"="UniversalForwardOnly" }
			
			Blend [_SRC] [_DST]
			ZWrite On
			ZTest LEqual
			Offset 0,0
			ColorMask RGBA
			

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define TREEVERSE_LINEAR_FOG
			#define ASE_SRP_VERSION 999999
			#define ASE_USING_SAMPLING_MACROS 1

			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#if ASE_SRP_VERSION <= 70108
			#define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
			#endif

			#define ASE_NEEDS_VERT_POSITION
			#define _ADDITIONAL_LIGHT_SHADOWS 1
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_SHADOWCOORDS
			#define ASE_NEEDS_VERT_NORMAL
			#define _MRT_GBUFFER0
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _SHADOWS_SOFT
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				
				float fogFactor : TEXCOORD2;
				
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_tangent : TANGENT;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				float4 ase_texcoord7 : TEXCOORD7;
				float4 ase_texcoord8 : TEXCOORD8;
				float4 ase_texcoord9 : TEXCOORD9;
				float4 ase_texcoord10 : TEXCOORD10;
				float4 ase_texcoord11 : TEXCOORD11;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)

			float4 _EmissionColor;
			float4 _FlashColor;
			float4 _GoochDarkColor;
			float4 _OutlineColor;
			float4 _GoochBrightColor;
			float4 _RimBrightColor;
			float4 _NormalMap_ST;
			float4 _MetallicGlossMap_ST;
			float4 _AlbedoColor;
			float4 _AlbedoMap_ST;
			float3 _CustomLightRotate;
			float _WrappedLighting;
			float _OcclusionStrength;
			float _DiffuseSmoothness;
			float _LightThreshold;
			float _CustomizeLightAngle;
			float _Smoothness;
			float _SpecularBrightness;
			float _Metallic;
			float _NormalMapIntensity;
			float _FlowEmission;
			float _DST;
			float _OutlineAlbedoBlend;
			float _OutlineWidthFadeScale;
			float _OutlineFarWidth;
			float _OutlineNearWidth;
			float _SupportAlbedoMapAlpha;
			float _RimLightIntensity;
			float _RimLightOffset;
			float _UseHoudiniVAT;
			float _playbackSpeed;
			float _frameCount;
			float _houdiniFPS;
			float _LifeTime;
			float _SRC;
			float _EmissionxAlbedo;
			float _Flash;
			CBUFFER_END
			TEXTURE2D(_posTexture);
			SAMPLER(sampler_posTexture);
			TEXTURE2D(_rotTexture);
			SAMPLER(sampler_rotTexture);
			TEXTURE2D(_MetallicGlossMap);
			SAMPLER(sampler_MetallicGlossMap);
			TEXTURE2D(_AlbedoMap);
			SAMPLER(sampler_AlbedoMap);
			TEXTURE2D(_NormalMap);
			SAMPLER(sampler_NormalMap);


			float4 Decode_Quaternion120_g55( float3 XYZ, float MaxComponent )
			{
				float w = sqrt(1.0 - pow(XYZ.x, 2) - pow(XYZ.y, 2) - pow(XYZ.z, 2));
				float4 q = float4(0, 0, 0, 1);
				switch(MaxComponent)
				{
				    case 0:
				        q = float4(XYZ.x, XYZ.y, XYZ.z, w);
				        break;
				    case 1:
				        q = float4(w, XYZ.y, XYZ.z, XYZ.x);
				        break;
				    case 2:
				        q = float4(XYZ.x, -w, XYZ.z, -XYZ.y);
				        break;
				    case 3:
				        q = float4(XYZ.x, XYZ.y, -w, -XYZ.z);
				        break;
				    default:
				        q = float4(XYZ.x, XYZ.y, XYZ.z, w);
				        break;
				}
				return q;
			}
			
			float3 TangentToWorld704( float3 NormalTS, float3x3 TBN )
			{
				float3 NormalWS = TransformTangentToWorld(NormalTS, TBN);
				NormalWS = NormalizeNormalPerPixel(NormalWS);
				return NormalWS;
			}
			
			float3 AdditionalLightsLambert( float3 WorldPosition, float3 WorldNormal )
			{
				float3 Color = 0;
				#ifdef _ADDITIONAL_LIGHTS
				int numLights = GetAdditionalLightsCount();
				for(int i = 0; i<numLights;i++)
				{
					Light light = GetAdditionalLight(i, WorldPosition);
					half3 AttLightColor = light.color *(light.distanceAttenuation * light.shadowAttenuation);
					Color +=LightingLambert(AttLightColor, light.direction, WorldNormal);
					
				}
				#endif
				return Color;
			}
			
			float4 Euler2Quat1_g61( float3 eulerAngles )
			{
				float x = eulerAngles.x;
				float y = eulerAngles.y;
				float z = eulerAngles.z;
				float rollOver2 = z * 0.5;
				float sinRollOver2 = sin(rollOver2);
				float cosRollOver2 = cos(rollOver2);
				float pitchOver2 = x * 0.5;
				float sinPitchOver2 = sin(pitchOver2);
				float cosPitchOver2 = cos(pitchOver2);
				float yawOver2 = y * 0.5;
				float sinYawOver2 = sin(yawOver2);
				float cosYawOver2 = cos(yawOver2);
				float4 result;
				    
				result.x = cosYawOver2 * sinPitchOver2 * cosRollOver2 + sinYawOver2 * cosPitchOver2 * sinRollOver2;
				result.y = sinYawOver2 * cosPitchOver2 * cosRollOver2 - cosYawOver2 * sinPitchOver2 * sinRollOver2;
				result.z = cosYawOver2 * cosPitchOver2 * sinRollOver2 - sinYawOver2 * sinPitchOver2 * cosRollOver2;
				result.w = cosYawOver2 * cosPitchOver2 * cosRollOver2 + sinYawOver2 * sinPitchOver2 * sinRollOver2;
				return result;
			}
			
			float3x3 Quat2RotMatCell11_g60( float4 _quat )
			{
				float q0p = _quat.w * _quat.w;
				float q1p = _quat.x * _quat.x;
				float q2p = _quat.y * _quat.y;
				float q3p = _quat.z * _quat.z;
				float q0q1 = _quat.w * _quat.x;
				float q0q2 = _quat.w * _quat.y;
				float q0q3 = _quat.w * _quat.z;
				float q1q2 = _quat.x * _quat.y;
				float q1q3 = _quat.x * _quat.z;
				float q2q3 = _quat.y * _quat.z;
				    
				float3x3 RotMatrix;
				    
				RotMatrix._11 = q0p + q1p - q2p - q3p;
				RotMatrix._12 = 2 * (q1q2 - q0q3);
				RotMatrix._13 = 2 * (q1q3 + q0q2);
				   
				RotMatrix._21 = 2 * (q1q2 + q0q3);
				RotMatrix._22 = q0p - q1p + q2p - q3p;
				RotMatrix._23 = 2 * (q2q3 - q0q1);
				    
				RotMatrix._31 = 2 * (q1q3 - q0q2);
				RotMatrix._32 = 2 * (q2q3 + q0q1);
				RotMatrix._33 = q0p - q1p - q2p + q3p;
				    
				return RotMatrix;
			}
			
			float3 RGBToHSV(float3 c)
			{
				float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
				float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
				float d = q.x - min( q.w, q.y );
				float e = 1.0e-10;
				return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}
			
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float temp_output_82_0_g55 = ( 1.0 - v.ase_texcoord1.y );
				float temp_output_63_0_g55 = _frameCount;
				float temp_output_75_0_g55 = floor( ( frac( ( _LifeTime * ( _houdiniFPS / ( temp_output_63_0_g55 - 0.01 ) ) * _playbackSpeed ) ) * temp_output_63_0_g55 ) );
				float temp_output_78_0_g55 = ( 1.0 / temp_output_63_0_g55 );
				float2 appendResult96_g55 = (float2(v.ase_texcoord1.x , ( 1.0 - ( temp_output_82_0_g55 + ( fmod( ( temp_output_75_0_g55 + 1.0 ) , temp_output_63_0_g55 ) * temp_output_78_0_g55 ) ) )));
				float2 next_frame_UV97_g55 = appendResult96_g55;
				float3 appendResult116_g55 = (float3(SAMPLE_TEXTURE2D_LOD( _posTexture, sampler_posTexture, next_frame_UV97_g55, 0.0 ).rgb));
				float2 appendResult86_g55 = (float2(v.ase_texcoord1.x , ( 1.0 - ( temp_output_82_0_g55 + ( fmod( temp_output_75_0_g55 , temp_output_63_0_g55 ) * temp_output_78_0_g55 ) ) )));
				float2 this_frame_UV87_g55 = appendResult86_g55;
				float3 appendResult107_g55 = (float3(SAMPLE_TEXTURE2D_LOD( _rotTexture, sampler_rotTexture, this_frame_UV87_g55, 0.0 ).rgb));
				float3 XYZ120_g55 = appendResult107_g55;
				float MaxComponent120_g55 = floor( ( SAMPLE_TEXTURE2D_LOD( _posTexture, sampler_posTexture, this_frame_UV87_g55, 0.0 ).a * 4.0 ) );
				float4 localDecode_Quaternion120_g55 = Decode_Quaternion120_g55( XYZ120_g55 , MaxComponent120_g55 );
				float3 appendResult122_g55 = (float3(localDecode_Quaternion120_g55.xyz));
				float3 quatXYZ123_g55 = appendResult122_g55;
				float3 appendResult111_g55 = (float3(-v.ase_texcoord2.x , v.ase_texcoord3.x , ( 1.0 - v.ase_texcoord3.y )));
				float3 pivot114_g55 = ( v.vertex.xyz - appendResult111_g55 );
				float quatW124_g55 = (localDecode_Quaternion120_g55).w;
				float3 VAT_vertex_offset666 = ( ( appendResult116_g55 + ( cross( quatXYZ123_g55 , ( cross( quatXYZ123_g55 , pivot114_g55 ) + ( pivot114_g55 * quatW124_g55 ) ) ) * float3( 2,2,2 ) ) + pivot114_g55 ) - v.vertex.xyz );
				float Houdini_VAT_Active678 = _UseHoudiniVAT;
				
				float mulTime725 = _TimeParameters.x * 3.0;
				float vertexToFrag730 = ( sin( ( sin( ( ( v.ase_texcoord2.x * ( 4.0 * PI ) ) + mulTime725 ) ) - 0.5 ) ) * step( 0.0 , v.ase_texcoord2.y ) * _FlowEmission );
				o.ase_texcoord3.z = vertexToFrag730;
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				float3 normalizeResult150_g55 = normalize( ( ( cross( quatXYZ123_g55 , ( ( quatW124_g55 * v.ase_tangent.xyz ) + cross( quatXYZ123_g55 , v.ase_tangent.xyz ) ) ) * float3( 2,2,2 ) ) + v.ase_tangent.xyz ) );
				float3 VAT_tangent693 = normalizeResult150_g55;
				float3 objToWorldDir708 = mul( GetObjectToWorldMatrix(), float4( VAT_tangent693, 0 ) ).xyz;
				float3 lerpResult713 = lerp( ase_worldTangent , objToWorldDir708 , Houdini_VAT_Active678);
				float3 vertexToFrag709 = lerpResult713;
				o.ase_texcoord4.xyz = vertexToFrag709;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				float3 normalizeResult145_g55 = normalize( ( ( cross( quatXYZ123_g55 , ( ( quatW124_g55 * v.ase_normal ) + cross( quatXYZ123_g55 , v.ase_normal ) ) ) * float3( 2,2,2 ) ) + v.ase_normal ) );
				float3 VAT_normal669 = normalizeResult145_g55;
				float3 objToWorldDir716 = mul( GetObjectToWorldMatrix(), float4( VAT_normal669, 0 ) ).xyz;
				float3 lerpResult710 = lerp( ase_worldNormal , objToWorldDir716 , Houdini_VAT_Active678);
				float3 vertexToFrag706 = lerpResult710;
				o.ase_texcoord5.xyz = vertexToFrag706;
				float4 appendResult406 = (float4(_MainLightColor.rgb , max( max( _MainLightColor.rgb.x , 0.0 ) , 0.0 )));
				float4 vertexToFrag404 = appendResult406;
				o.ase_texcoord6 = vertexToFrag404;
				o.ase_texcoord7.xyz = ase_worldTangent;
				o.ase_texcoord8.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord9.xyz = ase_worldBitangent;
				float3 eulerAngles1_g61 = radians( _CustomLightRotate );
				float4 localEuler2Quat1_g61 = Euler2Quat1_g61( eulerAngles1_g61 );
				float4 temp_output_8_0_g60 = localEuler2Quat1_g61;
				float4 _quat11_g60 = temp_output_8_0_g60;
				float3x3 localQuat2RotMatCell11_g60 = Quat2RotMatCell11_g60( _quat11_g60 );
				float3 lerpResult581 = lerp( _MainLightPosition.xyz , mul( localQuat2RotMatCell11_g60, float3(0,0,-1) ) , _CustomizeLightAngle);
				float3 vertexToFrag583 = lerpResult581;
				o.ase_texcoord10.xyz = vertexToFrag583;
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float dotResult558 = dot( ase_worldNormal , ase_worldViewDir );
				float smoothstepResult578 = smoothstep( 0.01 , 0.81 , ( 1.0 - max( 0.0 , dotResult558 ) ));
				float temp_output_572_0 = ( smoothstepResult578 * 2.0 );
				float vertexToFrag574 = ( temp_output_572_0 * temp_output_572_0 );
				o.ase_texcoord3.w = vertexToFrag574;
				
				float3 worldToObj328 = mul( GetWorldToObjectMatrix(), float4( _WorldSpaceCameraPos, 1 ) ).xyz;
				float vertexDist464 = distance( worldToObj328 , float3( 0,0,0 ) );
				float vertexToFrag322 = ( _RimLightOffset / vertexDist464 );
				o.ase_texcoord4.w = vertexToFrag322;
				float3 objectToViewPos = TransformWorldToView(TransformObjectToWorld(v.vertex.xyz));
				float eyeDepth = -objectToViewPos.z;
				float2 uv_AlbedoMap = v.ase_texcoord.xy * _AlbedoMap_ST.xy + _AlbedoMap_ST.zw;
				float4 tex2DNode137 = SAMPLE_TEXTURE2D_LOD( _AlbedoMap, sampler_AlbedoMap, uv_AlbedoMap, 0.0 );
				float lerpResult744 = lerp( 1.0 , tex2DNode137.a , _SupportAlbedoMapAlpha);
				float alpha419 = ( _AlbedoColor.a * lerpResult744 );
				float vertexToFrag331 = ( ( ( eyeDepth + 1.001 ) / vertexDist464 ) * _RimLightIntensity * alpha419 );
				o.ase_texcoord5.w = vertexToFrag331;
				float3 hsvTorgb386 = RGBToHSV( _RimBrightColor.rgb );
				float3 vertexToFrag387 = hsvTorgb386;
				o.ase_texcoord11.xyz = vertexToFrag387;
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				o.ase_tangent = v.ase_tangent;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord7.w = 0;
				o.ase_texcoord8.w = 0;
				o.ase_texcoord9.w = 0;
				o.ase_texcoord10.w = 0;
				o.ase_texcoord11.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( VAT_vertex_offset666 * Houdini_VAT_Active678 );
				#ifndef VERTEX_OPERATION_HIDE_PASS_ONLY
					#ifdef ASE_ABSOLUTE_VERTEX_POS
						v.vertex.xyz = vertexValue;
					#else
						v.vertex.xyz += vertexValue;
					#endif
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				
				#ifdef TREEVERSE_LINEAR_FOG
					float fz = UNITY_Z_0_FAR_FROM_CLIPSPACE(positionCS.z);
					real fogFactor =  saturate( fz * unity_FogParams.z + unity_FogParams.w);
					fogFactor = lerp(1.0, fogFactor, unity_FogColor.a * step(0.001, -1.0 / unity_FogParams.z));
				#else
					half fogFactor = 0.0;
				#endif
				
				o.fogFactor = fogFactor;

				#ifdef _CUSTOM_OUTPUT_POSITION
				o.clipPos = v.vertex;
				#else
				o.clipPos = positionCS;
				#endif
				return o;
			}

			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}

			half4 frag ( VertexOutput IN
			#ifdef _MRT_GBUFFER0
			,out half4 gbuffer:SV_Target1
			#endif
			 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				#ifdef PUSH_SELFSHADOW_TO_MAIN_LIGHT
				float selfShadowPush = 0.0;
				float3 pushRatio = _MainLightPosition.xyz * selfShadowPush;
				#else
				float3 pushRatio = 0.0;
				#endif

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition + pushRatio);
					#endif
				#endif
				float3 appendResult102 = (float3(_EmissionColor.rgb));
				float2 uv_MetallicGlossMap = IN.ase_texcoord3.xy * _MetallicGlossMap_ST.xy + _MetallicGlossMap_ST.zw;
				float4 tex2DNode423 = SAMPLE_TEXTURE2D( _MetallicGlossMap, sampler_MetallicGlossMap, uv_MetallicGlossMap );
				float emissionMask452 = tex2DNode423.a;
				float3 appendResult135 = (float3(_AlbedoColor.rgb));
				float2 uv_AlbedoMap = IN.ase_texcoord3.xy * _AlbedoMap_ST.xy + _AlbedoMap_ST.zw;
				float4 tex2DNode137 = SAMPLE_TEXTURE2D( _AlbedoMap, sampler_AlbedoMap, uv_AlbedoMap );
				float3 appendResult8 = (float3(tex2DNode137.rgb));
				float3 albedoColor170 = ( appendResult135 * appendResult8 );
				float3 lerpResult492 = lerp( float3( 1,1,1 ) , albedoColor170 , _EmissionxAlbedo);
				float3 temp_output_28_0 = ( appendResult102 * emissionMask452 * lerpResult492 );
				float vertexToFrag730 = IN.ase_texcoord3.z;
				float3 emissionColor173 = min( float3( 500,500,500 ) , ( temp_output_28_0 + ( temp_output_28_0 * vertexToFrag730 ) ) );
				float4 lerpResult124 = lerp( float4( 1,1,1,1 ) , _GoochDarkColor , _GoochDarkColor.a);
				float3 appendResult101 = (float3(lerpResult124.rgb));
				float4 lerpResult125 = lerp( float4( 1,1,1,1 ) , _GoochBrightColor , _GoochBrightColor.a);
				float3 appendResult100 = (float3(lerpResult125.rgb));
				float ase_lightAtten = 0;
				Light ase_mainLight = GetMainLight( ShadowCoords );
				ase_lightAtten = ase_mainLight.distanceAttenuation * ase_mainLight.shadowAttenuation;
				float temp_output_81_0 = ( _DiffuseSmoothness * 0.5 );
				float2 uv_NormalMap = IN.ase_texcoord3.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;
				float3 unpack11 = UnpackNormalScale( SAMPLE_TEXTURE2D( _NormalMap, sampler_NormalMap, uv_NormalMap ), _NormalMapIntensity );
				unpack11.z = lerp( 1, unpack11.z, saturate(_NormalMapIntensity) );
				float3 NormalTS704 = unpack11;
				float3 vertexToFrag709 = IN.ase_texcoord4.xyz;
				float3 vertexToFrag706 = IN.ase_texcoord5.xyz;
				float3 Binormal702 = ( sign( IN.ase_tangent.w ) * cross( vertexToFrag706 , vertexToFrag709 ) );
				float3x3 TBN697 = float3x3(vertexToFrag709, Binormal702, vertexToFrag706);
				float3x3 TBN704 = TBN697;
				float3 localTangentToWorld704 = TangentToWorld704( NormalTS704 , TBN704 );
				float3 worldNormal30 = localTangentToWorld704;
				float dotResult33 = dot( worldNormal30 , _MainLightPosition.xyz );
				float ndl35 = dotResult33;
				float temp_output_140_0 = ( ( ndl35 * 0.5 ) + 0.5 );
				float lerpResult142 = lerp( ndl35 , ( temp_output_140_0 * temp_output_140_0 ) , _WrappedLighting);
				float LMStyle_Lambert88 = lerpResult142;
				float temp_output_86_0 = fwidth( LMStyle_Lambert88 );
				float smoothstepResult82 = smoothstep( ( ( _LightThreshold - temp_output_81_0 ) - temp_output_86_0 ) , ( _LightThreshold + temp_output_81_0 + temp_output_86_0 ) , LMStyle_Lambert88);
				float diff95 = ( ase_lightAtten * smoothstepResult82 );
				float4 vertexToFrag404 = IN.ase_texcoord6;
				float4 break407 = vertexToFrag404;
				float LightIntensity405 = max( break407.w , 0.5 );
				float3 lerpResult99 = lerp( appendResult101 , appendResult100 , ( diff95 * LightIntensity405 ));
				float3 shadowColor178 = lerpResult99;
				float aoMask451 = tex2DNode423.b;
				float3 lerpResult539 = lerp( float3( 0,0,0 ) , ( albedoColor170 * shadowColor178 ) , ( ( aoMask451 * _OcclusionStrength ) + ( 1.0 - _OcclusionStrength ) ));
				float3 worldPosValue44_g59 = WorldPosition;
				float3 WorldPosition37_g59 = worldPosValue44_g59;
				float3 ase_worldTangent = IN.ase_texcoord7.xyz;
				float3 ase_worldNormal = IN.ase_texcoord8.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord9.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal12_g59 = float3(0,0,1);
				float3 worldNormal12_g59 = float3(dot(tanToWorld0,tanNormal12_g59), dot(tanToWorld1,tanNormal12_g59), dot(tanToWorld2,tanNormal12_g59));
				float3 worldNormalValue50_g59 = worldNormal12_g59;
				float3 WorldNormal37_g59 = worldNormalValue50_g59;
				float3 localAdditionalLightsLambert37_g59 = AdditionalLightsLambert( WorldPosition37_g59 , WorldNormal37_g59 );
				float3 lambertResult38_g59 = localAdditionalLightsLambert37_g59;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 vertexToFrag583 = IN.ase_texcoord10.xyz;
				float3 lightDir586 = vertexToFrag583;
				float3 normalizeResult428 = normalize( ( ase_worldViewDir + lightDir586 ) );
				float dotResult430 = dot( normalizeResult428 , worldNormal30 );
				float smoothnessMask450 = tex2DNode423.g;
				float temp_output_512_0 = ( ( ( smoothnessMask450 * _Smoothness ) - 0.5 ) * 2.0 );
				float lerpResult437 = lerp( 4.0 , 10.0 , temp_output_512_0);
				float3 normalizeResult623 = normalize( max( albedoColor170 , float3( 0.01,0.01,0.01 ) ) );
				float metallicMask449 = tex2DNode423.r;
				float temp_output_530_0 = ( 1.0 - ( _Metallic * metallicMask449 ) );
				float3 lerpResult526 = lerp( float3( 1,1,1 ) , ( normalizeResult623 * ( _SpecularBrightness + 1.0 ) ) , ( 1.0 - ( temp_output_530_0 * temp_output_530_0 ) ));
				float temp_output_519_0 = ( 1.0 - saturate( ( temp_output_512_0 * -1.0 ) ) );
				float temp_output_520_0 = ( temp_output_519_0 * temp_output_519_0 );
				float3 Out_Specular447 = ( ( floor( ( pow( max( 0.0 , dotResult430 ) , exp2( lerpResult437 ) ) * 2.0 ) ) * 0.5 ) * ( lerpResult526 * ase_lightAtten * diff95 * ( temp_output_520_0 * temp_output_520_0 ) ) * ( _SpecularBrightness * _SpecularBrightness ) );
				float3 appendResult554 = (float3(_FlashColor.rgb));
				float vertexToFrag574 = IN.ase_texcoord3.w;
				float temp_output_552_0 = ( max( ( floor( vertexToFrag574 ) * 0.33 ) , 0.125 ) * max( _Flash , 0.0 ) );
				float3 lerpResult576 = lerp( ( emissionColor173 + lerpResult539 + lambertResult38_g59 + Out_Specular447 ) , ( appendResult554 * temp_output_552_0 ) , temp_output_552_0);
				
				float lerpResult744 = lerp( 1.0 , tex2DNode137.a , _SupportAlbedoMapAlpha);
				float alpha419 = ( _AlbedoColor.a * lerpResult744 );
				
				float vertexToFrag322 = IN.ase_texcoord4.w;
				float vertexToFrag331 = IN.ase_texcoord5.w;
				float3 vertexToFrag387 = IN.ase_texcoord11.xyz;
				float3 break388 = vertexToFrag387;
				float3 appendResult334 = (float3(vertexToFrag322 , vertexToFrag331 , break388.x));
				float4 appendResult656 = (float4(appendResult334 , break388.y));
				
#ifdef DISCARD_FRAGMENT
				float DiscardValue = 1.0;
				float DiscardThreshold = 0;

				if(DiscardValue < DiscardThreshold)discard;
#endif
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = lerpResult576;
				float Alpha = alpha419;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				#ifdef TREEVERSE_LINEAR_FOG
					Color.rgb = lerp(unity_FogColor.rgb, Color.rgb, IN.fogFactor);
				#endif

				#ifdef _MRT_GBUFFER0
				gbuffer = appendResult656;
				#endif
				return half4( Color, Alpha );
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define TREEVERSE_LINEAR_FOG
			#define ASE_SRP_VERSION 999999
			#define ASE_USING_SAMPLING_MACROS 1

			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_VERT_POSITION
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)

			float4 _EmissionColor;
			float4 _FlashColor;
			float4 _GoochDarkColor;
			float4 _OutlineColor;
			float4 _GoochBrightColor;
			float4 _RimBrightColor;
			float4 _NormalMap_ST;
			float4 _MetallicGlossMap_ST;
			float4 _AlbedoColor;
			float4 _AlbedoMap_ST;
			float3 _CustomLightRotate;
			float _WrappedLighting;
			float _OcclusionStrength;
			float _DiffuseSmoothness;
			float _LightThreshold;
			float _CustomizeLightAngle;
			float _Smoothness;
			float _SpecularBrightness;
			float _Metallic;
			float _NormalMapIntensity;
			float _FlowEmission;
			float _DST;
			float _OutlineAlbedoBlend;
			float _OutlineWidthFadeScale;
			float _OutlineFarWidth;
			float _OutlineNearWidth;
			float _SupportAlbedoMapAlpha;
			float _RimLightIntensity;
			float _RimLightOffset;
			float _UseHoudiniVAT;
			float _playbackSpeed;
			float _frameCount;
			float _houdiniFPS;
			float _LifeTime;
			float _SRC;
			float _EmissionxAlbedo;
			float _Flash;
			CBUFFER_END
			TEXTURE2D(_posTexture);
			SAMPLER(sampler_posTexture);
			TEXTURE2D(_rotTexture);
			SAMPLER(sampler_rotTexture);
			TEXTURE2D(_AlbedoMap);
			SAMPLER(sampler_AlbedoMap);


			float4 Decode_Quaternion120_g55( float3 XYZ, float MaxComponent )
			{
				float w = sqrt(1.0 - pow(XYZ.x, 2) - pow(XYZ.y, 2) - pow(XYZ.z, 2));
				float4 q = float4(0, 0, 0, 1);
				switch(MaxComponent)
				{
				    case 0:
				        q = float4(XYZ.x, XYZ.y, XYZ.z, w);
				        break;
				    case 1:
				        q = float4(w, XYZ.y, XYZ.z, XYZ.x);
				        break;
				    case 2:
				        q = float4(XYZ.x, -w, XYZ.z, -XYZ.y);
				        break;
				    case 3:
				        q = float4(XYZ.x, XYZ.y, -w, -XYZ.z);
				        break;
				    default:
				        q = float4(XYZ.x, XYZ.y, XYZ.z, w);
				        break;
				}
				return q;
			}
			

			float3 _LightDirection;

			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float temp_output_82_0_g55 = ( 1.0 - v.ase_texcoord1.y );
				float temp_output_63_0_g55 = _frameCount;
				float temp_output_75_0_g55 = floor( ( frac( ( _LifeTime * ( _houdiniFPS / ( temp_output_63_0_g55 - 0.01 ) ) * _playbackSpeed ) ) * temp_output_63_0_g55 ) );
				float temp_output_78_0_g55 = ( 1.0 / temp_output_63_0_g55 );
				float2 appendResult96_g55 = (float2(v.ase_texcoord1.x , ( 1.0 - ( temp_output_82_0_g55 + ( fmod( ( temp_output_75_0_g55 + 1.0 ) , temp_output_63_0_g55 ) * temp_output_78_0_g55 ) ) )));
				float2 next_frame_UV97_g55 = appendResult96_g55;
				float3 appendResult116_g55 = (float3(SAMPLE_TEXTURE2D_LOD( _posTexture, sampler_posTexture, next_frame_UV97_g55, 0.0 ).rgb));
				float2 appendResult86_g55 = (float2(v.ase_texcoord1.x , ( 1.0 - ( temp_output_82_0_g55 + ( fmod( temp_output_75_0_g55 , temp_output_63_0_g55 ) * temp_output_78_0_g55 ) ) )));
				float2 this_frame_UV87_g55 = appendResult86_g55;
				float3 appendResult107_g55 = (float3(SAMPLE_TEXTURE2D_LOD( _rotTexture, sampler_rotTexture, this_frame_UV87_g55, 0.0 ).rgb));
				float3 XYZ120_g55 = appendResult107_g55;
				float MaxComponent120_g55 = floor( ( SAMPLE_TEXTURE2D_LOD( _posTexture, sampler_posTexture, this_frame_UV87_g55, 0.0 ).a * 4.0 ) );
				float4 localDecode_Quaternion120_g55 = Decode_Quaternion120_g55( XYZ120_g55 , MaxComponent120_g55 );
				float3 appendResult122_g55 = (float3(localDecode_Quaternion120_g55.xyz));
				float3 quatXYZ123_g55 = appendResult122_g55;
				float3 appendResult111_g55 = (float3(-v.ase_texcoord2.x , v.ase_texcoord3.x , ( 1.0 - v.ase_texcoord3.y )));
				float3 pivot114_g55 = ( v.vertex.xyz - appendResult111_g55 );
				float quatW124_g55 = (localDecode_Quaternion120_g55).w;
				float3 VAT_vertex_offset666 = ( ( appendResult116_g55 + ( cross( quatXYZ123_g55 , ( cross( quatXYZ123_g55 , pivot114_g55 ) + ( pivot114_g55 * quatW124_g55 ) ) ) * float3( 2,2,2 ) ) + pivot114_g55 ) - v.vertex.xyz );
				float Houdini_VAT_Active678 = _UseHoudiniVAT;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( VAT_vertex_offset666 * Houdini_VAT_Active678 );
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				float3 normalWS = TransformObjectToWorldDir( v.ase_normal );

				float4 clipPos = TransformWorldToHClip( ApplyShadowBias( positionWS, normalWS, _LightDirection ) );

				#if UNITY_REVERSED_Z
					clipPos.z = min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#else
					clipPos.z = max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				o.clipPos = clipPos;

				return o;
			}
			
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_AlbedoMap = IN.ase_texcoord2.xy * _AlbedoMap_ST.xy + _AlbedoMap_ST.zw;
				float4 tex2DNode137 = SAMPLE_TEXTURE2D( _AlbedoMap, sampler_AlbedoMap, uv_AlbedoMap );
				float lerpResult744 = lerp( 1.0 , tex2DNode137.a , _SupportAlbedoMapAlpha);
				float alpha419 = ( _AlbedoColor.a * lerpResult744 );
				
#ifdef DISCARD_FRAGMENT
				float DiscardValue = 1.0;
				float DiscardThreshold = 0;

				if(DiscardValue < DiscardThreshold)discard;
#endif
				float Alpha = alpha419;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					#ifdef _ALPHATEST_SHADOW_ON
						clip(Alpha - AlphaClipThresholdShadow);
					#else
						clip(Alpha - AlphaClipThreshold);
					#endif
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define TREEVERSE_LINEAR_FOG
			#define ASE_SRP_VERSION 999999
			#define ASE_USING_SAMPLING_MACROS 1

			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_VERT_POSITION
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)

			float4 _EmissionColor;
			float4 _FlashColor;
			float4 _GoochDarkColor;
			float4 _OutlineColor;
			float4 _GoochBrightColor;
			float4 _RimBrightColor;
			float4 _NormalMap_ST;
			float4 _MetallicGlossMap_ST;
			float4 _AlbedoColor;
			float4 _AlbedoMap_ST;
			float3 _CustomLightRotate;
			float _WrappedLighting;
			float _OcclusionStrength;
			float _DiffuseSmoothness;
			float _LightThreshold;
			float _CustomizeLightAngle;
			float _Smoothness;
			float _SpecularBrightness;
			float _Metallic;
			float _NormalMapIntensity;
			float _FlowEmission;
			float _DST;
			float _OutlineAlbedoBlend;
			float _OutlineWidthFadeScale;
			float _OutlineFarWidth;
			float _OutlineNearWidth;
			float _SupportAlbedoMapAlpha;
			float _RimLightIntensity;
			float _RimLightOffset;
			float _UseHoudiniVAT;
			float _playbackSpeed;
			float _frameCount;
			float _houdiniFPS;
			float _LifeTime;
			float _SRC;
			float _EmissionxAlbedo;
			float _Flash;
			CBUFFER_END
			TEXTURE2D(_posTexture);
			SAMPLER(sampler_posTexture);
			TEXTURE2D(_rotTexture);
			SAMPLER(sampler_rotTexture);
			TEXTURE2D(_AlbedoMap);
			SAMPLER(sampler_AlbedoMap);


			float4 Decode_Quaternion120_g55( float3 XYZ, float MaxComponent )
			{
				float w = sqrt(1.0 - pow(XYZ.x, 2) - pow(XYZ.y, 2) - pow(XYZ.z, 2));
				float4 q = float4(0, 0, 0, 1);
				switch(MaxComponent)
				{
				    case 0:
				        q = float4(XYZ.x, XYZ.y, XYZ.z, w);
				        break;
				    case 1:
				        q = float4(w, XYZ.y, XYZ.z, XYZ.x);
				        break;
				    case 2:
				        q = float4(XYZ.x, -w, XYZ.z, -XYZ.y);
				        break;
				    case 3:
				        q = float4(XYZ.x, XYZ.y, -w, -XYZ.z);
				        break;
				    default:
				        q = float4(XYZ.x, XYZ.y, XYZ.z, w);
				        break;
				}
				return q;
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float temp_output_82_0_g55 = ( 1.0 - v.ase_texcoord1.y );
				float temp_output_63_0_g55 = _frameCount;
				float temp_output_75_0_g55 = floor( ( frac( ( _LifeTime * ( _houdiniFPS / ( temp_output_63_0_g55 - 0.01 ) ) * _playbackSpeed ) ) * temp_output_63_0_g55 ) );
				float temp_output_78_0_g55 = ( 1.0 / temp_output_63_0_g55 );
				float2 appendResult96_g55 = (float2(v.ase_texcoord1.x , ( 1.0 - ( temp_output_82_0_g55 + ( fmod( ( temp_output_75_0_g55 + 1.0 ) , temp_output_63_0_g55 ) * temp_output_78_0_g55 ) ) )));
				float2 next_frame_UV97_g55 = appendResult96_g55;
				float3 appendResult116_g55 = (float3(SAMPLE_TEXTURE2D_LOD( _posTexture, sampler_posTexture, next_frame_UV97_g55, 0.0 ).rgb));
				float2 appendResult86_g55 = (float2(v.ase_texcoord1.x , ( 1.0 - ( temp_output_82_0_g55 + ( fmod( temp_output_75_0_g55 , temp_output_63_0_g55 ) * temp_output_78_0_g55 ) ) )));
				float2 this_frame_UV87_g55 = appendResult86_g55;
				float3 appendResult107_g55 = (float3(SAMPLE_TEXTURE2D_LOD( _rotTexture, sampler_rotTexture, this_frame_UV87_g55, 0.0 ).rgb));
				float3 XYZ120_g55 = appendResult107_g55;
				float MaxComponent120_g55 = floor( ( SAMPLE_TEXTURE2D_LOD( _posTexture, sampler_posTexture, this_frame_UV87_g55, 0.0 ).a * 4.0 ) );
				float4 localDecode_Quaternion120_g55 = Decode_Quaternion120_g55( XYZ120_g55 , MaxComponent120_g55 );
				float3 appendResult122_g55 = (float3(localDecode_Quaternion120_g55.xyz));
				float3 quatXYZ123_g55 = appendResult122_g55;
				float3 appendResult111_g55 = (float3(-v.ase_texcoord2.x , v.ase_texcoord3.x , ( 1.0 - v.ase_texcoord3.y )));
				float3 pivot114_g55 = ( v.vertex.xyz - appendResult111_g55 );
				float quatW124_g55 = (localDecode_Quaternion120_g55).w;
				float3 VAT_vertex_offset666 = ( ( appendResult116_g55 + ( cross( quatXYZ123_g55 , ( cross( quatXYZ123_g55 , pivot114_g55 ) + ( pivot114_g55 * quatW124_g55 ) ) ) * float3( 2,2,2 ) ) + pivot114_g55 ) - v.vertex.xyz );
				float Houdini_VAT_Active678 = _UseHoudiniVAT;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( VAT_vertex_offset666 * Houdini_VAT_Active678 );
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				o.clipPos = TransformWorldToHClip( positionWS );
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = o.clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				return o;
			}

			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_AlbedoMap = IN.ase_texcoord2.xy * _AlbedoMap_ST.xy + _AlbedoMap_ST.zw;
				float4 tex2DNode137 = SAMPLE_TEXTURE2D( _AlbedoMap, sampler_AlbedoMap, uv_AlbedoMap );
				float lerpResult744 = lerp( 1.0 , tex2DNode137.a , _SupportAlbedoMapAlpha);
				float alpha419 = ( _AlbedoColor.a * lerpResult744 );
				
#ifdef DISCARD_FRAGMENT
				float DiscardValue = 1.0;
				float DiscardThreshold = 0;

				if(DiscardValue < DiscardThreshold)discard;
#endif
				float Alpha = alpha419;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			Name "SceneSelectionPass"
			Tags { "LightMode"="SceneSelectionPass" }
			
			Blend One Zero
			Cull Back
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define TREEVERSE_LINEAR_FOG
			#define ASE_SRP_VERSION 999999
			#define ASE_USING_SAMPLING_MACROS 1

			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#if ASE_SRP_VERSION <= 70108
			#define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
			#endif

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_VERT_POSITION
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef ASE_FOG
				float fogFactor : TEXCOORD2;
				#endif
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)

			float4 _EmissionColor;
			float4 _FlashColor;
			float4 _GoochDarkColor;
			float4 _OutlineColor;
			float4 _GoochBrightColor;
			float4 _RimBrightColor;
			float4 _NormalMap_ST;
			float4 _MetallicGlossMap_ST;
			float4 _AlbedoColor;
			float4 _AlbedoMap_ST;
			float3 _CustomLightRotate;
			float _WrappedLighting;
			float _OcclusionStrength;
			float _DiffuseSmoothness;
			float _LightThreshold;
			float _CustomizeLightAngle;
			float _Smoothness;
			float _SpecularBrightness;
			float _Metallic;
			float _NormalMapIntensity;
			float _FlowEmission;
			float _DST;
			float _OutlineAlbedoBlend;
			float _OutlineWidthFadeScale;
			float _OutlineFarWidth;
			float _OutlineNearWidth;
			float _SupportAlbedoMapAlpha;
			float _RimLightIntensity;
			float _RimLightOffset;
			float _UseHoudiniVAT;
			float _playbackSpeed;
			float _frameCount;
			float _houdiniFPS;
			float _LifeTime;
			float _SRC;
			float _EmissionxAlbedo;
			float _Flash;
			CBUFFER_END
			TEXTURE2D(_rotTexture);
			SAMPLER(sampler_rotTexture);
			TEXTURE2D(_posTexture);
			SAMPLER(sampler_posTexture);


			float4 Decode_Quaternion120_g55( float3 XYZ, float MaxComponent )
			{
				float w = sqrt(1.0 - pow(XYZ.x, 2) - pow(XYZ.y, 2) - pow(XYZ.z, 2));
				float4 q = float4(0, 0, 0, 1);
				switch(MaxComponent)
				{
				    case 0:
				        q = float4(XYZ.x, XYZ.y, XYZ.z, w);
				        break;
				    case 1:
				        q = float4(w, XYZ.y, XYZ.z, XYZ.x);
				        break;
				    case 2:
				        q = float4(XYZ.x, -w, XYZ.z, -XYZ.y);
				        break;
				    case 3:
				        q = float4(XYZ.x, XYZ.y, -w, -XYZ.z);
				        break;
				    default:
				        q = float4(XYZ.x, XYZ.y, XYZ.z, w);
				        break;
				}
				return q;
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 appendResult612 = (float3(v.ase_texcoord3.xyz));
				float3 lerpResult611 = lerp( appendResult612 , v.ase_normal , v.ase_texcoord3.w);
				float temp_output_82_0_g55 = ( 1.0 - v.ase_texcoord1.y );
				float temp_output_63_0_g55 = _frameCount;
				float temp_output_75_0_g55 = floor( ( frac( ( _LifeTime * ( _houdiniFPS / ( temp_output_63_0_g55 - 0.01 ) ) * _playbackSpeed ) ) * temp_output_63_0_g55 ) );
				float temp_output_78_0_g55 = ( 1.0 / temp_output_63_0_g55 );
				float2 appendResult86_g55 = (float2(v.ase_texcoord1.x , ( 1.0 - ( temp_output_82_0_g55 + ( fmod( temp_output_75_0_g55 , temp_output_63_0_g55 ) * temp_output_78_0_g55 ) ) )));
				float2 this_frame_UV87_g55 = appendResult86_g55;
				float3 appendResult107_g55 = (float3(SAMPLE_TEXTURE2D_LOD( _rotTexture, sampler_rotTexture, this_frame_UV87_g55, 0.0 ).rgb));
				float3 XYZ120_g55 = appendResult107_g55;
				float MaxComponent120_g55 = floor( ( SAMPLE_TEXTURE2D_LOD( _posTexture, sampler_posTexture, this_frame_UV87_g55, 0.0 ).a * 4.0 ) );
				float4 localDecode_Quaternion120_g55 = Decode_Quaternion120_g55( XYZ120_g55 , MaxComponent120_g55 );
				float3 appendResult122_g55 = (float3(localDecode_Quaternion120_g55.xyz));
				float3 quatXYZ123_g55 = appendResult122_g55;
				float quatW124_g55 = (localDecode_Quaternion120_g55).w;
				float3 normalizeResult145_g55 = normalize( ( ( cross( quatXYZ123_g55 , ( ( quatW124_g55 * v.ase_normal ) + cross( quatXYZ123_g55 , v.ase_normal ) ) ) * float3( 2,2,2 ) ) + v.ase_normal ) );
				float3 VAT_normal669 = normalizeResult145_g55;
				float Houdini_VAT_Active678 = _UseHoudiniVAT;
				float3 lerpResult680 = lerp( lerpResult611 , VAT_normal669 , Houdini_VAT_Active678);
				float3 outlineNormal609 = lerpResult680;
				float3 worldToObj328 = mul( GetWorldToObjectMatrix(), float4( _WorldSpaceCameraPos, 1 ) ).xyz;
				float vertexDist464 = distance( worldToObj328 , float3( 0,0,0 ) );
				float lerpResult477 = lerp( _OutlineNearWidth , _OutlineFarWidth , ( _OutlineWidthFadeScale * vertexDist464 * 0.05 ));
				float2 appendResult96_g55 = (float2(v.ase_texcoord1.x , ( 1.0 - ( temp_output_82_0_g55 + ( fmod( ( temp_output_75_0_g55 + 1.0 ) , temp_output_63_0_g55 ) * temp_output_78_0_g55 ) ) )));
				float2 next_frame_UV97_g55 = appendResult96_g55;
				float3 appendResult116_g55 = (float3(SAMPLE_TEXTURE2D_LOD( _posTexture, sampler_posTexture, next_frame_UV97_g55, 0.0 ).rgb));
				float3 appendResult111_g55 = (float3(-v.ase_texcoord2.x , v.ase_texcoord3.x , ( 1.0 - v.ase_texcoord3.y )));
				float3 pivot114_g55 = ( v.vertex.xyz - appendResult111_g55 );
				float3 VAT_vertex_offset666 = ( ( appendResult116_g55 + ( cross( quatXYZ123_g55 , ( cross( quatXYZ123_g55 , pivot114_g55 ) + ( pivot114_g55 * quatW124_g55 ) ) ) * float3( 2,2,2 ) ) + pivot114_g55 ) - v.vertex.xyz );
				float3 temp_output_676_0 = ( ( outlineNormal609 * 0.001 * min( lerpResult477 , _OutlineFarWidth ) * v.ase_color.a ) + ( VAT_vertex_offset666 * Houdini_VAT_Active678 ) );
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = temp_output_676_0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				#ifdef ASE_FOG
				o.fogFactor = ComputeFogFactor( positionCS.z );
				#endif
				o.clipPos = positionCS;
				return o;
			}

			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif
				float3 temp_cast_0 = (1.0).xxx;
				
#ifdef DISCARD_FRAGMENT
				float DiscardValue = 1.0;
				float DiscardThreshold = 0;

				if(DiscardValue < DiscardThreshold)discard;
#endif
				float3 Color = temp_cast_0;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				return half4( Color, Alpha );
			}

			ENDHLSL
		}

	
	}
	CustomEditorForRenderPipeline "CustomDrawersShaderEditor" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
	CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=18935
0;821;1954;530;3360.483;2025.209;1.33246;True;False
Node;AmplifyShaderEditor.CommentaryNode;466;285.3,-1390.4;Inherit;False;918;234;vertex Distance;4;325;328;329;464;Vertex Distance;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;325;335.3,-1340.4;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;681;-2610,3662;Inherit;False;1064;1176;Houdini VAT;14;677;678;661;658;660;662;663;657;669;665;664;666;691;693;Houdini VAT;1,0.3392684,0,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;661;-2560,4608;Inherit;True;Property;_rotTexture;Rotation Texture;34;1;[SingleLineTexture];Create;False;0;0;0;False;0;False;None;4a41cc4cf951c2a49a9c232712284396;False;black;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;658;-2560,4096;Inherit;False;Property;_houdiniFPS;Houdini FPS;35;0;Create;False;0;0;0;False;0;False;30;30;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;662;-2560,4224;Inherit;False;Property;_frameCount;Frame Count;36;0;Create;False;0;0;0;False;0;False;1;144;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;660;-2560,4350.865;Inherit;True;Property;_posTexture;Position Texture;33;1;[SingleLineTexture];Create;False;0;0;0;False;1;Space(10);False;None;4a79b7fd9bb94ee44af2a3c07de65b41;False;black;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;663;-2560,3840;Inherit;False;Property;_playbackSpeed;Playback Speed;37;0;Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;691;-2560,3968;Inherit;False;Property;_LifeTime;LifeTime;38;0;Create;True;0;0;0;False;0;False;0;0.14;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;328;591.3,-1340.4;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;677;-2560,3712;Inherit;False;Property;_UseHoudiniVAT;Use Houdini VAT;32;2;[Header];[Toggle];Create;True;1;______Houdini VAT______;0;0;False;1;Space(10);False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;329;847.3,-1340.4;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;657;-2304,3968;Inherit;False;Houdini VAT Rigid;-1;;55;e3250adcd89e67e4cb5b0cc03e6c26b3;0;6;59;FLOAT;1;False;60;FLOAT;0;False;62;FLOAT;0;False;63;FLOAT;30;False;8;SAMPLER2D;0;False;58;SAMPLER2D;0;False;3;FLOAT3;0;FLOAT3;57;FLOAT3;146
Node;AmplifyShaderEditor.TexCoordVertexDataNode;610;-384,2816;Inherit;False;3;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;678;-2304,3712;Inherit;False;Houdini_VAT_Active;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;669;-1792,4096;Inherit;False;VAT_normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;169;464,2624;Inherit;False;1319.829;1382.934;Outline and SelectionPass;27;486;129;422;150;126;130;479;477;468;478;467;481;128;469;485;487;488;483;613;653;117;121;674;676;682;683;740;Outline and SelectionPass;0.9528302,0.2471965,0.4900168,1;0;0
Node;AmplifyShaderEditor.NormalVertexDataNode;238;-384,3072;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;612;-208,2816;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;464;975.3,-1340.4;Inherit;False;vertexDist;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;481;528,3776;Inherit;False;Constant;_Float1;Float 1;14;0;Create;True;0;0;0;False;0;False;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;469;528,3712;Inherit;False;464;vertexDist;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;675;-384,3584;Inherit;False;669;VAT_normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;128;528,3584;Inherit;False;Property;_OutlineWidthFadeScale;Width Fade Scale;24;0;Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;611;0,2944;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;665;-2176,4224;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;679;-384,3456;Inherit;False;678;Houdini_VAT_Active;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;468;528,3456;Inherit;False;Property;_OutlineFarWidth;Far Width;23;0;Create;False;0;0;0;False;0;False;50;50;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;680;128,2944;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;478;736,3584;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;467;528,3328;Inherit;False;Property;_OutlineNearWidth;Near Width;22;0;Create;False;0;0;0;False;0;False;25;23.92;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;664;-1920,3968;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;609;304,2944;Inherit;False;outlineNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;666;-1792,3968;Inherit;False;VAT_vertex_offset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;477;784,3328;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;130;528,3200;Inherit;False;Constant;_05;.05;14;0;Create;True;0;0;0;False;0;False;0.001;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;479;928,3328;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;613;512,3072;Inherit;False;609;outlineNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;683;896,3840;Inherit;False;678;Houdini_VAT_Active;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;674;896,3712;Inherit;False;666;VAT_vertex_offset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexColorNode;653;512,3840;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;177;-2480,-560;Inherit;False;1202.727;937.5439;Shadow Color;11;96;412;411;101;97;100;99;124;178;125;98;Shadow Color;0,0,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;448;464,1744;Inherit;False;1315.667;577;Mask;7;451;450;449;424;423;452;10;Mask;0.5849056,0.5849056,0.5849056,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;94;-944,-48;Inherit;False;961.8428;606.9229;Light Threshold;10;76;77;86;83;84;93;81;82;95;132;Light Threshold;0.9434034,0.9811321,0.4118904,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;167;-966.6978,-4106.172;Inherit;False;2145.061;1410.03;Rim Light Color;25;308;335;313;339;322;324;330;318;334;388;387;386;361;185;338;331;314;420;465;493;494;656;688;689;690;Rim Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;171;-2482,-2098;Inherit;False;1170;536;Albedo Color;11;134;8;136;137;133;135;170;419;652;743;744;Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;42;467,590;Inherit;False;2237.013;480.8593;Prepare Normal;13;12;30;11;698;700;703;699;695;697;702;704;709;706;Prepare Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;180;-1132.573,-2130.625;Inherit;False;852;721;;9;172;143;179;535;536;538;533;537;539;It's MK Shader Diffuse;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;74;-2480,592;Inherit;False;2176.396;991.9929;OrenNayar;33;138;72;68;54;64;61;69;59;51;57;62;70;52;55;53;63;58;60;65;50;67;48;71;66;56;75;49;73;88;139;140;142;141;Diffuse;0,0.4626691,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;579;-4476.073,1974.982;Inherit;False;1682;678;Custom Light Angles;8;588;586;585;583;582;581;580;595;Custom Light Angles;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;129;896,2944;Inherit;False;4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;41;471,-50;Inherit;False;653;489;Prepare Light Model;9;34;31;40;37;35;38;39;33;36;Prepare Light Model;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;410;-2738,-2994;Inherit;False;1558;334;Light;11;401;400;402;399;406;404;407;409;408;405;549;Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;682;1152,3712;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;418;848,-1840;Inherit;False;216;293;BlendMode;2;415;416;BlendMode;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;458;-2686.076,1870;Inherit;False;2250.979;1595.016;Specular;42;43;456;455;512;511;624;447;518;524;444;622;434;436;482;523;442;446;428;425;520;435;517;519;532;462;521;441;526;531;530;430;623;427;459;527;499;528;621;439;437;589;440;Specular;1,0.8389269,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;174;-2482,-1458;Inherit;False;1178;771.0001;Emission Color;22;727;726;724;719;721;729;725;723;718;492;491;461;717;173;28;102;460;116;730;736;737;742;Emission;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;185;-896,-3968;Inherit;False;Property;_RimBrightColor;Rim Color;17;1;[Header];Create;False;1;______Rim Light______;0;0;True;1;Space(10);False;1,1,1,0.5019608;1,1,1,0.5019608;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;417;0,-1920;Inherit;False;SRP Additional Light;-1;;59;6c86746ad131a0a408ca599df5f40861;7,6,1,9,0,23,0,26,0,27,0,24,0,25,0;6;2;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;15;FLOAT3;0,0,0;False;14;FLOAT3;1,1,1;False;18;FLOAT;0.5;False;32;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;140;-1042,1146;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;172;-1024,-2048;Inherit;False;170;albedoColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexToFragmentNode;404;-1920,-2944;Inherit;False;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;688;256,-3328;Inherit;False;666;VAT_vertex_offset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;423;768,1792;Inherit;True;Property;_TextureSample3;Texture Sample 3;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;67;-1504,1280;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;450;1152,1920;Inherit;False;smoothnessMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;537;-1024,-1537;Inherit;False;Property;_OcclusionStrength;AO;14;0;Create;False;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;441;-768,2304;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FloorOpNode;571;-128.2094,-2564.264;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;446;-2304,2176;Inherit;False;30;worldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;72;-1408,640;Inherit;False;35;ndl;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SurfaceDepthNode;313;-896,-3328;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;36;512,256;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;483;512,2880;Inherit;False;170;albedoColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CrossProductOpNode;699;1536,768;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;452;1152,2176;Inherit;False;emissionMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;51;-2304,768;Inherit;False;FLOAT3;0;0;0;3;1;0;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;58;-2176,1408;Inherit;False;38;ndv;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;97;-2432,-128;Inherit;False;Property;_GoochBrightColor;Shadow Light Color;15;1;[Header];Create;False;1;______Shadow______;0;0;False;1;Space(10);False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;563;-704.9321,-2613.354;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;676;1152,2944;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;61;-2176,1152;Inherit;False;40;vdl;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-2560,3328;Inherit;False;Property;_Smoothness;Smoothness;13;0;Create;False;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;575;-591.7511,-2245.369;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RGBToHSVNode;386;-512,-3840;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;75;-576,640;Inherit;False;LMStyle_OrenNayar;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;126;512,2688;Inherit;False;Property;_OutlineColor;Outline Color;21;1;[Header];Create;False;1;______Outline______;0;0;False;1;Space(10);False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;388;0,-3840;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RegisterLocalVarNode;449;1152,1792;Inherit;False;metallicMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;486;1024,2688;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StepOpNode;64;-1792,1408;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexTangentNode;694;-256,1152;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;84;-600,388;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;623;-2176,2688;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;422;768,3072;Inherit;False;419;alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;580;-3840,2048;Inherit;False;2;2;0;FLOAT3x3;0,0,0,1,1,1,1,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;485;512,2944;Inherit;False;Property;_OutlineAlbedoBlend;Outline Albedo Blend;25;0;Create;True;0;0;0;False;0;False;0.1;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;487;768,2688;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexToFragmentNode;574;-411.3093,-2578.564;Inherit;False;False;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;539;-512,-2048;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;552;515.5416,-2534.895;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;-1253,263;Inherit;False;Property;_LightThreshold;LightThreshold;8;1;[Header];Create;False;1;______Toon Properties______;0;0;False;1;Space(10);False;0;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;-1152,640;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;456;-2304,3200;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;520;-1664,2944;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SignOpNode;703;1536,640;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;519;-1920,2944;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;408;-1408,-2944;Inherit;False;LightColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;338;-134.0102,-3240.119;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;561;-734.5999,-2245.588;Inherit;False;Property;_Flash;Flash;31;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;179;-1024,-1920;Inherit;False;178;shadowColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;528;-2304,2304;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;460;-2176,-1280;Inherit;False;452;emissionMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.MatrixFromVectors;695;1792,896;Inherit;False;FLOAT3x3;True;4;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3x3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;35;896,0;Inherit;False;ndl;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;589;-2560,2176;Inherit;False;586;lightDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;49;-2176,896;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;511;-2176,3200;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;465;-640,-3584;Inherit;False;464;vertexDist;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;535;-640,-1536;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;101;-1920,0;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;517;-2176,2944;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;137;-2176,-1792;Inherit;True;Property;_TextureSample0;Texture Sample 0;15;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;33;768,0;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;582;-4426.073,2408.982;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;60;-1792,1152;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;68;-1664,768;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SmoothstepOpNode;578;-1073.66,-2543.884;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.01;False;2;FLOAT;0.81;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;30;2432,640;Inherit;False;worldNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;451;1152,2048;Inherit;False;aoMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;399;-2688,-2944;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMinOpNode;742;-1496.296,-1265.877;Inherit;False;2;0;FLOAT3;500,500,500;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;142;-720,800;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;713;256,1024;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;586;-3072,2048;Inherit;False;lightDir;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;572;-884.2094,-2638.264;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;99;-1788,-505;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;702;1792,640;Inherit;False;Binormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;150;784,3200;Inherit;False;Constant;_Float0;Float 0;14;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;701;-256,640;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;494;908.7652,-3170.428;Inherit;True;Constant;_Vector4;Vector 4;27;0;Create;True;0;0;0;False;0;False;1,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;718;-1792,-1152;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;652;-1792,-1792;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;629;-4170.1,2049.3;Inherit;False;Transform Euler to RotationMatrix;-1;;60;2cd743ba17aa86741a9126a507ee8fb5;1,12,1;1;5;FLOAT3;0,0,0;False;1;FLOAT3x3;0
Node;AmplifyShaderEditor.GetLocalVarNode;707;-256,1280;Inherit;False;693;VAT_tangent;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;457;0,-1792;Inherit;False;447;Out_Specular;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;31;512,0;Inherit;False;30;worldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;577;291.3396,-2547.884;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.125;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;488;1184,2688;Inherit;False;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;737;-2058.319,-1004.603;Inherit;False;Property;_FlowEmission;FlowEmission;6;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;536;-512,-1664;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;499;-1152,1920;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;100;-1920,-128;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;8;-1792,-1920;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;744;-1867.56,-1686.809;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;139;-1170,1146;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;558;-1288.816,-2662.631;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-1253,391;Inherit;False;Property;_DiffuseSmoothness;Diffuse Smoothness;10;0;Create;False;0;0;0;False;0;False;0;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;689;256,-3200;Inherit;False;678;Houdini_VAT_Active;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;50;-2432,1024;Inherit;False;Constant;_Vector0;Vector 0;6;0;Create;True;0;0;0;False;0;False;0.33,0.13,0.09;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformDirectionNode;716;0,768;Inherit;False;Object;World;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-1408,896;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;585;-4426.073,2536.982;Inherit;False;Property;_CustomizeLightAngle;Customize Light Angle;28;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TangentVertexDataNode;698;1280,640;Inherit;False;1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;40;896,256;Inherit;False;vdl;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;743;-2226.979,-1573.436;Inherit;False;Property;_SupportAlbedoMapAlpha;Support Map Alpha;39;1;[Toggle];Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;53;-1920,896;Inherit;False;Constant;_Vector1;Vector 1;6;0;Create;True;0;0;0;False;0;False;1,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;531;-2048,2304;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;116;-2432,-1408;Inherit;False;Property;_EmissionColor;Emission Color;5;2;[HDR];[Gamma];Create;False;0;0;0;False;0;False;0,0,0,1;0,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightAttenuation;459;-1408,2560;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;318;-896,-3712;Inherit;False;Property;_RimLightOffset;RimLightOffset;18;0;Create;True;0;0;0;False;0;False;0.07;0.05;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;512,640;Inherit;False;Property;_NormalMapIntensity;Normal Map Intensity;4;0;Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;559;-1172.816,-2680.631;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;335;-896,-3200;Inherit;False;Property;_RimLightIntensity;RimLightIntensity;19;0;Create;True;0;0;0;False;0;False;1;1.5;0.001;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;562;-111.2096,-2303.552;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;428;-2048,1920;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RadiansOpNode;595;-4352,2048;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LightAttenuation;77;-512,0;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;700;1664,640;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;425;-2560,1920;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;57;-2176,1280;Inherit;False;35;ndl;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;532;-1920,2304;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;178;-1536,-512;Inherit;False;shadowColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;134;-1664,-2048;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;1,1,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexToFragmentNode;331;-6.010207,-3240.119;Inherit;False;False;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;705;-256.348,768;Inherit;False;669;VAT_normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CustomExpressionNode;66;-1664,1408;Inherit;False;return HALF_MIN@;1;Create;0;HALF_MIN;True;False;0;;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;435;-1408,2176;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;133;-2432,-2048;Inherit;False;Property;_AlbedoColor;Albedo Color;0;2;[HDR];[Header];Create;False;1;______Base Preperties______;0;0;False;1;Space(10);False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;308;-896,-3072;Inherit;False;Property;_RimLight;RimLight;20;1;[Toggle];Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;557;-1698.816,-2621.631;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;173;-1536,-1408;Inherit;False;emissionColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexToFragmentNode;709;910.1179,967.4081;Inherit;False;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;416;896,-1664;Inherit;False;Property;_DST;Dst;27;1;[Enum];Create;False;0;0;1;UnityEngine.Rendering.BlendMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;62;-1920,1408;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;38;896,128;Inherit;False;ndv;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;52;-2048,768;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;437;-1664,2688;Inherit;False;3;0;FLOAT;4;False;1;FLOAT;10;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;588;-4411.073,2268.982;Inherit;False;Constant;_Vector5;Vector 5;30;0;Create;True;0;0;0;False;0;False;0,0,-1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;98;-2432,128;Inherit;False;Property;_GoochDarkColor;Shadow Dark Color;16;0;Create;False;0;0;0;False;0;False;0,0,0,1;0.6887044,0.6730154,0.7169812,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;65;-1408,1152;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;538;-768,-1664;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;697;2048,768;Inherit;False;TBN;-1;True;1;0;FLOAT3x3;0,0,0,1,1,1,1,0,1;False;1;FLOAT3x3;0
Node;AmplifyShaderEditor.SimpleTimeNode;692;-2727.368,4004.098;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;48;-2432,640;Inherit;False;-1;;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;491;-2432,-1024;Inherit;False;Property;_EmissionxAlbedo;Emission x Albedo;7;1;[Toggle];Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;170;-1536,-2048;Inherit;False;albedoColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;420;-384,-3072;Inherit;False;419;alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;554;-567,-2345;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;124;-2176,128;Inherit;False;3;0;COLOR;1,1,1,1;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;427;-2176,1920;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;512;-2048,3200;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;444;-2560,2688;Inherit;False;170;albedoColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;581;-3523,2050;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;83;-720,163;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;125;-2176,-128;Inherit;False;3;0;COLOR;1,1,1,1;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;412;-2304,-384;Inherit;False;405;LightIntensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;442;-1152,2432;Inherit;False;4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;339;-512,-3328;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;583;-3328,2048;Inherit;False;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;95;-192,128;Inherit;False;diff;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;10;512,2048;Inherit;True;Property;_NormalMap;NormalMap;3;2;[Normal];[SingleLineTexture];Create;True;0;0;0;False;0;False;None;5521c197399d919469557a7e0e729503;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-1920,768;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;34;498,109;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;54;-2432,1152;Inherit;False;Constant;_Vector2;Vector 2;6;0;Create;True;0;0;0;False;0;False;-0.5,0.17,0.45;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;518;-2048,2944;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;624;-2304,2688;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0.01,0.01,0.01;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;88;-640,1152;Inherit;False;LMStyle_Lambert;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FWidthOpNode;86;-881,147;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;11;817,649;Inherit;True;Property;_TextureSample1;Texture Sample 1;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;560;-1062.816,-2665.631;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;56;-1792,768;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;430;-1808,1920;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;402;-2304,-2816;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;143;-768,-2048;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;37;768,128;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;439;-1152,2304;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;401;-2432,-2816;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;330;-256,-3456;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;415;895,-1792;Inherit;False;Property;_SRC;Src;26;2;[Header];[Enum];Create;False;1;______Blend Mode______;0;1;UnityEngine.Rendering.BlendMode;True;1;Space(15);False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;71;-1280,768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;482;-1664,1920;Inherit;False;Property;_SpecularBrightness;Specular Brightness;11;1;[Header];Create;False;1;Specular Settings;0;0;False;1;Space(10);False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;406;-2048,-2944;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SmoothstepOpNode;82;-384,128;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Exp2OpNode;436;-1536,2304;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;704;2304,768;Inherit;False;float3 NormalWS = TransformTangentToWorld(NormalTS, TBN)@$NormalWS = NormalizeNormalPerPixel(NormalWS)@$return NormalWS@;3;Create;2;True;NormalTS;FLOAT3;0,0,0;In;;Inherit;False;True;TBN;FLOAT3x3;1,0,0,1,1,1,1,0,1;In;;Inherit;False;TangentToWorld;True;False;0;;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3x3;1,0,0,1,1,1,1,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FloorOpNode;440;-1024,2304;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;573;64.7905,-2558.264;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0.33;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;549;-1563.315,-2789.483;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;493;898.9269,-3495.05;Inherit;True;Constant;_Vector3;Vector 3;27;0;Create;True;0;0;0;False;0;False;0.5,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;-838,434;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;584;-4803,2041;Inherit;False;Property;_CustomLightRotate;Custom Light Rotate;29;0;Create;True;0;0;0;False;0;False;45,-45,0;45,-45,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformDirectionNode;708;0,1024;Inherit;False;Object;World;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;-914,1146;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;455;-2560,3200;Inherit;False;450;smoothnessMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;690;512,-3328;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;411;-2048,-512;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;447;-640,2048;Inherit;False;Out_Specular;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;686;768,-2048;Inherit;False;678;Houdini_VAT_Active;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;622;-1536,2048;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;726;-1920,-896;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;407;-1664,-2944;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;175;0,-2176;Inherit;False;173;emissionColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;419;-1664,-1792;Inherit;False;alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;409;-1536,-2944;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;495;1179.112,-3462.209;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;556;-1474.816,-2581.631;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;523;-2560,2304;Inherit;False;Property;_Metallic;Metallic;12;0;Create;False;0;0;0;False;0;False;1;0.03;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-1917,1332;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;710;256,768;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;526;-1776,2560;Inherit;False;3;0;FLOAT3;1,1,1;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;576;752.0532,-2327.204;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;132;-256,0;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;724;-2048,-896;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;527;-2560,2432;Inherit;False;449;metallicMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;736;-1543.84,-890.1029;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;533;-1024,-1664;Inherit;False;451;aoMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;400;-2560,-2816;Inherit;False;FLOAT;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RegisterLocalVarNode;361;-640,-3968;Inherit;False;rimLightColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;687;1024,-2176;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;656;546.1428,-3616.362;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;135;-1920,-2048;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;719;-2176,-896;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;462;-1408,2688;Inherit;False;95;diff;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;96;-2304,-512;Inherit;False;95;diff;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;29;578,-2189;Inherit;False;4;4;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;63;-1664,1280;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;524;-896,2304;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;553;-1024,-2304;Inherit;False;Property;_FlashColor;FlashColor;30;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;405;-1408,-2816;Inherit;False;LightIntensity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;693;-1792,4224;Inherit;False;VAT_tangent;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;69;-1536,768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;712;-256,896;Inherit;False;678;Houdini_VAT_Active;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;138;-896,1024;Inherit;False;Property;_WrappedLighting;Half Lambert;9;2;[Toggle];[ToggleUI];Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;39;768,256;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;717;-1664,-1280;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;625;-1193.354,2793.796;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;93;-562,187;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;424;512,1792;Inherit;True;Property;_MetallicGlossMap;Metallic Map;2;1;[SingleLineTexture];Create;False;0;0;0;False;1;Space(15);False;None;14a75f40bf72dd044a628a8eba914807;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.DynamicAppendNode;102;-1920,-1408;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;739;-2299.319,-651.6033;Inherit;False;Constant;_Float2;Float 2;39;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;387;-256,-3840;Inherit;False;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;334;363.9662,-3874.427;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;461;-2432,-1152;Inherit;False;170;albedoColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SinOpNode;729;-1664,-896;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;434;-1792,2176;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-1792,-1408;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexToFragmentNode;730;-1412,-896;Inherit;False;False;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;706;512,768;Inherit;False;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PiNode;723;-2432,-768;Inherit;False;1;0;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;492;-2176,-1152;Inherit;False;3;0;FLOAT3;1,1,1;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;521;-1536,2944;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;136;-2432,-1792;Inherit;True;Property;_AlbedoMap;Albedo Map;1;1;[SingleLineTexture];Create;False;0;0;0;False;0;False;None;0bc77f6341005f34487d545029fcefc7;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;740;1153.807,2808.653;Inherit;False;Constant;_Float3;Float 3;39;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;76;-896,0;Inherit;False;88;LMStyle_Lambert;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;738;-1920,-768;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;421;1031.506,-2239.555;Inherit;False;419;alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;530;-2176,2304;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;324;0,-3584;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;322;128,-3584;Inherit;False;False;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;670;768,-2176;Inherit;False;666;VAT_vertex_offset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;721;-2432,-896;Inherit;False;2;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;725;-2176,-768;Inherit;False;1;0;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;727;-1792,-896;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;621;-2048,2688;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;651;1901.282,-2304;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;FullScreenPass;0;1;FullScreenPass;4;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;7;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForwardOnly;True;2;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;118;1280,-2304;Half;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;21;Treeverse/Dynamic/Toon;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;Forward;0;3;Forward;12;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;True;True;0;False;-1;False;False;False;False;False;False;False;False;True;True;True;128;False;-1;255;False;-1;255;False;-1;7;False;-1;3;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Geometry=Queue=0;True;4;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;True;True;2;5;True;415;10;True;416;0;5;False;-1;1;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;1;False;-1;True;3;False;-1;True;False;0;False;-1;0;False;-1;True;1;LightMode=UniversalForwardOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;19;Surface;1;637934776135466903;  Blend;0;0;Two Sided;1;0;Cast Shadows;1;0;  Use Shadow Threshold;0;0;Receive Shadows;1;0;GPU Instancing;1;0;LOD CrossFade;0;0;Treeverse Linear Fog;1;637993451053185263;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;1;637931343134552407;Full Screen Pass;0;0;Additional Pass;1;637933691143136380;Scene Selectioin Pass;1;637931343138312560;Vertex Position,InvertActionOnDeselection;1;638035934328796323;Vertex Operation Hide Pass Only;0;638035930220268045;Discard Fragment;0;0;Push SelfShadow to Main Light;0;0;2;MRT Output;1;637980555616948449;Custom Output Position;0;0;8;True;False;True;True;True;True;True;False;False;;True;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;121;1408,2944;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;21;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;SceneSelectionPass;0;6;SceneSelectionPass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=SceneSelectionPass;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;122;512,-640;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;18;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;Meta;0;7;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;117;1408,2688;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;21;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;ExtraPrePass;0;2;Outline;6;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;True;True;1;1;True;415;0;True;416;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;True;1;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;True;True;False;128;False;-1;255;False;-1;255;False;-1;2;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;1;MRT Output;0;638067742849656465;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;120;512,-2304;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;18;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;DepthOnly;0;5;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;119;512,-640;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;18;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;ShadowCaster;0;4;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;314;768,-3840;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;21;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;AdditionalPass;0;0;ToonPostProcessing;6;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;True;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;1;False;-1;True;3;False;-1;True;False;0;False;-1;0;False;-1;True;1;LightMode=ToonPostProcessing;False;False;0;Hidden/InternalErrorShader;0;0;Standard;1;MRT Output;0;637933887809711874;False;0
WireConnection;328;0;325;0
WireConnection;329;0;328;0
WireConnection;657;59;663;0
WireConnection;657;60;691;0
WireConnection;657;62;658;0
WireConnection;657;63;662;0
WireConnection;657;8;660;0
WireConnection;657;58;661;0
WireConnection;678;0;677;0
WireConnection;669;0;657;57
WireConnection;612;0;610;0
WireConnection;464;0;329;0
WireConnection;611;0;612;0
WireConnection;611;1;238;0
WireConnection;611;2;610;4
WireConnection;680;0;611;0
WireConnection;680;1;675;0
WireConnection;680;2;679;0
WireConnection;478;0;128;0
WireConnection;478;1;469;0
WireConnection;478;2;481;0
WireConnection;664;0;657;0
WireConnection;664;1;665;0
WireConnection;609;0;680;0
WireConnection;666;0;664;0
WireConnection;477;0;467;0
WireConnection;477;1;468;0
WireConnection;477;2;478;0
WireConnection;479;0;477;0
WireConnection;479;1;468;0
WireConnection;129;0;613;0
WireConnection;129;1;130;0
WireConnection;129;2;479;0
WireConnection;129;3;653;4
WireConnection;682;0;674;0
WireConnection;682;1;683;0
WireConnection;140;0;139;0
WireConnection;404;0;406;0
WireConnection;423;0;424;0
WireConnection;423;7;424;1
WireConnection;67;0;63;0
WireConnection;67;1;66;0
WireConnection;450;0;423;2
WireConnection;441;0;524;0
WireConnection;441;1;442;0
WireConnection;441;2;499;0
WireConnection;571;0;574;0
WireConnection;699;0;706;0
WireConnection;699;1;709;0
WireConnection;452;0;423;4
WireConnection;51;0;48;0
WireConnection;563;0;572;0
WireConnection;563;1;572;0
WireConnection;676;0;129;0
WireConnection;676;1;682;0
WireConnection;575;0;561;0
WireConnection;386;0;185;0
WireConnection;75;0;142;0
WireConnection;388;0;387;0
WireConnection;449;0;423;1
WireConnection;486;0;487;0
WireConnection;486;1;483;0
WireConnection;486;2;485;0
WireConnection;64;0;60;0
WireConnection;84;0;79;0
WireConnection;84;1;81;0
WireConnection;84;2;86;0
WireConnection;623;0;624;0
WireConnection;580;0;629;0
WireConnection;580;1;588;0
WireConnection;487;0;126;0
WireConnection;574;0;563;0
WireConnection;539;1;143;0
WireConnection;539;2;536;0
WireConnection;552;0;577;0
WireConnection;552;1;575;0
WireConnection;73;0;72;0
WireConnection;73;1;71;0
WireConnection;456;0;455;0
WireConnection;456;1;43;0
WireConnection;520;0;519;0
WireConnection;520;1;519;0
WireConnection;703;0;698;4
WireConnection;519;0;518;0
WireConnection;408;0;409;0
WireConnection;338;0;330;0
WireConnection;338;1;335;0
WireConnection;338;2;420;0
WireConnection;528;0;523;0
WireConnection;528;1;527;0
WireConnection;695;0;709;0
WireConnection;695;1;702;0
WireConnection;695;2;706;0
WireConnection;35;0;33;0
WireConnection;49;0;51;0
WireConnection;49;1;50;0
WireConnection;511;0;456;0
WireConnection;535;0;537;0
WireConnection;101;0;124;0
WireConnection;517;0;512;0
WireConnection;137;0;136;0
WireConnection;137;7;136;1
WireConnection;33;0;31;0
WireConnection;33;1;34;0
WireConnection;60;0;61;0
WireConnection;60;1;59;0
WireConnection;68;0;56;0
WireConnection;578;0;560;0
WireConnection;30;0;704;0
WireConnection;451;0;423;3
WireConnection;742;1;717;0
WireConnection;142;0;57;0
WireConnection;142;1;141;0
WireConnection;142;2;138;0
WireConnection;713;0;694;0
WireConnection;713;1;708;0
WireConnection;713;2;712;0
WireConnection;586;0;583;0
WireConnection;572;0;578;0
WireConnection;99;0;101;0
WireConnection;99;1;100;0
WireConnection;99;2;411;0
WireConnection;702;0;700;0
WireConnection;718;0;28;0
WireConnection;718;1;730;0
WireConnection;652;0;133;4
WireConnection;652;1;744;0
WireConnection;629;5;595;0
WireConnection;577;0;573;0
WireConnection;488;0;486;0
WireConnection;536;0;538;0
WireConnection;536;1;535;0
WireConnection;499;0;482;0
WireConnection;499;1;482;0
WireConnection;100;0;125;0
WireConnection;8;0;137;0
WireConnection;744;1;137;4
WireConnection;744;2;743;0
WireConnection;139;0;57;0
WireConnection;558;0;557;0
WireConnection;558;1;556;0
WireConnection;716;0;705;0
WireConnection;70;0;68;2
WireConnection;70;1;65;0
WireConnection;40;0;39;0
WireConnection;531;0;530;0
WireConnection;531;1;530;0
WireConnection;559;1;558;0
WireConnection;562;0;554;0
WireConnection;562;1;552;0
WireConnection;428;0;427;0
WireConnection;595;0;584;0
WireConnection;700;0;703;0
WireConnection;700;1;699;0
WireConnection;532;0;531;0
WireConnection;178;0;99;0
WireConnection;134;0;135;0
WireConnection;134;1;8;0
WireConnection;331;0;338;0
WireConnection;435;0;434;0
WireConnection;435;1;436;0
WireConnection;173;0;742;0
WireConnection;709;0;713;0
WireConnection;62;0;57;0
WireConnection;62;1;58;0
WireConnection;38;0;37;0
WireConnection;52;0;51;0
WireConnection;52;1;49;0
WireConnection;437;2;512;0
WireConnection;65;0;60;0
WireConnection;65;1;67;0
WireConnection;538;0;533;0
WireConnection;538;1;537;0
WireConnection;697;0;695;0
WireConnection;170;0;134;0
WireConnection;554;0;553;0
WireConnection;124;1;98;0
WireConnection;124;2;98;4
WireConnection;427;0;425;0
WireConnection;427;1;589;0
WireConnection;512;0;511;0
WireConnection;581;0;582;0
WireConnection;581;1;580;0
WireConnection;581;2;585;0
WireConnection;83;0;79;0
WireConnection;83;1;81;0
WireConnection;125;1;97;0
WireConnection;125;2;97;4
WireConnection;442;0;526;0
WireConnection;442;1;459;0
WireConnection;442;2;462;0
WireConnection;442;3;625;0
WireConnection;339;0;313;0
WireConnection;583;0;581;0
WireConnection;95;0;132;0
WireConnection;55;0;52;0
WireConnection;55;1;54;0
WireConnection;518;0;517;0
WireConnection;624;0;444;0
WireConnection;88;0;142;0
WireConnection;86;0;76;0
WireConnection;11;0;10;0
WireConnection;11;5;12;0
WireConnection;11;7;10;1
WireConnection;560;0;559;0
WireConnection;56;0;55;0
WireConnection;56;1;53;0
WireConnection;430;0;428;0
WireConnection;430;1;446;0
WireConnection;402;0;401;0
WireConnection;143;0;172;0
WireConnection;143;1;179;0
WireConnection;37;0;31;0
WireConnection;37;1;36;0
WireConnection;439;0;435;0
WireConnection;401;0;400;0
WireConnection;330;0;339;0
WireConnection;330;1;465;0
WireConnection;71;0;69;0
WireConnection;71;1;70;0
WireConnection;406;0;399;1
WireConnection;406;3;402;0
WireConnection;82;0;76;0
WireConnection;82;1;93;0
WireConnection;82;2;84;0
WireConnection;436;0;437;0
WireConnection;704;0;11;0
WireConnection;704;1;697;0
WireConnection;440;0;439;0
WireConnection;573;0;571;0
WireConnection;549;0;407;3
WireConnection;81;0;80;0
WireConnection;708;0;707;0
WireConnection;141;0;140;0
WireConnection;141;1;140;0
WireConnection;690;0;688;0
WireConnection;690;1;689;0
WireConnection;411;0;96;0
WireConnection;411;1;412;0
WireConnection;447;0;441;0
WireConnection;622;0;482;0
WireConnection;726;0;724;0
WireConnection;407;0;404;0
WireConnection;419;0;652;0
WireConnection;409;0;407;0
WireConnection;409;1;407;1
WireConnection;409;2;407;2
WireConnection;495;0;493;0
WireConnection;495;1;494;0
WireConnection;59;0;57;0
WireConnection;59;1;58;0
WireConnection;710;0;701;0
WireConnection;710;1;716;0
WireConnection;710;2;712;0
WireConnection;526;1;621;0
WireConnection;526;2;532;0
WireConnection;576;0;29;0
WireConnection;576;1;562;0
WireConnection;576;2;552;0
WireConnection;132;0;77;0
WireConnection;132;1;82;0
WireConnection;724;0;719;0
WireConnection;724;1;725;0
WireConnection;736;0;729;0
WireConnection;736;1;738;0
WireConnection;736;2;737;0
WireConnection;400;0;399;1
WireConnection;361;0;185;0
WireConnection;687;0;670;0
WireConnection;687;1;686;0
WireConnection;656;0;334;0
WireConnection;656;3;388;1
WireConnection;135;0;133;0
WireConnection;719;0;721;1
WireConnection;719;1;723;0
WireConnection;29;0;175;0
WireConnection;29;1;539;0
WireConnection;29;2;417;0
WireConnection;29;3;457;0
WireConnection;63;0;62;0
WireConnection;63;2;64;0
WireConnection;524;0;440;0
WireConnection;405;0;549;0
WireConnection;693;0;657;146
WireConnection;69;0;68;0
WireConnection;69;1;68;1
WireConnection;39;0;34;0
WireConnection;39;1;36;0
WireConnection;717;0;28;0
WireConnection;717;1;718;0
WireConnection;625;0;521;0
WireConnection;93;0;83;0
WireConnection;93;1;86;0
WireConnection;102;0;116;0
WireConnection;387;0;386;0
WireConnection;334;0;322;0
WireConnection;334;1;331;0
WireConnection;334;2;388;0
WireConnection;729;0;727;0
WireConnection;434;1;430;0
WireConnection;28;0;102;0
WireConnection;28;1;460;0
WireConnection;28;2;492;0
WireConnection;730;0;736;0
WireConnection;706;0;710;0
WireConnection;492;1;461;0
WireConnection;492;2;491;0
WireConnection;521;0;520;0
WireConnection;521;1;520;0
WireConnection;738;1;721;2
WireConnection;530;0;528;0
WireConnection;324;0;318;0
WireConnection;324;1;465;0
WireConnection;322;0;324;0
WireConnection;727;0;726;0
WireConnection;621;0;623;0
WireConnection;621;1;622;0
WireConnection;118;2;576;0
WireConnection;118;3;421;0
WireConnection;118;11;656;0
WireConnection;118;5;687;0
WireConnection;121;0;150;0
WireConnection;121;3;676;0
WireConnection;117;0;488;0
WireConnection;117;1;740;0
WireConnection;117;3;676;0
WireConnection;314;0;334;0
WireConnection;314;1;388;1
WireConnection;314;3;690;0
ASEEND*/
//CHKSM=CB6B0B9A39C61207103BB6EF8B88841FF1603AD3
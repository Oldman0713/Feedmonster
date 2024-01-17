// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Treeverse/Dynamic/Toon_Transparent"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[ASEBegin][Header(______Base Preperties______)][Space(10)]_AlbedoColor("Albedo Color", Color) = (1,1,1,0.9607843)
		[SingleLineTexture]_AlbedoMap("Albedo Map", 2D) = "white" {}
		[SingleLineTexture][Space(15)]_MetallicGlossMap("Metallic Map", 2D) = "white" {}
		[Normal][SingleLineTexture]_NormalMap("NormalMap", 2D) = "bump" {}
		_NormalMapIntensity("Normal Map Intensity", Float) = 1
		[HDR][Gamma]_EmissionColor("Emission Color", Color) = (0,0,0,1)
		[Toggle]_EmissionxAlbedo("Emission x Albedo", Range( 0 , 1)) = 1
		[Header(Specular Settings)][Space(10)]_SpecularBrightness("Specular Brightness", Float) = 1
		_Metallic("Metallic", Range( 0 , 1)) = 1
		_Smoothness("Smoothness", Range( 0 , 1)) = 1
		_OcclusionStrength("AO", Range( 0 , 1)) = 0
		[Header(______Shadow______)][Space(10)]_GoochBrightColor("Shadow Light Color", Color) = (1,1,1,1)
		_GoochDarkColor("Shadow Dark Color", Color) = (0.5019608,0.5019608,0.5019608,1)
		[Header(______Rim Light______)][Space(10)]_RimBrightColor("Rim Color", Color) = (1,1,1,0.5019608)
		_RimLightOffset("RimLightOffset", Range( 0 , 0.1)) = 0.07
		_RimLightIntensity("RimLightIntensity", Range( 0.001 , 100)) = 1
		[HDR][Gamma]_FresnelLightColor("Fresnel Light Color", Color) = (1,1,1,0.5019608)
		[Header(______Outline______)][Space(10)]_OutlineColor("Outline Color", Color) = (0,0,0,1)
		_OutlineNearWidth("Near Width", Float) = 25
		_OutlineFarWidth("Far Width", Float) = 50
		_OutlineWidthFadeScale("Width Fade Scale", Float) = 1
		_OutlineAlbedoBlend("Outline Albedo Blend", Range( 0 , 1)) = 0.1
		[Header(______Blend Mode______)][Enum(UnityEngine.Rendering.BlendMode)][Space(15)]_SRC("Src", Float) = 5
		[Enum(UnityEngine.Rendering.BlendMode)]_DST("Dst", Float) = 10
		_OpaqueBlending("Opaque Blending", Float) = 0.1
		[SingleLineTexture]_WeldingMask("WeldingMask", 2D) = "white" {}
		_ReflectionIntensity("Reflection Intensity", Range( 0 , 2)) = 0.2
		_CustomLightRotate("Custom Light Rotate", Vector) = (55.5,-28.5,0,0)
		[Toggle]_CustomizeLightAngle("Customize Light Angle", Float) = 0
		[HDR]_FlashColor("FlashColor", Color) = (1,1,1,0)
		[ASEEnd]_Flash("Flash", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

		
	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="AlphaTest+51" }
		
		Cull Back
		AlphaToMask Off
		
		HLSLINCLUDE
		#pragma target 3.0

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
			#define ASE_ABSOLUTE_VERTEX_POS 1
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

			float4 _NormalMap_ST;
			float4 _FlashColor;
			float4 _MetallicGlossMap_ST;
			float4 _EmissionColor;
			float4 _OutlineColor;
			float4 _GoochBrightColor;
			float4 _GoochDarkColor;
			float4 _AlbedoMap_ST;
			float4 _AlbedoColor;
			float4 _WeldingMask_ST;
			float4 _FresnelLightColor;
			float4 _RimBrightColor;
			float3 _CustomLightRotate;
			float _SpecularBrightness;
			float _CustomizeLightAngle;
			float _OpaqueBlending;
			float _OcclusionStrength;
			float _Smoothness;
			float _SRC;
			float _ReflectionIntensity;
			float _NormalMapIntensity;
			float _EmissionxAlbedo;
			float _OutlineAlbedoBlend;
			float _OutlineWidthFadeScale;
			float _OutlineFarWidth;
			float _OutlineNearWidth;
			float _RimLightIntensity;
			float _RimLightOffset;
			float _DST;
			float _Metallic;
			float _Flash;
			CBUFFER_END
			TEXTURE2D(_AlbedoMap);
			SAMPLER(sampler_AlbedoMap);


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

				float3 OutPosition603 = v.vertex.xyz;
				
				float3 worldToObj328 = mul( GetWorldToObjectMatrix(), float4( _WorldSpaceCameraPos, 1 ) ).xyz;
				float vertexDist464 = distance( worldToObj328 , float3( 0,0,0 ) );
				float vertexToFrag322 = ( _RimLightOffset / vertexDist464 );
				o.ase_texcoord3.x = vertexToFrag322;
				float3 objectToViewPos = TransformWorldToView(TransformObjectToWorld(v.vertex.xyz));
				float eyeDepth = -objectToViewPos.z;
				float2 uv_AlbedoMap = v.ase_texcoord.xy * _AlbedoMap_ST.xy + _AlbedoMap_ST.zw;
				float4 tex2DNode137 = SAMPLE_TEXTURE2D_LOD( _AlbedoMap, sampler_AlbedoMap, uv_AlbedoMap, 0.0 );
				float alpha419 = ( _AlbedoColor.a * tex2DNode137.a );
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
				float3 vertexValue = OutPosition603;
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
			Stencil
			{
				Ref 1
				Comp NotEqual
				Pass Keep
			}

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define ASE_ABSOLUTE_VERTEX_POS 1
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
			#define ASE_NEEDS_VERT_NORMAL
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
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
				
				float fogFactor : TEXCOORD2;
				
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)

			float4 _NormalMap_ST;
			float4 _FlashColor;
			float4 _MetallicGlossMap_ST;
			float4 _EmissionColor;
			float4 _OutlineColor;
			float4 _GoochBrightColor;
			float4 _GoochDarkColor;
			float4 _AlbedoMap_ST;
			float4 _AlbedoColor;
			float4 _WeldingMask_ST;
			float4 _FresnelLightColor;
			float4 _RimBrightColor;
			float3 _CustomLightRotate;
			float _SpecularBrightness;
			float _CustomizeLightAngle;
			float _OpaqueBlending;
			float _OcclusionStrength;
			float _Smoothness;
			float _SRC;
			float _ReflectionIntensity;
			float _NormalMapIntensity;
			float _EmissionxAlbedo;
			float _OutlineAlbedoBlend;
			float _OutlineWidthFadeScale;
			float _OutlineFarWidth;
			float _OutlineNearWidth;
			float _RimLightIntensity;
			float _RimLightOffset;
			float _DST;
			float _Metallic;
			float _Flash;
			CBUFFER_END
			TEXTURE2D(_AlbedoMap);
			SAMPLER(sampler_AlbedoMap);


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 OutPosition603 = v.vertex.xyz;
				float3 appendResult816 = (float3(v.ase_texcoord3.xyz));
				float3 lerpResult818 = lerp( appendResult816 , v.ase_normal , v.ase_texcoord3.w);
				float3 outlineNormal819 = lerpResult818;
				float3 worldToObj328 = mul( GetWorldToObjectMatrix(), float4( _WorldSpaceCameraPos, 1 ) ).xyz;
				float vertexDist464 = distance( worldToObj328 , float3( 0,0,0 ) );
				float lerpResult477 = lerp( _OutlineNearWidth , _OutlineFarWidth , ( _OutlineWidthFadeScale * vertexDist464 * 0.05 ));
				float3 temp_output_605_0 = ( OutPosition603 + ( outlineNormal819 * 0.001 * min( lerpResult477 , _OutlineFarWidth ) ) );
				
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
				float3 vertexValue = temp_output_605_0;
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
				float Alpha = _OutlineColor.a;
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
			Stencil
			{
				Ref 1
				Comp Always
				Pass Replace
				Fail Keep
				ZFail Keep
			}

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define TREEVERSE_LINEAR_FOG
			#define ASE_SRP_VERSION 999999
			#define REQUIRE_OPAQUE_TEXTURE 1
			#define REQUIRE_DEPTH_TEXTURE 1
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
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_NORMAL
			#define _ADDITIONAL_LIGHT_SHADOWS 1
			#define ASE_NEEDS_FRAG_SHADOWCOORDS
			#define ASE_NEEDS_FRAG_POSITION
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _SHADOWS_SOFT
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
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
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_tangent : TANGENT;
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

			float4 _NormalMap_ST;
			float4 _FlashColor;
			float4 _MetallicGlossMap_ST;
			float4 _EmissionColor;
			float4 _OutlineColor;
			float4 _GoochBrightColor;
			float4 _GoochDarkColor;
			float4 _AlbedoMap_ST;
			float4 _AlbedoColor;
			float4 _WeldingMask_ST;
			float4 _FresnelLightColor;
			float4 _RimBrightColor;
			float3 _CustomLightRotate;
			float _SpecularBrightness;
			float _CustomizeLightAngle;
			float _OpaqueBlending;
			float _OcclusionStrength;
			float _Smoothness;
			float _SRC;
			float _ReflectionIntensity;
			float _NormalMapIntensity;
			float _EmissionxAlbedo;
			float _OutlineAlbedoBlend;
			float _OutlineWidthFadeScale;
			float _OutlineFarWidth;
			float _OutlineNearWidth;
			float _RimLightIntensity;
			float _RimLightOffset;
			float _DST;
			float _Metallic;
			float _Flash;
			CBUFFER_END
			TEXTURE2D(_MetallicGlossMap);
			SAMPLER(sampler_MetallicGlossMap);
			TEXTURE2D(_AlbedoMap);
			SAMPLER(sampler_AlbedoMap);
			TEXTURE2D(_NormalMap);
			SAMPLER(sampler_NormalMap);
			uniform float4 _CameraDepthTexture_TexelSize;
			TEXTURE2D(_WeldingMask);
			SAMPLER(sampler_WeldingMask);


			inline float4 ASE_ComputeGrabScreenPos( float4 pos )
			{
				#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
				#else
				float scale = 1.0;
				#endif
				float4 o = pos;
				o.y = pos.w * 0.5f;
				o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
				return o;
			}
			
			float3 TangentToWorld13_g101( float3 NormalTS, float3x3 TBN )
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
			
			float4 Euler2Quat1_g103( float3 eulerAngles )
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
			
			float3x3 Quat2RotMatCell11_g102( float4 _quat )
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
			
			
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 OutPosition603 = v.vertex.xyz;
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord3 = screenPos;
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord5.xyz = ase_worldTangent;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord6.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord7.xyz = ase_worldBitangent;
				float3 break400 = _MainLightColor.rgb;
				float4 appendResult406 = (float4(_MainLightColor.rgb , max( max( max( break400.x , break400.y ) , break400.z ) , 0.5 )));
				float4 vertexToFrag404 = appendResult406;
				o.ase_texcoord9 = vertexToFrag404;
				float3 eulerAngles1_g103 = _CustomLightRotate;
				float4 localEuler2Quat1_g103 = Euler2Quat1_g103( eulerAngles1_g103 );
				float4 temp_output_8_0_g102 = localEuler2Quat1_g103;
				float4 _quat11_g102 = temp_output_8_0_g102;
				float3x3 localQuat2RotMatCell11_g102 = Quat2RotMatCell11_g102( _quat11_g102 );
				float3 lerpResult737 = lerp( _MainLightPosition.xyz , mul( localQuat2RotMatCell11_g102, float3(0,0,1) ) , _CustomizeLightAngle);
				float3 vertexToFrag740 = lerpResult737;
				o.ase_texcoord10.xyz = vertexToFrag740;
				float3 vertexToFrag751 = ase_worldNormal;
				o.ase_texcoord11.xyz = vertexToFrag751;
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float dotResult839 = dot( ase_worldNormal , ase_worldViewDir );
				float smoothstepResult842 = smoothstep( 0.01 , 0.81 , ( 1.0 - max( 0.0 , dotResult839 ) ));
				float temp_output_843_0 = ( smoothstepResult842 * 2.0 );
				float vertexToFrag831 = ( temp_output_843_0 * temp_output_843_0 );
				o.ase_texcoord4.z = vertexToFrag831;
				
				o.ase_texcoord4.xy = v.ase_texcoord.xy;
				o.ase_tangent = v.ase_tangent;
				o.ase_texcoord8 = v.vertex;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
				o.ase_texcoord6.w = 0;
				o.ase_texcoord7.w = 0;
				o.ase_texcoord10.w = 0;
				o.ase_texcoord11.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = OutPosition603;
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
			, FRONT_FACE_TYPE ase_vface : FRONT_FACE_SEMANTIC ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				#ifdef PUSH_SELFSHADOW_TO_MAIN_LIGHT
				float selfShadowPush = 3.0;
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
				float4 screenPos = IN.ase_texcoord3;
				float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( screenPos );
				float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
				float4 fetchOpaqueVal549 = float4( SHADERGRAPH_SAMPLE_SCENE_COLOR( ase_grabScreenPosNorm ), 1.0 );
				float3 appendResult592 = (float3(fetchOpaqueVal549.rgb));
				float3 screenColor665 = appendResult592;
				float3 appendResult102 = (float3(_EmissionColor.rgb));
				float2 uv_MetallicGlossMap = IN.ase_texcoord4.xy * _MetallicGlossMap_ST.xy + _MetallicGlossMap_ST.zw;
				float4 tex2DNode423 = SAMPLE_TEXTURE2D( _MetallicGlossMap, sampler_MetallicGlossMap, uv_MetallicGlossMap );
				float emissionMask452 = tex2DNode423.a;
				float3 appendResult135 = (float3(_AlbedoColor.rgb));
				float2 uv_AlbedoMap = IN.ase_texcoord4.xy * _AlbedoMap_ST.xy + _AlbedoMap_ST.zw;
				float4 tex2DNode137 = SAMPLE_TEXTURE2D( _AlbedoMap, sampler_AlbedoMap, uv_AlbedoMap );
				float3 appendResult8 = (float3(tex2DNode137.rgb));
				float3 albedoColor170 = ( appendResult135 * appendResult8 );
				float3 lerpResult492 = lerp( float3( 1,1,1 ) , albedoColor170 , _EmissionxAlbedo);
				float3 emissionColor173 = ( appendResult102 * emissionMask452 * lerpResult492 );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float2 uv_NormalMap = IN.ase_texcoord4.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;
				float3 unpack11 = UnpackNormalScale( SAMPLE_TEXTURE2D( _NormalMap, sampler_NormalMap, uv_NormalMap ), _NormalMapIntensity );
				unpack11.z = lerp( 1, unpack11.z, saturate(_NormalMapIntensity) );
				float3 NormalTS13_g101 = unpack11;
				float3 ase_worldTangent = IN.ase_texcoord5.xyz;
				float3 ase_worldNormal = IN.ase_texcoord6.xyz;
				float3 Binormal5_g101 = ( sign( IN.ase_tangent.w ) * cross( ase_worldNormal , ase_worldTangent ) );
				float3x3 TBN1_g101 = float3x3(ase_worldTangent, Binormal5_g101, ase_worldNormal);
				float3x3 TBN13_g101 = TBN1_g101;
				float3 localTangentToWorld13_g101 = TangentToWorld13_g101( NormalTS13_g101 , TBN13_g101 );
				float3 temp_output_156_0 = localTangentToWorld13_g101;
				float3 switchResult635 = (((ase_vface>0)?(temp_output_156_0):(-temp_output_156_0)));
				float3 worldNormal30 = switchResult635;
				float3 ase_worldBitangent = IN.ase_texcoord7.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal710 = worldNormal30;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float eyeDepth15_g105 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float3 objToWorld2_g105 = mul( GetObjectToWorldMatrix(), float4( IN.ase_texcoord8.xyz, 1 ) ).xyz;
				float3 worldToView13_g105 = mul( UNITY_MATRIX_V, float4( objToWorld2_g105, 1 ) ).xyz;
				float3 temp_output_685_0 = ( ( ( ( ( eyeDepth15_g105 / -worldToView13_g105.z ) - 1.0 ) * ( ( _WorldSpaceCameraPos.y - objToWorld2_g105.y ) + 20.0 ) ) * 1.2 ) * worldNormal30 );
				float3 worldToObjDir691 = mul( GetWorldToObjectMatrix(), float4( temp_output_685_0, 0 ) ).xyz;
				float3 objToView660 = mul( UNITY_MATRIX_MV, float4( worldToObjDir691, 1 ) ).xyz;
				float3 objToView661 = mul( UNITY_MATRIX_MV, float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 normalizeResult658 = normalize( ( objToView660 - objToView661 ) );
				float3 normalVS801 = normalizeResult658;
				float dotResult646 = dot( normalVS801 , float3(0,0,1) );
				float smoothstepResult651 = smoothstep( 0.6 , 0.95 , dotResult646);
				float fresnelNdotV696 = dot( temp_output_685_0, ase_worldViewDir );
				float fresnelNode696 = ( 0.25 + 1.0 * pow( 1.0 - fresnelNdotV696, 4.0 ) );
				float smoothstepResult703 = smoothstep( 0.5 , 0.75 , ( 1.0 - dotResult646 ));
				float temp_output_697_0 = ( ( 1.0 - smoothstepResult651 ) * saturate( max( fresnelNode696 , smoothstepResult703 ) ) );
				float smoothstepResult731 = smoothstep( 0.1 , 0.2 , temp_output_697_0);
				float diff798 = ( smoothstepResult731 * temp_output_697_0 );
				float ase_lightAtten = 0;
				Light ase_mainLight = GetMainLight( ShadowCoords );
				ase_lightAtten = ase_mainLight.distanceAttenuation * ase_mainLight.shadowAttenuation;
				float4 vertexToFrag404 = IN.ase_texcoord9;
				float4 break407 = vertexToFrag404;
				float LightIntensity405 = break407.w;
				float temp_output_707_0 = ( diff798 * ase_lightAtten * LightIntensity405 );
				float metallicMask449 = tex2DNode423.r;
				float temp_output_528_0 = ( _Metallic * metallicMask449 );
				float metallic716 = temp_output_528_0;
				half3 reflectVector710 = reflect( -ase_worldViewDir, float3(dot(tanToWorld0,tanNormal710), dot(tanToWorld1,tanNormal710), dot(tanToWorld2,tanNormal710)) );
				float3 indirectSpecular710 = GlossyEnvironmentReflection( reflectVector710, 1.0 - 1.0, ( _ReflectionIntensity * temp_output_707_0 * metallic716 ) );
				float3 reflection727 = indirectSpecular710;
				float4 lerpResult124 = lerp( float4( 1,1,1,1 ) , _GoochDarkColor , _GoochDarkColor.a);
				float3 appendResult101 = (float3(lerpResult124.rgb));
				float4 lerpResult125 = lerp( float4( 1,1,1,1 ) , _GoochBrightColor , _GoochBrightColor.a);
				float3 appendResult100 = (float3(lerpResult125.rgb));
				float3 lerpResult99 = lerp( appendResult101 , appendResult100 , temp_output_707_0);
				float3 shadowColor178 = lerpResult99;
				float aoMask451 = tex2DNode423.b;
				float3 lerpResult539 = lerp( float3( 0,0,0 ) , ( ( albedoColor170 + reflection727 ) * shadowColor178 ) , ( ( aoMask451 * _OcclusionStrength ) + ( 1.0 - _OcclusionStrength ) ));
				float3 worldPosValue44_g104 = WorldPosition;
				float3 WorldPosition37_g104 = worldPosValue44_g104;
				float3 tanNormal12_g104 = float3(0,0,1);
				float3 worldNormal12_g104 = float3(dot(tanToWorld0,tanNormal12_g104), dot(tanToWorld1,tanNormal12_g104), dot(tanToWorld2,tanNormal12_g104));
				float3 worldNormalValue50_g104 = worldNormal12_g104;
				float3 WorldNormal37_g104 = worldNormalValue50_g104;
				float3 localAdditionalLightsLambert37_g104 = AdditionalLightsLambert( WorldPosition37_g104 , WorldNormal37_g104 );
				float3 lambertResult38_g104 = localAdditionalLightsLambert37_g104;
				float3 vertexToFrag740 = IN.ase_texcoord10.xyz;
				float3 lightDir738 = vertexToFrag740;
				float3 normalizeResult428 = normalize( ( ase_worldViewDir + lightDir738 ) );
				float dotResult430 = dot( normalizeResult428 , worldNormal30 );
				float smoothnessMask450 = tex2DNode423.g;
				float temp_output_456_0 = ( smoothnessMask450 * _Smoothness );
				float temp_output_512_0 = ( ( temp_output_456_0 - 0.5 ) * 2.0 );
				float lerpResult437 = lerp( 4.0 , 10.0 , temp_output_512_0);
				float3 normalizeResult826 = normalize( max( albedoColor170 , float3( 0.01,0.01,0.01 ) ) );
				float temp_output_530_0 = ( 1.0 - temp_output_528_0 );
				float3 lerpResult526 = lerp( float3( 1,1,1 ) , ( normalizeResult826 * ( _SpecularBrightness + 1.0 ) ) , ( 1.0 - ( temp_output_530_0 * temp_output_530_0 ) ));
				float temp_output_519_0 = ( 1.0 - saturate( ( temp_output_512_0 * -1.0 ) ) );
				float temp_output_520_0 = ( temp_output_519_0 * temp_output_519_0 );
				float3 vertexToFrag751 = IN.ase_texcoord11.xyz;
				float dotResult755 = dot( vertexToFrag751 , ase_worldViewDir );
				float temp_output_761_0 = ( 1.0 - dotResult755 );
				float temp_output_776_0 = ( temp_output_761_0 * temp_output_761_0 );
				float eyeDepth15_g106 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float3 objToWorld2_g106 = mul( GetObjectToWorldMatrix(), float4( IN.ase_texcoord8.xyz, 1 ) ).xyz;
				float3 worldToView13_g106 = mul( UNITY_MATRIX_V, float4( objToWorld2_g106, 1 ) ).xyz;
				float temp_output_596_0 = max( IN.ase_texcoord8.xyz.y , 0.0 );
				float2 uv_WeldingMask = IN.ase_texcoord4.xy * _WeldingMask_ST.xy + _WeldingMask_ST.zw;
				float temp_output_670_0 = max( saturate( ( 1.0 * saturate( ( ( ( ( ( eyeDepth15_g106 / -worldToView13_g106.z ) - 1.0 ) * ( ( _WorldSpaceCameraPos.y - objToWorld2_g106.y ) + 1.0 ) ) / max( _OpaqueBlending , 1E-05 ) ) * ( temp_output_596_0 + 1.0 ) ) ) ) ) , ( 1.0 - SAMPLE_TEXTURE2D( _WeldingMask, sampler_WeldingMask, uv_WeldingMask ).r ) );
				float pushMask804 = ( 1.0 - temp_output_670_0 );
				float smoothstepResult809 = smoothstep( 0.5 , 1.0 , pushMask804);
				float3 appendResult812 = (float3(_FresnelLightColor.rgb));
				float3 baseFresnel745 = ( saturate( ( ( ( temp_output_776_0 * temp_output_776_0 ) * 5.0 ) + ( smoothstepResult809 * 4.0 ) + pushMask804 ) ) * appendResult812 * _FresnelLightColor.a );
				float3 Out_Specular447 = ( ( ( floor( ( pow( max( 0.0 , dotResult430 ) , exp2( lerpResult437 ) ) * 2.0 ) ) * 0.5 ) * ( lerpResult526 * ase_lightAtten * ( temp_output_520_0 * temp_output_520_0 ) ) * ( _SpecularBrightness * _SpecularBrightness ) ) + ( albedoColor170 * baseFresnel745 ) );
				float3 lerpResult560 = lerp( screenColor665 , ( emissionColor173 + lerpResult539 + lambertResult38_g104 + Out_Specular447 ) , temp_output_670_0);
				float3 appendResult845 = (float3(_FlashColor.rgb));
				float vertexToFrag831 = IN.ase_texcoord4.z;
				float temp_output_832_0 = ( max( ( floor( vertexToFrag831 ) * 0.33 ) , 0.125 ) * max( _Flash , 0.0 ) );
				float3 lerpResult830 = lerp( lerpResult560 , ( appendResult845 * temp_output_832_0 ) , temp_output_832_0);
				
				float alpha419 = ( _AlbedoColor.a * tex2DNode137.a );
				
#ifdef DISCARD_FRAGMENT
				float DiscardValue = 1.0;
				float DiscardThreshold = 0;

				if(DiscardValue < DiscardThreshold)discard;
#endif
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = lerpResult830;
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
				gbuffer = float4(0.0, 0.0, 0.0, 0.0);
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
			#define ASE_ABSOLUTE_VERTEX_POS 1
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

			float4 _NormalMap_ST;
			float4 _FlashColor;
			float4 _MetallicGlossMap_ST;
			float4 _EmissionColor;
			float4 _OutlineColor;
			float4 _GoochBrightColor;
			float4 _GoochDarkColor;
			float4 _AlbedoMap_ST;
			float4 _AlbedoColor;
			float4 _WeldingMask_ST;
			float4 _FresnelLightColor;
			float4 _RimBrightColor;
			float3 _CustomLightRotate;
			float _SpecularBrightness;
			float _CustomizeLightAngle;
			float _OpaqueBlending;
			float _OcclusionStrength;
			float _Smoothness;
			float _SRC;
			float _ReflectionIntensity;
			float _NormalMapIntensity;
			float _EmissionxAlbedo;
			float _OutlineAlbedoBlend;
			float _OutlineWidthFadeScale;
			float _OutlineFarWidth;
			float _OutlineNearWidth;
			float _RimLightIntensity;
			float _RimLightOffset;
			float _DST;
			float _Metallic;
			float _Flash;
			CBUFFER_END
			TEXTURE2D(_AlbedoMap);
			SAMPLER(sampler_AlbedoMap);


			
			float3 _LightDirection;

			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float3 OutPosition603 = v.vertex.xyz;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = OutPosition603;
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
				float alpha419 = ( _AlbedoColor.a * tex2DNode137.a );
				
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
			#define ASE_ABSOLUTE_VERTEX_POS 1
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

			float4 _NormalMap_ST;
			float4 _FlashColor;
			float4 _MetallicGlossMap_ST;
			float4 _EmissionColor;
			float4 _OutlineColor;
			float4 _GoochBrightColor;
			float4 _GoochDarkColor;
			float4 _AlbedoMap_ST;
			float4 _AlbedoColor;
			float4 _WeldingMask_ST;
			float4 _FresnelLightColor;
			float4 _RimBrightColor;
			float3 _CustomLightRotate;
			float _SpecularBrightness;
			float _CustomizeLightAngle;
			float _OpaqueBlending;
			float _OcclusionStrength;
			float _Smoothness;
			float _SRC;
			float _ReflectionIntensity;
			float _NormalMapIntensity;
			float _EmissionxAlbedo;
			float _OutlineAlbedoBlend;
			float _OutlineWidthFadeScale;
			float _OutlineFarWidth;
			float _OutlineNearWidth;
			float _RimLightIntensity;
			float _RimLightOffset;
			float _DST;
			float _Metallic;
			float _Flash;
			CBUFFER_END
			TEXTURE2D(_AlbedoMap);
			SAMPLER(sampler_AlbedoMap);


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 OutPosition603 = v.vertex.xyz;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = OutPosition603;
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
				float alpha419 = ( _AlbedoColor.a * tex2DNode137.a );
				
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
			#define ASE_ABSOLUTE_VERTEX_POS 1
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
			#define ASE_NEEDS_VERT_NORMAL
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord3 : TEXCOORD3;
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

			float4 _NormalMap_ST;
			float4 _FlashColor;
			float4 _MetallicGlossMap_ST;
			float4 _EmissionColor;
			float4 _OutlineColor;
			float4 _GoochBrightColor;
			float4 _GoochDarkColor;
			float4 _AlbedoMap_ST;
			float4 _AlbedoColor;
			float4 _WeldingMask_ST;
			float4 _FresnelLightColor;
			float4 _RimBrightColor;
			float3 _CustomLightRotate;
			float _SpecularBrightness;
			float _CustomizeLightAngle;
			float _OpaqueBlending;
			float _OcclusionStrength;
			float _Smoothness;
			float _SRC;
			float _ReflectionIntensity;
			float _NormalMapIntensity;
			float _EmissionxAlbedo;
			float _OutlineAlbedoBlend;
			float _OutlineWidthFadeScale;
			float _OutlineFarWidth;
			float _OutlineNearWidth;
			float _RimLightIntensity;
			float _RimLightOffset;
			float _DST;
			float _Metallic;
			float _Flash;
			CBUFFER_END
			

			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 OutPosition603 = v.vertex.xyz;
				float3 appendResult816 = (float3(v.ase_texcoord3.xyz));
				float3 lerpResult818 = lerp( appendResult816 , v.ase_normal , v.ase_texcoord3.w);
				float3 outlineNormal819 = lerpResult818;
				float3 worldToObj328 = mul( GetWorldToObjectMatrix(), float4( _WorldSpaceCameraPos, 1 ) ).xyz;
				float vertexDist464 = distance( worldToObj328 , float3( 0,0,0 ) );
				float lerpResult477 = lerp( _OutlineNearWidth , _OutlineFarWidth , ( _OutlineWidthFadeScale * vertexDist464 * 0.05 ));
				float3 temp_output_605_0 = ( OutPosition603 + ( outlineNormal819 * 0.001 * min( lerpResult477 , _OutlineFarWidth ) ) );
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = temp_output_605_0;
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
2560;307;2048;1100.6;-276.4575;2933.796;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;466;206,-1458;Inherit;False;918;234;vertex Distance;4;325;328;329;464;Vertex Distance;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;325;256,-1408;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;328;512,-1408;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DistanceOpNode;329;768,-1408;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;169;464,1728;Inherit;False;1319.829;1382.934;Outline and SelectionPass;25;486;129;422;150;126;130;479;477;468;478;467;481;128;469;485;487;488;483;604;605;601;603;820;117;121;Outline and SelectionPass;0.9528302,0.2471965,0.4900168,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;464;896,-1408;Inherit;False;vertexDist;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;815;-217.6689,2039.204;Inherit;False;3;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalVertexDataNode;817;-217.6689,2295.204;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;816;-41.66891,2039.204;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;128;528,2688;Inherit;False;Property;_OutlineWidthFadeScale;Width Fade Scale;20;0;Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;469;528,2816;Inherit;False;464;vertexDist;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;481;528,2880;Inherit;False;Constant;_Float1;Float 1;14;0;Create;True;0;0;0;False;0;False;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;818;166.3311,2167.204;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;478;736,2688;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;467;528,2432;Inherit;False;Property;_OutlineNearWidth;Near Width;18;0;Create;False;0;0;0;False;0;False;25;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;468;528,2560;Inherit;False;Property;_OutlineFarWidth;Far Width;19;0;Create;False;0;0;0;False;0;False;50;30;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;477;784,2432;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;601;1024,2816;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;819;294.3311,2167.204;Inherit;False;outlineNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMinOpNode;479;928,2432;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;603;1280,2816;Inherit;False;OutPosition;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;130;528,2304;Inherit;False;Constant;_05;.05;14;0;Create;True;0;0;0;False;0;False;0.001;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;820;516.881,2177.208;Inherit;False;819;outlineNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;180;-1132.573,-2130.625;Inherit;False;852;721;;11;172;143;179;535;536;538;533;537;539;715;728;It's MK Shader Diffuse;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;418;848,-1840;Inherit;False;216;293;BlendMode;2;415;416;BlendMode;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;810;-5682,-50;Inherit;False;2322;483;Fresnel Light Color;17;745;812;811;805;809;806;783;772;777;751;773;755;778;776;808;761;813;Fresnel Light Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;604;768,1920;Inherit;False;603;OutPosition;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;171;-2482,-2098;Inherit;False;1170;536;Albedo Color;9;134;8;136;137;133;135;170;419;829;Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;129;784,2048;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;448;464,1104;Inherit;False;1315.667;577;Mask;6;451;450;449;424;423;452;Mask;0.5849056,0.5849056,0.5849056,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;410;-2736,-4016;Inherit;False;1558;334;Light;11;401;400;402;399;406;404;407;409;408;405;722;Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;167;-960,-5136;Inherit;False;2145.061;1410.03;Rim Light Color;19;335;313;339;322;324;330;318;334;388;387;386;361;185;338;331;420;465;631;314;Rim Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;41;471,-50;Inherit;False;653;489;Prepare Light Model;9;34;31;40;37;35;38;39;33;36;Prepare Light Model;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;743;-4397.864,1870;Inherit;False;1682;678;Custom Light Angles;9;736;426;734;735;737;738;732;740;822;Custom Light Angles;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;42;467,590;Inherit;False;1297;421;Prepare Normal;8;156;11;10;30;12;635;636;637;Prepare Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;174;-2482,-1458;Inherit;False;1170;536;Emission Color;8;116;102;28;173;460;461;491;492;Emission;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;177;-3312,-560;Inherit;False;2005.798;990.4683;Shadow Color;12;125;97;101;100;98;124;99;178;707;77;724;800;Shadow Color;0,0,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;74;-2480,591;Inherit;False;2176.396;991.9929;Slime;26;747;698;703;701;652;650;651;646;702;697;731;663;662;658;660;661;681;686;685;691;708;801;802;696;799;798;Diffuse;0,0.4626691,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;458;-2482,1870;Inherit;False;2212.703;1168.938;Specular;45;447;746;781;779;434;530;531;437;430;520;532;518;455;456;482;511;441;523;739;519;517;446;711;527;43;716;459;435;428;521;442;528;499;425;427;512;436;526;782;784;823;824;825;826;827;Specular;1,0.8389269,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;94;-960,-64;Inherit;False;961.8428;606.9229;Reflection;8;710;714;712;713;717;725;727;729;Reflection;0.9434034,0.9811321,0.4118904,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;605;1042.637,2009.078;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LightColorNode;399;-2688,-3968;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SmoothstepOpNode;731;-1024,1024;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.1;False;2;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;539;-512,-2048;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;781;-940.4767,2420.13;Inherit;False;2;2;0;FLOAT3;1,0,0;False;1;FLOAT3;0.5,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexToFragmentNode;488;1179.029,1792.013;Inherit;False;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformDirectionNode;691;-1920,640;Inherit;False;World;Object;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.BreakToComponentsNode;388;0,-4864;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.VertexToFragmentNode;387;-256,-4864;Inherit;False;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;606;1792,-2176;Inherit;False;603;OutPosition;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;491;-2176,-1024;Inherit;False;Property;_EmissionxAlbedo;Emission x Albedo;6;1;[Toggle];Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;135;-1920,-2048;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;318;-896,-4736;Inherit;False;Property;_RimLightOffset;RimLightOffset;14;0;Create;True;0;0;0;False;0;False;0.07;0.027;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;697;-1152,896;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;30;1536,640;Inherit;False;worldNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;434;-1408,2048;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;806;-4096,0;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;417;-128,-1920;Inherit;False;SRP Additional Light;-1;;104;6c86746ad131a0a408ca599df5f40861;7,6,1,9,0,23,0,26,0,27,0,24,0,25,0;6;2;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;15;FLOAT3;0,0,0;False;14;FLOAT3;1,1,1;False;18;FLOAT;0.5;False;32;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;745;-3584,0;Inherit;False;baseFresnel;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;29;384,-2048;Inherit;False;4;4;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;97;-2448,-128;Inherit;False;Property;_GoochBrightColor;Shadow Light Color;11;1;[Header];Create;False;1;______Shadow______;0;0;False;1;Space(10);False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;778;-4352,0;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;702;-1920,1280;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;698;-1280,1152;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;829;-1792,-1792;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;586;-256,-2558;Inherit;False;Property;_OpaqueBlending;Opaque Blending;24;0;Create;True;0;0;0;False;0;False;0.1;0.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;681;-2432,640;Inherit;False;HeightDepth;-1;;105;b9577529e1aad6b41b40db01c6b47b7c;0;2;14;FLOAT;0;False;16;FLOAT;20;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;460;-2176,-1280;Inherit;False;452;emissionMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;532;-1671.044,2203.737;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;784;-1152,2688;Inherit;False;361;rimLightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;808;-4480,256;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;650;-1664.043,1150.748;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;409;-1536,-3968;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;427;-2176,1920;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;592;2176,-2048;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;487;768,1792;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.IndirectSpecularLight;710;-512,0;Inherit;False;Tangent;3;0;FLOAT3;0,0,1;False;1;FLOAT;1;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FaceVariableNode;636;1086.566,864.2138;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;324;0,-4608;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SurfaceDepthNode;313;-896,-4352;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;116;-2432,-1408;Inherit;False;Property;_EmissionColor;Emission Color;5;2;[HDR];[Gamma];Create;False;0;0;0;False;0;False;0,0,0,1;0,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;517;-2048,2688;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;800;-2304,-512;Inherit;False;798;diff;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;583;-256,-2688;Inherit;False;HeightDepth;-1;;106;b9577529e1aad6b41b40db01c6b47b7c;0;2;14;FLOAT;0;False;16;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;425;-2432,1920;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;827;-1403.815,1938.892;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;419;-1536,-1792;Inherit;False;alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;755;-5120,0;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;405;-1408,-3840;Inherit;False;LightIntensity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;661;-2048,768;Inherit;False;Object;View;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.OneMinusNode;519;-1792,2560;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;33;768,0;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;37;768,128;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;499;-1152,1920;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;100;-1936,-128;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;8;-1792,-1920;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;594;-256,-2432;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;739;-2432,2176;Inherit;False;738;lightDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexToFragmentNode;652;-1024,832;Inherit;False;False;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;751;-5376,0;Inherit;False;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;441;-768,2048;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;35;896,0;Inherit;False;ndl;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;729;-699.8313,50.35962;Inherit;False;Constant;_Float3;Float 3;29;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;824;-1772.065,2724.793;Inherit;False;170;albedoColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;31;512,0;Inherit;False;30;worldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;426;-4347.864,2304;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;811;-4352,256;Inherit;False;Property;_FresnelLightColor;Fresnel Light Color;16;2;[HDR];[Gamma];Create;True;0;0;0;False;0;False;1,1,1,0.5019608;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;735;-3707.864,1920;Inherit;False;2;2;0;FLOAT3x3;0,0,0,1,1,1,1,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;783;-3968,0;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;736;-4347.864,2432;Inherit;False;Property;_CustomizeLightAngle;Customize Light Angle;28;1;[Toggle];Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;126;512,1792;Inherit;False;Property;_OutlineColor;Outline Color;17;1;[Header];Create;False;1;______Outline______;0;0;False;1;Space(10);False;0,0,0,1;0.1747501,0.1862181,0.1981126,0.8235294;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;10;512,640;Inherit;True;Property;_NormalMap;NormalMap;3;2;[Normal];[SingleLineTexture];Create;True;0;0;0;False;0;False;None;4888bea98fe37ad48892ecb86251d4ce;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleMaxOpNode;823;-1632.71,2795.852;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0.01,0.01,0.01;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;483;512,1984;Inherit;False;170;albedoColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;133;-2432,-2048;Inherit;False;Property;_AlbedoColor;Albedo Color;0;1;[Header];Create;False;1;______Base Preperties______;0;0;False;1;Space(10);False;1,1,1,0.9607843;0.6721698,0.8731278,0.8962264,0.7803922;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;686;-2176,640;Inherit;False;2;2;0;FLOAT;1;False;1;FLOAT;1.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;831;315.1749,-3190.272;Inherit;False;False;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;832;1242.025,-3146.603;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;646;-2176,1024;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;833;598.2748,-3175.972;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;835;21.55207,-3225.062;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;836;791.2745,-3169.972;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0.33;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;837;-1065.516,-3171.708;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;838;-1065.516,-3043.708;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;839;-809.5156,-3171.708;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;840;-681.5157,-3171.708;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;841;-553.5157,-3171.708;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;842;-425.5157,-3171.708;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.01;False;2;FLOAT;0.81;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;843;-169.5157,-3171.708;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;844;-681.5157,-2915.708;Inherit;False;Property;_FlashColor;FlashColor;29;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;845;-169.5157,-3043.708;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;846;1238.484,-2915.708;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;847;-41.51566,-2915.708;Inherit;False;Property;_Flash;Flash;30;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;834;1017.823,-3159.592;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.125;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;776;-4736,0;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;747;-1134.129,706.7294;Inherit;False;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;813;-3712,0;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;430;-1808,1920;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;124;-2192,128;Inherit;False;3;0;COLOR;1,1,1,1;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;179;-1034.135,-1795.006;Inherit;False;178;shadowColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;416;896,-1664;Inherit;False;Property;_DST;Dst;23;1;[Enum];Create;False;0;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;713;-640,128;Inherit;False;3;3;0;FLOAT;0.2;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;442;-1152,2176;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;134;-1664,-2048;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;1,1,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;715;-973.1112,-1972.45;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;334;512,-4864;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;805;-4992,256;Inherit;False;804;pushMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;809;-4736,256;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;665;2304,-2048;Inherit;False;screenColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;727;-256,0;Inherit;False;reflection;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;596;0,-2432;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;404;-1920,-3968;Inherit;False;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TransformPositionNode;660;-1664,640;Inherit;False;Object;View;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;714;-896,0;Inherit;False;30;worldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;777;-4544,0;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;773;-5632,128;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;428;-2048,1920;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;738;-2939.864,1920;Inherit;False;lightDir;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;437;-1792,2048;Inherit;False;3;0;FLOAT;4;False;1;FLOAT;10;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;779;-1152,2432;Inherit;False;170;albedoColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexToFragmentNode;740;-3195.864,1920;Inherit;False;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;98;-2448,128;Inherit;False;Property;_GoochDarkColor;Shadow Dark Color;12;0;Create;False;0;0;0;False;0;False;0.5019608,0.5019608,0.5019608,1;0.510235,0.7236872,0.9245283,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;172;-1104,-2048;Inherit;False;170;albedoColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;737;-3451.864,1920;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;761;-4864,0;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;734;-4091.864,2048;Inherit;False;Constant;_Vector4;Vector 4;30;0;Create;True;0;0;0;False;0;False;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;486;1024,1792;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;485;512,2048;Inherit;False;Property;_OutlineAlbedoBlend;Outline Albedo Blend;21;0;Create;True;0;0;0;False;0;False;0.1;0.222;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;455;-2432,2432;Inherit;False;450;smoothnessMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;101;-1936,0;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;782;-640,2048;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;175;-128,-2176;Inherit;False;173;emissionColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-1664,-1408;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;406;-2048,-3968;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;711;-2304,2688;Inherit;False;smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;669;128,-2304;Inherit;True;Property;_WeldingMask;WeldingMask;25;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;3796605200351144f8f5668d8d48702a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;492;-1920,-1152;Inherit;False;3;0;FLOAT3;1,1,1;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;535;-640,-1536;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;420;-512,-4096;Inherit;False;419;alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;685;-2048,640;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;798;-640,768;Inherit;False;diff;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;422;985.4002,2167.864;Inherit;False;419;alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;549;1920,-2048;Inherit;False;Global;_GrabScreen0;Grab Screen 0;28;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;663;-2432,1152;Inherit;False;Constant;_Vector3;Vector 3;30;0;Create;True;0;0;0;False;0;False;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMaxOpNode;701;-1408,1152;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;637;1187.566,778.2138;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;39;768,256;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;457;0,-1792;Inherit;False;447;Out_Specular;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;728;-1120,-1920;Inherit;False;727;reflection;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;597;128,-2432;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;77;-2304,-384;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;156;1152,640;Inherit;False;URP Tangent To World Normal;-1;;101;e73075222d6e6944aa84a1f1cd458852;0;1;14;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;801;-896,640;Inherit;False;normalVS;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;408;-1408,-3968;Inherit;False;LightColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;402;-2304,-3840;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;440;-1020,1667;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;772;-5632,0;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;533;-1024,-1664;Inherit;False;451;aoMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;560;1536,-2304;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;804;1152,-2048;Inherit;False;pushMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;524;-892,1667;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;512,896;Inherit;False;Property;_NormalMapIntensity;Normal Map Intensity;4;0;Create;False;0;0;0;False;0;False;1;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;450;1152,1280;Inherit;False;smoothnessMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;718;1792,-2432;Inherit;False;Constant;_Float2;Float 2;28;0;Create;True;0;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Exp2OpNode;436;-1584,2056;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;456;-2176,2432;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;591;0,-2558;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1E-05;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;589;256,-2688;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;446;-2432,2048;Inherit;False;30;worldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;423;768,1152;Inherit;True;Property;_TextureSample3;Texture Sample 3;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;102;-1920,-1408;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;716;-2187.591,2843.118;Inherit;False;metallic;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;530;-1792,2304;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;178;-1552,-512;Inherit;False;shadowColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;361;-640,-4992;Inherit;False;rimLightColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;461;-2176,-1152;Inherit;False;170;albedoColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;520;-1662.094,2435.024;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;339;-512,-4352;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;746;-1152,2560;Inherit;False;745;baseFresnel;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;447;-512,2048;Inherit;False;Out_Specular;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;407;-1664,-3968;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleSubtractOpNode;511;-2048,2432;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;724;-2304,-256;Inherit;False;405;LightIntensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;598;384,-2688;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;802;-2432,1024;Inherit;False;801;normalVS;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;712;-896,128;Inherit;False;711;smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;521;-1536,2432;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;803;896,-2048;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;537;-1024,-1537;Inherit;False;Property;_OcclusionStrength;AO;10;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;452;1152,1536;Inherit;False;emissionMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;696;-1664,896;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0.25;False;2;FLOAT;1;False;3;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.RGBToHSVNode;386;-512,-4864;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;538;-768,-1664;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;671;512,-2176;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;725;-896,384;Inherit;False;Property;_ReflectionIntensity;Reflection Intensity;26;0;Create;True;0;0;0;False;0;False;0.2;0.2;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;38;896,128;Inherit;False;ndv;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;639;640,-2688;Inherit;False;2;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;435;-1300.532,2048;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;526;-1435.196,2269.497;Inherit;False;3;0;FLOAT3;1,1,1;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;707;-2048,-512;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;40;896,256;Inherit;False;vdl;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;34;512,128;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;717;-896,256;Inherit;False;716;metallic;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;662;-1408,640;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;338;-128,-4256;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;136;-2432,-1792;Inherit;True;Property;_AlbedoMap;Albedo Map;1;1;[SingleLineTexture];Create;False;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;449;1152,1152;Inherit;False;metallicMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;36;512,256;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;536;-512,-1664;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;11;768,640;Inherit;True;Property;_TextureSample1;Texture Sample 1;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;848;86.48425,-2915.708;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;512;-1920,2432;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;99;-1792,-512;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;451;1152,1408;Inherit;False;aoMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;170;-1536,-2048;Inherit;False;albedoColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;599;284.8612,-2451.589;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;150;784,2304;Inherit;False;Constant;_Float0;Float 0;14;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;322;128,-4608;Inherit;False;False;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;670;640,-2304;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;424;512,1152;Inherit;True;Property;_MetallicGlossMap;Metallic Map;2;1;[SingleLineTexture];Create;False;0;0;0;False;1;Space(15);False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;335;-896,-4224;Inherit;False;Property;_RimLightIntensity;RimLightIntensity;15;0;Create;True;0;0;0;False;0;False;1;3.7;0.001;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;658;-1280,640;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;708;-2432,768;Inherit;False;30;worldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;518;-1920,2688;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;799;-768,896;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;528;-1959,2287;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;143;-768,-2048;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SmoothstepOpNode;703;-1664,1280;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.75;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;421;1792,-2560;Inherit;False;419;alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;722;-2133.691,-3820.764;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;732;-4347.864,1920;Inherit;False;Property;_CustomLightRotate;Custom Light Rotate;27;0;Create;True;0;0;0;False;0;False;55.5,-28.5,0;48.2,-45,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;640;768,-2560;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;590;512,-2560;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;185;-896,-4992;Inherit;False;Property;_RimBrightColor;Rim Color;13;1;[Header];Create;False;1;______Rim Light______;0;0;True;1;Space(10);False;1,1,1,0.5019608;0.9103774,0.9468173,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;415;896,-1792;Inherit;False;Property;_SRC;Src;22;2;[Header];[Enum];Create;False;1;______Blend Mode______;0;1;UnityEngine.Rendering.BlendMode;True;1;Space(15);False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-2432,2560;Inherit;False;Property;_Smoothness;Smoothness;9;0;Create;False;0;0;0;False;0;False;1;0.591;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;459;-1536,2560;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;465;-640,-4608;Inherit;False;464;vertexDist;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;401;-2432,-3840;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;331;0,-4256;Inherit;False;False;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;330;-256,-4480;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;666;1024,-2304;Inherit;False;665;screenColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;400;-2560,-3840;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;531;-1792.177,2201.684;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;523;-2176,2176;Inherit;False;Property;_Metallic;Metallic;8;0;Create;False;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;482;-1664,1920;Inherit;False;Property;_SpecularBrightness;Specular Brightness;7;1;[Header];Create;False;1;Specular Settings;0;0;False;1;Space(10);False;1;1.36;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;830;1704.886,-2309.446;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;825;-1430.065,2732.793;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;527;-2179.19,2305.366;Inherit;False;449;metallicMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;631;611.8576,-4695.894;Inherit;False;603;OutPosition;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SmoothstepOpNode;651;-1920,1152;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.6;False;2;FLOAT;0.95;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;137;-2176,-1792;Inherit;True;Property;_TextureSample0;Texture Sample 0;15;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwitchByFaceNode;635;1396.566,802.2138;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;173;-1536,-1408;Inherit;False;emissionColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;826;-1556.71,2716.852;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;125;-2192,-128;Inherit;False;3;0;COLOR;1,1,1,1;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;439;-1148,1667;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;822;-4091.864,1920;Inherit;False;Transform Euler to RotationMatrix;-1;;102;2cd743ba17aa86741a9126a507ee8fb5;1,12,1;1;5;FLOAT3;0,0,0;False;1;FLOAT3x3;0
Node;AmplifyShaderEditor.DynamicAppendNode;812;-4096,128;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;117;1406.827,1792;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;21;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;ExtraPrePass;0;2;Outline;6;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;True;True;1;1;True;415;0;True;416;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;True;1;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;True;True;True;1;False;-1;255;False;-1;255;False;-1;6;False;-1;1;False;-1;0;False;-1;0;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;1;MRT Output;0;637933691105019490;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;314;768,-4992;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;21;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;AdditionalPass;0;0;ToonPostProcessing;6;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;True;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;1;False;-1;True;3;False;-1;True;False;0;False;-1;0;False;-1;True;1;LightMode=ToonPostProcessing;False;False;0;Hidden/InternalErrorShader;0;0;Standard;1;MRT Output;0;637933887809711874;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;121;1408,2048;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;21;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;SceneSelectionPass;0;6;SceneSelectionPass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=SceneSelectionPass;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;120;512,-640;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;18;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;DepthOnly;0;5;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;122;512,-640;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;18;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;Meta;0;7;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;119;512,-640;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;18;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;ShadowCaster;0;4;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;828;2124.247,-2309.737;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;FullScreenPass;0;1;FullScreenPass;4;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;7;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForwardOnly;True;2;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;118;2124.247,-2309.737;Half;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;21;Treeverse/Dynamic/Toon_Transparent;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;Forward;0;3;Forward;12;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;True;True;False;128;False;-1;255;False;-1;255;False;-1;7;False;-1;3;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=AlphaTest=Queue=51;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;True;True;2;5;True;415;10;True;416;0;5;False;-1;1;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;True;True;True;1;False;-1;255;False;-1;255;False;-1;7;False;-1;3;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;1;False;-1;True;3;False;-1;True;False;0;False;-1;0;False;-1;True;1;LightMode=UniversalForwardOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;18;Surface;1;637934776135466903;  Blend;0;0;Two Sided;1;637944178679130320;Cast Shadows;1;637944232155468822;  Use Shadow Threshold;0;0;Receive Shadows;1;0;GPU Instancing;1;0;LOD CrossFade;0;0;Treeverse Linear Fog;1;637993450525179531;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;1;637931343134552407;Full Screen Pass;0;0;Additional Pass;1;637933691143136380;Scene Selectioin Pass;1;637931343138312560;Vertex Position,InvertActionOnDeselection;0;637944175497281896;Discard Fragment;0;0;Push SelfShadow to Main Light;0;0;2;MRT Output;0;637933854335023384;Custom Output Position;0;0;8;True;False;True;True;True;True;True;False;False;;True;0
WireConnection;328;0;325;0
WireConnection;329;0;328;0
WireConnection;464;0;329;0
WireConnection;816;0;815;0
WireConnection;818;0;816;0
WireConnection;818;1;817;0
WireConnection;818;2;815;4
WireConnection;478;0;128;0
WireConnection;478;1;469;0
WireConnection;478;2;481;0
WireConnection;477;0;467;0
WireConnection;477;1;468;0
WireConnection;477;2;478;0
WireConnection;819;0;818;0
WireConnection;479;0;477;0
WireConnection;479;1;468;0
WireConnection;603;0;601;0
WireConnection;129;0;820;0
WireConnection;129;1;130;0
WireConnection;129;2;479;0
WireConnection;605;0;604;0
WireConnection;605;1;129;0
WireConnection;731;0;697;0
WireConnection;539;1;143;0
WireConnection;539;2;536;0
WireConnection;781;0;779;0
WireConnection;781;1;746;0
WireConnection;488;0;486;0
WireConnection;691;0;685;0
WireConnection;388;0;387;0
WireConnection;387;0;386;0
WireConnection;135;0;133;0
WireConnection;697;0;650;0
WireConnection;697;1;698;0
WireConnection;30;0;635;0
WireConnection;434;1;430;0
WireConnection;806;0;778;0
WireConnection;806;1;808;0
WireConnection;806;2;805;0
WireConnection;745;0;813;0
WireConnection;29;0;175;0
WireConnection;29;1;539;0
WireConnection;29;2;417;0
WireConnection;29;3;457;0
WireConnection;778;0;777;0
WireConnection;702;0;646;0
WireConnection;698;0;701;0
WireConnection;829;0;133;4
WireConnection;829;1;137;4
WireConnection;532;0;531;0
WireConnection;808;0;809;0
WireConnection;650;0;651;0
WireConnection;409;0;407;0
WireConnection;409;1;407;1
WireConnection;409;2;407;2
WireConnection;427;0;425;0
WireConnection;427;1;739;0
WireConnection;592;0;549;0
WireConnection;487;0;126;0
WireConnection;710;0;714;0
WireConnection;710;1;729;0
WireConnection;710;2;713;0
WireConnection;324;0;318;0
WireConnection;324;1;465;0
WireConnection;517;0;512;0
WireConnection;827;0;482;0
WireConnection;419;0;829;0
WireConnection;755;0;751;0
WireConnection;755;1;773;0
WireConnection;405;0;407;3
WireConnection;519;0;518;0
WireConnection;33;0;31;0
WireConnection;33;1;34;0
WireConnection;37;0;31;0
WireConnection;37;1;36;0
WireConnection;499;0;482;0
WireConnection;499;1;482;0
WireConnection;100;0;125;0
WireConnection;8;0;137;0
WireConnection;652;0;697;0
WireConnection;751;0;772;0
WireConnection;441;0;524;0
WireConnection;441;1;442;0
WireConnection;441;2;499;0
WireConnection;35;0;33;0
WireConnection;735;0;822;0
WireConnection;735;1;734;0
WireConnection;783;0;806;0
WireConnection;823;0;824;0
WireConnection;686;0;681;0
WireConnection;831;0;835;0
WireConnection;832;0;834;0
WireConnection;832;1;848;0
WireConnection;646;0;802;0
WireConnection;646;1;663;0
WireConnection;833;0;831;0
WireConnection;835;0;843;0
WireConnection;835;1;843;0
WireConnection;836;0;833;0
WireConnection;839;0;837;0
WireConnection;839;1;838;0
WireConnection;840;1;839;0
WireConnection;841;0;840;0
WireConnection;842;0;841;0
WireConnection;843;0;842;0
WireConnection;845;0;844;0
WireConnection;846;0;845;0
WireConnection;846;1;832;0
WireConnection;834;0;836;0
WireConnection;776;0;761;0
WireConnection;776;1;761;0
WireConnection;747;0;658;0
WireConnection;813;0;783;0
WireConnection;813;1;812;0
WireConnection;813;2;811;4
WireConnection;430;0;428;0
WireConnection;430;1;446;0
WireConnection;124;1;98;0
WireConnection;124;2;98;4
WireConnection;713;0;725;0
WireConnection;713;1;707;0
WireConnection;713;2;717;0
WireConnection;442;0;526;0
WireConnection;442;1;459;0
WireConnection;442;2;521;0
WireConnection;134;0;135;0
WireConnection;134;1;8;0
WireConnection;715;0;172;0
WireConnection;715;1;728;0
WireConnection;334;0;322;0
WireConnection;334;1;331;0
WireConnection;334;2;388;0
WireConnection;809;0;805;0
WireConnection;665;0;592;0
WireConnection;727;0;710;0
WireConnection;596;0;594;2
WireConnection;404;0;406;0
WireConnection;660;0;691;0
WireConnection;777;0;776;0
WireConnection;777;1;776;0
WireConnection;428;0;427;0
WireConnection;738;0;740;0
WireConnection;437;2;512;0
WireConnection;740;0;737;0
WireConnection;737;0;426;0
WireConnection;737;1;735;0
WireConnection;737;2;736;0
WireConnection;761;0;755;0
WireConnection;486;0;487;0
WireConnection;486;1;483;0
WireConnection;486;2;485;0
WireConnection;101;0;124;0
WireConnection;782;0;441;0
WireConnection;782;1;781;0
WireConnection;28;0;102;0
WireConnection;28;1;460;0
WireConnection;28;2;492;0
WireConnection;406;0;399;1
WireConnection;406;3;722;0
WireConnection;711;0;456;0
WireConnection;492;1;461;0
WireConnection;492;2;491;0
WireConnection;535;0;537;0
WireConnection;685;0;686;0
WireConnection;685;1;708;0
WireConnection;798;0;799;0
WireConnection;701;0;696;0
WireConnection;701;1;703;0
WireConnection;637;0;156;0
WireConnection;39;0;34;0
WireConnection;39;1;36;0
WireConnection;597;0;596;0
WireConnection;156;14;11;0
WireConnection;801;0;658;0
WireConnection;408;0;409;0
WireConnection;402;0;401;0
WireConnection;402;1;400;2
WireConnection;440;0;439;0
WireConnection;560;0;666;0
WireConnection;560;1;29;0
WireConnection;560;2;670;0
WireConnection;804;0;803;0
WireConnection;524;0;440;0
WireConnection;450;0;423;2
WireConnection;436;0;437;0
WireConnection;456;0;455;0
WireConnection;456;1;43;0
WireConnection;591;0;586;0
WireConnection;589;0;583;0
WireConnection;589;1;591;0
WireConnection;423;0;424;0
WireConnection;423;7;424;1
WireConnection;102;0;116;0
WireConnection;716;0;528;0
WireConnection;530;0;528;0
WireConnection;178;0;99;0
WireConnection;361;0;185;0
WireConnection;520;0;519;0
WireConnection;520;1;519;0
WireConnection;339;0;313;0
WireConnection;447;0;782;0
WireConnection;407;0;404;0
WireConnection;511;0;456;0
WireConnection;598;0;589;0
WireConnection;598;1;599;0
WireConnection;521;0;520;0
WireConnection;521;1;520;0
WireConnection;803;0;670;0
WireConnection;452;0;423;4
WireConnection;696;0;685;0
WireConnection;386;0;185;0
WireConnection;538;0;533;0
WireConnection;538;1;537;0
WireConnection;671;0;669;1
WireConnection;38;0;37;0
WireConnection;639;1;590;0
WireConnection;435;0;434;0
WireConnection;435;1;436;0
WireConnection;526;1;825;0
WireConnection;526;2;532;0
WireConnection;707;0;800;0
WireConnection;707;1;77;0
WireConnection;707;2;724;0
WireConnection;40;0;39;0
WireConnection;662;0;660;0
WireConnection;662;1;661;0
WireConnection;338;0;330;0
WireConnection;338;1;335;0
WireConnection;338;2;420;0
WireConnection;449;0;423;1
WireConnection;536;0;538;0
WireConnection;536;1;535;0
WireConnection;11;0;10;0
WireConnection;11;5;12;0
WireConnection;11;7;10;1
WireConnection;848;0;847;0
WireConnection;512;0;511;0
WireConnection;99;0;101;0
WireConnection;99;1;100;0
WireConnection;99;2;707;0
WireConnection;451;0;423;3
WireConnection;170;0;134;0
WireConnection;599;0;596;0
WireConnection;322;0;324;0
WireConnection;670;0;640;0
WireConnection;670;1;671;0
WireConnection;658;0;662;0
WireConnection;518;0;517;0
WireConnection;799;0;731;0
WireConnection;799;1;697;0
WireConnection;528;0;523;0
WireConnection;528;1;527;0
WireConnection;143;0;715;0
WireConnection;143;1;179;0
WireConnection;703;0;702;0
WireConnection;722;0;402;0
WireConnection;640;0;639;0
WireConnection;590;0;598;0
WireConnection;401;0;400;0
WireConnection;401;1;400;1
WireConnection;331;0;338;0
WireConnection;330;0;339;0
WireConnection;330;1;465;0
WireConnection;400;0;399;1
WireConnection;531;0;530;0
WireConnection;531;1;530;0
WireConnection;830;0;560;0
WireConnection;830;1;846;0
WireConnection;830;2;832;0
WireConnection;825;0;826;0
WireConnection;825;1;827;0
WireConnection;651;0;646;0
WireConnection;137;0;136;0
WireConnection;137;7;136;1
WireConnection;635;0;156;0
WireConnection;635;1;637;0
WireConnection;173;0;28;0
WireConnection;826;0;823;0
WireConnection;125;1;97;0
WireConnection;125;2;97;4
WireConnection;439;0;435;0
WireConnection;822;5;732;0
WireConnection;812;0;811;0
WireConnection;117;0;488;0
WireConnection;117;1;126;4
WireConnection;117;3;605;0
WireConnection;314;0;334;0
WireConnection;314;1;388;1
WireConnection;314;3;631;0
WireConnection;121;0;150;0
WireConnection;121;3;605;0
WireConnection;118;30;718;0
WireConnection;118;2;830;0
WireConnection;118;3;421;0
WireConnection;118;5;606;0
ASEEND*/
//CHKSM=DE36B63FD04A188EC2BABA9FA8BDCB4353976547
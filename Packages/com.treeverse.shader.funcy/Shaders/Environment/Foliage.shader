// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Treeverse/Static/Environment/Foliage"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[ASEBegin][NoScaleOffset][SingleLineTexture]_ShadingGradientTexture("Color", 2D) = "white" {}
		[HDR][Gamma][NoScaleOffset][SingleLineTexture]_FresnelGradientTexture("Rim Color", 2D) = "white" {}
		_MainTex("MainTex", 2D) = "white" {}
		_BumpMap("BumpMap", 2D) = "white" {}
		[Space(20)][Toggle(DISCARD_FRAGMENT)]_AlphaClipping("AlphaClipping", Float) = 0
		_AlphaCutoff("Alpha Cutoff", Range( 0 , 1)) = 0.001
		_MidCutoff("Mid Cutoff", Range( 0 , 1)) = 0.5
		_NormalMapIntensity("Normal Map Intensity", Float) = 1
		_NormalMapRimIntensity("Normal Map Rim Intensity", Float) = 1
		[Vector2]_RimStep("RimStep", Vector) = (0,0,0,0)
		[Gamma]_RimIntensity("Rim Intensity", Float) = 1
		_VertexAnimationIntensity("Intensity", Float) = 0.05
		_VertexAnimationFrequency("Frequency", Vector) = (2.5,2.5,2.5,0)
		[ASEEnd][Toggle]_DitherMask("DitherMask", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

		
	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
		
		Cull Back
		AlphaToMask Off
		
		HLSLINCLUDE
		#pragma target 2.0

		#pragma prefer_hlslcc gles
		#pragma exclude_renderers d3d11_9x 

		ENDHLSL
		
		Pass
		{
			
			Name "Forward"
			
			Tags { "LightMode"="UniversalForwardOnly" }
			
			Blend Off
			ZWrite On
			ZTest LEqual
			Offset 0,0
			ColorMask RGBA
			

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define DISCARD_FRAGMENT
			#define PUSH_SELFSHADOW_TO_MAIN_LIGHT
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
			#define _ADDITIONAL_LIGHT_SHADOWS 1
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_SHADOWCOORDS
			#define ASE_NEEDS_FRAG_TANGENT
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _SHADOWS_SOFT


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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)

			float4 _MainTex_ST;
			float4 _BumpMap_ST;
			float3 _VertexAnimationFrequency;
			float2 _RimStep;
			float _AlphaClipping;
			float _VertexAnimationIntensity;
			float _DitherMask;
			float _NormalMapIntensity;
			float _MidCutoff;
			float _AlphaCutoff;
			float _NormalMapRimIntensity;
			float _RimIntensity;
			CBUFFER_END
			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);
			float2 _DitherStep;
			TEXTURE2D(_BumpMap);
			SAMPLER(sampler_BumpMap);
			TEXTURE2D(_ShadingGradientTexture);
			SAMPLER(sampler_ShadingGradientTexture);
			TEXTURE2D(_FresnelGradientTexture);
			SAMPLER(sampler_FresnelGradientTexture);


			inline float Dither4x4Bayer( int x, int y )
			{
				const float dither[ 16 ] = {
			 1,  9,  3, 11,
			13,  5, 15,  7,
			 4, 12,  2, 10,
			16,  8, 14,  6 };
				int r = y * 4 + x;
				return dither[r] / 16; // same # of instructions as pre-dividing due to compiler magic
			}
			
			float3 TangentToWorld13_g1( float3 NormalTS, float3x3 TBN )
			{
				float3 NormalWS = TransformTangentToWorld(NormalTS, TBN);
				NormalWS = NormalizeNormalPerPixel(NormalWS);
				return NormalWS;
			}
			
			float3 TangentToWorld13_g2( float3 NormalTS, float3x3 TBN )
			{
				float3 NormalWS = TransformTangentToWorld(NormalTS, TBN);
				NormalWS = NormalizeNormalPerPixel(NormalWS);
				return NormalWS;
			}
			
			
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 appendResult242 = (float3(( ( v.ase_texcoord.xy - float2( 0.5,0.5 ) ) * float2( 4,4 ) ) , 1.0));
				float3 normalizeResult248 = normalize( mul( float4( mul( float4( appendResult242 , 0.0 ), UNITY_MATRIX_V ).xyz , 0.0 ), GetObjectToWorldMatrix() ).xyz );
				float3 vxaFreq490 = _VertexAnimationFrequency;
				float vxaIntensity492 = _VertexAnimationIntensity;
				float3 sineAnimation503 = ( sin( ( ( (v.vertex.xyz).zxx + _TimeParameters.x ) * (vxaFreq490).zyx ) ) * vxaIntensity492 );
				float3 Out_Position339 = ( normalizeResult248 + v.vertex.xyz + sineAnimation503 + ( v.ase_normal * -0.6 ) );
				
				float4 unityObjectToClipPos537 = TransformWorldToHClip(TransformObjectToWorld(Out_Position339));
				float4 computeScreenPos538 = ComputeScreenPos( unityObjectToClipPos537 );
				computeScreenPos538 = computeScreenPos538 / computeScreenPos538.w;
				computeScreenPos538.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? computeScreenPos538.z : computeScreenPos538.z* 0.5 + 0.5;
				float4 vertexToFrag543 = computeScreenPos538;
				o.ase_texcoord4 = vertexToFrag543;
				float2 appendResult519 = (float2(computeScreenPos538.xy));
				float2 appendResult527 = (float2(( ( _ScreenParams.x / _ScreenParams.y ) * 2.0 ) , 2.0));
				float3 customSurfaceDepth535 = Out_Position339;
				float customEye535 = -TransformWorldToView(TransformObjectToWorld( customSurfaceDepth535 )).z;
				float smoothstepResult532 = smoothstep( _DitherStep.x , _DitherStep.y , length( ( ( appendResult519 - float2( 0.5,0.5 ) ) * appendResult527 * ( customEye535 * 0.3 ) ) ));
				float vertexToFrag518 = smoothstepResult532;
				o.ase_texcoord3.z = vertexToFrag518;
				
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord5.xyz = ase_worldTangent;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord6.xyz = ase_worldNormal;
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				o.ase_tangent = v.ase_tangent;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.w = 0;
				o.ase_texcoord5.w = 0;
				o.ase_texcoord6.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = Out_Position339;
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
				float selfShadowPush = 2.0;
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
				float2 uv_MainTex = IN.ase_texcoord3.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode252 = SAMPLE_TEXTURE2D( _MainTex, sampler_MainTex, uv_MainTex );
				float4 vertexToFrag543 = IN.ase_texcoord4;
				float4 ditherCustomScreenPos520 = vertexToFrag543;
				float2 clipScreen520 = ditherCustomScreenPos520.xy * _ScreenParams.xy;
				float dither520 = Dither4x4Bayer( fmod(clipScreen520.x, 4), fmod(clipScreen520.y, 4) );
				float vertexToFrag518 = IN.ase_texcoord3.z;
				float viewDitherMask545 = step( dither520 , vertexToFrag518 );
				float lerpResult547 = lerp( 1.0 , viewDitherMask545 , _DitherMask);
				float Out_Mask450 = ( tex2DNode252.a * lerpResult547 );
				
				float2 uv_BumpMap = IN.ase_texcoord3.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				float4 tex2DNode256 = SAMPLE_TEXTURE2D( _BumpMap, sampler_BumpMap, uv_BumpMap );
				float3 unpack459 = UnpackNormalScale( tex2DNode256, _NormalMapIntensity );
				unpack459.z = lerp( 1, unpack459.z, saturate(_NormalMapIntensity) );
				float3 NormalTS13_g1 = unpack459;
				float3 ase_worldTangent = IN.ase_texcoord5.xyz;
				float3 ase_worldNormal = IN.ase_texcoord6.xyz;
				float3 Binormal5_g1 = ( sign( IN.ase_tangent.w ) * cross( ase_worldNormal , ase_worldTangent ) );
				float3x3 TBN1_g1 = float3x3(ase_worldTangent, Binormal5_g1, ase_worldNormal);
				float3x3 TBN13_g1 = TBN1_g1;
				float3 localTangentToWorld13_g1 = TangentToWorld13_g1( NormalTS13_g1 , TBN13_g1 );
				float3 worldNormal424 = localTangentToWorld13_g1;
				float dotResult367 = dot( worldNormal424 , _MainLightPosition.xyz );
				float ndl410 = dotResult367;
				float smoothstepResult446 = smoothstep( 0.25 , 1.0 , ( 1.0 - abs( ndl410 ) ));
				float out_cutoff330 = ( ( smoothstepResult446 * _MidCutoff ) + _AlphaCutoff );
				
				float ase_lightAtten = 0;
				Light ase_mainLight = GetMainLight( ShadowCoords );
				ase_lightAtten = ase_mainLight.distanceAttenuation * ase_mainLight.shadowAttenuation;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 unpack460 = UnpackNormalScale( tex2DNode256, _NormalMapRimIntensity );
				unpack460.z = lerp( 1, unpack460.z, saturate(_NormalMapRimIntensity) );
				float3 NormalTS13_g2 = unpack460;
				float3 Binormal5_g2 = ( sign( IN.ase_tangent.w ) * cross( ase_worldNormal , ase_worldTangent ) );
				float3x3 TBN1_g2 = float3x3(ase_worldTangent, Binormal5_g2, ase_worldNormal);
				float3x3 TBN13_g2 = TBN1_g2;
				float3 localTangentToWorld13_g2 = TangentToWorld13_g2( NormalTS13_g2 , TBN13_g2 );
				float fresnelNdotV397 = dot( normalize( localTangentToWorld13_g2 ), ase_worldViewDir );
				float fresnelNode397 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV397, 1.0 ) );
				float smoothstepResult405 = smoothstep( _RimStep.x , _RimStep.y , fresnelNode397);
				float temp_output_399_0 = ( smoothstepResult405 * saturate( ndl410 ) );
				float half_ndl372 = ( ( dotResult367 * 0.5 * max( ase_lightAtten , ( 1.0 - temp_output_399_0 ) ) ) + 0.5 );
				float2 appendResult394 = (float2(half_ndl372 , 0.5));
				float3 appendResult395 = (float3(SAMPLE_TEXTURE2D( _ShadingGradientTexture, sampler_ShadingGradientTexture, appendResult394 ).rgb));
				float2 appendResult455 = (float2(temp_output_399_0 , 0.5));
				float3 appendResult456 = (float3(SAMPLE_TEXTURE2D( _FresnelGradientTexture, sampler_FresnelGradientTexture, appendResult455 ).rgb));
				float3 Out_Color427 = ( appendResult395 + ( appendResult456 * _RimIntensity ) );
				
#ifdef DISCARD_FRAGMENT
				float DiscardValue = Out_Mask450;
				float DiscardThreshold = out_cutoff330;

				if(DiscardValue < DiscardThreshold)discard;
#endif
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = Out_Color427;
				float Alpha = 1;
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
			#define DISCARD_FRAGMENT
			#define PUSH_SELFSHADOW_TO_MAIN_LIGHT
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
			#define ASE_NEEDS_VERT_NORMAL


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
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_tangent : TANGENT;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)

			float4 _MainTex_ST;
			float4 _BumpMap_ST;
			float3 _VertexAnimationFrequency;
			float2 _RimStep;
			float _AlphaClipping;
			float _VertexAnimationIntensity;
			float _DitherMask;
			float _NormalMapIntensity;
			float _MidCutoff;
			float _AlphaCutoff;
			float _NormalMapRimIntensity;
			float _RimIntensity;
			CBUFFER_END
			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);
			float2 _DitherStep;
			TEXTURE2D(_BumpMap);
			SAMPLER(sampler_BumpMap);


			inline float Dither4x4Bayer( int x, int y )
			{
				const float dither[ 16 ] = {
			 1,  9,  3, 11,
			13,  5, 15,  7,
			 4, 12,  2, 10,
			16,  8, 14,  6 };
				int r = y * 4 + x;
				return dither[r] / 16; // same # of instructions as pre-dividing due to compiler magic
			}
			
			float3 TangentToWorld13_g1( float3 NormalTS, float3x3 TBN )
			{
				float3 NormalWS = TransformTangentToWorld(NormalTS, TBN);
				NormalWS = NormalizeNormalPerPixel(NormalWS);
				return NormalWS;
			}
			

			float3 _LightDirection;

			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float3 appendResult242 = (float3(( ( v.ase_texcoord.xy - float2( 0.5,0.5 ) ) * float2( 4,4 ) ) , 1.0));
				float3 normalizeResult248 = normalize( mul( float4( mul( float4( appendResult242 , 0.0 ), UNITY_MATRIX_V ).xyz , 0.0 ), GetObjectToWorldMatrix() ).xyz );
				float3 vxaFreq490 = _VertexAnimationFrequency;
				float vxaIntensity492 = _VertexAnimationIntensity;
				float3 sineAnimation503 = ( sin( ( ( (v.vertex.xyz).zxx + _TimeParameters.x ) * (vxaFreq490).zyx ) ) * vxaIntensity492 );
				float3 Out_Position339 = ( normalizeResult248 + v.vertex.xyz + sineAnimation503 + ( v.ase_normal * -0.6 ) );
				
				float4 unityObjectToClipPos537 = TransformWorldToHClip(TransformObjectToWorld(Out_Position339));
				float4 computeScreenPos538 = ComputeScreenPos( unityObjectToClipPos537 );
				computeScreenPos538 = computeScreenPos538 / computeScreenPos538.w;
				computeScreenPos538.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? computeScreenPos538.z : computeScreenPos538.z* 0.5 + 0.5;
				float4 vertexToFrag543 = computeScreenPos538;
				o.ase_texcoord3 = vertexToFrag543;
				float2 appendResult519 = (float2(computeScreenPos538.xy));
				float2 appendResult527 = (float2(( ( _ScreenParams.x / _ScreenParams.y ) * 2.0 ) , 2.0));
				float3 customSurfaceDepth535 = Out_Position339;
				float customEye535 = -TransformWorldToView(TransformObjectToWorld( customSurfaceDepth535 )).z;
				float smoothstepResult532 = smoothstep( _DitherStep.x , _DitherStep.y , length( ( ( appendResult519 - float2( 0.5,0.5 ) ) * appendResult527 * ( customEye535 * 0.3 ) ) ));
				float vertexToFrag518 = smoothstepResult532;
				o.ase_texcoord2.z = vertexToFrag518;
				
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord4.xyz = ase_worldTangent;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord5.xyz = ase_worldNormal;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_tangent = v.ase_tangent;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.w = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = Out_Position339;
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

				float2 uv_MainTex = IN.ase_texcoord2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode252 = SAMPLE_TEXTURE2D( _MainTex, sampler_MainTex, uv_MainTex );
				float4 vertexToFrag543 = IN.ase_texcoord3;
				float4 ditherCustomScreenPos520 = vertexToFrag543;
				float2 clipScreen520 = ditherCustomScreenPos520.xy * _ScreenParams.xy;
				float dither520 = Dither4x4Bayer( fmod(clipScreen520.x, 4), fmod(clipScreen520.y, 4) );
				float vertexToFrag518 = IN.ase_texcoord2.z;
				float viewDitherMask545 = step( dither520 , vertexToFrag518 );
				float lerpResult547 = lerp( 1.0 , viewDitherMask545 , _DitherMask);
				float Out_Mask450 = ( tex2DNode252.a * lerpResult547 );
				
				float2 uv_BumpMap = IN.ase_texcoord2.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				float4 tex2DNode256 = SAMPLE_TEXTURE2D( _BumpMap, sampler_BumpMap, uv_BumpMap );
				float3 unpack459 = UnpackNormalScale( tex2DNode256, _NormalMapIntensity );
				unpack459.z = lerp( 1, unpack459.z, saturate(_NormalMapIntensity) );
				float3 NormalTS13_g1 = unpack459;
				float3 ase_worldTangent = IN.ase_texcoord4.xyz;
				float3 ase_worldNormal = IN.ase_texcoord5.xyz;
				float3 Binormal5_g1 = ( sign( IN.ase_tangent.w ) * cross( ase_worldNormal , ase_worldTangent ) );
				float3x3 TBN1_g1 = float3x3(ase_worldTangent, Binormal5_g1, ase_worldNormal);
				float3x3 TBN13_g1 = TBN1_g1;
				float3 localTangentToWorld13_g1 = TangentToWorld13_g1( NormalTS13_g1 , TBN13_g1 );
				float3 worldNormal424 = localTangentToWorld13_g1;
				float dotResult367 = dot( worldNormal424 , _MainLightPosition.xyz );
				float ndl410 = dotResult367;
				float smoothstepResult446 = smoothstep( 0.25 , 1.0 , ( 1.0 - abs( ndl410 ) ));
				float out_cutoff330 = ( ( smoothstepResult446 * _MidCutoff ) + _AlphaCutoff );
				
#ifdef DISCARD_FRAGMENT
				float DiscardValue = Out_Mask450;
				float DiscardThreshold = out_cutoff330;

				if(DiscardValue < DiscardThreshold)discard;
#endif
				float Alpha = 1;
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
			#define DISCARD_FRAGMENT
			#define PUSH_SELFSHADOW_TO_MAIN_LIGHT
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
			#define ASE_NEEDS_VERT_NORMAL


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
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_tangent : TANGENT;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)

			float4 _MainTex_ST;
			float4 _BumpMap_ST;
			float3 _VertexAnimationFrequency;
			float2 _RimStep;
			float _AlphaClipping;
			float _VertexAnimationIntensity;
			float _DitherMask;
			float _NormalMapIntensity;
			float _MidCutoff;
			float _AlphaCutoff;
			float _NormalMapRimIntensity;
			float _RimIntensity;
			CBUFFER_END
			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);
			float2 _DitherStep;
			TEXTURE2D(_BumpMap);
			SAMPLER(sampler_BumpMap);


			inline float Dither4x4Bayer( int x, int y )
			{
				const float dither[ 16 ] = {
			 1,  9,  3, 11,
			13,  5, 15,  7,
			 4, 12,  2, 10,
			16,  8, 14,  6 };
				int r = y * 4 + x;
				return dither[r] / 16; // same # of instructions as pre-dividing due to compiler magic
			}
			
			float3 TangentToWorld13_g1( float3 NormalTS, float3x3 TBN )
			{
				float3 NormalWS = TransformTangentToWorld(NormalTS, TBN);
				NormalWS = NormalizeNormalPerPixel(NormalWS);
				return NormalWS;
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 appendResult242 = (float3(( ( v.ase_texcoord.xy - float2( 0.5,0.5 ) ) * float2( 4,4 ) ) , 1.0));
				float3 normalizeResult248 = normalize( mul( float4( mul( float4( appendResult242 , 0.0 ), UNITY_MATRIX_V ).xyz , 0.0 ), GetObjectToWorldMatrix() ).xyz );
				float3 vxaFreq490 = _VertexAnimationFrequency;
				float vxaIntensity492 = _VertexAnimationIntensity;
				float3 sineAnimation503 = ( sin( ( ( (v.vertex.xyz).zxx + _TimeParameters.x ) * (vxaFreq490).zyx ) ) * vxaIntensity492 );
				float3 Out_Position339 = ( normalizeResult248 + v.vertex.xyz + sineAnimation503 + ( v.ase_normal * -0.6 ) );
				
				float4 unityObjectToClipPos537 = TransformWorldToHClip(TransformObjectToWorld(Out_Position339));
				float4 computeScreenPos538 = ComputeScreenPos( unityObjectToClipPos537 );
				computeScreenPos538 = computeScreenPos538 / computeScreenPos538.w;
				computeScreenPos538.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? computeScreenPos538.z : computeScreenPos538.z* 0.5 + 0.5;
				float4 vertexToFrag543 = computeScreenPos538;
				o.ase_texcoord3 = vertexToFrag543;
				float2 appendResult519 = (float2(computeScreenPos538.xy));
				float2 appendResult527 = (float2(( ( _ScreenParams.x / _ScreenParams.y ) * 2.0 ) , 2.0));
				float3 customSurfaceDepth535 = Out_Position339;
				float customEye535 = -TransformWorldToView(TransformObjectToWorld( customSurfaceDepth535 )).z;
				float smoothstepResult532 = smoothstep( _DitherStep.x , _DitherStep.y , length( ( ( appendResult519 - float2( 0.5,0.5 ) ) * appendResult527 * ( customEye535 * 0.3 ) ) ));
				float vertexToFrag518 = smoothstepResult532;
				o.ase_texcoord2.z = vertexToFrag518;
				
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord4.xyz = ase_worldTangent;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord5.xyz = ase_worldNormal;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_tangent = v.ase_tangent;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.w = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = Out_Position339;
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

				float2 uv_MainTex = IN.ase_texcoord2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode252 = SAMPLE_TEXTURE2D( _MainTex, sampler_MainTex, uv_MainTex );
				float4 vertexToFrag543 = IN.ase_texcoord3;
				float4 ditherCustomScreenPos520 = vertexToFrag543;
				float2 clipScreen520 = ditherCustomScreenPos520.xy * _ScreenParams.xy;
				float dither520 = Dither4x4Bayer( fmod(clipScreen520.x, 4), fmod(clipScreen520.y, 4) );
				float vertexToFrag518 = IN.ase_texcoord2.z;
				float viewDitherMask545 = step( dither520 , vertexToFrag518 );
				float lerpResult547 = lerp( 1.0 , viewDitherMask545 , _DitherMask);
				float Out_Mask450 = ( tex2DNode252.a * lerpResult547 );
				
				float2 uv_BumpMap = IN.ase_texcoord2.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				float4 tex2DNode256 = SAMPLE_TEXTURE2D( _BumpMap, sampler_BumpMap, uv_BumpMap );
				float3 unpack459 = UnpackNormalScale( tex2DNode256, _NormalMapIntensity );
				unpack459.z = lerp( 1, unpack459.z, saturate(_NormalMapIntensity) );
				float3 NormalTS13_g1 = unpack459;
				float3 ase_worldTangent = IN.ase_texcoord4.xyz;
				float3 ase_worldNormal = IN.ase_texcoord5.xyz;
				float3 Binormal5_g1 = ( sign( IN.ase_tangent.w ) * cross( ase_worldNormal , ase_worldTangent ) );
				float3x3 TBN1_g1 = float3x3(ase_worldTangent, Binormal5_g1, ase_worldNormal);
				float3x3 TBN13_g1 = TBN1_g1;
				float3 localTangentToWorld13_g1 = TangentToWorld13_g1( NormalTS13_g1 , TBN13_g1 );
				float3 worldNormal424 = localTangentToWorld13_g1;
				float dotResult367 = dot( worldNormal424 , _MainLightPosition.xyz );
				float ndl410 = dotResult367;
				float smoothstepResult446 = smoothstep( 0.25 , 1.0 , ( 1.0 - abs( ndl410 ) ));
				float out_cutoff330 = ( ( smoothstepResult446 * _MidCutoff ) + _AlphaCutoff );
				
#ifdef DISCARD_FRAGMENT
				float DiscardValue = Out_Mask450;
				float DiscardThreshold = out_cutoff330;

				if(DiscardValue < DiscardThreshold)discard;
#endif
				float Alpha = 1;
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
			
			Blend Off
			Cull Back
			ZWrite On
			ZTest LEqual
			Offset 0,0
			ColorMask RGBA
			

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define DISCARD_FRAGMENT
			#define PUSH_SELFSHADOW_TO_MAIN_LIGHT
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
				#ifdef ASE_FOG
				float fogFactor : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_tangent : TANGENT;
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)

			float4 _MainTex_ST;
			float4 _BumpMap_ST;
			float3 _VertexAnimationFrequency;
			float2 _RimStep;
			float _AlphaClipping;
			float _VertexAnimationIntensity;
			float _DitherMask;
			float _NormalMapIntensity;
			float _MidCutoff;
			float _AlphaCutoff;
			float _NormalMapRimIntensity;
			float _RimIntensity;
			CBUFFER_END
			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);
			float2 _DitherStep;
			TEXTURE2D(_BumpMap);
			SAMPLER(sampler_BumpMap);


			inline float Dither4x4Bayer( int x, int y )
			{
				const float dither[ 16 ] = {
			 1,  9,  3, 11,
			13,  5, 15,  7,
			 4, 12,  2, 10,
			16,  8, 14,  6 };
				int r = y * 4 + x;
				return dither[r] / 16; // same # of instructions as pre-dividing due to compiler magic
			}
			
			float3 TangentToWorld13_g1( float3 NormalTS, float3x3 TBN )
			{
				float3 NormalWS = TransformTangentToWorld(NormalTS, TBN);
				NormalWS = NormalizeNormalPerPixel(NormalWS);
				return NormalWS;
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 appendResult242 = (float3(( ( v.ase_texcoord.xy - float2( 0.5,0.5 ) ) * float2( 4,4 ) ) , 1.0));
				float3 normalizeResult248 = normalize( mul( float4( mul( float4( appendResult242 , 0.0 ), UNITY_MATRIX_V ).xyz , 0.0 ), GetObjectToWorldMatrix() ).xyz );
				float3 vxaFreq490 = _VertexAnimationFrequency;
				float vxaIntensity492 = _VertexAnimationIntensity;
				float3 sineAnimation503 = ( sin( ( ( (v.vertex.xyz).zxx + _TimeParameters.x ) * (vxaFreq490).zyx ) ) * vxaIntensity492 );
				float3 Out_Position339 = ( normalizeResult248 + v.vertex.xyz + sineAnimation503 + ( v.ase_normal * -0.6 ) );
				
				float4 unityObjectToClipPos537 = TransformWorldToHClip(TransformObjectToWorld(Out_Position339));
				float4 computeScreenPos538 = ComputeScreenPos( unityObjectToClipPos537 );
				computeScreenPos538 = computeScreenPos538 / computeScreenPos538.w;
				computeScreenPos538.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? computeScreenPos538.z : computeScreenPos538.z* 0.5 + 0.5;
				float4 vertexToFrag543 = computeScreenPos538;
				o.ase_texcoord4 = vertexToFrag543;
				float2 appendResult519 = (float2(computeScreenPos538.xy));
				float2 appendResult527 = (float2(( ( _ScreenParams.x / _ScreenParams.y ) * 2.0 ) , 2.0));
				float3 customSurfaceDepth535 = Out_Position339;
				float customEye535 = -TransformWorldToView(TransformObjectToWorld( customSurfaceDepth535 )).z;
				float smoothstepResult532 = smoothstep( _DitherStep.x , _DitherStep.y , length( ( ( appendResult519 - float2( 0.5,0.5 ) ) * appendResult527 * ( customEye535 * 0.3 ) ) ));
				float vertexToFrag518 = smoothstepResult532;
				o.ase_texcoord3.z = vertexToFrag518;
				
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord5.xyz = ase_worldTangent;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord6.xyz = ase_worldNormal;
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				o.ase_tangent = v.ase_tangent;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.w = 0;
				o.ase_texcoord5.w = 0;
				o.ase_texcoord6.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = Out_Position339;
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
				float2 uv_MainTex = IN.ase_texcoord3.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode252 = SAMPLE_TEXTURE2D( _MainTex, sampler_MainTex, uv_MainTex );
				float4 vertexToFrag543 = IN.ase_texcoord4;
				float4 ditherCustomScreenPos520 = vertexToFrag543;
				float2 clipScreen520 = ditherCustomScreenPos520.xy * _ScreenParams.xy;
				float dither520 = Dither4x4Bayer( fmod(clipScreen520.x, 4), fmod(clipScreen520.y, 4) );
				float vertexToFrag518 = IN.ase_texcoord3.z;
				float viewDitherMask545 = step( dither520 , vertexToFrag518 );
				float lerpResult547 = lerp( 1.0 , viewDitherMask545 , _DitherMask);
				float Out_Mask450 = ( tex2DNode252.a * lerpResult547 );
				
				float2 uv_BumpMap = IN.ase_texcoord3.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				float4 tex2DNode256 = SAMPLE_TEXTURE2D( _BumpMap, sampler_BumpMap, uv_BumpMap );
				float3 unpack459 = UnpackNormalScale( tex2DNode256, _NormalMapIntensity );
				unpack459.z = lerp( 1, unpack459.z, saturate(_NormalMapIntensity) );
				float3 NormalTS13_g1 = unpack459;
				float3 ase_worldTangent = IN.ase_texcoord5.xyz;
				float3 ase_worldNormal = IN.ase_texcoord6.xyz;
				float3 Binormal5_g1 = ( sign( IN.ase_tangent.w ) * cross( ase_worldNormal , ase_worldTangent ) );
				float3x3 TBN1_g1 = float3x3(ase_worldTangent, Binormal5_g1, ase_worldNormal);
				float3x3 TBN13_g1 = TBN1_g1;
				float3 localTangentToWorld13_g1 = TangentToWorld13_g1( NormalTS13_g1 , TBN13_g1 );
				float3 worldNormal424 = localTangentToWorld13_g1;
				float dotResult367 = dot( worldNormal424 , _MainLightPosition.xyz );
				float ndl410 = dotResult367;
				float smoothstepResult446 = smoothstep( 0.25 , 1.0 , ( 1.0 - abs( ndl410 ) ));
				float out_cutoff330 = ( ( smoothstepResult446 * _MidCutoff ) + _AlphaCutoff );
				
				float3 temp_cast_1 = (1.0).xxx;
				
#ifdef DISCARD_FRAGMENT
				float DiscardValue = Out_Mask450;
				float DiscardThreshold = out_cutoff330;

				if(DiscardValue < DiscardThreshold)discard;
#endif
				float3 Color = temp_cast_1;
				float Alpha = step( out_cutoff330 , Out_Mask450 );
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

		
		Pass
		{
			
			Name "Meta"
			Tags { "LightMode"="Meta" }

			Cull Off

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define DISCARD_FRAGMENT
			#define PUSH_SELFSHADOW_TO_MAIN_LIGHT
			#define TREEVERSE_LINEAR_FOG
			#define ASE_SRP_VERSION 999999
			#define ASE_USING_SAMPLING_MACROS 1

			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_VERT_NORMAL


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
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
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_tangent : TANGENT;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)

			float4 _MainTex_ST;
			float4 _BumpMap_ST;
			float3 _VertexAnimationFrequency;
			float2 _RimStep;
			float _AlphaClipping;
			float _VertexAnimationIntensity;
			float _DitherMask;
			float _NormalMapIntensity;
			float _MidCutoff;
			float _AlphaCutoff;
			float _NormalMapRimIntensity;
			float _RimIntensity;
			CBUFFER_END
			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);
			float2 _DitherStep;
			TEXTURE2D(_BumpMap);
			SAMPLER(sampler_BumpMap);


			inline float Dither4x4Bayer( int x, int y )
			{
				const float dither[ 16 ] = {
			 1,  9,  3, 11,
			13,  5, 15,  7,
			 4, 12,  2, 10,
			16,  8, 14,  6 };
				int r = y * 4 + x;
				return dither[r] / 16; // same # of instructions as pre-dividing due to compiler magic
			}
			
			float3 TangentToWorld13_g1( float3 NormalTS, float3x3 TBN )
			{
				float3 NormalWS = TransformTangentToWorld(NormalTS, TBN);
				NormalWS = NormalizeNormalPerPixel(NormalWS);
				return NormalWS;
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 appendResult242 = (float3(( ( v.ase_texcoord.xy - float2( 0.5,0.5 ) ) * float2( 4,4 ) ) , 1.0));
				float3 normalizeResult248 = normalize( mul( float4( mul( float4( appendResult242 , 0.0 ), UNITY_MATRIX_V ).xyz , 0.0 ), GetObjectToWorldMatrix() ).xyz );
				float3 vxaFreq490 = _VertexAnimationFrequency;
				float vxaIntensity492 = _VertexAnimationIntensity;
				float3 sineAnimation503 = ( sin( ( ( (v.vertex.xyz).zxx + _TimeParameters.x ) * (vxaFreq490).zyx ) ) * vxaIntensity492 );
				float3 Out_Position339 = ( normalizeResult248 + v.vertex.xyz + sineAnimation503 + ( v.ase_normal * -0.6 ) );
				
				float4 unityObjectToClipPos537 = TransformWorldToHClip(TransformObjectToWorld(Out_Position339));
				float4 computeScreenPos538 = ComputeScreenPos( unityObjectToClipPos537 );
				computeScreenPos538 = computeScreenPos538 / computeScreenPos538.w;
				computeScreenPos538.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? computeScreenPos538.z : computeScreenPos538.z* 0.5 + 0.5;
				float4 vertexToFrag543 = computeScreenPos538;
				o.ase_texcoord3 = vertexToFrag543;
				float2 appendResult519 = (float2(computeScreenPos538.xy));
				float2 appendResult527 = (float2(( ( _ScreenParams.x / _ScreenParams.y ) * 2.0 ) , 2.0));
				float3 customSurfaceDepth535 = Out_Position339;
				float customEye535 = -TransformWorldToView(TransformObjectToWorld( customSurfaceDepth535 )).z;
				float smoothstepResult532 = smoothstep( _DitherStep.x , _DitherStep.y , length( ( ( appendResult519 - float2( 0.5,0.5 ) ) * appendResult527 * ( customEye535 * 0.3 ) ) ));
				float vertexToFrag518 = smoothstepResult532;
				o.ase_texcoord2.z = vertexToFrag518;
				
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord4.xyz = ase_worldTangent;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord5.xyz = ase_worldNormal;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_tangent = v.ase_tangent;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.w = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = Out_Position339;
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

				o.clipPos = MetaVertexPosition( v.vertex, v.texcoord1.xy, v.texcoord1.xy, unity_LightmapST, unity_DynamicLightmapST );
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

				float2 uv_MainTex = IN.ase_texcoord2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode252 = SAMPLE_TEXTURE2D( _MainTex, sampler_MainTex, uv_MainTex );
				float4 vertexToFrag543 = IN.ase_texcoord3;
				float4 ditherCustomScreenPos520 = vertexToFrag543;
				float2 clipScreen520 = ditherCustomScreenPos520.xy * _ScreenParams.xy;
				float dither520 = Dither4x4Bayer( fmod(clipScreen520.x, 4), fmod(clipScreen520.y, 4) );
				float vertexToFrag518 = IN.ase_texcoord2.z;
				float viewDitherMask545 = step( dither520 , vertexToFrag518 );
				float lerpResult547 = lerp( 1.0 , viewDitherMask545 , _DitherMask);
				float Out_Mask450 = ( tex2DNode252.a * lerpResult547 );
				
				float2 uv_BumpMap = IN.ase_texcoord2.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				float4 tex2DNode256 = SAMPLE_TEXTURE2D( _BumpMap, sampler_BumpMap, uv_BumpMap );
				float3 unpack459 = UnpackNormalScale( tex2DNode256, _NormalMapIntensity );
				unpack459.z = lerp( 1, unpack459.z, saturate(_NormalMapIntensity) );
				float3 NormalTS13_g1 = unpack459;
				float3 ase_worldTangent = IN.ase_texcoord4.xyz;
				float3 ase_worldNormal = IN.ase_texcoord5.xyz;
				float3 Binormal5_g1 = ( sign( IN.ase_tangent.w ) * cross( ase_worldNormal , ase_worldTangent ) );
				float3x3 TBN1_g1 = float3x3(ase_worldTangent, Binormal5_g1, ase_worldNormal);
				float3x3 TBN13_g1 = TBN1_g1;
				float3 localTangentToWorld13_g1 = TangentToWorld13_g1( NormalTS13_g1 , TBN13_g1 );
				float3 worldNormal424 = localTangentToWorld13_g1;
				float dotResult367 = dot( worldNormal424 , _MainLightPosition.xyz );
				float ndl410 = dotResult367;
				float smoothstepResult446 = smoothstep( 0.25 , 1.0 , ( 1.0 - abs( ndl410 ) ));
				float out_cutoff330 = ( ( smoothstepResult446 * _MidCutoff ) + _AlphaCutoff );
				
#ifdef DISCARD_FRAGMENT
				float DiscardValue = Out_Mask450;
				float DiscardThreshold = out_cutoff330;

				if(DiscardValue < DiscardThreshold)discard;
#endif
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				MetaInput metaInput = (MetaInput)0;
				metaInput.Albedo = BakedAlbedo;
				metaInput.Emission = BakedEmission;
				
				return MetaFragment(metaInput);
			}
			ENDHLSL
		}
		
	}
	CustomEditorForRenderPipeline "CustomDrawersShaderEditor" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
	CustomEditor "UnityEditor.ShaderGraphUnlitGUI"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=18935
-1913;119;1920;919;3372.144;1094.991;1;True;False
Node;AmplifyShaderEditor.Vector3Node;489;-2560,2176;Inherit;False;Property;_VertexAnimationFrequency;Frequency;12;0;Create;False;0;0;0;False;0;False;2.5,2.5,2.5;0,0,2;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;471;-1968,2000;Inherit;False;1302;490;Sine Animation;11;503;502;501;500;499;498;497;496;495;494;493;Sine Animation;1,1,1,1;0;0
Node;AmplifyShaderEditor.PosVertexDataNode;493;-1920,2048;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;337;-2676.195,721.6871;Inherit;False;1756.275;648.4056;Out_Position;16;339;306;248;247;246;243;244;242;250;249;239;358;504;505;506;507;;0.9529412,0.2470588,0.4901961,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;490;-2304,2176;Inherit;False;vxaFreq;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;494;-1920,2304;Inherit;False;490;vxaFreq;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;239;-2560,772;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;495;-1664,2048;Inherit;False;FLOAT3;2;0;0;3;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleTimeNode;496;-1536,2304;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;497;-1664,2176;Inherit;False;FLOAT3;2;1;0;3;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;491;-2560,2304;Inherit;False;Property;_VertexAnimationIntensity;Intensity;11;0;Create;False;0;0;0;False;0;False;0.05;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;249;-2304,768;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;498;-1408,2048;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;492;-2304,2304;Inherit;False;vxaIntensity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;250;-2176,768;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;4,4;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;499;-1280,2048;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SinOpNode;500;-1152,2048;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewMatrixNode;243;-2048,896;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.GetLocalVarNode;501;-1280,2176;Inherit;False;492;vxaIntensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;242;-2048,768;Inherit;False;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ObjectToWorldMatrixNode;246;-2048,1024;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;244;-1920,768;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;502;-1024,2048;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalVertexDataNode;505;-1664,896;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;247;-1664,768;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;507;-1920,1152;Inherit;False;Constant;_NormalPush;NormalPush;13;0;Create;True;0;0;0;False;0;False;-0.6;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;503;-896,2048;Inherit;False;sineAnimation;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;504;-1664,1280;Inherit;False;503;sineAnimation;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;506;-1472.674,890.832;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;248;-1536,768;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;358;-1664,1024;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;306;-1280,768;Inherit;False;4;4;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;339;-1152,768;Inherit;False;Out_Position;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;544;-5234,-1074;Inherit;False;2141;726;View Dither Mask;20;536;537;538;519;528;543;532;520;518;523;525;526;527;521;522;535;541;534;529;545;View Dither Mask;0.4333334,1,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;278;-1472,-896;Inherit;False;1399.5;523.1;Prepare Normal;8;280;424;319;256;255;439;444;459;Prepare Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;536;-5184,-1024;Inherit;False;339;Out_Position;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;255;-1408,-768;Inherit;True;Property;_BumpMap;BumpMap;3;0;Create;True;0;0;0;False;0;False;None;b6570421264a62d41a3ee5cace7ea42c;True;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;256;-1056,-768;Inherit;True;Property;_TextureSample1;Texture Sample 1;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;0.5;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;280;-1408,-512;Inherit;False;Property;_NormalMapIntensity;Normal Map Intensity;7;0;Create;False;0;0;0;False;0;False;1;2.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenParams;523;-5184,-768;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.UnityObjToClipPosHlpNode;537;-4928,-1024;Inherit;False;1;0;FLOAT3;0,0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComputeScreenPosHlpNode;538;-4672,-1024;Inherit;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.UnpackScaleNormalNode;459;-774.2693,-542.0364;Inherit;False;Tangent;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleDivideOpNode;525;-4928,-768;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SurfaceDepthNode;535;-4928,-640;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;526;-4800,-768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;319;-672,-768;Inherit;False;URP Tangent To World Normal;-1;;1;e73075222d6e6944aa84a1f1cd458852;0;1;14;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;519;-4416,-1024;Inherit;False;FLOAT2;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;541;-4544,-640;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;521;-4352,-768;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;527;-4672,-768;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;424;-368,-768;Inherit;False;worldNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;425;-384,-1408;Inherit;False;424;worldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;522;-4224,-768;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;2,2;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;369;-384,-1280;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;367;-128,-1408;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;528;-4096,-640;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;534;-4480,-512;Inherit;False;Global;_DitherStep;_DitherStep;13;0;Create;True;0;0;0;False;1;Vector2;False;1,10;1,4.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;410;0,-1408;Inherit;False;ndl;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;532;-3968,-640;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.06;False;2;FLOAT;1.09;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;543;-4224,-896;Inherit;False;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;439;-375,-647;Inherit;False;410;ndl;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DitheringNode;520;-3968,-1024;Inherit;False;0;True;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;518;-3840,-768;Inherit;False;False;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;444;-201.3127,-644.3995;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;529;-3584,-896;Inherit;True;2;0;FLOAT;0.35;False;1;FLOAT;0.79;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;545;-3328,-896;Inherit;False;viewDitherMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;445;-82.31274,-645.3995;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;446;44.50598,-593.2891;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.25;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;449;197.4358,-666.3014;Inherit;False;Property;_MidCutoff;Mid Cutoff;6;0;Create;True;0;0;0;False;0;False;0.5;0.867;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;251;-2560,-896;Inherit;True;Property;_MainTex;MainTex;2;0;Create;True;0;0;0;False;0;False;None;90e542d625fd24f47a8d51a00f0998ee;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;546;-2304,-640;Inherit;False;545;viewDitherMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;548;-2304,-512;Inherit;False;Property;_DitherMask;DitherMask;13;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;253;256,-384;Inherit;False;Property;_AlphaCutoff;Alpha Cutoff;5;0;Create;False;0;0;0;False;0;False;0.001;0.001;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;448;515,-538;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.6;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;252;-2304,-896;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;547;-2048,-640;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;441;744.6873,-472.3995;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;533;-1920,-768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;466;-1968,2640;Inherit;False;1818.667;677;Noise Animation;21;488;487;486;485;484;483;482;481;480;479;478;477;476;475;474;473;472;470;469;468;467;Noise Animation;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;450;-1792,-769;Inherit;False;Out_Mask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;330;903,-419;Inherit;False;out_cutoff;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;453;-2048,512;Inherit;True;Property;_FresnelGradientTexture;Rim Color;1;4;[HDR];[Gamma];[NoScaleOffset];[SingleLineTexture];Create;False;0;0;0;True;0;False;None;b17dcaf694e02814f8c8b7c0e48a4ef0;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;380;-212,-995;Inherit;False;Constant;_LightThreshold1;LightThreshold;9;0;Create;False;1;______Toon Properties______;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;405;-2400,384;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;427;-384,256;Inherit;False;Out_Color;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;487;-512,2816;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;477;-1280,3072;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;397;-2688,288;Inherit;True;Standard;WorldNormal;ViewDir;True;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;512;266.2911,-1250.714;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;404;-2592,512;Inherit;False;Property;_RimStep;RimStep;9;0;Create;True;0;0;0;False;1;Vector2;False;0,0;-2.71,2.9;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;457;-789,391;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;451;-256,128;Inherit;False;450;Out_Mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;452;-3505.919,-20.68194;Inherit;False;Property;_NormalMapRimIntensity;Normal Map Rim Intensity;8;0;Create;False;0;0;0;False;0;False;1;100;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;465;-1242.084,435.427;Inherit;False;Property;_RimIntensity;Rim Intensity;10;1;[Gamma];Create;True;0;0;0;False;0;False;1;0.5499999;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;396;-1920,-256;Inherit;False;372;half_ndl;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;329;0,128;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;470;-1664,3072;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;480;-1024,2816;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;472;-1664,2816;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;123456.5;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;462;-2774.737,115.8683;Inherit;False;URP Tangent To World Normal;-1;;2;e73075222d6e6944aa84a1f1cd458852;0;1;14;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;438;-128,-128;Inherit;False;427;Out_Color;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SinOpNode;478;-1280,2816;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;485;-768,3200;Inherit;False;492;vxaIntensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;456;-1034.397,512;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;331;-256,0;Inherit;False;330;out_cutoff;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;479;-1152,2816;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;455;-1920,384;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;467;-1920,3072;Inherit;False;Constant;_Float1;Float 1;13;0;Create;True;0;0;0;False;0;False;123456;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;394;-1408,0;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.UnpackScaleNormalNode;460;-2885.553,-69.96645;Inherit;False;Tangent;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;488;-384,2816;Inherit;False;noiseAnimation;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleTimeNode;481;-1152,2944;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;483;-896,2816;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;392;-1664,128;Inherit;True;Property;_ShadingGradientTexture;Color;0;2;[NoScaleOffset];[SingleLineTexture];Create;False;0;0;0;True;0;False;None;b17dcaf694e02814f8c8b7c0e48a4ef0;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;482;-1152,3200;Inherit;False;490;vxaFreq;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;320;-1792,-896;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;254;256,-288;Inherit;False;Property;_AlphaClipping;AlphaClipping;4;0;Create;False;0;0;0;True;2;Space(20);Toggle(DISCARD_FRAGMENT);False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;399;-2176,384;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;510;-668,-1131;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;516;-687.2762,-994.5416;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;338;0,256;Inherit;False;339;Out_Position;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;372;512,-1408;Inherit;False;half_ndl;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;468;-1920,3200;Inherit;False;Constant;_Float2;Float 2;13;0;Create;True;0;0;0;False;0;False;0.54321;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;469;-1920,2816;Inherit;False;Constant;_REL_LUMA;REL_LUMA;13;0;Create;True;0;0;0;False;0;False;0.2126,0.7152,0.0722;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;411;-2560,640;Inherit;False;410;ndl;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;486;-768,3072;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;474;-1536,3200;Inherit;False;Constant;_Float4;Float 4;13;0;Create;True;0;0;0;False;0;False;0.56789;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;403;-2304,512;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;332;256,512;Inherit;False;Constant;_Float0;Float 0;8;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;473;-1664,2688;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;387;0,-1280;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;391;-1152,128;Inherit;True;Property;_TextureSample2;Texture Sample 2;8;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;475;-1408,2816;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;398;-512,256;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;395;-768,128;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;515;-374.3239,-1108.248;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;484;-640,2816;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;366;88.29997,-213.2;Inherit;False;Constant;_Float3;Float 3;8;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;388;128,-1280;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;454;-1664,512;Inherit;True;Property;_TextureSample3;Texture Sample 3;8;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;476;-1536,3072;Inherit;False;Constant;_Float5;Float 5;13;0;Create;True;0;0;0;False;0;False;987654;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;323;256,-128;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;21;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;ExtraPrePass;0;2;ExtraPrePass;6;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;1;MRT Output;0;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;324;256,-129;Half;False;True;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;21;Treeverse/Static/Environment/Foliage;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;Forward;0;3;Forward;12;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;True;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;0;False;-1;True;0;False;-1;True;False;0;False;-1;0;False;-1;True;1;LightMode=UniversalForwardOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;19;Surface;0;637967549277983458;  Blend;0;0;Two Sided;1;0;Cast Shadows;1;637967531422748399;  Use Shadow Threshold;0;0;Receive Shadows;1;0;GPU Instancing;1;0;LOD CrossFade;0;0;Treeverse Linear Fog;1;637993451862743308;DOTS Instancing;0;0;Meta Pass;1;637969163918093195;Extra Pre Pass;0;0;Full Screen Pass;0;0;Additional Pass;0;0;Scene Selectioin Pass;1;637970163037001921;Vertex Position,InvertActionOnDeselection;0;637967369760135678;Vertex Operation Hide Pass Only;0;0;Discard Fragment;1;637967369769089670;Push SelfShadow to Main Light;1;637989132711727905;2;MRT Output;0;0;Custom Output Position;0;0;8;False;False;False;True;True;True;True;True;False;;True;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;322;256,-128;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;21;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;FullScreenPass;0;1;FullScreenPass;4;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;7;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForwardOnly;True;2;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;328;256,-128;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;21;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;Meta;0;7;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;326;256,-128;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;21;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;DepthOnly;0;5;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;325;256,-128;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;21;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;ShadowCaster;0;4;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;321;256,-128;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;21;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;AdditionalPass;0;0;AdditionalPass;6;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;1;MRT Output;0;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;327;256,256;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;21;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;SceneSelectionPass;0;6;SceneSelectionPass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;True;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;1;False;-1;True;3;False;-1;True;False;0;False;-1;0;False;-1;True;1;LightMode=SceneSelectionPass;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;490;0;489;0
WireConnection;495;0;493;0
WireConnection;497;0;494;0
WireConnection;249;0;239;0
WireConnection;498;0;495;0
WireConnection;498;1;496;0
WireConnection;492;0;491;0
WireConnection;250;0;249;0
WireConnection;499;0;498;0
WireConnection;499;1;497;0
WireConnection;500;0;499;0
WireConnection;242;0;250;0
WireConnection;244;0;242;0
WireConnection;244;1;243;0
WireConnection;502;0;500;0
WireConnection;502;1;501;0
WireConnection;247;0;244;0
WireConnection;247;1;246;0
WireConnection;503;0;502;0
WireConnection;506;0;505;0
WireConnection;506;1;507;0
WireConnection;248;0;247;0
WireConnection;306;0;248;0
WireConnection;306;1;358;0
WireConnection;306;2;504;0
WireConnection;306;3;506;0
WireConnection;339;0;306;0
WireConnection;256;0;255;0
WireConnection;256;7;255;1
WireConnection;537;0;536;0
WireConnection;538;0;537;0
WireConnection;459;0;256;0
WireConnection;459;1;280;0
WireConnection;525;0;523;1
WireConnection;525;1;523;2
WireConnection;535;0;536;0
WireConnection;526;0;525;0
WireConnection;319;14;459;0
WireConnection;519;0;538;0
WireConnection;541;0;535;0
WireConnection;521;0;519;0
WireConnection;527;0;526;0
WireConnection;424;0;319;0
WireConnection;522;0;521;0
WireConnection;522;1;527;0
WireConnection;522;2;541;0
WireConnection;367;0;425;0
WireConnection;367;1;369;0
WireConnection;528;0;522;0
WireConnection;410;0;367;0
WireConnection;532;0;528;0
WireConnection;532;1;534;1
WireConnection;532;2;534;2
WireConnection;543;0;538;0
WireConnection;520;2;543;0
WireConnection;518;0;532;0
WireConnection;444;0;439;0
WireConnection;529;0;520;0
WireConnection;529;1;518;0
WireConnection;545;0;529;0
WireConnection;445;0;444;0
WireConnection;446;0;445;0
WireConnection;448;0;446;0
WireConnection;448;1;449;0
WireConnection;252;0;251;0
WireConnection;547;1;546;0
WireConnection;547;2;548;0
WireConnection;441;0;448;0
WireConnection;441;1;253;0
WireConnection;533;0;252;4
WireConnection;533;1;547;0
WireConnection;450;0;533;0
WireConnection;330;0;441;0
WireConnection;405;0;397;0
WireConnection;405;1;404;1
WireConnection;405;2;404;2
WireConnection;427;0;398;0
WireConnection;487;0;484;0
WireConnection;487;1;486;0
WireConnection;487;2;485;0
WireConnection;477;0;476;0
WireConnection;477;1;474;0
WireConnection;397;0;462;0
WireConnection;457;0;456;0
WireConnection;457;1;465;0
WireConnection;329;0;331;0
WireConnection;329;1;451;0
WireConnection;470;0;467;0
WireConnection;470;1;468;0
WireConnection;480;0;479;0
WireConnection;472;0;469;0
WireConnection;472;1;470;0
WireConnection;462;14;460;0
WireConnection;478;0;475;0
WireConnection;456;0;454;0
WireConnection;479;0;478;0
WireConnection;479;1;477;0
WireConnection;455;0;399;0
WireConnection;394;0;396;0
WireConnection;460;0;256;0
WireConnection;460;1;452;0
WireConnection;488;0;487;0
WireConnection;483;0;480;0
WireConnection;483;1;481;0
WireConnection;483;2;482;0
WireConnection;320;0;252;0
WireConnection;399;0;405;0
WireConnection;399;1;403;0
WireConnection;516;0;399;0
WireConnection;372;0;388;0
WireConnection;403;0;411;0
WireConnection;387;0;367;0
WireConnection;387;2;515;0
WireConnection;391;0;392;0
WireConnection;391;1;394;0
WireConnection;391;7;392;1
WireConnection;475;0;473;0
WireConnection;475;1;472;0
WireConnection;398;0;395;0
WireConnection;398;1;457;0
WireConnection;395;0;391;0
WireConnection;515;0;510;0
WireConnection;515;1;516;0
WireConnection;484;0;483;0
WireConnection;388;0;387;0
WireConnection;388;1;380;0
WireConnection;454;0;453;0
WireConnection;454;1;455;0
WireConnection;454;7;453;1
WireConnection;324;30;366;0
WireConnection;324;21;451;0
WireConnection;324;22;331;0
WireConnection;324;2;438;0
WireConnection;324;5;338;0
WireConnection;327;0;332;0
WireConnection;327;1;329;0
WireConnection;327;3;338;0
ASEEND*/
//CHKSM=7B372C011774CE5D6CDEAF7851C25564E7EB69E0
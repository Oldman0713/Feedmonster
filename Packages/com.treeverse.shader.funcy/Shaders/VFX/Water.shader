// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Treeverse/VFX/Water"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[ASEBegin]_SplashDensity("Splash Density", Float) = 28
		[HDR]_Color("Color", Color) = (2.8,2.8,2.8,0.5019608)
		[NoScaleOffset][SingleLineTexture]_ShadingGradientTexture("Color", 2D) = "white" {}
		_SplashSpeed("Splash Speed", Float) = 4
		[Vector2]_SplashRange("Splash Range", Vector) = (0.7,1.1,0,0)
		[HDR]_SplashColor("Splash Color", Color) = (1,1,1,1)
		_SplashDepth("Splash Depth", Float) = 1.5
		_SplashRefraction("Splash Refraction", Float) = 2
		_WaterDepth("Water Depth", Float) = 1.5
		_SSPRDither("SSPRDither", Float) = 0.05
		[Header(Specular Settings)][Space(10)]_SpecularBrightness("Specular Brightness", Float) = 1
		_NormalDist("NormalDist", Float) = 0
		_Metallic("Metallic", Range( 0 , 1)) = 1
		_Normal("Normal", 2D) = "bump" {}
		_Smoothness("Smoothness", Range( 0 , 1)) = 1
		_SSPRIntensity("SSPR Intensity", Range( 0 , 1)) = 1
		_ReflectionDither("ReflectionDither", 2D) = "black" {}
		_WaterNormalScale("Normal Scale", Float) = 0
		[Toggle]_CustomizeLightAngle("Customize Light Angle", Float) = 0
		[ASEEnd]_CustomSpecularRotate("Custom Specular Rotate", Vector) = (45,-45,0,0)

		
	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
		
		Cull Back
		AlphaToMask Off
		
		HLSLINCLUDE
		#pragma target 3.0

		#pragma prefer_hlslcc gles
		#pragma exclude_renderers d3d11_9x 

		ENDHLSL
		
		Pass
		{
			
			Name "Forward"
			
			Tags { "LightMode"="UniversalForwardOnlyAfterOpaque" }
			
			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
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
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
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
				float4 ase_texcoord6 : TEXCOORD6;
				float4 ase_texcoord7 : TEXCOORD7;
				float4 ase_texcoord8 : TEXCOORD8;
				float4 ase_tangent : TANGENT;
				float4 ase_texcoord9 : TEXCOORD9;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)

			float4 _Normal_ST;
			float4 _SplashColor;
			float4 _ReflectionDither_ST;
			float4 _Color;
			float3 _CustomSpecularRotate;
			float2 _SplashRange;
			float _Smoothness;
			float _CustomizeLightAngle;
			float _SSPRIntensity;
			float _SSPRDither;
			float _SplashRefraction;
			float _SplashDensity;
			float _SplashSpeed;
			float _SplashDepth;
			float _WaterDepth;
			float _NormalDist;
			float _WaterNormalScale;
			float _SpecularBrightness;
			float _Metallic;
			CBUFFER_END
			TEXTURE2D(_Normal);
			SAMPLER(sampler_Normal);
			uniform float4 _CameraDepthTexture_TexelSize;
			TEXTURE2D(_ShadingGradientTexture);
			SAMPLER(sampler_ShadingGradientTexture);
			TEXTURE2D(_MobileSSPR_ColorRT);
			TEXTURE2D(_ReflectionDither);
			SAMPLER(sampler_ReflectionDither);
			SAMPLER(sampler_MobileSSPR_ColorRT);


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
			
			float3 TangentToWorld13_g62( float3 NormalTS, float3x3 TBN )
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

				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float2 appendResult685 = (float2(ase_worldPos.x , ase_worldPos.z));
				float2 vertexToFrag689 = ( ( appendResult685 / _Normal_ST.xy ) + _Normal_ST.zw );
				o.ase_texcoord3.xy = vertexToFrag689;
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord4 = screenPos;
				float3 objToWorld651 = mul( GetObjectToWorldMatrix(), float4( v.vertex.xyz, 1 ) ).xyz;
				float3 worldToView654 = mul( UNITY_MATRIX_V, float4( objToWorld651, 1 ) ).xyz;
				float vertexToFrag659 = -worldToView654.z;
				o.ase_texcoord3.z = vertexToFrag659;
				float vertexToFrag660 = ( _WorldSpaceCameraPos.y - objToWorld651.y );
				o.ase_texcoord3.w = vertexToFrag660;
				float2 appendResult491 = (float2(screenPos.xy));
				float2 vertexToFrag505 = appendResult491;
				o.ase_texcoord5.xy = vertexToFrag505;
				float vertexToFrag503 = screenPos.w;
				o.ase_texcoord5.z = vertexToFrag503;
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_tanViewDir =  tanToWorld0 * ase_worldViewDir.x + tanToWorld1 * ase_worldViewDir.y  + tanToWorld2 * ase_worldViewDir.z;
				ase_tanViewDir = normalize(ase_tanViewDir);
				float3 vertexToFrag484 = ase_tanViewDir;
				o.ase_texcoord6.xyz = vertexToFrag484;
				float3 eulerAngles1_g61 = radians( _CustomSpecularRotate );
				float4 localEuler2Quat1_g61 = Euler2Quat1_g61( eulerAngles1_g61 );
				float4 temp_output_8_0_g60 = localEuler2Quat1_g61;
				float4 _quat11_g60 = temp_output_8_0_g60;
				float3x3 localQuat2RotMatCell11_g60 = Quat2RotMatCell11_g60( _quat11_g60 );
				float3 lerpResult758 = lerp( _MainLightPosition.xyz , mul( localQuat2RotMatCell11_g60, float3(0,0,-1) ) , _CustomizeLightAngle);
				float3 vertexToFrag745 = lerpResult758;
				o.ase_texcoord7.xyz = vertexToFrag745;
				o.ase_texcoord8.xyz = ase_worldTangent;
				o.ase_texcoord9.xyz = ase_worldNormal;
				
				o.ase_tangent = v.ase_tangent;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord5.w = 0;
				o.ase_texcoord6.w = 0;
				o.ase_texcoord7.w = 0;
				o.ase_texcoord8.w = 0;
				o.ase_texcoord9.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
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
				float mulTime678 = _TimeParameters.x * 0.125;
				float2 vertexToFrag689 = IN.ase_texcoord3.xy;
				float2 panner591 = ( ( mulTime678 * 1.0 ) * float2( 0.70707,0.13314 ) + vertexToFrag689);
				float3 unpack582 = UnpackNormalScale( SAMPLE_TEXTURE2D( _Normal, sampler_Normal, panner591 ), _WaterNormalScale );
				unpack582.z = lerp( 1, unpack582.z, saturate(_WaterNormalScale) );
				float3 tex2DNode582 = unpack582;
				float2 appendResult586 = (float2(tex2DNode582.r , tex2DNode582.g));
				float4 screenPos = IN.ase_texcoord4;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float eyeDepth658 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float vertexToFrag659 = IN.ase_texcoord3.z;
				float vertexToFrag660 = IN.ase_texcoord3.w;
				float temp_output_656_0 = ( ( ( eyeDepth658 / vertexToFrag659 ) - 1.0 ) * ( vertexToFrag660 + 0.0 ) );
				float base_HeightDepth604 = temp_output_656_0;
				float waterDepth616 = ( base_HeightDepth604 / _WaterDepth );
				float temp_output_467_0 = ( 1.0 - saturate( ( base_HeightDepth604 / _SplashDepth ) ) );
				float smoothstepResult474 = smoothstep( _SplashRange.x , _SplashRange.y , temp_output_467_0);
				float mulTime420 = _TimeParameters.x * _SplashSpeed;
				float splash480 = saturate( ( smoothstepResult474 * sin( ( ( temp_output_467_0 - ( ( ( mulTime420 + sin( _TimeParameters.x * 0.5 ) ) * 0.5 ) / _SplashDensity ) ) * _SplashDensity ) ) ) );
				float splashMask526 = smoothstepResult474;
				float splash_Alpha698 = ( _SplashColor.a * splash480 * ( 1.0 - splashMask526 ) );
				float2 water_Normal_Refraction714 = ( appendResult586 * ( _NormalDist * 0.1 ) * ( waterDepth616 + splash_Alpha698 ) );
				float2 vertexToFrag505 = IN.ase_texcoord5.xy;
				float vertexToFrag503 = IN.ase_texcoord5.z;
				float screenZ612 = vertexToFrag503;
				float2 viewPoint607 = ( vertexToFrag505 / screenZ612 );
				float3 vertexToFrag484 = IN.ase_texcoord6.xyz;
				float3 ts_viewDir486 = vertexToFrag484;
				float2 Offset487 = ( ( 3.0 - 1 ) * ts_viewDir486.xy * ( splash_Alpha698 * _SplashRefraction ) ) + viewPoint607;
				float2 splash_Refraction711 = Offset487;
				float4 fetchOpaqueVal446 = float4( SHADERGRAPH_SAMPLE_SCENE_COLOR( ( water_Normal_Refraction714 + splash_Refraction711 ) ), 1.0 );
				float3 appendResult447 = (float3(fetchOpaqueVal446.rgb));
				float2 appendResult645 = (float2(waterDepth616 , 0.5));
				float3 appendResult668 = (float3(SAMPLE_TEXTURE2D( _ShadingGradientTexture, sampler_ShadingGradientTexture, appendResult645 ).rgb));
				float3 water_Color667 = appendResult668;
				float3 appendResult442 = (float3(water_Color667));
				float3 appendResult670 = (float3(_Color.rgb));
				float sat_HeightDepth719 = saturate( temp_output_656_0 );
				float3 lerpResult525 = lerp( appendResult447 , ( appendResult442 * appendResult670 ) , ( _Color.a * ( 1.0 - splashMask526 ) * sat_HeightDepth719 ));
				float4 tex2DNode618 = SAMPLE_TEXTURE2D( _ReflectionDither, sampler_ReflectionDither, ( ( viewPoint607 * _ReflectionDither_ST.xy * 1024.0 * ( screenZ612 + 1.0 ) ) + _ReflectionDither_ST.zw ) );
				float sspr_Dither619 = ( ( ( tex2DNode618.r - 0.5 ) * 2.0 ) - ( ( tex2DNode618.a - 0.5 ) * 2.0 ) );
				float temp_output_561_0 = ( _SSPRDither * 0.1 );
				float2 Offset557 = ( ( sspr_Dither619 - 1 ) * float3( 0,2,0 ).xy * temp_output_561_0 ) + viewPoint607;
				float2 Offset572 = ( ( sspr_Dither619 - 1 ) * float3( 1,0,0 ).xy * temp_output_561_0 ) + viewPoint607;
				float2 lerpResult558 = lerp( splash_Refraction711 , ( ( Offset557 + Offset572 ) * float2( 0.5,0.5 ) ) , sspr_Dither619);
				float4 tex2DNode537 = SAMPLE_TEXTURE2D( _MobileSSPR_ColorRT, sampler_MobileSSPR_ColorRT, ( lerpResult558 + water_Normal_Refraction714 ) );
				float3 appendResult538 = (float3(tex2DNode537.rgb));
				float3 ssprColor540 = appendResult538;
				float ssprMask539 = ( tex2DNode537.a * _SSPRIntensity );
				float3 lerpResult541 = lerp( lerpResult525 , ssprColor540 , ( ssprMask539 * _Color.a ));
				float3 appendResult439 = (float3(_SplashColor.rgb));
				float3 splash_Color701 = appendResult439;
				float3 lerpResult697 = lerp( lerpResult541 , splash_Color701 , splash_Alpha698);
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 vertexToFrag745 = IN.ase_texcoord7.xyz;
				float3 lightDir784 = vertexToFrag745;
				float3 normalizeResult780 = normalize( ( ase_worldViewDir + lightDir784 ) );
				float3 appendResult795 = (float3(0.0 , 0.0 , splash_Alpha698));
				float3 NormalTS13_g62 = ( tex2DNode582 + appendResult795 );
				float3 ase_worldTangent = IN.ase_texcoord8.xyz;
				float3 ase_worldNormal = IN.ase_texcoord9.xyz;
				float3 Binormal5_g62 = ( sign( IN.ase_tangent.w ) * cross( ase_worldNormal , ase_worldTangent ) );
				float3x3 TBN1_g62 = float3x3(ase_worldTangent, Binormal5_g62, ase_worldNormal);
				float3x3 TBN13_g62 = TBN1_g62;
				float3 localTangentToWorld13_g62 = TangentToWorld13_g62( NormalTS13_g62 , TBN13_g62 );
				float3 world_Normal727 = localTangentToWorld13_g62;
				float dotResult748 = dot( normalizeResult780 , world_Normal727 );
				float temp_output_742_0 = ( ( _Smoothness - 0.5 ) * 2.0 );
				float lerpResult736 = lerp( 4.0 , 13.0 , temp_output_742_0);
				float3 water_HDR_Color790 = lerpResult525;
				float3 normalizeResult789 = normalize( max( water_HDR_Color790 , float3( 0.01,0.01,0.01 ) ) );
				float temp_output_751_0 = ( 1.0 - _Metallic );
				float3 lerpResult741 = lerp( float3( 1,1,1 ) , ( normalizeResult789 * ( _SpecularBrightness + 1.0 ) ) , ( 1.0 - ( temp_output_751_0 * temp_output_751_0 ) ));
				float temp_output_766_0 = ( 1.0 - saturate( ( temp_output_742_0 * -1.0 ) ) );
				float temp_output_765_0 = ( temp_output_766_0 * temp_output_766_0 );
				float3 Out_Specular737 = ( ( floor( ( pow( max( 0.0 , dotResult748 ) , exp2( lerpResult736 ) ) * 2.0 ) ) * 0.5 ) * ( lerpResult741 * ( temp_output_765_0 * temp_output_765_0 ) * ( 1.0 - splashMask526 ) ) * ( _SpecularBrightness * _SpecularBrightness ) );
				
#ifdef DISCARD_FRAGMENT
				float DiscardValue = 1.0;
				float DiscardThreshold = 0;

				if(DiscardValue < DiscardThreshold)discard;
#endif
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( lerpResult697 + Out_Specular737 );
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

	
	}
	CustomEditorForRenderPipeline "CustomDrawersShaderEditor" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
	CustomEditor "UnityEditor.ShaderGraphUnlitGUI"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=18935
2560;307;1706.667;908.3334;6442.354;3973.131;2.164377;True;False
Node;AmplifyShaderEditor.CommentaryNode;718;-5810,-1586;Inherit;False;1702;746;Height Depth;16;652;651;654;649;653;650;659;658;648;660;655;657;656;604;717;719;Height Depth;1,0.8398737,0.1572326,1;0;0
Node;AmplifyShaderEditor.PosVertexDataNode;652;-5760,-1024;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformPositionNode;651;-5504,-1024;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;654;-5248,-1024;Inherit;False;World;View;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NegateNode;653;-5120,-1152;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;649;-5760,-1280;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ScreenDepthNode;658;-5760,-1536;Inherit;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;659;-4992,-1152;Inherit;False;False;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;650;-5376,-1280;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;660;-5248,-1280;Inherit;False;False;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;648;-4864,-1536;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;655;-4736,-1536;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;657;-4992,-1280;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;656;-4608,-1536;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;479;-3760,-2608;Inherit;False;1796.995;1011.061;Splash;33;478;470;468;469;435;436;474;429;471;477;476;420;475;473;467;466;452;480;526;531;533;534;535;605;693;438;481;508;698;439;694;695;701;Splash;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;473;-3712,-2048;Inherit;False;Property;_SplashSpeed;Splash Speed;3;0;Create;True;0;0;0;False;0;False;4;8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;604;-4352,-1536;Inherit;False;base_HeightDepth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinTimeNode;475;-3712,-2176;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;420;-3456,-2048;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;605;-3712,-2560;Inherit;False;604;base_HeightDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;452;-3712,-2432;Inherit;False;Property;_SplashDepth;Splash Depth;6;0;Create;True;0;0;0;False;0;False;1.5;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;476;-3328,-2176;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;693;-3456,-2560;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;477;-3200,-2176;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;466;-3328,-2560;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;429;-3712,-1920;Inherit;False;Property;_SplashDensity;Splash Density;0;0;Create;True;0;0;0;False;0;False;28;28;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;467;-3200,-2560;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;471;-3072,-2176;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;436;-2944,-2176;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;469;-2816,-2176;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;435;-3712,-1792;Inherit;False;Property;_SplashRange;Splash Range;4;0;Create;True;0;0;0;False;1;Vector2;False;0.7,1.1;0.7,1.1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.CommentaryNode;615;974,-1458;Inherit;False;1170;422;Screen Props;8;612;489;491;505;503;610;504;607;;0.4701851,0.4004984,0.6792453,1;0;0
Node;AmplifyShaderEditor.SinOpNode;468;-2560,-2176;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;489;1024,-1408;Float;False;1;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;474;-2432,-2560;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;683;-5632,-3584;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;470;-2432,-2176;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;491;1280,-1408;Inherit;False;FLOAT2;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VertexToFragmentNode;503;1280,-1280;Inherit;False;False;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureTransformNode;686;-5632,-3456;Inherit;False;582;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;612;1536,-1152;Inherit;False;screenZ;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;505;1408,-1408;Inherit;False;False;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;685;-5376,-3584;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;526;-2176,-2560;Inherit;False;splashMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;478;-2304,-2176;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;687;-5248,-3584;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;504;1792,-1280;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;480;-2176,-2176;Inherit;False;splash;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;694;-3072,-1664;Inherit;False;526;splashMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;594;-5632,-2816;Inherit;False;Property;_WaterDepth;Water Depth;8;0;Create;True;0;0;0;False;0;False;1.5;2.95;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;688;-5120,-3584;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;681;-5632,-3200;Inherit;False;Constant;_WaveSpeed;WaveSpeed;18;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;606;-5632,-2944;Inherit;False;604;base_HeightDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;438;-3072,-2048;Inherit;False;Property;_SplashColor;Splash Color;5;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;0.7843137,2.821203,2.996078,0.7647059;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;678;-5632,-3328;Inherit;False;1;0;FLOAT;0.125;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;614;-3712,-1408;Inherit;False;612;screenZ;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;695;-2896,-1664;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;607;1920,-1280;Inherit;False;viewPoint;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;483;976,-944;Inherit;False;786;238;View Tangent;3;486;485;484;;0.534365,0.764151,0.4289338,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;481;-3072,-1792;Inherit;False;480;splash;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;508;-2816,-1920;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;637;-3712,-1152;Inherit;False;Constant;_1024;1024;15;0;Create;True;0;0;0;False;0;False;1024;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;485;1024,-896;Inherit;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;642;-3456,-1408;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;682;-5376,-3328;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;611;-3712,-1536;Inherit;False;607;viewPoint;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VertexToFragmentNode;689;-4992,-3584;Inherit;False;False;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureTransformNode;625;-3712,-1280;Inherit;False;618;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.SimpleDivideOpNode;692;-5376,-2944;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;677;-4608,-3968;Inherit;False;Property;_WaterNormalScale;Normal Scale;19;0;Create;False;0;0;0;False;0;False;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;616;-5120,-2944;Inherit;False;waterDepth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;484;1280,-896;Inherit;False;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;698;-2560,-1920;Inherit;False;splash_Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;591;-4736,-3584;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.70707,0.13314;False;1;FLOAT;0.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;632;-3328,-1536;Inherit;False;4;4;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;486;1536,-896;Inherit;False;ts_viewDir;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;582;-4352,-3968;Inherit;True;Property;_Normal;Normal;14;0;Create;True;0;0;0;False;0;False;-1;None;9431cebe1a5eedc4ea3d8bf028956c80;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;666;-1152,-3328;Inherit;False;616;waterDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;721;-4480,-3712;Inherit;False;616;waterDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;724;-4480,-3584;Inherit;False;698;splash_Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;733;-2815.8,101.4784;Inherit;False;Property;_CustomSpecularRotate;Custom Specular Rotate;21;0;Create;True;0;0;0;False;0;False;45,-45,0;45,-45,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;731;-2488.873,35.46045;Inherit;False;1682;678;Custom Light Angles;9;784;782;776;774;772;770;758;745;744;Custom Light Angles;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;633;-3200,-1536;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;699;-1808,-384;Inherit;False;698;splash_Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;588;-4608,-4096;Inherit;False;Property;_NormalDist;NormalDist;12;0;Create;True;0;0;0;False;0;False;0;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;510;-1808,-288;Inherit;False;Property;_SplashRefraction;Splash Refraction;7;0;Create;True;0;0;0;False;0;False;2;0.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;643;-1152,-3200;Inherit;True;Property;_ShadingGradientTexture;Color;2;2;[NoScaleOffset];[SingleLineTexture];Create;False;0;0;0;True;0;False;None;523eb3d25ba68df47a4c9b3afa22216c;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;488;-1808,-128;Inherit;False;486;ts_viewDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;618;-3072,-1536;Inherit;True;Property;_ReflectionDither;ReflectionDither;17;0;Create;True;0;0;0;False;0;False;-1;None;6a1fffff897d00e459ab3c9226cbedc6;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RadiansOpNode;772;-2364.8,108.4784;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;723;-4224,-3712;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;609;-1808,-512;Inherit;False;607;viewPoint;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;700;-1552,-384;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;586;-3968,-3968;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;645;-896,-3328;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;589;-4352,-4096;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;644;-768,-3328;Inherit;True;Property;_TextureSample2;Texture Sample 2;8;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;587;-3840,-3968;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0.01;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;782;-2182.9,109.7784;Inherit;False;Transform Euler to RotationMatrix;-1;;60;2cd743ba17aa86741a9126a507ee8fb5;1,12,1;1;5;FLOAT3;0,0,0;False;1;FLOAT3x3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;639;-2688,-1408;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ParallaxMappingNode;487;-1280,-512;Inherit;True;Normal;4;0;FLOAT2;0,0;False;1;FLOAT;3;False;2;FLOAT;1;False;3;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector3Node;744;-2423.873,329.4603;Inherit;False;Constant;_Vector5;Vector 5;30;0;Create;True;0;0;0;False;0;False;0,0,-1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;623;-2688,-1536;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;776;-2438.873,469.4603;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;770;-1852.8,108.4784;Inherit;False;2;2;0;FLOAT3x3;0,0,0,1,1,1,1,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;774;-2438.873,597.4603;Inherit;False;Property;_CustomizeLightAngle;Customize Light Angle;20;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;714;-3584,-3968;Inherit;False;water_Normal_Refraction;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;668;-384,-3328;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;640;-2528,-1408;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;711;-896,-512;Inherit;False;splash_Refraction;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;624;-2528,-1536;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;758;-1535.8,110.4784;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;717;-4480,-1280;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;641;-2304,-1536;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;667;-256,-3328;Inherit;False;water_Color;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;712;-1024,-1152;Inherit;False;711;splash_Refraction;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;716;-1024,-1280;Inherit;False;714;water_Normal_Refraction;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;554;-1920,-1280;Inherit;False;Property;_SSPRDither;SSPRDither;10;0;Create;True;0;0;0;False;0;False;0.05;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;619;-2176,-1536;Inherit;False;sspr_Dither;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;719;-4353,-1280;Inherit;False;sat_HeightDepth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;593;-640,-1280;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;669;-512,-1664;Inherit;False;667;water_Color;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexToFragmentNode;745;-1340.8,108.4784;Inherit;False;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;441;-512,-1536;Inherit;False;Property;_Color;Color;1;1;[HDR];Create;True;0;0;0;False;0;False;2.8,2.8,2.8,0.5019608;1.720795,1.720795,1.720795,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;704;-428.3331,-1361.957;Inherit;False;526;splashMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;795;-4025.544,-3668.542;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;561;-1664,-1280;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;720;-239.0287,-1356.021;Inherit;False;719;sat_HeightDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;608;-1408,-1920;Inherit;False;607;viewPoint;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;621;-1408,-1664;Inherit;False;619;sspr_Dither;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;446;-512,-1280;Inherit;False;Global;_GrabScreen0;Grab Screen 0;28;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;620;-1408,-1792;Inherit;False;619;sspr_Dither;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;707;-173.3331,-1419.957;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;442;-256,-1664;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;670;-256,-1536;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;730;-698.8757,-69.52161;Inherit;False;2250.979;1595.016;Specular;45;783;781;780;779;778;775;771;769;768;766;765;764;762;759;757;756;755;753;752;751;750;748;747;746;742;741;740;739;738;737;736;734;732;416;412;417;415;410;411;414;786;789;791;792;793;Specular;1,0.8389269,0,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;784;-1084.8,108.4784;Inherit;False;lightDir;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;794;-3959.544,-3801.542;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ParallaxMappingNode;557;-1152,-1920;Inherit;True;Normal;4;0;FLOAT2;0,0;False;1;FLOAT;5;False;2;FLOAT;1;False;3;FLOAT3;0,2,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;447;-128,-1280;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;764;-640,1152;Inherit;False;Property;_Smoothness;Smoothness;15;0;Create;False;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;705;-38.33313,-1514.957;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;725;-3813,-3790;Inherit;False;URP Tangent To World Normal;-1;;62;e73075222d6e6944aa84a1f1cd458852;0;1;14;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;671;-128,-1664;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;779;-640,0;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ParallaxMappingNode;572;-1152,-1664;Inherit;True;Normal;4;0;FLOAT2;0,0;False;1;FLOAT;5;False;2;FLOAT;1;False;3;FLOAT3;1,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;762;-640,128;Inherit;False;784;lightDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;573;-768,-1920;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;759;-240,1168;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;775;-188.7998,-19.52161;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;727;-3474,-3794;Inherit;False;world_Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;525;128,-1664;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;780;-60.7998,-19.52161;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;577;-640,-1920;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;790;384,-1664;Inherit;False;water_HDR_Color;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;622;-768,-1792;Inherit;False;619;sspr_Dither;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;769;-256,128;Inherit;False;727;world_Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;713;-768,-2176;Inherit;False;711;splash_Refraction;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;742;-112,1168;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;748;179.2002,-19.52161;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;757;-188.7998,1004.478;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;715;-768,-2304;Inherit;False;714;water_Normal_Refraction;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;755;-640,256;Inherit;False;Property;_Metallic;Metallic;13;0;Create;False;0;0;0;False;0;False;1;0.03;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;791;-640,768;Inherit;False;790;water_HDR_Color;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;558;-512,-2048;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;736;323.2002,748.4784;Inherit;False;3;0;FLOAT;4;False;1;FLOAT;13;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;751;-256,256;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;732;323.2002,-19.52161;Inherit;False;Property;_SpecularBrightness;Specular Brightness;11;1;[Header];Create;False;1;Specular Settings;0;0;False;1;Space(10);False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;786;-384,640;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0.01,0.01,0.01;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;590;-384,-2176;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;740;-60.7998,1004.478;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;753;195.2002,236.4784;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Exp2OpNode;734;451.2002,364.4784;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;536;-894.7657,-2944.418;Inherit;True;Global;_MobileSSPR_ColorRT;_MobileSSPR_ColorRT;9;0;Create;True;0;0;0;False;0;False;None;;False;black;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;602;-709.0391,-2634.708;Inherit;False;Property;_SSPRIntensity;SSPR Intensity;16;0;Create;True;0;0;0;False;0;False;1;0.596;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;746;512,128;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;537;-384,-2944;Inherit;True;Property;_TextureSample1;Texture Sample 1;31;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;781;-93.7998,282.4784;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;766;67.2002,1004.478;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;778;640,256;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;789;-256,640;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;765;323.2002,1004.478;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;601;-195.3713,-2748.058;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;771;67.2002,364.4784;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;752;0,640;Inherit;False;2;2;0;FLOAT3;1,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;792;512,640;Inherit;False;526;splashMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;747;768,256;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;538;2.323427,-2842.725;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FloorOpNode;739;896,256;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;750;451.2002,1004.478;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;741;264.2002,526.4784;Inherit;False;3;0;FLOAT3;1,1,1;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;793;736.7192,710.2529;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;539;-2.323427,-2744.606;Inherit;False;ssprMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;540;193.2675,-2840.078;Inherit;False;ssprColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;543;-384,-1024;Inherit;False;539;ssprMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;738;835.2002,492.4784;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;756;1024,256;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;439;-2816,-2048;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;783;835.2002,-19.52161;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;701;-2560,-2048;Inherit;False;splash_Color;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;544;0,-1152;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;768;1152,256;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;542;128,-1408;Inherit;False;540;ssprColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;737;1347.2,108.4784;Inherit;False;Out_Specular;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;703;128,-1024;Inherit;False;701;splash_Color;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;702;128,-896;Inherit;False;698;splash_Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;541;384,-1408;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;785;382.5831,-738.6058;Inherit;False;737;Out_Specular;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;697;518.4141,-1110.963;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;610;1664,-1408;Inherit;False;screenPosition;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;729;723.0309,-874.3378;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;535;-3456,-2304;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.CosOpNode;533;-3072,-2304;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;534;-3328,-2304;Inherit;False;1;0;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;663;-4096,-3456;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;673;-4736,-3328;Inherit;False;Property;_WaterDepthNormalScale;Normal Scale;18;0;Create;False;0;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;674;-4480,-3456;Inherit;True;Property;_TextureSample0;Texture Sample 0;13;0;Create;True;0;0;0;False;0;False;582;None;None;True;0;False;white;Auto;True;Instance;582;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;603;198.4738,-2211.896;Inherit;False;Constant;_Float0;Float 0;14;0;Create;True;0;0;0;False;0;False;1.200002;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;690;-3824,-3440;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;710;-4201.549,-2668.881;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;531;-2944,-2304;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;709;-4457.549,-2668.881;Inherit;False;604;base_HeightDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;664;-3968,-3456;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;417;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;21;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;Meta;0;7;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;413;1024,-512;Half;False;True;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;21;Treeverse/VFX/Water;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;Forward;0;3;Forward;12;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;1;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForwardOnlyAfterOpaque;False;False;0;Hidden/InternalErrorShader;0;0;Standard;19;Surface;0;0;  Blend;0;0;Two Sided;1;0;Cast Shadows;0;638047780135710820;  Use Shadow Threshold;0;0;Receive Shadows;0;638047870180850040;GPU Instancing;1;0;LOD CrossFade;0;0;Treeverse Linear Fog;0;0;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;0;0;Full Screen Pass;0;0;Additional Pass;0;0;Scene Selectioin Pass;0;0;Vertex Position,InvertActionOnDeselection;1;0;Vertex Operation Hide Pass Only;0;0;Discard Fragment;0;0;Push SelfShadow to Main Light;0;0;2;MRT Output;0;0;Custom Output Position;0;0;8;False;False;False;True;False;False;False;False;False;;True;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;415;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;21;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;DepthOnly;0;5;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;414;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;21;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;ShadowCaster;0;4;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;412;16,-16;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;21;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;ExtraPrePass;0;2;ExtraPrePass;6;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;1;MRT Output;0;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;411;16,-16;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;21;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;FullScreenPass;0;1;FullScreenPass;4;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;7;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForwardOnly;True;2;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;410;16,-16;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;21;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;AdditionalPass;0;0;AdditionalPass;6;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;1;MRT Output;0;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;416;16,-16;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;21;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;SceneSelectionPass;0;6;SceneSelectionPass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=SceneSelectionPass;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;651;0;652;0
WireConnection;654;0;651;0
WireConnection;653;0;654;3
WireConnection;659;0;653;0
WireConnection;650;0;649;2
WireConnection;650;1;651;2
WireConnection;660;0;650;0
WireConnection;648;0;658;0
WireConnection;648;1;659;0
WireConnection;655;0;648;0
WireConnection;657;0;660;0
WireConnection;656;0;655;0
WireConnection;656;1;657;0
WireConnection;604;0;656;0
WireConnection;420;0;473;0
WireConnection;476;0;420;0
WireConnection;476;1;475;3
WireConnection;693;0;605;0
WireConnection;693;1;452;0
WireConnection;477;0;476;0
WireConnection;466;0;693;0
WireConnection;467;0;466;0
WireConnection;471;0;477;0
WireConnection;471;1;429;0
WireConnection;436;0;467;0
WireConnection;436;1;471;0
WireConnection;469;0;436;0
WireConnection;469;1;429;0
WireConnection;468;0;469;0
WireConnection;474;0;467;0
WireConnection;474;1;435;1
WireConnection;474;2;435;2
WireConnection;470;0;474;0
WireConnection;470;1;468;0
WireConnection;491;0;489;0
WireConnection;503;0;489;4
WireConnection;612;0;503;0
WireConnection;505;0;491;0
WireConnection;685;0;683;1
WireConnection;685;1;683;3
WireConnection;526;0;474;0
WireConnection;478;0;470;0
WireConnection;687;0;685;0
WireConnection;687;1;686;0
WireConnection;504;0;505;0
WireConnection;504;1;612;0
WireConnection;480;0;478;0
WireConnection;688;0;687;0
WireConnection;688;1;686;1
WireConnection;695;0;694;0
WireConnection;607;0;504;0
WireConnection;508;0;438;4
WireConnection;508;1;481;0
WireConnection;508;2;695;0
WireConnection;642;0;614;0
WireConnection;682;0;678;0
WireConnection;682;1;681;0
WireConnection;689;0;688;0
WireConnection;692;0;606;0
WireConnection;692;1;594;0
WireConnection;616;0;692;0
WireConnection;484;0;485;0
WireConnection;698;0;508;0
WireConnection;591;0;689;0
WireConnection;591;1;682;0
WireConnection;632;0;611;0
WireConnection;632;1;625;0
WireConnection;632;2;637;0
WireConnection;632;3;642;0
WireConnection;486;0;484;0
WireConnection;582;1;591;0
WireConnection;582;5;677;0
WireConnection;633;0;632;0
WireConnection;633;1;625;1
WireConnection;618;1;633;0
WireConnection;772;0;733;0
WireConnection;723;0;721;0
WireConnection;723;1;724;0
WireConnection;700;0;699;0
WireConnection;700;1;510;0
WireConnection;586;0;582;1
WireConnection;586;1;582;2
WireConnection;645;0;666;0
WireConnection;589;0;588;0
WireConnection;644;0;643;0
WireConnection;644;1;645;0
WireConnection;644;7;643;1
WireConnection;587;0;586;0
WireConnection;587;1;589;0
WireConnection;587;2;723;0
WireConnection;782;5;772;0
WireConnection;639;0;618;1
WireConnection;487;0;609;0
WireConnection;487;2;700;0
WireConnection;487;3;488;0
WireConnection;623;0;618;4
WireConnection;770;0;782;0
WireConnection;770;1;744;0
WireConnection;714;0;587;0
WireConnection;668;0;644;0
WireConnection;640;0;639;0
WireConnection;711;0;487;0
WireConnection;624;0;623;0
WireConnection;758;0;776;0
WireConnection;758;1;770;0
WireConnection;758;2;774;0
WireConnection;717;0;656;0
WireConnection;641;0;640;0
WireConnection;641;1;624;0
WireConnection;667;0;668;0
WireConnection;619;0;641;0
WireConnection;719;0;717;0
WireConnection;593;0;716;0
WireConnection;593;1;712;0
WireConnection;745;0;758;0
WireConnection;795;2;724;0
WireConnection;561;0;554;0
WireConnection;446;0;593;0
WireConnection;707;0;704;0
WireConnection;442;0;669;0
WireConnection;670;0;441;0
WireConnection;784;0;745;0
WireConnection;794;0;582;0
WireConnection;794;1;795;0
WireConnection;557;0;608;0
WireConnection;557;1;620;0
WireConnection;557;2;561;0
WireConnection;447;0;446;0
WireConnection;705;0;441;4
WireConnection;705;1;707;0
WireConnection;705;2;720;0
WireConnection;725;14;794;0
WireConnection;671;0;442;0
WireConnection;671;1;670;0
WireConnection;572;0;608;0
WireConnection;572;1;621;0
WireConnection;572;2;561;0
WireConnection;573;0;557;0
WireConnection;573;1;572;0
WireConnection;759;0;764;0
WireConnection;775;0;779;0
WireConnection;775;1;762;0
WireConnection;727;0;725;0
WireConnection;525;0;447;0
WireConnection;525;1;671;0
WireConnection;525;2;705;0
WireConnection;780;0;775;0
WireConnection;577;0;573;0
WireConnection;790;0;525;0
WireConnection;742;0;759;0
WireConnection;748;0;780;0
WireConnection;748;1;769;0
WireConnection;757;0;742;0
WireConnection;558;0;713;0
WireConnection;558;1;577;0
WireConnection;558;2;622;0
WireConnection;736;2;742;0
WireConnection;751;0;755;0
WireConnection;786;0;791;0
WireConnection;590;0;558;0
WireConnection;590;1;715;0
WireConnection;740;0;757;0
WireConnection;753;1;748;0
WireConnection;734;0;736;0
WireConnection;746;0;732;0
WireConnection;537;0;536;0
WireConnection;537;1;590;0
WireConnection;537;7;536;1
WireConnection;781;0;751;0
WireConnection;781;1;751;0
WireConnection;766;0;740;0
WireConnection;778;0;753;0
WireConnection;778;1;734;0
WireConnection;789;0;786;0
WireConnection;765;0;766;0
WireConnection;765;1;766;0
WireConnection;601;0;537;4
WireConnection;601;1;602;0
WireConnection;771;0;781;0
WireConnection;752;0;789;0
WireConnection;752;1;746;0
WireConnection;747;0;778;0
WireConnection;538;0;537;0
WireConnection;739;0;747;0
WireConnection;750;0;765;0
WireConnection;750;1;765;0
WireConnection;741;1;752;0
WireConnection;741;2;771;0
WireConnection;793;0;792;0
WireConnection;539;0;601;0
WireConnection;540;0;538;0
WireConnection;738;0;741;0
WireConnection;738;1;750;0
WireConnection;738;2;793;0
WireConnection;756;0;739;0
WireConnection;439;0;438;0
WireConnection;783;0;732;0
WireConnection;783;1;732;0
WireConnection;701;0;439;0
WireConnection;544;0;543;0
WireConnection;544;1;441;4
WireConnection;768;0;756;0
WireConnection;768;1;738;0
WireConnection;768;2;783;0
WireConnection;737;0;768;0
WireConnection;541;0;525;0
WireConnection;541;1;542;0
WireConnection;541;2;544;0
WireConnection;697;0;541;0
WireConnection;697;1;703;0
WireConnection;697;2;702;0
WireConnection;610;0;505;0
WireConnection;729;0;697;0
WireConnection;729;1;785;0
WireConnection;535;0;473;0
WireConnection;533;0;534;0
WireConnection;534;0;535;0
WireConnection;663;0;674;1
WireConnection;663;1;674;2
WireConnection;674;1;591;0
WireConnection;674;5;673;0
WireConnection;690;0;664;0
WireConnection;710;0;709;0
WireConnection;531;0;533;0
WireConnection;664;0;663;0
WireConnection;413;2;729;0
ASEEND*/
//CHKSM=ABBEA0FB3DDA3553817C045C8B9C3D307C1D9A56
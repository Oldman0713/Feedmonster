// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Treeverse/Static/Environment/Billboard"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[ASEBegin][NoScaleOffset][SingleLineTexture]_ShadingGradientTexture("Shading Gradient Texture", 2D) = "white" {}
		[NoScaleOffset][SingleLineTexture]Shape_Texture("Shape Texture", 2D) = "white" {}
		[NoScaleOffset][SingleLineTexture]ShapeRimTexture("Shape Rim Texture", 2D) = "black" {}
		Clip_Threshold("[t]Alpha Clip", Range( 0 , 1)) = 0.5
		[Toggle]_USE_FILL_TEXTURE("[s]Use Fill Texture", Float) = 0
		Fill_Impact("[t]Fill Impact", Range( 0 , 1)) = 0.5
		Fill_Scale("[t]Fill Scale", Range( 0 , 5)) = 1
		[NoScaleOffset][SingleLineTexture]Fill_Texture("[t]Fill Texture", 2D) = "black" {}
		Offset_Along_Normal("[s]Offset Along Normal", Float) = 0
		_ShadowStrength("[s]Shadow Strength", Range( 0 , 1)) = 1
		[Toggle]_WIND("[s]Wind", Range( 0 , 1)) = 0
		Wind_Direction("[t]Wind Direction", Vector) = (1,0,0,0)
		Wind_Speed("[t]Wind Speed", Range( 0 , 1)) = 0.1
		Wind_Turbulence("[t]Wind Turbulence", Range( 0 , 5)) = 1
		Wind_Strength("[t]Wind Strength", Range( 0 , 1)) = 0.2
		Billboard_Scale("[s]Billboard Scale", Range( 0 , 1)) = 1
		[Enum(Whole Object,0,Each Face,1)]_BillboardRotation("Billboard Rotation", Float) = 0
		[Toggle]BILLBOARD_FACE_CAMERA_POSITION_ON("Billboard Face Camera Position", Float) = 0
		[HDR]_RimColor("Rim Color", Color) = (0,0,0,1)
		[ASEEnd]_RimLightOffset("RimLightOffset", Range( 0 , 0.1)) = 0.01

		
	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="AlphaTest" }
		
		Cull Off
		AlphaToMask Off
		
		HLSLINCLUDE
		#pragma target 3.0

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
			#define DISCARD_FRAGMENT
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

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define _ADDITIONAL_LIGHT_SHADOWS 1
			#define ASE_NEEDS_FRAG_SHADOWCOORDS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _SHADOWS_SOFT


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
				
				float fogFactor : TEXCOORD2;
				
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)

			float4 _RimColor;
			float3 Wind_Direction;
			float Billboard_Scale;
			float Offset_Along_Normal;
			float BILLBOARD_FACE_CAMERA_POSITION_ON;
			float _BillboardRotation;
			float Wind_Speed;
			float Wind_Turbulence;
			float Wind_Strength;
			float _WIND;
			float Clip_Threshold;
			float Fill_Impact;
			float Fill_Scale;
			float _USE_FILL_TEXTURE;
			float _ShadowStrength;
			float _RimLightOffset;
			CBUFFER_END
			TEXTURE2D(Shape_Texture);
			SAMPLER(sampler_linear_clamp);
			TEXTURE2D(_ShadingGradientTexture);
			TEXTURE2D(Fill_Texture);
			SAMPLER(sampler_linear_repeat);
			SAMPLER(sampler_ShadingGradientTexture);
			TEXTURE2D(ShapeRimTexture);
			SAMPLER(samplerShapeRimTexture);


			float2 UnityGradientNoiseDir( float2 p )
			{
				p = fmod(p , 289);
				float x = fmod((34 * p.x + 1) * p.x , 289) + p.y;
				x = fmod( (34 * x + 1) * x , 289);
				x = frac( x / 41 ) * 2 - 1;
				return normalize( float2(x - floor(x + 0.5 ), abs( x ) - 0.5 ) );
			}
			
			float UnityGradientNoise( float2 UV, float Scale )
			{
				float2 p = UV * Scale;
				float2 ip = floor( p );
				float2 fp = frac( p );
				float d00 = dot( UnityGradientNoiseDir( ip ), fp );
				float d01 = dot( UnityGradientNoiseDir( ip + float2( 0, 1 ) ), fp - float2( 0, 1 ) );
				float d10 = dot( UnityGradientNoiseDir( ip + float2( 1, 0 ) ), fp - float2( 1, 0 ) );
				float d11 = dot( UnityGradientNoiseDir( ip + float2( 1, 1 ) ), fp - float2( 1, 1 ) );
				fp = fp * fp * fp * ( fp * ( fp * 6 - 15 ) + 10 );
				return lerp( lerp( d00, d01, fp.y ), lerp( d10, d11, fp.y ), fp.x ) + 0.5;
			}
			
			
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float billboard_Scale539 = Billboard_Scale;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				float3 objToWorld559 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 world_pivot560 = objToWorld559;
				float3 worldToObjDir491 = normalize( mul( GetWorldToObjectMatrix(), float4( ( world_pivot560 - _WorldSpaceCameraPos ), 0 ) ).xyz );
				float3 temp_output_492_0 = cross( float3( 0,1,0 ) , worldToObjDir491 );
				float3 temp_output_493_0 = cross( worldToObjDir491 , temp_output_492_0 );
				float billboard_Face_Camera_Position529 = BILLBOARD_FACE_CAMERA_POSITION_ON;
				float3 lerpResult531 = lerp( ase_worldNormal , mul( float3x3(temp_output_492_0, temp_output_493_0, worldToObjDir491), ase_worldNormal ) , billboard_Face_Camera_Position529);
				float3 temp_output_533_0 = ( Offset_Along_Normal * lerpResult531 );
				float3 ase_objectScale = float3( length( GetObjectToWorldMatrix()[ 0 ].xyz ), length( GetObjectToWorldMatrix()[ 1 ].xyz ), length( GetObjectToWorldMatrix()[ 2 ].xyz ) );
				float4 appendResult552 = (float4(( temp_output_533_0 + ( v.vertex.xyz * ase_objectScale ) ) , 0.0));
				float3 appendResult557 = (float3(mul( transpose( UNITY_MATRIX_V ), appendResult552 ).xyz));
				float3 worldToObj564 = mul( GetWorldToObjectMatrix(), float4( ( ( billboard_Scale539 * appendResult557 ) + world_pivot560 ), 1 ) ).xyz;
				float3 lerpResult566 = lerp( worldToObj564 , ( billboard_Scale539 * ( mul( v.vertex.xyz, float3x3(temp_output_492_0, temp_output_493_0, worldToObjDir491) ) + temp_output_533_0 ) ) , billboard_Face_Camera_Position529);
				float2 uv0500 = v.ase_texcoord.xy;
				float2 temp_output_504_0 = (float2( -1,-1 ) + (uv0500 - float2( 0,0 )) * (float2( 1,1 ) - float2( -1,-1 )) / (float2( 1,1 ) - float2( 0,0 )));
				float4 appendResult510 = (float4(temp_output_504_0 , 0.0 , 0.0));
				float4 appendResult509 = (float4(temp_output_504_0 , 0.0 , 0.0));
				float4 lerpResult513 = lerp( mul( appendResult510, UNITY_MATRIX_V ) , mul( appendResult509, float4x4(float4( temp_output_492_0 , 0.0 ), float4( temp_output_493_0 , 0.0 ), float4( worldToObjDir491 , 0.0 ), float4( 0,0,0,0 )) ) , billboard_Face_Camera_Position529);
				float3 normalizeResult520 = normalize( ( (mul( lerpResult513, UNITY_MATRIX_M )).xyz * ase_objectScale ) );
				float3 lerpResult569 = lerp( lerpResult566 , ( v.vertex.xyz + temp_output_533_0 + ( normalizeResult520 * billboard_Scale539 ) ) , _BillboardRotation);
				float3 windDirection448 = Wind_Direction;
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float gradientNoise432 = UnityGradientNoise(( ( ( (ase_worldPos).xy + (( ( windDirection448 * float3( 1,0,1 ) ) * ( Wind_Speed * 10.0 ) * _TimeParameters.x )).xy ) * Wind_Turbulence ) * float2( 0.1,0.1 ) ),10.0);
				float windStrength446 = Wind_Strength;
				float windEnabled458 = _WIND;
				float3 Out_WindOffset577 = ( windDirection448 * ( saturate( distance( v.vertex.xyz , float3( 0,0,0 ) ) ) * 0.5 * ( (-1.0 + (gradientNoise432 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) * windStrength446 ) ) * windEnabled458 );
				float3 Out_Position580 = ( lerpResult569 + Out_WindOffset577 );
				
				o.ase_texcoord4.xyz = ase_worldNormal;
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;
				o.ase_texcoord4.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = Out_Position580;
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
				float2 uv0500 = IN.ase_texcoord3.xy;
				float windStrength446 = Wind_Strength;
				float3 windDirection448 = Wind_Direction;
				float gradientNoise432 = UnityGradientNoise(( ( ( (WorldPosition).xy + (( ( windDirection448 * float3( 1,0,1 ) ) * ( Wind_Speed * 10.0 ) * _TimeParameters.x )).xy ) * Wind_Turbulence ) * float2( 0.1,0.1 ) ),10.0);
				float cos435 = cos( ( windStrength446 * gradientNoise432 ) );
				float sin435 = sin( ( windStrength446 * gradientNoise432 ) );
				float2 rotator435 = mul( uv0500 - float2( 0.5,0.5 ) , float2x2( cos435 , -sin435 , sin435 , cos435 )) + float2( 0.5,0.5 );
				float windEnabled458 = _WIND;
				float2 lerpResult439 = lerp( uv0500 , rotator435 , windEnabled458);
				float2 windUV441 = lerpResult439;
				float4 tex2DNode462 = SAMPLE_TEXTURE2D( Shape_Texture, sampler_linear_clamp, windUV441 );
				
				float3 ase_worldNormal = IN.ase_texcoord4.xyz;
				float dotResult641 = dot( ase_worldNormal , _MainLightPosition.xyz );
				float temp_output_597_0 = ( 1.0 - Fill_Impact );
				float lerpResult599 = lerp( temp_output_597_0 , (temp_output_597_0 + (SAMPLE_TEXTURE2D( Fill_Texture, sampler_linear_repeat, ( Fill_Scale * windUV441 ) ).r - 0.0) * (1.0 - temp_output_597_0) / (1.0 - 0.0)) , _USE_FILL_TEXTURE);
				float shadingFactor624 = lerpResult599;
				float temp_output_632_0 = saturate( ( (dotResult641*0.53 + 0.53) * shadingFactor624 ) );
				float2 appendResult600 = (float2(temp_output_632_0 , 0.5));
				float3 appendResult609 = (float3(SAMPLE_TEXTURE2D( _ShadingGradientTexture, sampler_ShadingGradientTexture, appendResult600 ).rgb));
				float ase_lightAtten = 0;
				Light ase_mainLight = GetMainLight( ShadowCoords );
				ase_lightAtten = ase_mainLight.distanceAttenuation * ase_mainLight.shadowAttenuation;
				float lerpResult613 = lerp( 1.0 , ase_lightAtten , _ShadowStrength);
				float3 Out_Color611 = ( appendResult609 * lerpResult613 );
				float3 worldToViewDir654 = mul( UNITY_MATRIX_V, float4( _MainLightPosition.xyz, 0 ) ).xyz;
				float2 normalizeResult658 = normalize( (worldToViewDir654).xy );
				float temp_output_664_0 = ( SAMPLE_TEXTURE2D( ShapeRimTexture, samplerShapeRimTexture, ( windUV441 - ( normalizeResult658 * _RimLightOffset ) ) ).a - tex2DNode462.a );
				float3 appendResult673 = (float3(_RimColor.rgb));
				
#ifdef DISCARD_FRAGMENT
				float DiscardValue = tex2DNode462.a;
				float DiscardThreshold = Clip_Threshold;

				if(DiscardValue < DiscardThreshold)discard;
#endif
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( Out_Color611 + ( Out_Color611 * abs( temp_output_664_0 ) * lerpResult613 * temp_output_632_0 * appendResult673 ) );
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
			#define DISCARD_FRAGMENT
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

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION


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

			float4 _RimColor;
			float3 Wind_Direction;
			float Billboard_Scale;
			float Offset_Along_Normal;
			float BILLBOARD_FACE_CAMERA_POSITION_ON;
			float _BillboardRotation;
			float Wind_Speed;
			float Wind_Turbulence;
			float Wind_Strength;
			float _WIND;
			float Clip_Threshold;
			float Fill_Impact;
			float Fill_Scale;
			float _USE_FILL_TEXTURE;
			float _ShadowStrength;
			float _RimLightOffset;
			CBUFFER_END
			TEXTURE2D(Shape_Texture);
			SAMPLER(sampler_linear_clamp);


			float2 UnityGradientNoiseDir( float2 p )
			{
				p = fmod(p , 289);
				float x = fmod((34 * p.x + 1) * p.x , 289) + p.y;
				x = fmod( (34 * x + 1) * x , 289);
				x = frac( x / 41 ) * 2 - 1;
				return normalize( float2(x - floor(x + 0.5 ), abs( x ) - 0.5 ) );
			}
			
			float UnityGradientNoise( float2 UV, float Scale )
			{
				float2 p = UV * Scale;
				float2 ip = floor( p );
				float2 fp = frac( p );
				float d00 = dot( UnityGradientNoiseDir( ip ), fp );
				float d01 = dot( UnityGradientNoiseDir( ip + float2( 0, 1 ) ), fp - float2( 0, 1 ) );
				float d10 = dot( UnityGradientNoiseDir( ip + float2( 1, 0 ) ), fp - float2( 1, 0 ) );
				float d11 = dot( UnityGradientNoiseDir( ip + float2( 1, 1 ) ), fp - float2( 1, 1 ) );
				fp = fp * fp * fp * ( fp * ( fp * 6 - 15 ) + 10 );
				return lerp( lerp( d00, d01, fp.y ), lerp( d10, d11, fp.y ), fp.x ) + 0.5;
			}
			

			float3 _LightDirection;

			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float billboard_Scale539 = Billboard_Scale;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				float3 objToWorld559 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 world_pivot560 = objToWorld559;
				float3 worldToObjDir491 = normalize( mul( GetWorldToObjectMatrix(), float4( ( world_pivot560 - _WorldSpaceCameraPos ), 0 ) ).xyz );
				float3 temp_output_492_0 = cross( float3( 0,1,0 ) , worldToObjDir491 );
				float3 temp_output_493_0 = cross( worldToObjDir491 , temp_output_492_0 );
				float billboard_Face_Camera_Position529 = BILLBOARD_FACE_CAMERA_POSITION_ON;
				float3 lerpResult531 = lerp( ase_worldNormal , mul( float3x3(temp_output_492_0, temp_output_493_0, worldToObjDir491), ase_worldNormal ) , billboard_Face_Camera_Position529);
				float3 temp_output_533_0 = ( Offset_Along_Normal * lerpResult531 );
				float3 ase_objectScale = float3( length( GetObjectToWorldMatrix()[ 0 ].xyz ), length( GetObjectToWorldMatrix()[ 1 ].xyz ), length( GetObjectToWorldMatrix()[ 2 ].xyz ) );
				float4 appendResult552 = (float4(( temp_output_533_0 + ( v.vertex.xyz * ase_objectScale ) ) , 0.0));
				float3 appendResult557 = (float3(mul( transpose( UNITY_MATRIX_V ), appendResult552 ).xyz));
				float3 worldToObj564 = mul( GetWorldToObjectMatrix(), float4( ( ( billboard_Scale539 * appendResult557 ) + world_pivot560 ), 1 ) ).xyz;
				float3 lerpResult566 = lerp( worldToObj564 , ( billboard_Scale539 * ( mul( v.vertex.xyz, float3x3(temp_output_492_0, temp_output_493_0, worldToObjDir491) ) + temp_output_533_0 ) ) , billboard_Face_Camera_Position529);
				float2 uv0500 = v.ase_texcoord.xy;
				float2 temp_output_504_0 = (float2( -1,-1 ) + (uv0500 - float2( 0,0 )) * (float2( 1,1 ) - float2( -1,-1 )) / (float2( 1,1 ) - float2( 0,0 )));
				float4 appendResult510 = (float4(temp_output_504_0 , 0.0 , 0.0));
				float4 appendResult509 = (float4(temp_output_504_0 , 0.0 , 0.0));
				float4 lerpResult513 = lerp( mul( appendResult510, UNITY_MATRIX_V ) , mul( appendResult509, float4x4(float4( temp_output_492_0 , 0.0 ), float4( temp_output_493_0 , 0.0 ), float4( worldToObjDir491 , 0.0 ), float4( 0,0,0,0 )) ) , billboard_Face_Camera_Position529);
				float3 normalizeResult520 = normalize( ( (mul( lerpResult513, UNITY_MATRIX_M )).xyz * ase_objectScale ) );
				float3 lerpResult569 = lerp( lerpResult566 , ( v.vertex.xyz + temp_output_533_0 + ( normalizeResult520 * billboard_Scale539 ) ) , _BillboardRotation);
				float3 windDirection448 = Wind_Direction;
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float gradientNoise432 = UnityGradientNoise(( ( ( (ase_worldPos).xy + (( ( windDirection448 * float3( 1,0,1 ) ) * ( Wind_Speed * 10.0 ) * _TimeParameters.x )).xy ) * Wind_Turbulence ) * float2( 0.1,0.1 ) ),10.0);
				float windStrength446 = Wind_Strength;
				float windEnabled458 = _WIND;
				float3 Out_WindOffset577 = ( windDirection448 * ( saturate( distance( v.vertex.xyz , float3( 0,0,0 ) ) ) * 0.5 * ( (-1.0 + (gradientNoise432 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) * windStrength446 ) ) * windEnabled458 );
				float3 Out_Position580 = ( lerpResult569 + Out_WindOffset577 );
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = Out_Position580;
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

				float2 uv0500 = IN.ase_texcoord2.xy;
				float windStrength446 = Wind_Strength;
				float3 windDirection448 = Wind_Direction;
				float gradientNoise432 = UnityGradientNoise(( ( ( (WorldPosition).xy + (( ( windDirection448 * float3( 1,0,1 ) ) * ( Wind_Speed * 10.0 ) * _TimeParameters.x )).xy ) * Wind_Turbulence ) * float2( 0.1,0.1 ) ),10.0);
				float cos435 = cos( ( windStrength446 * gradientNoise432 ) );
				float sin435 = sin( ( windStrength446 * gradientNoise432 ) );
				float2 rotator435 = mul( uv0500 - float2( 0.5,0.5 ) , float2x2( cos435 , -sin435 , sin435 , cos435 )) + float2( 0.5,0.5 );
				float windEnabled458 = _WIND;
				float2 lerpResult439 = lerp( uv0500 , rotator435 , windEnabled458);
				float2 windUV441 = lerpResult439;
				float4 tex2DNode462 = SAMPLE_TEXTURE2D( Shape_Texture, sampler_linear_clamp, windUV441 );
				
#ifdef DISCARD_FRAGMENT
				float DiscardValue = tex2DNode462.a;
				float DiscardThreshold = Clip_Threshold;

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
			#define DISCARD_FRAGMENT
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

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION


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

			float4 _RimColor;
			float3 Wind_Direction;
			float Billboard_Scale;
			float Offset_Along_Normal;
			float BILLBOARD_FACE_CAMERA_POSITION_ON;
			float _BillboardRotation;
			float Wind_Speed;
			float Wind_Turbulence;
			float Wind_Strength;
			float _WIND;
			float Clip_Threshold;
			float Fill_Impact;
			float Fill_Scale;
			float _USE_FILL_TEXTURE;
			float _ShadowStrength;
			float _RimLightOffset;
			CBUFFER_END
			TEXTURE2D(Shape_Texture);
			SAMPLER(sampler_linear_clamp);


			float2 UnityGradientNoiseDir( float2 p )
			{
				p = fmod(p , 289);
				float x = fmod((34 * p.x + 1) * p.x , 289) + p.y;
				x = fmod( (34 * x + 1) * x , 289);
				x = frac( x / 41 ) * 2 - 1;
				return normalize( float2(x - floor(x + 0.5 ), abs( x ) - 0.5 ) );
			}
			
			float UnityGradientNoise( float2 UV, float Scale )
			{
				float2 p = UV * Scale;
				float2 ip = floor( p );
				float2 fp = frac( p );
				float d00 = dot( UnityGradientNoiseDir( ip ), fp );
				float d01 = dot( UnityGradientNoiseDir( ip + float2( 0, 1 ) ), fp - float2( 0, 1 ) );
				float d10 = dot( UnityGradientNoiseDir( ip + float2( 1, 0 ) ), fp - float2( 1, 0 ) );
				float d11 = dot( UnityGradientNoiseDir( ip + float2( 1, 1 ) ), fp - float2( 1, 1 ) );
				fp = fp * fp * fp * ( fp * ( fp * 6 - 15 ) + 10 );
				return lerp( lerp( d00, d01, fp.y ), lerp( d10, d11, fp.y ), fp.x ) + 0.5;
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float billboard_Scale539 = Billboard_Scale;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				float3 objToWorld559 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 world_pivot560 = objToWorld559;
				float3 worldToObjDir491 = normalize( mul( GetWorldToObjectMatrix(), float4( ( world_pivot560 - _WorldSpaceCameraPos ), 0 ) ).xyz );
				float3 temp_output_492_0 = cross( float3( 0,1,0 ) , worldToObjDir491 );
				float3 temp_output_493_0 = cross( worldToObjDir491 , temp_output_492_0 );
				float billboard_Face_Camera_Position529 = BILLBOARD_FACE_CAMERA_POSITION_ON;
				float3 lerpResult531 = lerp( ase_worldNormal , mul( float3x3(temp_output_492_0, temp_output_493_0, worldToObjDir491), ase_worldNormal ) , billboard_Face_Camera_Position529);
				float3 temp_output_533_0 = ( Offset_Along_Normal * lerpResult531 );
				float3 ase_objectScale = float3( length( GetObjectToWorldMatrix()[ 0 ].xyz ), length( GetObjectToWorldMatrix()[ 1 ].xyz ), length( GetObjectToWorldMatrix()[ 2 ].xyz ) );
				float4 appendResult552 = (float4(( temp_output_533_0 + ( v.vertex.xyz * ase_objectScale ) ) , 0.0));
				float3 appendResult557 = (float3(mul( transpose( UNITY_MATRIX_V ), appendResult552 ).xyz));
				float3 worldToObj564 = mul( GetWorldToObjectMatrix(), float4( ( ( billboard_Scale539 * appendResult557 ) + world_pivot560 ), 1 ) ).xyz;
				float3 lerpResult566 = lerp( worldToObj564 , ( billboard_Scale539 * ( mul( v.vertex.xyz, float3x3(temp_output_492_0, temp_output_493_0, worldToObjDir491) ) + temp_output_533_0 ) ) , billboard_Face_Camera_Position529);
				float2 uv0500 = v.ase_texcoord.xy;
				float2 temp_output_504_0 = (float2( -1,-1 ) + (uv0500 - float2( 0,0 )) * (float2( 1,1 ) - float2( -1,-1 )) / (float2( 1,1 ) - float2( 0,0 )));
				float4 appendResult510 = (float4(temp_output_504_0 , 0.0 , 0.0));
				float4 appendResult509 = (float4(temp_output_504_0 , 0.0 , 0.0));
				float4 lerpResult513 = lerp( mul( appendResult510, UNITY_MATRIX_V ) , mul( appendResult509, float4x4(float4( temp_output_492_0 , 0.0 ), float4( temp_output_493_0 , 0.0 ), float4( worldToObjDir491 , 0.0 ), float4( 0,0,0,0 )) ) , billboard_Face_Camera_Position529);
				float3 normalizeResult520 = normalize( ( (mul( lerpResult513, UNITY_MATRIX_M )).xyz * ase_objectScale ) );
				float3 lerpResult569 = lerp( lerpResult566 , ( v.vertex.xyz + temp_output_533_0 + ( normalizeResult520 * billboard_Scale539 ) ) , _BillboardRotation);
				float3 windDirection448 = Wind_Direction;
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float gradientNoise432 = UnityGradientNoise(( ( ( (ase_worldPos).xy + (( ( windDirection448 * float3( 1,0,1 ) ) * ( Wind_Speed * 10.0 ) * _TimeParameters.x )).xy ) * Wind_Turbulence ) * float2( 0.1,0.1 ) ),10.0);
				float windStrength446 = Wind_Strength;
				float windEnabled458 = _WIND;
				float3 Out_WindOffset577 = ( windDirection448 * ( saturate( distance( v.vertex.xyz , float3( 0,0,0 ) ) ) * 0.5 * ( (-1.0 + (gradientNoise432 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) * windStrength446 ) ) * windEnabled458 );
				float3 Out_Position580 = ( lerpResult569 + Out_WindOffset577 );
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = Out_Position580;
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

				float2 uv0500 = IN.ase_texcoord2.xy;
				float windStrength446 = Wind_Strength;
				float3 windDirection448 = Wind_Direction;
				float gradientNoise432 = UnityGradientNoise(( ( ( (WorldPosition).xy + (( ( windDirection448 * float3( 1,0,1 ) ) * ( Wind_Speed * 10.0 ) * _TimeParameters.x )).xy ) * Wind_Turbulence ) * float2( 0.1,0.1 ) ),10.0);
				float cos435 = cos( ( windStrength446 * gradientNoise432 ) );
				float sin435 = sin( ( windStrength446 * gradientNoise432 ) );
				float2 rotator435 = mul( uv0500 - float2( 0.5,0.5 ) , float2x2( cos435 , -sin435 , sin435 , cos435 )) + float2( 0.5,0.5 );
				float windEnabled458 = _WIND;
				float2 lerpResult439 = lerp( uv0500 , rotator435 , windEnabled458);
				float2 windUV441 = lerpResult439;
				float4 tex2DNode462 = SAMPLE_TEXTURE2D( Shape_Texture, sampler_linear_clamp, windUV441 );
				
#ifdef DISCARD_FRAGMENT
				float DiscardValue = tex2DNode462.a;
				float DiscardThreshold = Clip_Threshold;

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
			
			Blend One Zero
			Cull Back
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define DISCARD_FRAGMENT
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

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION


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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)

			float4 _RimColor;
			float3 Wind_Direction;
			float Billboard_Scale;
			float Offset_Along_Normal;
			float BILLBOARD_FACE_CAMERA_POSITION_ON;
			float _BillboardRotation;
			float Wind_Speed;
			float Wind_Turbulence;
			float Wind_Strength;
			float _WIND;
			float Clip_Threshold;
			float Fill_Impact;
			float Fill_Scale;
			float _USE_FILL_TEXTURE;
			float _ShadowStrength;
			float _RimLightOffset;
			CBUFFER_END
			TEXTURE2D(Shape_Texture);
			SAMPLER(sampler_linear_clamp);


			float2 UnityGradientNoiseDir( float2 p )
			{
				p = fmod(p , 289);
				float x = fmod((34 * p.x + 1) * p.x , 289) + p.y;
				x = fmod( (34 * x + 1) * x , 289);
				x = frac( x / 41 ) * 2 - 1;
				return normalize( float2(x - floor(x + 0.5 ), abs( x ) - 0.5 ) );
			}
			
			float UnityGradientNoise( float2 UV, float Scale )
			{
				float2 p = UV * Scale;
				float2 ip = floor( p );
				float2 fp = frac( p );
				float d00 = dot( UnityGradientNoiseDir( ip ), fp );
				float d01 = dot( UnityGradientNoiseDir( ip + float2( 0, 1 ) ), fp - float2( 0, 1 ) );
				float d10 = dot( UnityGradientNoiseDir( ip + float2( 1, 0 ) ), fp - float2( 1, 0 ) );
				float d11 = dot( UnityGradientNoiseDir( ip + float2( 1, 1 ) ), fp - float2( 1, 1 ) );
				fp = fp * fp * fp * ( fp * ( fp * 6 - 15 ) + 10 );
				return lerp( lerp( d00, d01, fp.y ), lerp( d10, d11, fp.y ), fp.x ) + 0.5;
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float billboard_Scale539 = Billboard_Scale;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				float3 objToWorld559 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 world_pivot560 = objToWorld559;
				float3 worldToObjDir491 = normalize( mul( GetWorldToObjectMatrix(), float4( ( world_pivot560 - _WorldSpaceCameraPos ), 0 ) ).xyz );
				float3 temp_output_492_0 = cross( float3( 0,1,0 ) , worldToObjDir491 );
				float3 temp_output_493_0 = cross( worldToObjDir491 , temp_output_492_0 );
				float billboard_Face_Camera_Position529 = BILLBOARD_FACE_CAMERA_POSITION_ON;
				float3 lerpResult531 = lerp( ase_worldNormal , mul( float3x3(temp_output_492_0, temp_output_493_0, worldToObjDir491), ase_worldNormal ) , billboard_Face_Camera_Position529);
				float3 temp_output_533_0 = ( Offset_Along_Normal * lerpResult531 );
				float3 ase_objectScale = float3( length( GetObjectToWorldMatrix()[ 0 ].xyz ), length( GetObjectToWorldMatrix()[ 1 ].xyz ), length( GetObjectToWorldMatrix()[ 2 ].xyz ) );
				float4 appendResult552 = (float4(( temp_output_533_0 + ( v.vertex.xyz * ase_objectScale ) ) , 0.0));
				float3 appendResult557 = (float3(mul( transpose( UNITY_MATRIX_V ), appendResult552 ).xyz));
				float3 worldToObj564 = mul( GetWorldToObjectMatrix(), float4( ( ( billboard_Scale539 * appendResult557 ) + world_pivot560 ), 1 ) ).xyz;
				float3 lerpResult566 = lerp( worldToObj564 , ( billboard_Scale539 * ( mul( v.vertex.xyz, float3x3(temp_output_492_0, temp_output_493_0, worldToObjDir491) ) + temp_output_533_0 ) ) , billboard_Face_Camera_Position529);
				float2 uv0500 = v.ase_texcoord.xy;
				float2 temp_output_504_0 = (float2( -1,-1 ) + (uv0500 - float2( 0,0 )) * (float2( 1,1 ) - float2( -1,-1 )) / (float2( 1,1 ) - float2( 0,0 )));
				float4 appendResult510 = (float4(temp_output_504_0 , 0.0 , 0.0));
				float4 appendResult509 = (float4(temp_output_504_0 , 0.0 , 0.0));
				float4 lerpResult513 = lerp( mul( appendResult510, UNITY_MATRIX_V ) , mul( appendResult509, float4x4(float4( temp_output_492_0 , 0.0 ), float4( temp_output_493_0 , 0.0 ), float4( worldToObjDir491 , 0.0 ), float4( 0,0,0,0 )) ) , billboard_Face_Camera_Position529);
				float3 normalizeResult520 = normalize( ( (mul( lerpResult513, UNITY_MATRIX_M )).xyz * ase_objectScale ) );
				float3 lerpResult569 = lerp( lerpResult566 , ( v.vertex.xyz + temp_output_533_0 + ( normalizeResult520 * billboard_Scale539 ) ) , _BillboardRotation);
				float3 windDirection448 = Wind_Direction;
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float gradientNoise432 = UnityGradientNoise(( ( ( (ase_worldPos).xy + (( ( windDirection448 * float3( 1,0,1 ) ) * ( Wind_Speed * 10.0 ) * _TimeParameters.x )).xy ) * Wind_Turbulence ) * float2( 0.1,0.1 ) ),10.0);
				float windStrength446 = Wind_Strength;
				float windEnabled458 = _WIND;
				float3 Out_WindOffset577 = ( windDirection448 * ( saturate( distance( v.vertex.xyz , float3( 0,0,0 ) ) ) * 0.5 * ( (-1.0 + (gradientNoise432 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) * windStrength446 ) ) * windEnabled458 );
				float3 Out_Position580 = ( lerpResult569 + Out_WindOffset577 );
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = Out_Position580;
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
				float2 uv0500 = IN.ase_texcoord3.xy;
				float windStrength446 = Wind_Strength;
				float3 windDirection448 = Wind_Direction;
				float gradientNoise432 = UnityGradientNoise(( ( ( (WorldPosition).xy + (( ( windDirection448 * float3( 1,0,1 ) ) * ( Wind_Speed * 10.0 ) * _TimeParameters.x )).xy ) * Wind_Turbulence ) * float2( 0.1,0.1 ) ),10.0);
				float cos435 = cos( ( windStrength446 * gradientNoise432 ) );
				float sin435 = sin( ( windStrength446 * gradientNoise432 ) );
				float2 rotator435 = mul( uv0500 - float2( 0.5,0.5 ) , float2x2( cos435 , -sin435 , sin435 , cos435 )) + float2( 0.5,0.5 );
				float windEnabled458 = _WIND;
				float2 lerpResult439 = lerp( uv0500 , rotator435 , windEnabled458);
				float2 windUV441 = lerpResult439;
				float4 tex2DNode462 = SAMPLE_TEXTURE2D( Shape_Texture, sampler_linear_clamp, windUV441 );
				
				float3 temp_cast_0 = (1.0).xxx;
				
#ifdef DISCARD_FRAGMENT
				float DiscardValue = tex2DNode462.a;
				float DiscardThreshold = Clip_Threshold;

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
	CustomEditor "UnityEditor.ShaderGraphUnlitGUI"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=18935
330;902;1920;792;2031.244;1074.743;1;True;False
Node;AmplifyShaderEditor.TransformPositionNode;559;-3840,-3712;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;498;-3888,-4528;Inherit;False;1314;489;Camera Position Matrix;10;488;489;491;492;495;497;493;496;561;582;Camera Position Matrix;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;560;-3584,-3712;Inherit;False;world_pivot;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;488;-3840,-4224;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;561;-3840,-4480;Inherit;False;560;world_pivot;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;489;-3584,-4352;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformDirectionNode;491;-3456,-4352;Inherit;False;World;Object;True;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;417;-3840,-1921;Inherit;False;Property;Wind_Direction;[t]Wind Direction;11;0;Create;False;0;0;0;False;0;False;1,0,0;1,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CrossProductOpNode;492;-3200,-4480;Inherit;False;2;0;FLOAT3;0,1,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CrossProductOpNode;493;-3072,-4352;Inherit;False;2;0;FLOAT3;0,1,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;582;-2914.516,-4407.946;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;448;-3584,-1920;Inherit;False;windDirection;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;440;-3235.498,-2079.375;Inherit;False;2055.775;889.2555;Wind;22;441;439;435;434;432;429;427;424;428;425;421;426;418;419;422;420;423;447;449;451;459;501;Wind;0.4811321,0.4811321,0.4811321,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;449;-3200,-1664;Inherit;False;448;windDirection;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;418;-3200,-1408;Inherit;False;Property;Wind_Speed;[t]Wind Speed;12;0;Create;False;0;0;0;False;0;False;0.1;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.MatrixFromVectors;497;-2816,-4224;Inherit;False;FLOAT3x3;True;4;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3x3;0
Node;AmplifyShaderEditor.CommentaryNode;535;-2736,-3888;Inherit;False;1108;422;Offset along normal;6;528;526;531;533;527;530;Offset along normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;511;-3840,-3968;Inherit;False;Property;BILLBOARD_FACE_CAMERA_POSITION_ON;Billboard Face Camera Position;17;1;[Toggle];Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;419;-2929.498,-1645.374;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;1,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;420;-2944,-1408;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;536;-2480,-4144;Inherit;False;1;0;FLOAT3x3;1,0,0,1,1,1,1,0,1;False;1;FLOAT3x3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;529;-3456,-3968;Inherit;False;billboard_Face_Camera_Position;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;528;-2688,-3712;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;422;-3200,-1536;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;499;1024,-2432;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;500;1280,-2432;Inherit;False;uv0;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;421;-2816,-1536;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;423;-3200,-1920;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;516;-2480,-4784;Inherit;False;1529.476;563.8704;Billboard each face;13;519;513;515;514;503;504;506;508;505;507;509;510;538;Billboard each face;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;530;-2432,-3584;Inherit;False;529;billboard_Face_Camera_Position;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;527;-2432,-3840;Inherit;False;2;2;0;FLOAT3x3;0,0,0,1,1,1,1,0,1;False;1;FLOAT3;0,1,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;526;-2048,-3840;Inherit;False;Property;Offset_Along_Normal;[s]Offset Along Normal;8;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;503;-2432,-4736;Inherit;False;500;uv0;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;575;-1712,-3376;Inherit;False;1874.76;556.1238;Billboard whole object;17;566;565;544;564;563;558;556;557;552;554;555;547;546;583;644;651;650;Billboard whole object;1,1,1,1;0;0
Node;AmplifyShaderEditor.SwizzleNode;424;-2816,-1792;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;496;-2960,-4256;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;531;-2048,-3712;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;427;-2688,-1536;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;533;-1792,-3712;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,1,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TFHCRemapNode;504;-2176,-4736;Inherit;False;5;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;1,1;False;3;FLOAT2;-1,-1;False;4;FLOAT2;1,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.MatrixFromVectors;495;-2816,-4480;Inherit;False;FLOAT4x4;True;4;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;1;FLOAT4x4;0
Node;AmplifyShaderEditor.RangedFloatNode;426;-2688,-1664;Inherit;False;Property;Wind_Turbulence;[t]Wind Turbulence;13;0;Create;False;0;0;0;False;0;False;1;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;544;-1664,-3328;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ObjectScaleNode;583;-1664,-3072;Inherit;False;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;425;-2560,-1792;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ViewMatrixNode;508;-2176,-4480;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;428;-2432,-1792;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;506;-2032,-4576;Inherit;False;1;0;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4x4;0
Node;AmplifyShaderEditor.DynamicAppendNode;510;-1920,-4480;Inherit;False;FLOAT4;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;546;-1408,-3072;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;550;-1627.251,-3679.825;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;509;-1920,-4736;Inherit;False;FLOAT4;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;547;-1152,-3072;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;507;-1792,-4480;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;538;-1920,-4352;Inherit;False;529;billboard_Face_Camera_Position;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;505;-1792,-4736;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;429;-2304,-1792;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.1,0.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ViewMatrixNode;651;-1280,-3328;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.LerpOp;513;-1536,-4608;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;522;-3840,-3840;Inherit;False;Property;Billboard_Scale;[s]Billboard Scale;15;0;Create;False;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;433;-3840,-2048;Inherit;False;Property;Wind_Strength;[t]Wind Strength;14;0;Create;False;0;0;0;False;0;False;0.2;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;457;-1840,-2736;Inherit;False;1183.917;565.0188;Vertex motion;11;577;454;442;444;452;455;453;460;450;456;443;Vertex motion;1,1,1,1;0;0
Node;AmplifyShaderEditor.MMatrixNode;515;-1536,-4480;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.DynamicAppendNode;552;-1024,-3072;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TransposeOpNode;650;-1152,-3328;Inherit;False;1;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4x4;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;432;-2176,-1792;Inherit;True;Gradient;False;True;2;0;FLOAT2;0,0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;451;-1947.532,-1807.349;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;442;-1792,-2688;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;446;-3584,-2048;Inherit;False;windStrength;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;539;-3456,-3840;Inherit;False;billboard_Scale;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;514;-1280,-4608;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;554;-768,-3072;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;521;-816,-4528;Inherit;False;481;361;Scale;3;517;518;520;Scale;1,1,1,1;0;0
Node;AmplifyShaderEditor.ObjectScaleNode;518;-768,-4352;Inherit;False;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;452;-1792,-2304;Inherit;False;446;windStrength;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;519;-1104,-4608;Inherit;False;FLOAT3;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;524;-2432,-4096;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DistanceOpNode;443;-1536,-2688;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;555;-896,-3328;Inherit;False;539;billboard_Scale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;437;-3840,-1664;Inherit;False;Property;_WIND;[s]Wind;10;1;[Toggle];Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;534;-2256,-4144;Inherit;False;1;0;FLOAT3x3;1,0,0,1,1,1,1,0,1;False;1;FLOAT3x3;0
Node;AmplifyShaderEditor.TFHCRemapNode;450;-1792,-2560;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;557;-640,-3072;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;444;-1408,-2688;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;573;-1624.701,-3704.069;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;453;-1536,-2560;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;517;-640,-4480;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;549;-1624.251,-3729.825;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;556;-512,-3200;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;458;-3584,-1664;Inherit;False;windEnabled;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;563;-640,-2944;Inherit;False;560;world_pivot;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;525;-2048,-4096;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3x3;0,0,0,1,1,1,1,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;540;-512,-4096;Inherit;False;539;billboard_Scale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;558;-384,-3200;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;454;-1280,-2560;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;537;-1408,-3968;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;543;-1409,-4096;Inherit;False;539;billboard_Scale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;460;-1280,-2304;Inherit;False;458;windEnabled;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;572;-306.3184,-4025.55;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;455;-1280,-2688;Inherit;False;448;windDirection;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;520;-512,-4480;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;447;-2176,-1920;Inherit;False;446;windStrength;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;564;-256,-3200;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;576;62,-3762;Inherit;False;504;294;Select rotation mode;2;568;569;Select rotation mode;1,0,0.7737832,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;565;-384,-2944;Inherit;False;529;billboard_Face_Camera_Position;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;456;-1024,-2560;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;523;-256,-4352;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;501;-2176,-2048;Inherit;False;500;uv0;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;571;-137.8493,-4240.383;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;542;-1152,-3968;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;434;-1920,-1792;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;574;-512,-4736;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;459;-1920,-1536;Inherit;False;458;windEnabled;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;566;0,-3200;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;577;-896,-2560;Inherit;False;Out_WindOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;568;112,-3584;Inherit;False;Property;_BillboardRotation;Billboard Rotation;16;1;[Enum];Create;False;0;2;Whole Object;0;Each Face;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;435;-1792,-1920;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;570;0,-4352;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;439;-1664,-1664;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;569;384,-3712;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;579;384,-3456;Inherit;False;577;Out_WindOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;441;-1408,-1920;Inherit;False;windUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;578;640,-3584;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerStateNode;634;128,-2176;Inherit;False;1;1;1;1;-1;None;1;0;SAMPLER2D;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.TexturePropertyNode;461;-256,-2560;Inherit;True;Property;Shape_Texture;Shape Texture;1;2;[NoScaleOffset];[SingleLineTexture];Create;False;0;0;0;True;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.CommentaryNode;591;-3250,-818;Inherit;False;1377;385;wtf???;10;474;469;468;473;470;467;476;475;471;502;wtf???;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;610;-1586,-946;Inherit;False;2369.5;1365.16;Shading;35;639;640;119;120;122;637;608;624;484;595;636;609;586;592;611;604;625;605;613;594;415;635;632;600;597;606;631;593;590;587;596;599;642;641;638;Shading;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;463;128,-2304;Inherit;False;441;windUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;580;768,-3584;Inherit;False;Out_Position;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;502;-3200,-640;Inherit;False;500;uv0;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;644;-241.7799,-2838.019;Inherit;False;Constant;_Float1;Float 1;17;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;599;-512,-256;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;586;-768,128;Inherit;False;Property;_USE_FILL_TEXTURE;[s]Use Fill Texture;4;1;[Toggle];Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;469;-2560,-640;Inherit;False;FLOAT4;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ViewMatrixNode;470;-2560,-768;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;624;-256,-256;Inherit;False;shadingFactor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;642;-1536,-896;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;658;-256,-1792;Inherit;False;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;462;512,-2560;Inherit;True;Property;_TextureSample0;Texture Sample 0;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;639;-1536,-768;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;632;-1024,-512;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;484;-384,-768;Inherit;True;Property;_TextureSample1;Texture Sample 1;8;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;600;-896,-512;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;605;-384,-384;Inherit;False;Property;_ShadowStrength;[s]Shadow Strength;9;0;Create;False;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;670;-528,-1536;Inherit;False;Property;_RimLightOffset;RimLightOffset;19;0;Create;True;0;0;0;False;0;False;0.01;0.01;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;667;433.6053,-1722.323;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;476;-2176,-640;Inherit;False;FLOAT3;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;473;-2048,-640;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;415;-896,-768;Inherit;True;Property;_ShadingGradientTexture;Shading Gradient Texture;0;2;[NoScaleOffset];[SingleLineTexture];Create;False;0;0;0;True;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;468;-2688,-640;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;2,2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;669;-128,-1792;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TransformDirectionNode;654;-656,-1792;Inherit;False;World;View;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;662;128,-2048;Inherit;True;Property;_TextureSample3;Texture Sample 3;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;636;-512,-128;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;663;-896,-1920;Inherit;False;441;windUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;664;256,-1792;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;640;-1280,-768;Float;False;Constant;_RemapValue;Remap Value;0;0;Create;True;0;0;0;False;0;False;0.53;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;597;-1152,256;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;595;-768,-256;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;672;32.83722,-1641.849;Inherit;False;Property;_RimColor;Rim Color;18;1;[HDR];Create;False;1;______Rim Light______;0;0;True;0;False;0,0,0,1;0,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;611;512,-768;Inherit;False;Out_Color;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;652;-912,-1792;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;464;512,-2304;Inherit;False;Property;Clip_Threshold;[t]Alpha Clip;3;0;Create;False;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;594;-1152,-256;Inherit;True;Property;_TextureSample2;Texture Sample 2;15;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.IndirectDiffuseLighting;637;-432,48;Inherit;False;World;1;0;FLOAT3;0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;471;-2432,-640;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;609;0,-768;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LightAttenuation;606;-256,-512;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;631;-1152,-640;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;613;0,-512;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;645;-2433.3,-3200;Inherit;False;Constant;_Vector0;Vector 0;17;0;Create;True;0;0;0;False;0;False;0,0,0.001;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;590;-1536,128;Inherit;False;441;windUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;467;-2944,-640;Inherit;False;5;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;1,1;False;3;FLOAT2;-1,-1;False;4;FLOAT2;1,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;674;-256,-2304;Inherit;True;Property;ShapeRimTexture;Shape Rim Texture;2;2;[NoScaleOffset];[SingleLineTexture];Create;False;0;0;0;True;0;False;None;None;False;black;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.ObjectToWorldMatrixNode;474;-2432,-768;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.Vector3Node;648;-2432,-2944;Inherit;False;Constant;_Vector1;Vector 1;17;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;673;256,-1664;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.IndirectSpecularLight;635;-256,-128;Inherit;False;World;3;0;FLOAT3;0,0,1;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;475;-2304,-640;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;608;256,-768;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;671;-28.08057,-1926.742;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;612;384,-2176;Inherit;False;611;Out_Color;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;638;-1152,-896;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;592;-1280,0;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;587;-1536,0;Inherit;False;Property;Fill_Scale;[t]Fill Scale;6;0;Create;False;0;0;0;False;0;False;1;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;646;-1920,-2944;Inherit;False;#if defined(MAIN_PASS)$return In0@$#else$return In1@$#endif;3;Create;2;True;In0;FLOAT3;0,0,0;In;;Inherit;False;True;In1;FLOAT3;0,0,0;In;;Inherit;False;DepthZFightFixer;True;False;0;;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;596;-1408,256;Inherit;False;Property;Fill_Impact;[t]Fill Impact;5;0;Create;False;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;668;589.7625,-2063.906;Inherit;False;5;5;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;633;768,-1920;Inherit;False;Constant;_Float0;Float 0;17;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;581;768,-1792;Inherit;False;580;Out_Position;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;656;-384,-1792;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DotProductOpNode;641;-1280,-896;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;666;768,-2176;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.AbsOpNode;665;394,-1832;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;625;-1536,-640;Inherit;False;624;shadingFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerStateNode;604;-1536,-512;Inherit;False;0;0;0;1;-1;None;1;0;SAMPLER2D;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.TexturePropertyNode;593;-1536,-384;Inherit;True;Property;Fill_Texture;[t]Fill Texture;7;2;[NoScaleOffset];[SingleLineTexture];Create;False;0;0;0;True;0;False;None;None;False;black;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;117;1028.8,-2304;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;18;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;ExtraPrePass;0;2;Outline;6;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;True;2;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;True;True;True;128;False;-1;255;False;-1;255;False;-1;2;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;1;MRT Output;0;637933691105019490;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;120;512,-640;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;18;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;DepthOnly;0;5;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;314;0,-2304;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;18;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;AdditionalPass;0;0;ToonPostProcessing;6;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;True;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;1;False;-1;True;3;False;-1;True;False;0;False;-1;0;False;-1;True;1;LightMode=ToonPostProcessing;False;False;0;Hidden/InternalErrorShader;0;0;Standard;1;MRT Output;0;637933887809711874;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;121;1024,-2074;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;21;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;SceneSelectionPass;0;6;SceneSelectionPass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=SceneSelectionPass;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;119;512,-640;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;18;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;ShadowCaster;0;4;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;118;1024,-2304;Half;False;True;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;21;Treeverse/Static/Environment/Billboard;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;Forward;0;3;Forward;12;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;2;False;-1;False;False;False;False;False;False;False;False;True;True;False;128;False;-1;255;False;-1;255;False;-1;7;False;-1;3;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=AlphaTest=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;True;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;1;False;-1;True;0;False;-1;True;False;0;False;-1;0;False;-1;True;1;LightMode=UniversalForwardOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;18;Surface;0;0;  Blend;0;0;Two Sided;0;637938115334150996;Cast Shadows;1;637938170312636948;  Use Shadow Threshold;0;637938173281125973;Receive Shadows;1;637938170329994691;GPU Instancing;1;0;LOD CrossFade;0;0;Treeverse Linear Fog;1;637993452453667377;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;0;637934715139007372;Full Screen Pass;0;0;Additional Pass;0;637934715104248665;Scene Selectioin Pass;1;637938170389763265;Vertex Position,InvertActionOnDeselection;0;637938228692803188;Discard Fragment;1;637938174214296471;Push SelfShadow to Main Light;0;0;2;MRT Output;0;637933854335023384;Custom Output Position;0;0;8;False;False;False;True;True;True;True;False;False;;True;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;122;512,-640;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;18;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;Meta;0;7;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;675;1024,-2304;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;FullScreenPass;0;1;FullScreenPass;4;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;7;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForwardOnly;True;2;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;560;0;559;0
WireConnection;489;0;561;0
WireConnection;489;1;488;0
WireConnection;491;0;489;0
WireConnection;492;1;491;0
WireConnection;493;0;491;0
WireConnection;493;1;492;0
WireConnection;582;0;492;0
WireConnection;448;0;417;0
WireConnection;497;0;582;0
WireConnection;497;1;493;0
WireConnection;497;2;491;0
WireConnection;419;0;449;0
WireConnection;420;0;418;0
WireConnection;536;0;497;0
WireConnection;529;0;511;0
WireConnection;500;0;499;0
WireConnection;421;0;419;0
WireConnection;421;1;420;0
WireConnection;421;2;422;0
WireConnection;527;0;536;0
WireConnection;527;1;528;0
WireConnection;424;0;423;0
WireConnection;496;0;491;0
WireConnection;531;0;528;0
WireConnection;531;1;527;0
WireConnection;531;2;530;0
WireConnection;427;0;421;0
WireConnection;533;0;526;0
WireConnection;533;1;531;0
WireConnection;504;0;503;0
WireConnection;495;0;492;0
WireConnection;495;1;493;0
WireConnection;495;2;496;0
WireConnection;425;0;424;0
WireConnection;425;1;427;0
WireConnection;428;0;425;0
WireConnection;428;1;426;0
WireConnection;506;0;495;0
WireConnection;510;0;504;0
WireConnection;546;0;544;0
WireConnection;546;1;583;0
WireConnection;550;0;533;0
WireConnection;509;0;504;0
WireConnection;547;0;550;0
WireConnection;547;1;546;0
WireConnection;507;0;510;0
WireConnection;507;1;508;0
WireConnection;505;0;509;0
WireConnection;505;1;506;0
WireConnection;429;0;428;0
WireConnection;513;0;507;0
WireConnection;513;1;505;0
WireConnection;513;2;538;0
WireConnection;552;0;547;0
WireConnection;650;0;651;0
WireConnection;432;0;429;0
WireConnection;451;0;432;0
WireConnection;446;0;433;0
WireConnection;539;0;522;0
WireConnection;514;0;513;0
WireConnection;514;1;515;0
WireConnection;554;0;650;0
WireConnection;554;1;552;0
WireConnection;519;0;514;0
WireConnection;443;0;442;0
WireConnection;534;0;497;0
WireConnection;450;0;451;0
WireConnection;557;0;554;0
WireConnection;444;0;443;0
WireConnection;573;0;533;0
WireConnection;453;0;450;0
WireConnection;453;1;452;0
WireConnection;517;0;519;0
WireConnection;517;1;518;0
WireConnection;549;0;533;0
WireConnection;556;0;555;0
WireConnection;556;1;557;0
WireConnection;458;0;437;0
WireConnection;525;0;524;0
WireConnection;525;1;534;0
WireConnection;558;0;556;0
WireConnection;558;1;563;0
WireConnection;454;0;444;0
WireConnection;454;2;453;0
WireConnection;537;0;525;0
WireConnection;537;1;549;0
WireConnection;572;0;573;0
WireConnection;520;0;517;0
WireConnection;564;0;558;0
WireConnection;456;0;455;0
WireConnection;456;1;454;0
WireConnection;456;2;460;0
WireConnection;523;0;520;0
WireConnection;523;1;540;0
WireConnection;571;0;572;0
WireConnection;542;0;543;0
WireConnection;542;1;537;0
WireConnection;434;0;447;0
WireConnection;434;1;432;0
WireConnection;566;0;564;0
WireConnection;566;1;542;0
WireConnection;566;2;565;0
WireConnection;577;0;456;0
WireConnection;435;0;501;0
WireConnection;435;2;434;0
WireConnection;570;0;574;0
WireConnection;570;1;571;0
WireConnection;570;2;523;0
WireConnection;439;0;501;0
WireConnection;439;1;435;0
WireConnection;439;2;459;0
WireConnection;569;0;566;0
WireConnection;569;1;570;0
WireConnection;569;2;568;0
WireConnection;441;0;439;0
WireConnection;578;0;569;0
WireConnection;578;1;579;0
WireConnection;580;0;578;0
WireConnection;599;0;597;0
WireConnection;599;1;595;0
WireConnection;599;2;586;0
WireConnection;469;0;468;0
WireConnection;624;0;599;0
WireConnection;658;0;656;0
WireConnection;462;0;461;0
WireConnection;462;1;463;0
WireConnection;462;7;634;0
WireConnection;632;0;631;0
WireConnection;484;0;415;0
WireConnection;484;1;600;0
WireConnection;484;7;415;1
WireConnection;600;0;632;0
WireConnection;667;0;664;0
WireConnection;476;0;475;0
WireConnection;473;0;476;0
WireConnection;468;0;467;0
WireConnection;669;0;658;0
WireConnection;669;1;670;0
WireConnection;654;0;652;0
WireConnection;662;0;674;0
WireConnection;662;1;671;0
WireConnection;664;0;662;4
WireConnection;664;1;462;4
WireConnection;597;0;596;0
WireConnection;595;0;594;1
WireConnection;595;3;597;0
WireConnection;611;0;608;0
WireConnection;594;0;593;0
WireConnection;594;1;592;0
WireConnection;594;7;604;0
WireConnection;637;0;636;0
WireConnection;471;0;470;0
WireConnection;471;1;469;0
WireConnection;609;0;484;0
WireConnection;631;0;638;0
WireConnection;631;1;625;0
WireConnection;613;1;606;0
WireConnection;613;2;605;0
WireConnection;467;0;502;0
WireConnection;673;0;672;0
WireConnection;635;0;636;0
WireConnection;475;0;474;0
WireConnection;475;1;471;0
WireConnection;608;0;609;0
WireConnection;608;1;613;0
WireConnection;671;0;663;0
WireConnection;671;1;669;0
WireConnection;638;0;641;0
WireConnection;638;1;640;0
WireConnection;638;2;640;0
WireConnection;592;0;587;0
WireConnection;592;1;590;0
WireConnection;646;0;645;0
WireConnection;646;1;648;0
WireConnection;668;0;612;0
WireConnection;668;1;665;0
WireConnection;668;2;613;0
WireConnection;668;3;632;0
WireConnection;668;4;673;0
WireConnection;656;0;654;0
WireConnection;641;0;642;0
WireConnection;641;1;639;0
WireConnection;666;0;612;0
WireConnection;666;1;668;0
WireConnection;665;0;664;0
WireConnection;121;0;633;0
WireConnection;121;3;581;0
WireConnection;118;21;462;4
WireConnection;118;22;464;0
WireConnection;118;2;666;0
WireConnection;118;5;581;0
ASEEND*/
//CHKSM=B422639D4C52EC3387C858619E163794B97A76B1
// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Treeverse/VFX/Volumetic/Texture3D"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[ASEBegin][NoScaleOffset][SingleLineTexture]_ShadingGradientTexture("Color", 2D) = "white" {}
		_Voume("Voume", 3D) = "white" {}
		[HDR]_Color("Color", Color) = (0.5,0.5,0.5,1)
		_HeightDetensity("Height Detensity", Float) = 1
		[ASEEnd]_FlowSpeed("Flow Speed", Float) = 0.1

		
	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
		
		Cull Off
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
			
			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
			ZWrite Off
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define ASE_SRP_VERSION 999999
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
			#define ASE_NEEDS_FRAG_POSITION
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_FRAG_NORMAL
			#define _ADDITIONAL_LIGHT_SHADOWS 1
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_SHADOWCOORDS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _SHADOWS_SOFT
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
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
				float4 ase_color : COLOR;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)

			float4 _Color;
			float4 _Voume_ST;
			float _FlowSpeed;
			float _HeightDetensity;
			CBUFFER_END
			TEXTURE2D(_ShadingGradientTexture);
			TEXTURE3D(_Voume);
			SAMPLER(sampler_Voume);
			SAMPLER(sampler_ShadingGradientTexture);
			uniform float4 _CameraDepthTexture_TexelSize;


			real3 ASESafeNormalize(float3 inVec)
			{
				real dp3 = max(FLT_MIN, dot(inVec, inVec));
				return inVec* rsqrt( dp3);
			}
			
			float SelfShadow201( float3 wp )
			{
				Light mainLight = GetMainLight( TransformWorldToShadowCoord(wp) );
				return mainLight.distanceAttenuation * mainLight.shadowAttenuation ;
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
			
			
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 temp_output_131_0 = ( v.vertex.xyz + ( ( v.ase_color.r - 1.5 ) * v.ase_normal ) );
				
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord4.xyz = ase_worldTangent;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord5.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord6.xyz = ase_worldBitangent;
				
				o.ase_texcoord3 = v.vertex;
				o.ase_color = v.ase_color;
				o.ase_normal = v.ase_normal;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
				o.ase_texcoord6.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = temp_output_131_0;
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
					half fogFactor =  (1.0 - saturate( positionCS.z * unity_FogParams.z + unity_FogParams.w)) * step(0.001, -1.0 / unity_FogParams.z);
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
				float mulTime196 = _TimeParameters.x * _FlowSpeed;
				float2 appendResult185 = (float2(IN.ase_texcoord3.xyz.xy));
				float2 panner184 = ( mulTime196 * float2( 1,0 ) + appendResult185);
				float3 appendResult186 = (float3(panner184 , IN.ase_texcoord3.xyz.z));
				float3 appendResult127 = (float3(_Voume_ST.xy , 1.0));
				float3 appendResult126 = (float3(_Voume_ST.zw , 0.0));
				float3 temp_output_129_0 = ( ( ( appendResult186 + ( IN.ase_color.g * IN.ase_normal ) ) * appendResult127 ) + appendResult126 );
				float2 _Vector0 = float2(0.03,0);
				float3 appendResult167 = (float3(SAMPLE_TEXTURE3D( _Voume, sampler_Voume, ( temp_output_129_0 - (_Vector0).xyy ) ).r , SAMPLE_TEXTURE3D( _Voume, sampler_Voume, ( temp_output_129_0 - (_Vector0).yxy ) ).r , SAMPLE_TEXTURE3D( _Voume, sampler_Voume, ( temp_output_129_0 - (_Vector0).yyx ) ).r));
				float4 tex3DNode109 = SAMPLE_TEXTURE3D( _Voume, sampler_Voume, temp_output_129_0 );
				float3 normalizeResult172 = ASESafeNormalize( ( appendResult167 - (tex3DNode109).rgb ) );
				float3 objToWorldDir173 = mul( GetObjectToWorldMatrix(), float4( normalizeResult172, 0 ) ).xyz;
				float3 normalizeResult174 = ASESafeNormalize( objToWorldDir173 );
				float dotResult179 = dot( _MainLightPosition.xyz , normalizeResult174 );
				float3 temp_output_131_0 = ( IN.ase_texcoord3.xyz + ( ( IN.ase_color.r - 1.5 ) * IN.ase_normal ) );
				float3 objToWorld200 = mul( GetObjectToWorldMatrix(), float4( temp_output_131_0, 1 ) ).xyz;
				float3 wp201 = objToWorld200;
				float localSelfShadow201 = SelfShadow201( wp201 );
				float ase_lightAtten = 0;
				Light ase_mainLight = GetMainLight( ShadowCoords );
				ase_lightAtten = ase_mainLight.distanceAttenuation * ase_mainLight.shadowAttenuation;
				float2 appendResult199 = (float2(( ( ( dotResult179 * 0.5 ) + 0.5 ) * ( localSelfShadow201 * max( ase_lightAtten , 1.0 ) ) ) , 0.5));
				float3 worldPosValue44_g1 = WorldPosition;
				float3 WorldPosition37_g1 = worldPosValue44_g1;
				float3 ase_worldTangent = IN.ase_texcoord4.xyz;
				float3 ase_worldNormal = IN.ase_texcoord5.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord6.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal12_g1 = normalizeResult174;
				float3 worldNormal12_g1 = float3(dot(tanToWorld0,tanNormal12_g1), dot(tanToWorld1,tanNormal12_g1), dot(tanToWorld2,tanNormal12_g1));
				float3 worldNormalValue50_g1 = worldNormal12_g1;
				float3 WorldNormal37_g1 = worldNormalValue50_g1;
				float3 localAdditionalLightsLambert37_g1 = AdditionalLightsLambert( WorldPosition37_g1 , WorldNormal37_g1 );
				float3 lambertResult38_g1 = localAdditionalLightsLambert37_g1;
				
				float4 unityObjectToClipPos133 = TransformWorldToHClip(TransformObjectToWorld(temp_output_131_0));
				float4 computeScreenPos136 = ComputeScreenPos( unityObjectToClipPos133 );
				computeScreenPos136 = computeScreenPos136 / computeScreenPos136.w;
				computeScreenPos136.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? computeScreenPos136.z : computeScreenPos136.z* 0.5 + 0.5;
				float eyeDepth139 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( computeScreenPos136.xy ),_ZBufferParams);
				float3 objToWorld134 = mul( GetObjectToWorldMatrix(), float4( temp_output_131_0, 1 ) ).xyz;
				float3 worldToView135 = mul( UNITY_MATRIX_V, float4( objToWorld134, 1 ) ).xyz;
				
#ifdef DISCARD_FRAGMENT
				float DiscardValue = 1.0;
				float DiscardThreshold = 0;

				if(DiscardValue < DiscardThreshold)discard;
#endif
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( ( _Color * SAMPLE_TEXTURE2D( _ShadingGradientTexture, sampler_ShadingGradientTexture, appendResult199 ) ) + float4( lambertResult38_g1 , 0.0 ) ).rgb;
				float Alpha = ( tex3DNode109.r * saturate( ( ( ( ( eyeDepth139 / -worldToView135.z ) - 1.0 ) * ( ( _WorldSpaceCameraPos.y - objToWorld134.y ) + 10.0 ) ) / max( _HeightDetensity , 0.01 ) ) ) * _Color.a );
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
					Color.rgb = lerp(Color.rgb, unity_FogColor.rgb, IN.fogFactor * unity_FogColor.a);
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
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM
			
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define ASE_SRP_VERSION 999999
			#define REQUIRE_DEPTH_TEXTURE 1
			#define ASE_USING_SAMPLING_MACROS 1

			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_POSITION
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_FRAG_NORMAL
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
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
				float4 ase_color : COLOR;
				float3 ase_normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)

			float4 _Color;
			float4 _Voume_ST;
			float _FlowSpeed;
			float _HeightDetensity;
			CBUFFER_END
			TEXTURE3D(_Voume);
			SAMPLER(sampler_Voume);
			uniform float4 _CameraDepthTexture_TexelSize;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 temp_output_131_0 = ( v.vertex.xyz + ( ( v.ase_color.r - 1.5 ) * v.ase_normal ) );
				
				o.ase_texcoord2 = v.vertex;
				o.ase_color = v.ase_color;
				o.ase_normal = v.ase_normal;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = temp_output_131_0;
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

				float mulTime196 = _TimeParameters.x * _FlowSpeed;
				float2 appendResult185 = (float2(IN.ase_texcoord2.xyz.xy));
				float2 panner184 = ( mulTime196 * float2( 1,0 ) + appendResult185);
				float3 appendResult186 = (float3(panner184 , IN.ase_texcoord2.xyz.z));
				float3 appendResult127 = (float3(_Voume_ST.xy , 1.0));
				float3 appendResult126 = (float3(_Voume_ST.zw , 0.0));
				float3 temp_output_129_0 = ( ( ( appendResult186 + ( IN.ase_color.g * IN.ase_normal ) ) * appendResult127 ) + appendResult126 );
				float4 tex3DNode109 = SAMPLE_TEXTURE3D( _Voume, sampler_Voume, temp_output_129_0 );
				float3 temp_output_131_0 = ( IN.ase_texcoord2.xyz + ( ( IN.ase_color.r - 1.5 ) * IN.ase_normal ) );
				float4 unityObjectToClipPos133 = TransformWorldToHClip(TransformObjectToWorld(temp_output_131_0));
				float4 computeScreenPos136 = ComputeScreenPos( unityObjectToClipPos133 );
				computeScreenPos136 = computeScreenPos136 / computeScreenPos136.w;
				computeScreenPos136.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? computeScreenPos136.z : computeScreenPos136.z* 0.5 + 0.5;
				float eyeDepth139 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( computeScreenPos136.xy ),_ZBufferParams);
				float3 objToWorld134 = mul( GetObjectToWorldMatrix(), float4( temp_output_131_0, 1 ) ).xyz;
				float3 worldToView135 = mul( UNITY_MATRIX_V, float4( objToWorld134, 1 ) ).xyz;
				
#ifdef DISCARD_FRAGMENT
				float DiscardValue = 1.0;
				float DiscardThreshold = 0;

				if(DiscardValue < DiscardThreshold)discard;
#endif
				float Alpha = ( tex3DNode109.r * saturate( ( ( ( ( eyeDepth139 / -worldToView135.z ) - 1.0 ) * ( ( _WorldSpaceCameraPos.y - objToWorld134.y ) + 10.0 ) ) / max( _HeightDetensity , 0.01 ) ) ) * _Color.a );
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

	
	}
	CustomEditorForRenderPipeline "CustomDrawersShaderEditor" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
	CustomEditor "UnityEditor.ShaderGraphUnlitGUI"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=18935
2560;307;2048;1100.6;1391.277;-254.8716;1.114347;True;False
Node;AmplifyShaderEditor.VertexColorNode;107;-896,768;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalVertexDataNode;114;-896,1024;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;132;-640.2369,847.3437;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;105;-1280,384;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;-512,896;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;131;-256,768;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;195;-1169.36,559.3141;Inherit;False;Property;_FlowSpeed;Flow Speed;7;0;Create;True;0;0;0;False;0;False;0.1;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;134;-778.9931,2683.712;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.UnityObjToClipPosHlpNode;133;-1290.993,2171.712;Inherit;False;1;0;FLOAT3;0,0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;185;-1024,384;Inherit;False;FLOAT2;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;196;-997.8091,553.0402;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;135;-522.9931,2683.712;Inherit;False;World;View;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ComputeScreenPosHlpNode;136;-1034.993,2299.712;Inherit;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TexturePropertyNode;18;-896,128;Inherit;True;Property;_Voume;Voume;3;0;Create;True;0;0;0;False;0;False;None;e0588dabcbc0aba459a82eb839636da7;False;white;LockedToTexture3D;Texture3D;-1;0;2;SAMPLER3D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.WorldSpaceCameraPos;138;-1034.993,2427.712;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NegateNode;137;-522.9931,2555.712;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenDepthNode;139;-778.9931,2299.712;Inherit;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;184;-896,384;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;140;-522.9931,2299.712;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureTransformNode;125;-640,0;Inherit;False;-1;False;1;0;SAMPLER3D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.SimpleSubtractOpNode;141;-778.9931,2427.712;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;186;-640,384;Inherit;False;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;123;-512,640;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;127;-384,0;Inherit;False;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;144;-394.9931,2171.712;Inherit;False;Property;_HeightDetensity;Height Detensity;5;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;143;-394.9931,2299.712;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;124;-256,0;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;142;-394.9931,2427.712;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;126;-256,512;Inherit;False;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;146;-138.9931,2171.712;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;128;-128,0;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;145;-138.9931,2299.712;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;129;0,0;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;147;-10.9931,2171.712;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;109;384,128;Inherit;True;Property;_TextureSample0;Texture Sample 0;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture3D;8;0;SAMPLER3D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;57;768,-640;Inherit;False;Property;_Color;Color;4;1;[HDR];Create;True;0;0;0;False;0;False;0.5,0.5,0.5,1;0.4528302,0.4528302,0.4528302,0.2509804;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;148;117.0069,2171.712;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;162;-128,1024;Inherit;False;FLOAT3;1;0;1;3;1;0;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;167;768,384;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;164;256,384;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;161;-128,896;Inherit;False;FLOAT3;0;1;1;3;1;0;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;54;-896,-256;Inherit;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;53;-1280,-128;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SinOpNode;188;-1886.909,703.1516;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;-1280,-384;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;191;-2270.909,575.1517;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;360;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;155;384,384;Inherit;True;Property;_TextureSample1;Texture Sample 1;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture3D;8;0;SAMPLER3D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformDirectionNode;173;1408,128;Inherit;False;Object;World;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;172;1280,128;Inherit;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;163;-128,1152;Inherit;False;FLOAT3;1;1;0;3;1;0;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ObjectScaleNode;178;-1280,640;Inherit;False;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;15;-1024,-256;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;207;2336.214,-261.294;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;204;1029.675,-294.7807;Inherit;False;2;2;0;FLOAT;1;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;203;822.1036,-395.8155;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;166;256,896;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexToFragmentNode;72;-1024,-384;Inherit;False;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;170;768,-128;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CustomExpressionNode;201;681.0037,-268.6145;Inherit;False;Light mainLight = GetMainLight( TransformWorldToShadowCoord(wp) )@$return mainLight.distanceAttenuation * mainLight.shadowAttenuation @;1;Create;1;True;wp;FLOAT3;0,0,0;In;;Inherit;False;SelfShadow;True;False;0;;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;181;1280,-128;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;179;1152,-128;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;94;-1317.71,-271.2029;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;165;256,640;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;149;-522.9931,2939.712;Inherit;False;worldPosition;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;171;1180.626,479.0237;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;182;1408,-128;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;189;-1758.909,575.1517;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;14;-1536,-128;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;17;-1280,256;Inherit;False;Property;_DensityScale;Density Scale;1;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CosOpNode;187;-1886.909,575.1517;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;190;-1630.908,575.1517;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;198;1847.995,-214.9135;Inherit;True;Property;_TextureSample4;Texture Sample 4;8;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;159;768,128;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;52;-1536,-384;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;156;384,640;Inherit;True;Property;_TextureSample2;Texture Sample 2;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture3D;8;0;SAMPLER3D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexToFragmentNode;55;-768,-256;Inherit;False;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RadiansOpNode;192;-2142.909,575.1517;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectScaleNode;92;-1548.498,-242.4563;Inherit;False;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CustomExpressionNode;10;-256,-384;Inherit;False;float density = 0@$float transmission = 0@$float lightAccumulation = 0@$float finalLight = 0@$$float stepSize = 1.0 / numSteps@$for(int i =0@ i< numSteps@ i++){$	rayOrigin += (rayDirection *  stepSize)@$	$	float3 samplePos = rayOrigin + 0.5.xxx@$$	float sampledDensity = tex3D(Volume, samplePos).r@$	density += sampledDensity@	$}$$return density * densityScale@$;1;Create;5;True;rayOrigin;FLOAT3;0,0,0;In;;Inherit;False;True;rayDirection;FLOAT3;0,0,0;In;;Inherit;False;True;numSteps;INT;0;In;;Inherit;False;True;densityScale;FLOAT;0;In;;Inherit;False;True;Volume;SAMPLER3D;;In;;Inherit;False;Raymarch;True;False;0;;False;5;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;INT;0;False;3;FLOAT;0;False;4;SAMPLER3D;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;199;1664,-128;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;194;-2526.909,447.1514;Inherit;False;Property;_FlowAngle;Flow Angle;6;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;157;384,896;Inherit;True;Property;_TextureSample3;Texture Sample 3;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture3D;8;0;SAMPLER3D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;154;1410.6,666.8;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;160;-384,1024;Inherit;False;Constant;_Vector0;Vector 0;5;0;Create;True;0;0;0;False;0;False;0.03,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;2067.916,-410.507;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;158;1024,128;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;205;1536,-128;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;202;566.1038,-395.8155;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;206;1885.228,98.87385;Inherit;False;SRP Additional Light;-1;;1;6c86746ad131a0a408ca599df5f40861;7,6,1,9,0,23,0,26,0,27,0,24,0,25,0;6;2;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;15;FLOAT3;0,0,0;False;14;FLOAT3;1,1,1;False;18;FLOAT;0.5;False;32;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;197;1337.759,-862.5623;Inherit;True;Property;_ShadingGradientTexture;Color;2;2;[NoScaleOffset];[SingleLineTexture];Create;False;0;0;0;True;0;False;None;195ca85aab33f3f41b66ea0412f7c640;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TransformPositionNode;200;425.0037,-268.6145;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;174;1632,128;Inherit;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-1280,128;Inherit;False;Property;_VoxelDensity;Voxel Density;0;1;[IntRange];Create;True;0;0;0;False;0;False;16;16;4;64;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;193;-1502.908,575.1517;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;99;958,37;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;ShadowCaster;0;4;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;95;958,37;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;AdditionalPass;0;0;AdditionalPass;6;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;1;MRT Output;0;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;102;958,37;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;Meta;0;7;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;98;2479.274,-211.8707;Half;False;True;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;21;Treeverse/VFX/Volumetic/Texture3D;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;Forward;0;3;Forward;12;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForwardOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;18;Surface;1;637994339106358753;  Blend;0;0;Two Sided;0;637994347145843804;Cast Shadows;0;637994339122048748;  Use Shadow Threshold;1;637994339116105321;Receive Shadows;1;637994393657078438;GPU Instancing;0;637994339113596079;LOD CrossFade;0;0;Treeverse Linear Fog;0;0;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;0;0;Full Screen Pass;0;0;Additional Pass;0;0;Scene Selectioin Pass;0;0;Vertex Position,InvertActionOnDeselection;0;637994340832870243;Discard Fragment;0;0;Push SelfShadow to Main Light;0;0;2;MRT Output;0;0;Custom Output Position;0;0;8;False;False;False;True;False;True;False;False;False;;True;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;97;958,37;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;ExtraPrePass;0;2;ExtraPrePass;6;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;1;MRT Output;0;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;96;958,37;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;FullScreenPass;0;1;FullScreenPass;4;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;7;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForwardOnly;True;2;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;101;958,37;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;SceneSelectionPass;0;6;SceneSelectionPass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=SceneSelectionPass;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;100;958,37;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;DepthOnly;0;5;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;132;0;107;1
WireConnection;130;0;132;0
WireConnection;130;1;114;0
WireConnection;131;0;105;0
WireConnection;131;1;130;0
WireConnection;134;0;131;0
WireConnection;133;0;131;0
WireConnection;185;0;105;0
WireConnection;196;0;195;0
WireConnection;135;0;134;0
WireConnection;136;0;133;0
WireConnection;137;0;135;3
WireConnection;139;0;136;0
WireConnection;184;0;185;0
WireConnection;184;1;196;0
WireConnection;140;0;139;0
WireConnection;140;1;137;0
WireConnection;125;0;18;0
WireConnection;141;0;138;2
WireConnection;141;1;134;2
WireConnection;186;0;184;0
WireConnection;186;2;105;3
WireConnection;123;0;107;2
WireConnection;123;1;114;0
WireConnection;127;0;125;0
WireConnection;143;0;140;0
WireConnection;124;0;186;0
WireConnection;124;1;123;0
WireConnection;142;0;141;0
WireConnection;126;0;125;1
WireConnection;146;0;144;0
WireConnection;128;0;124;0
WireConnection;128;1;127;0
WireConnection;145;0;143;0
WireConnection;145;1;142;0
WireConnection;129;0;128;0
WireConnection;129;1;126;0
WireConnection;147;0;145;0
WireConnection;147;1;146;0
WireConnection;109;0;18;0
WireConnection;109;1;129;0
WireConnection;148;0;147;0
WireConnection;162;0;160;0
WireConnection;167;0;155;1
WireConnection;167;1;156;1
WireConnection;167;2;157;1
WireConnection;164;0;129;0
WireConnection;164;1;161;0
WireConnection;161;0;160;0
WireConnection;54;0;15;0
WireConnection;53;0;14;0
WireConnection;188;0;192;0
WireConnection;93;0;52;0
WireConnection;93;1;94;0
WireConnection;191;0;194;0
WireConnection;155;0;18;0
WireConnection;155;1;164;0
WireConnection;173;0;172;0
WireConnection;172;0;158;0
WireConnection;163;0;160;0
WireConnection;15;0;52;0
WireConnection;15;1;53;0
WireConnection;207;0;58;0
WireConnection;207;1;206;0
WireConnection;204;0;201;0
WireConnection;204;1;203;0
WireConnection;203;0;202;0
WireConnection;166;0;129;0
WireConnection;166;1;163;0
WireConnection;72;0;93;0
WireConnection;201;0;200;0
WireConnection;181;0;179;0
WireConnection;179;0;170;0
WireConnection;179;1;174;0
WireConnection;94;0;92;1
WireConnection;94;2;92;3
WireConnection;165;0;129;0
WireConnection;165;1;162;0
WireConnection;149;0;134;0
WireConnection;182;0;181;0
WireConnection;189;0;187;0
WireConnection;187;0;192;0
WireConnection;190;0;189;0
WireConnection;190;1;188;0
WireConnection;198;0;197;0
WireConnection;198;1;199;0
WireConnection;159;0;109;0
WireConnection;156;0;18;0
WireConnection;156;1;165;0
WireConnection;55;0;54;0
WireConnection;192;0;191;0
WireConnection;10;0;72;0
WireConnection;10;1;55;0
WireConnection;10;2;11;0
WireConnection;10;3;17;0
WireConnection;10;4;18;0
WireConnection;199;0;205;0
WireConnection;157;0;18;0
WireConnection;157;1;166;0
WireConnection;154;0;109;1
WireConnection;154;1;148;0
WireConnection;154;2;57;4
WireConnection;58;0;57;0
WireConnection;58;1;198;0
WireConnection;158;0;167;0
WireConnection;158;1;159;0
WireConnection;205;0;182;0
WireConnection;205;1;204;0
WireConnection;206;2;174;0
WireConnection;200;0;131;0
WireConnection;174;0;173;0
WireConnection;193;0;190;0
WireConnection;98;2;207;0
WireConnection;98;3;154;0
WireConnection;98;5;131;0
ASEEND*/
//CHKSM=131FBFFC7E57D2873040F9E141A3882F05579C0C
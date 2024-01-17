// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Treeverse/VFX/AreaFog"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[ASEBegin][Header(______Base Preperties______)][Space(10)]_AlbedoColor("Albedo Color", Color) = (1,1,1,1)
		[NoScaleOffset][SingleLineTexture]_ShadingGradientTexture("Color", 2D) = "white" {}
		_HeightDetensity("Height Detensity", Float) = 1
		_MapDetensity("Map Detensity", Float) = 1
		_ParallaxScale("Parallax Scale", Range( 0 , 0.1)) = 0.1
		_MainTex("MainTex", 2D) = "gray" {}
		[ASEEnd]_FlowSpeed("Flow Speed", Float) = 1

		
	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
		
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
			
			Tags { "LightMode"="UniversalForwardOnly" }
			
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			ZTest LEqual
			Offset 0,0
			ColorMask RGBA
			

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define TREEVERSE_LINEAR_FOG
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

			#define ASE_NEEDS_VERT_NORMAL
			#define _ADDITIONAL_LIGHT_SHADOWS 1
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_SHADOWCOORDS
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_FRAG_POSITION
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _SHADOWS_SOFT
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
				float4 ase_texcoord2 : TEXCOORD2;
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
				float4 ase_color : COLOR;
				float4 ase_texcoord6 : TEXCOORD6;
				float4 ase_texcoord7 : TEXCOORD7;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)

			float4 _MainTex_ST;
			float4 _AlbedoColor;
			float _FlowSpeed;
			float _ParallaxScale;
			float _HeightDetensity;
			float _MapDetensity;
			CBUFFER_END
			TEXTURE2D(_ShadingGradientTexture);
			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);
			SAMPLER(sampler_ShadingGradientTexture);
			uniform float4 _CameraDepthTexture_TexelSize;


			float SelfShadow836( float3 wp )
			{
				Light mainLight = GetMainLight( TransformWorldToShadowCoord(wp) );
				return mainLight.distanceAttenuation * mainLight.shadowAttenuation ;
			}
			
			float3 AdditionalLightsHalfLambert( float3 WorldPosition, float3 WorldNormal )
			{
				float3 Color = 0;
				#ifdef _ADDITIONAL_LIGHTS
				int numLights = GetAdditionalLightsCount();
				for(int i = 0; i<numLights;i++)
				{
					Light light = GetAdditionalLight(i, WorldPosition);
					half3 AttLightColor = light.color *(light.distanceAttenuation * light.shadowAttenuation);
					Color +=(dot(light.direction, WorldNormal)*0.5+0.5 )* AttLightColor;
					
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

				float temp_output_939_0 = ( v.ase_color.r - 1.5 );
				float3 appendResult779 = (float3(0.0 , temp_output_939_0 , 0.0));
				
				float temp_output_918_0 = radians( ( v.ase_texcoord2.z * 360.0 ) );
				float2 appendResult944 = (float2(-cos( temp_output_918_0 ) , sin( temp_output_918_0 )));
				float2 temp_output_908_0 = (appendResult944).xy;
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float2 temp_output_743_0 = (ase_worldPos).xz;
				float2 panner833 = ( ( 0.4942984 * _FlowSpeed ) * temp_output_908_0 + temp_output_743_0);
				float mulTime928 = _TimeParameters.x * ( _FlowSpeed * 0.05 );
				float2 temp_output_923_0 = ( _MainTex_ST.zw + ( temp_output_908_0 * mulTime928 ) );
				float2 vertexToFrag883 = ( ( panner833 * float2( 0.025,0.025 ) * _MainTex_ST.xy ) + temp_output_923_0 );
				o.ase_texcoord3.xy = vertexToFrag883;
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
				float3 vertexToFrag739 = ase_tanViewDir;
				o.ase_texcoord4.xyz = vertexToFrag739;
				float2 panner745 = ( ( 2.131217 * _FlowSpeed ) * temp_output_908_0 + temp_output_743_0);
				float2 vertexToFrag882 = ( ( panner745 * float2( 0.025,0.025 ) * _MainTex_ST.xy ) + temp_output_923_0 );
				o.ase_texcoord3.zw = vertexToFrag882;
				float temp_output_402_0 = max( max( _MainLightColor.rgb.x , 0.0 ) , 0.0 );
				float4 appendResult406 = (float4(_MainLightColor.rgb , temp_output_402_0));
				float4 vertexToFrag404 = appendResult406;
				o.ase_texcoord6 = vertexToFrag404;
				
				o.ase_texcoord5 = v.vertex;
				o.ase_color = v.ase_color;
				o.ase_texcoord7.xyz = v.ase_texcoord2.xyz;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord4.w = 0;
				o.ase_texcoord7.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = appendResult779;
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
				float2 vertexToFrag883 = IN.ase_texcoord3.xy;
				float2 tc2871 = vertexToFrag883;
				float3 vertexToFrag739 = IN.ase_texcoord4.xyz;
				float3 ts_viewDir740 = vertexToFrag739;
				float2 Offset766 = ( ( ( -_ParallaxScale * 0.11 ) - 1 ) * ( ts_viewDir740.xy / ts_viewDir740.z ) * -_ParallaxScale ) + tc2871;
				float2 vertexToFrag882 = IN.ase_texcoord3.zw;
				float2 tc1869 = vertexToFrag882;
				float4 tex2DNode750 = SAMPLE_TEXTURE2D( _MainTex, sampler_MainTex, tc1869 );
				float parallax_height746 = (tex2DNode750.r).x;
				float2 Offset756 = ( ( parallax_height746 - 1 ) * ( ts_viewDir740.xy / ts_viewDir740.z ) * -_ParallaxScale ) + tc2871;
				float temp_output_773_0 = ( SAMPLE_TEXTURE2D( _MainTex, sampler_MainTex, Offset766 ).a - SAMPLE_TEXTURE2D( _MainTex, sampler_MainTex, Offset756 ).r );
				float2 Offset753 = ( ( ( parallax_height746 * 0.45 ) - 1 ) * ( ts_viewDir740.xy / ts_viewDir740.z ) * -_ParallaxScale ) + tc1869;
				float2 Offset733 = ( ( parallax_height746 - 1 ) * ( ts_viewDir740.xy / ts_viewDir740.z ) * -_ParallaxScale ) + tc1869;
				float temp_output_772_0 = ( SAMPLE_TEXTURE2D( _MainTex, sampler_MainTex, Offset753 ).a - SAMPLE_TEXTURE2D( _MainTex, sampler_MainTex, Offset733 ).r );
				float3 appendResult849 = (float3(( temp_output_773_0 * parallax_height746 ) , parallax_height746 , ( temp_output_772_0 * parallax_height746 )));
				float3 shadowWP977 = appendResult849;
				float3 normalizeResult984 = normalize( ( shadowWP977 + float3( -0.5,-0.5,-0.5 ) ) );
				float3 worldNormal30 = normalizeResult984;
				float dotResult33 = dot( worldNormal30 , _MainLightPosition.xyz );
				float ndl35 = dotResult33;
				float ase_lightAtten = 0;
				Light ase_mainLight = GetMainLight( ShadowCoords );
				ase_lightAtten = ase_mainLight.distanceAttenuation * ase_mainLight.shadowAttenuation;
				float temp_output_939_0 = ( IN.ase_color.r - 1.5 );
				float vertexYOffset940 = temp_output_939_0;
				float3 appendResult803 = (float3(0.0 , vertexYOffset940 , 0.0));
				float3 temp_output_802_0 = ( IN.ase_texcoord5.xyz + appendResult803 );
				float3 objToWorld847 = mul( GetObjectToWorldMatrix(), float4( ( temp_output_802_0 + appendResult849 ), 1 ) ).xyz;
				float3 wp836 = objToWorld847;
				float localSelfShadow836 = SelfShadow836( wp836 );
				float lerpResult860 = lerp( 1.0 , localSelfShadow836 , IN.ase_color.g);
				float2 appendResult862 = (float2(( ( ( ndl35 * 0.5 * ndl35 ) + 0.5 ) * max( ase_lightAtten , 1.0 ) * lerpResult860 ) , 0.5));
				float3 appendResult863 = (float3(SAMPLE_TEXTURE2D( _ShadingGradientTexture, sampler_ShadingGradientTexture, appendResult862 ).rgb));
				float3 appendResult701 = (float3(_AlbedoColor.rgb));
				float4 vertexToFrag404 = IN.ase_texcoord6;
				float4 break407 = vertexToFrag404;
				float3 appendResult409 = (float3(break407.x , break407.y , break407.z));
				float3 LightColor408 = appendResult409;
				float3 worldPosValue44_g57 = WorldPosition;
				float3 WorldPosition22_g57 = worldPosValue44_g57;
				float3 worldNormalValue50_g57 = worldNormal30;
				float3 WorldNormal22_g57 = worldNormalValue50_g57;
				float3 localAdditionalLightsHalfLambert22_g57 = AdditionalLightsHalfLambert( WorldPosition22_g57 , WorldNormal22_g57 );
				float3 halfLambertResult58_g57 = localAdditionalLightsHalfLambert22_g57;
				
				float4 unityObjectToClipPos806 = TransformWorldToHClip(TransformObjectToWorld(temp_output_802_0));
				float4 computeScreenPos807 = ComputeScreenPos( unityObjectToClipPos806 );
				computeScreenPos807 = computeScreenPos807 / computeScreenPos807.w;
				computeScreenPos807.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? computeScreenPos807.z : computeScreenPos807.z* 0.5 + 0.5;
				float eyeDepth791 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( computeScreenPos807.xy ),_ZBufferParams);
				float3 objToWorld795 = mul( GetObjectToWorldMatrix(), float4( temp_output_802_0, 1 ) ).xyz;
				float3 worldToView797 = mul( UNITY_MATRIX_V, float4( objToWorld795, 1 ) ).xyz;
				float temp_output_1005_0 = ( 1.0 - abs( ( ( IN.ase_color.r - 1.5 ) * 1.99 ) ) );
				float temp_output_1010_0 = saturate( ( ( temp_output_1005_0 * temp_output_1005_0 ) / max( _MapDetensity , 0.001 ) ) );
				
#ifdef DISCARD_FRAGMENT
				float DiscardValue = 1.0;
				float DiscardThreshold = 0;

				if(DiscardValue < DiscardThreshold)discard;
#endif
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( ( appendResult863 * appendResult701 * LightColor408 ) + halfLambertResult58_g57 );
				float Alpha = ( _AlbedoColor.a * saturate( ( max( abs( temp_output_772_0 ) , abs( temp_output_773_0 ) ) * saturate( ( ( ( ( eyeDepth791 / -worldToView797.z ) - 1.0 ) * ( ( _WorldSpaceCameraPos.y - objToWorld795.y ) + 10.0 ) ) / max( _HeightDetensity , 0.01 ) ) ) ) ) * temp_output_1010_0 * IN.ase_texcoord7.xyz.xy.x );
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

	
	}
	CustomEditorForRenderPipeline "CustomDrawersShaderEditor" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
	CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=18935
-1913;31;1920;1021;-870.3674;1862.631;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;950;-3632,-4784;Inherit;False;2322.8;702.8;Comment;31;947;949;913;942;943;918;946;944;908;742;743;745;744;932;931;934;936;928;933;935;930;833;762;834;923;872;871;868;882;883;869;Fog UVs;1,0.654717,0.654717,1;0;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;947;-3584,-4352;Inherit;False;2;3;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;949;-3328,-4352;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;360;False;1;FLOAT;0
Node;AmplifyShaderEditor.RadiansOpNode;918;-3200,-4352;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CosOpNode;942;-2944,-4352;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;943;-2944,-4224;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;946;-2816,-4352;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;931;-2944,-4608;Inherit;False;Property;_FlowSpeed;Flow Speed;9;0;Create;True;0;0;0;False;0;False;1;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;932;-2944,-4736;Inherit;False;Constant;_Float0;Float 0;12;0;Create;True;0;0;0;False;0;False;2.131217;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;944;-2688,-4352;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldPosInputsNode;742;-3584,-4736;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;936;-2688,-4608;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.05;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;934;-2688,-4736;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;743;-3328,-4736;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;908;-2560,-4352;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;928;-2560,-4608;Inherit;False;1;0;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;745;-2304,-4736;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1.0771,0.1641;False;1;FLOAT;2.131217;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;930;-2432,-4480;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureTransformNode;762;-2688,-4224;Inherit;False;750;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;744;-2048,-4736;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0.025,0.025;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;923;-2304,-4224;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;868;-1920,-4736;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;933;-2944,-4480;Inherit;False;Constant;_Float1;Float 1;12;0;Create;True;0;0;0;False;0;False;0.4942984;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;882;-1792,-4736;Inherit;False;False;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;869;-1536,-4736;Inherit;False;tc1;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;935;-2688,-4480;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;833;-2304,-4480;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.93411,0.4368767;False;1;FLOAT;0.4942984;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;870;-128,-4096;Inherit;False;869;tc1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;750;128,-4224;Inherit;True;Property;_MainTex;MainTex;7;0;Create;True;0;0;0;False;0;False;-1;None;6a1fffff897d00e459ab3c9226cbedc6;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;834;-2048,-4480;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0.025,0.025;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;737;2512,-3120;Inherit;False;786;238;View Tangent;3;740;739;738;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;872;-1920,-4224;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;738;2560,-3072;Inherit;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;729;512,-4224;Inherit;False;FLOAT;0;1;2;3;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;739;2816,-3072;Inherit;False;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;746;640,-4224;Inherit;False;parallax_height;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;883;-1792,-4224;Inherit;False;False;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;734;-640,-3328;Inherit;False;Property;_ParallaxScale;Parallax Scale;6;0;Create;True;0;0;0;False;0;False;0.1;0.0566;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;747;-384,-3584;Inherit;False;746;parallax_height;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;771;-256,-3328;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;871;-1536,-4224;Inherit;False;tc2;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;740;3072,-3072;Inherit;False;ts_viewDir;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;732;-256,-3072;Inherit;False;740;ts_viewDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;754;128,-3584;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.45;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;765;128,-3200;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.11;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;873;-128,-3712;Inherit;False;871;tc2;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ParallaxMappingNode;733;384,-3840;Inherit;False;Planar;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ParallaxMappingNode;753;384,-3584;Inherit;False;Planar;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ParallaxMappingNode;766;384,-3136;Inherit;False;Planar;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ParallaxMappingNode;756;384,-3328;Inherit;False;Planar;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;757;640,-3328;Inherit;True;Property;_TextureSample5;Texture Sample 5;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;750;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;767;640,-3072;Inherit;True;Property;_TextureSample0;Texture Sample 0;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;750;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;751;640,-3840;Inherit;True;Property;_TextureSample2;Texture Sample 2;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;750;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;752;640,-3584;Inherit;True;Property;_TextureSample4;Texture Sample 4;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;750;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;859;768,-2816;Inherit;False;746;parallax_height;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;773;1024,-3328;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;772;1024,-3712;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;857;1024,-3072;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;858;1024,-3200;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;849;1152,-3072;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexColorNode;778;1920,-2432;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;977;1650,-3056;Inherit;False;shadowWP;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;42;1360,-1328;Inherit;False;1297;421;Prepare Normal;5;30;12;978;984;1013;Prepare Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;939;2176,-2432;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;978;1408,-1280;Inherit;False;977;shadowWP;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;940;2432,-2432;Inherit;False;vertexYOffset;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1013;1664,-1280;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;-0.5,-0.5,-0.5;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;984;2048,-1280;Inherit;True;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;941;-896,-2432;Inherit;False;940;vertexYOffset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;786;-896,-2944;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;410;-2738,-2994;Inherit;False;1558;334;Light;11;401;400;402;399;406;404;407;409;408;405;886;Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;41;1376,-1952;Inherit;False;653;489;Prepare Light Model;9;34;31;40;37;35;38;39;33;36;Prepare Light Model;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;30;2429.4,-1280;Inherit;False;worldNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;803;-640,-2432;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;1009;-560,-1952;Inherit;False;1622.8;1061.4;Comment;17;806;795;807;797;791;796;790;793;794;799;798;800;684;723;697;696;842;Height Alpha;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;802;-512,-2944;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;31;1408,-1904;Inherit;False;30;worldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LightColorNode;399;-2688,-2944;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;34;1392,-1792;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;33;1664,-1904;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;400;-2560,-2816;Inherit;False;FLOAT;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.UnityObjToClipPosHlpNode;806;-512,-1792;Inherit;False;1;0;FLOAT3;0,0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformPositionNode;795;0,-1280;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;848;1280,-3200;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;797;256,-1280;Inherit;False;World;View;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ComputeScreenPosHlpNode;807;-256,-1664;Inherit;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;401;-2432,-2816;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;35;1789,-1900;Inherit;False;ndl;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;402;-2304,-2816;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenDepthNode;791;0,-1664;Inherit;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;951;1485,-3774;Inherit;False;35;ndl;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;804;-896,-2688;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformPositionNode;847;1408,-3200;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NegateNode;796;256,-1408;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;790;-256,-1536;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;991;1664,-3840;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;836;1664,-3200;Inherit;False;Light mainLight = GetMainLight( TransformWorldToShadowCoord(wp) )@$return mainLight.distanceAttenuation * mainLight.shadowAttenuation @;1;Create;1;True;wp;FLOAT3;0,0,0;In;;Inherit;False;SelfShadow;True;False;0;;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;840;1549.1,-3327.201;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;794;0,-1536;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;406;-2048,-2944;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;793;256,-1664;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;808;-640,-2816;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;810;-512,-2816;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1.99;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;799;384,-1536;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;992;1792,-3840;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;684;384,-1792;Inherit;False;Property;_HeightDetensity;Height Detensity;3;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;404;-1920,-2944;Inherit;False;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;841;1805.1,-3327.201;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;860;1869.109,-3190.282;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;798;384,-1664;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;723;640,-1792;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;809;-384,-2816;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;407;-1664,-2944;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;828;2048,-3840;Inherit;False;3;3;0;FLOAT;1;False;1;FLOAT;0.5;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;800;640,-1664;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;832;1152,-3328;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;697;768,-1792;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;862;2304,-3840;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;1005;-256,-2816;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;865;1536,-4224;Inherit;True;Property;_ShadingGradientTexture;Color;1;2;[NoScaleOffset];[SingleLineTexture];Create;False;0;0;0;True;0;False;None;43630138e7bebbe4692eb4cc7a754ee4;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.DynamicAppendNode;409;-1536,-2944;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;775;-256,-2944;Inherit;False;Property;_MapDetensity;Map Detensity;4;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;831;1152,-3712;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;700;1536,-3584;Inherit;False;Property;_AlbedoColor;Albedo Color;0;1;[Header];Create;False;1;______Base Preperties______;0;0;False;1;Space(10);False;1,1,1,1;0.5,0.5,0.5,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;1003;0,-2944;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;864;2646.285,-3996.357;Inherit;True;Property;_TextureSample6;Texture Sample 6;8;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;812;0,-2688;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;696;896,-1792;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;408;-1408,-2944;Inherit;False;LightColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;760;1408,-3328;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;1006;128,-2688;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;997;2048,-3584;Inherit;False;408;LightColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;863;3030.285,-3996.357;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;821;1536,-2944;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;701;1924,-3436;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;996;1536,-2816;Inherit;False;30;worldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;938;1664,-2688;Inherit;False;2;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;830;2183.935,-3254.28;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;448;1360,-816;Inherit;False;1315.667;577;Mask;6;451;450;449;424;423;452;Mask;0.5849056,0.5849056,0.5849056,1;0;0
Node;AmplifyShaderEditor.SaturateNode;1010;256,-2688;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;866;1920,-2944;Inherit;False;SRP Additional Light;-1;;57;6c86746ad131a0a408ca599df5f40861;7,6,1,9,1,23,1,26,0,27,0,24,0,25,0;6;2;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;15;FLOAT3;0,0,0;False;14;FLOAT3;1,1,1;False;18;FLOAT;0.5;False;32;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;774;1664,-2944;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;424;1408,-768;Inherit;True;Property;_MetallicGlossMap;Metallic Map;2;1;[SingleLineTexture];Create;False;0;0;0;False;1;Space(15);False;None;82a44da0e6fe55045b2b3a5debf0144e;False;black;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;12;1408,-1152;Inherit;False;Property;_NormalMapIntensity;Normal Map Intensity;5;0;Create;False;0;0;0;False;0;False;1;2.55;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;779;2304,-2688;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1012;381.149,-2793.517;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.05;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;423;1664,-768;Inherit;True;Property;_TextureSample3;Texture Sample 3;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;952;1315.085,-4079.223;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;954;1299.325,-3907.772;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;450;2048,-640;Inherit;False;smoothnessMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;913;-3584,-4480;Inherit;False;Property;_FlowAngle;Flow Angle;8;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;842;256,-1024;Inherit;False;worldPosition;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;38;1792,-1776;Inherit;False;ndv;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;36;1408,-1648;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;823;2048,-2816;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;886;-2176,-2816;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.0001;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;449;2048,-768;Inherit;False;metallicMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;451;2048,-512;Inherit;False;aoMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;37;1664,-1776;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;953;1667.325,-3939.772;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;867;2176,-2944;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;39;1664,-1648;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;452;2048,-384;Inherit;False;emissionMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;995;1924.248,-2632.836;Inherit;False;38;ndv;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;405;-1408,-2818.01;Inherit;False;LightIntensity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;999;416.8361,-4138.317;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;40;1792,-1648;Inherit;False;vdl;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;651;1901.282,-2816;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;21;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;FullScreenPass;0;1;FullScreenPass;4;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;7;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForwardOnly;True;2;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;117;1408,-2816;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;21;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;ExtraPrePass;0;2;Outline;6;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;True;True;1;1;True;415;0;True;416;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;True;1;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;True;True;True;128;False;-1;255;False;-1;255;False;-1;2;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;1;MRT Output;0;637974302310119949;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;118;2560,-2816;Half;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;21;Treeverse/VFX/AreaFog;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;Forward;0;3;Forward;12;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;True;True;False;128;False;-1;255;False;-1;255;False;-1;7;False;-1;3;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;True;True;2;5;False;415;10;False;416;0;5;False;-1;1;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;2;False;-1;True;3;False;-1;True;False;0;False;-1;0;False;-1;True;1;LightMode=UniversalForwardOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;18;Surface;1;637934776135466903;  Blend;0;0;Two Sided;1;637988289116458818;Cast Shadows;0;637989049756704363;  Use Shadow Threshold;0;0;Receive Shadows;1;637989052069076295;GPU Instancing;1;0;LOD CrossFade;0;0;Treeverse Linear Fog;1;637993464678671687;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;0;637988244116982952;Full Screen Pass;0;637988272258335592;Additional Pass;0;637988244126039661;Scene Selectioin Pass;0;637988244140085544;Vertex Position,InvertActionOnDeselection;1;0;Discard Fragment;0;0;Push SelfShadow to Main Light;0;0;2;MRT Output;0;637988247105428694;Custom Output Position;0;0;8;False;False;False;True;False;False;False;False;False;;True;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;122;512,-640;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;21;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;Meta;0;7;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;121;1408,-2816;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;21;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;SceneSelectionPass;0;6;SceneSelectionPass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=SceneSelectionPass;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;119;512,-640;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;21;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;ShadowCaster;0;4;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;120;512,-640;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;21;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;DepthOnly;0;5;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;314;-208,-2816;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;21;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;AdditionalPass;0;0;ToonPostProcessing;6;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;True;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;1;False;-1;True;3;False;-1;True;False;0;False;-1;0;False;-1;True;1;LightMode=ToonPostProcessing;False;False;0;Hidden/InternalErrorShader;0;0;Standard;1;MRT Output;0;637933887809711874;False;0
WireConnection;949;0;947;3
WireConnection;918;0;949;0
WireConnection;942;0;918;0
WireConnection;943;0;918;0
WireConnection;946;0;942;0
WireConnection;944;0;946;0
WireConnection;944;1;943;0
WireConnection;936;0;931;0
WireConnection;934;0;932;0
WireConnection;934;1;931;0
WireConnection;743;0;742;0
WireConnection;908;0;944;0
WireConnection;928;0;936;0
WireConnection;745;0;743;0
WireConnection;745;2;908;0
WireConnection;745;1;934;0
WireConnection;930;0;908;0
WireConnection;930;1;928;0
WireConnection;744;0;745;0
WireConnection;744;2;762;0
WireConnection;923;0;762;1
WireConnection;923;1;930;0
WireConnection;868;0;744;0
WireConnection;868;1;923;0
WireConnection;882;0;868;0
WireConnection;869;0;882;0
WireConnection;935;0;933;0
WireConnection;935;1;931;0
WireConnection;833;0;743;0
WireConnection;833;2;908;0
WireConnection;833;1;935;0
WireConnection;750;1;870;0
WireConnection;834;0;833;0
WireConnection;834;2;762;0
WireConnection;872;0;834;0
WireConnection;872;1;923;0
WireConnection;729;0;750;1
WireConnection;739;0;738;0
WireConnection;746;0;729;0
WireConnection;883;0;872;0
WireConnection;771;0;734;0
WireConnection;871;0;883;0
WireConnection;740;0;739;0
WireConnection;754;0;747;0
WireConnection;765;0;771;0
WireConnection;733;0;870;0
WireConnection;733;1;747;0
WireConnection;733;2;771;0
WireConnection;733;3;732;0
WireConnection;753;0;870;0
WireConnection;753;1;754;0
WireConnection;753;2;771;0
WireConnection;753;3;732;0
WireConnection;766;0;873;0
WireConnection;766;1;765;0
WireConnection;766;2;771;0
WireConnection;766;3;732;0
WireConnection;756;0;873;0
WireConnection;756;1;747;0
WireConnection;756;2;771;0
WireConnection;756;3;732;0
WireConnection;757;1;756;0
WireConnection;767;1;766;0
WireConnection;751;1;733;0
WireConnection;752;1;753;0
WireConnection;773;0;767;4
WireConnection;773;1;757;1
WireConnection;772;0;752;4
WireConnection;772;1;751;1
WireConnection;857;0;772;0
WireConnection;857;1;859;0
WireConnection;858;0;773;0
WireConnection;858;1;859;0
WireConnection;849;0;858;0
WireConnection;849;1;859;0
WireConnection;849;2;857;0
WireConnection;977;0;849;0
WireConnection;939;0;778;1
WireConnection;940;0;939;0
WireConnection;1013;0;978;0
WireConnection;984;0;1013;0
WireConnection;30;0;984;0
WireConnection;803;1;941;0
WireConnection;802;0;786;0
WireConnection;802;1;803;0
WireConnection;33;0;31;0
WireConnection;33;1;34;0
WireConnection;400;0;399;1
WireConnection;806;0;802;0
WireConnection;795;0;802;0
WireConnection;848;0;802;0
WireConnection;848;1;849;0
WireConnection;797;0;795;0
WireConnection;807;0;806;0
WireConnection;401;0;400;0
WireConnection;35;0;33;0
WireConnection;402;0;401;0
WireConnection;791;0;807;0
WireConnection;847;0;848;0
WireConnection;796;0;797;3
WireConnection;991;0;951;0
WireConnection;991;2;951;0
WireConnection;836;0;847;0
WireConnection;794;0;790;2
WireConnection;794;1;795;2
WireConnection;406;0;399;1
WireConnection;406;3;402;0
WireConnection;793;0;791;0
WireConnection;793;1;796;0
WireConnection;808;0;804;1
WireConnection;810;0;808;0
WireConnection;799;0;794;0
WireConnection;992;0;991;0
WireConnection;404;0;406;0
WireConnection;841;0;840;0
WireConnection;860;1;836;0
WireConnection;860;2;804;2
WireConnection;798;0;793;0
WireConnection;723;0;684;0
WireConnection;809;0;810;0
WireConnection;407;0;404;0
WireConnection;828;0;992;0
WireConnection;828;1;841;0
WireConnection;828;2;860;0
WireConnection;800;0;798;0
WireConnection;800;1;799;0
WireConnection;832;0;773;0
WireConnection;697;0;800;0
WireConnection;697;1;723;0
WireConnection;862;0;828;0
WireConnection;1005;0;809;0
WireConnection;409;0;407;0
WireConnection;409;1;407;1
WireConnection;409;2;407;2
WireConnection;831;0;772;0
WireConnection;1003;0;775;0
WireConnection;864;0;865;0
WireConnection;864;1;862;0
WireConnection;864;7;865;1
WireConnection;812;0;1005;0
WireConnection;812;1;1005;0
WireConnection;696;0;697;0
WireConnection;408;0;409;0
WireConnection;760;0;831;0
WireConnection;760;1;832;0
WireConnection;1006;0;812;0
WireConnection;1006;1;1003;0
WireConnection;863;0;864;0
WireConnection;821;0;760;0
WireConnection;821;1;696;0
WireConnection;701;0;700;0
WireConnection;830;0;863;0
WireConnection;830;1;701;0
WireConnection;830;2;997;0
WireConnection;1010;0;1006;0
WireConnection;866;11;996;0
WireConnection;774;0;821;0
WireConnection;779;1;939;0
WireConnection;1012;0;1010;0
WireConnection;423;0;424;0
WireConnection;423;7;424;1
WireConnection;450;0;423;2
WireConnection;842;0;795;0
WireConnection;38;0;37;0
WireConnection;823;0;700;4
WireConnection;823;1;774;0
WireConnection;823;2;1010;0
WireConnection;823;3;938;1
WireConnection;886;0;402;0
WireConnection;449;0;423;1
WireConnection;451;0;423;3
WireConnection;37;0;31;0
WireConnection;37;1;36;0
WireConnection;953;0;952;0
WireConnection;953;1;954;0
WireConnection;867;0;830;0
WireConnection;867;1;866;0
WireConnection;39;0;34;0
WireConnection;39;1;36;0
WireConnection;452;0;423;4
WireConnection;405;0;407;3
WireConnection;999;0;750;1
WireConnection;999;1;750;4
WireConnection;40;0;39;0
WireConnection;118;2;867;0
WireConnection;118;3;823;0
WireConnection;118;5;779;0
ASEEND*/
//CHKSM=F126BF58CC789785F3FCA3623846AB216B9A5E22
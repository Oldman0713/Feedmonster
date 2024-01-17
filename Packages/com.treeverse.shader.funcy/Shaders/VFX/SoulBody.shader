// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Treeverse/VFX/SoulBody"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[ASEBegin]_MainTex("MainTex", 2D) = "white" {}
		_Speed("Speed", Float) = 1
		_push("push", Float) = 1
		[ASEEnd][HDR]_Color("Color", Color) = (1,1,1,1)

		
	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
		
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
			
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			ZTest Always
			Offset 0,0
			ColorMask RGBA
			

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
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

			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_VERT_POSITION


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
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
				
				float fogFactor : TEXCOORD2;
				
				float4 ase_color : COLOR;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)

			float4 _Color;
			float4 _MainTex_ST;
			float _push;
			float _Speed;
			CBUFFER_END
			uniform float4 _CameraDepthTexture_TexelSize;
			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);


						
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord3 = screenPos;
				float3 objectToViewPos = TransformWorldToView(TransformObjectToWorld(v.vertex.xyz));
				float eyeDepth = -objectToViewPos.z;
				o.ase_texcoord4.z = eyeDepth;
				
				o.ase_color = v.ase_color;
				o.ase_texcoord4.xy = v.ase_texcoord.xy;
				o.ase_texcoord5 = v.ase_texcoord1;
				o.ase_texcoord6 = v.ase_texcoord2;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord4.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( ase_worldViewDir * _push );
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
				float3 appendResult86 = (float3(IN.ase_color.rgb));
				float3 appendResult87 = (float3(_Color.rgb));
				
				float4 screenPos = IN.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 appendResult31 = (float2(ase_screenPosNorm.x , ase_screenPosNorm.y));
				float2 screenUV40 = appendResult31;
				float mulTime34 = _TimeParameters.x * _Speed;
				float2 uv_MainTex = IN.ase_texcoord4.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 appendResult91 = (float2(IN.ase_texcoord5.x , IN.ase_texcoord5.y));
				float2 appendResult92 = (float2(IN.ase_texcoord5.z , IN.ase_texcoord5.w));
				float2 temp_output_93_0 = (uv_MainTex*appendResult91 + appendResult92);
				float2 panner38 = ( mulTime34 * float2( 0,-0.9913 ) + temp_output_93_0);
				float2 panner39 = ( mulTime34 * float2( 0.217,-0.799641 ) + temp_output_93_0);
				float2 appendResult48 = (float2(0.0 , ( ( max( SAMPLE_TEXTURE2D( _MainTex, sampler_MainTex, frac( panner38 ) ).b , SAMPLE_TEXTURE2D( _MainTex, sampler_MainTex, frac( panner39 ) ).b ) - 0.4 ) * IN.ase_texcoord6.x )));
				float4 appendResult30 = (float4(( screenUV40 + appendResult48 ) , ase_screenPosNorm.z , ase_screenPosNorm.w));
				float eyeDepth11 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( appendResult30.xy ),_ZBufferParams);
				float eyeDepth = IN.ase_texcoord4.z;
				float smoothstepResult26 = smoothstep( 0.999 , 1.0 , abs( ( eyeDepth11 - eyeDepth ) ));
				float eyeDepth52 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float smoothstepResult55 = smoothstep( 0.999 , 1.0 , abs( ( eyeDepth52 - eyeDepth ) ));
				float temp_output_79_0 = ( 1.0 - abs( ( ( IN.ase_texcoord4.xy.x - 0.5 ) * 2.0 ) ) );
				float smoothstepResult80 = smoothstep( 0.0 , 1.0 , temp_output_79_0);
				
#ifdef DISCARD_FRAGMENT
				float DiscardValue = 1.0;
				float DiscardThreshold = 0;

				if(DiscardValue < DiscardThreshold)discard;
#endif
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( appendResult86 * appendResult87 );
				float Alpha = ( IN.ase_color.a * _Color.a * saturate( ( ( ( 1.0 - smoothstepResult26 ) - ( 1.0 - smoothstepResult55 ) ) * smoothstepResult80 * saturate( ( IN.ase_texcoord4.xy.y - 0.1 ) ) ) ) );
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
2560;307;2048;1100.6;3207.378;424.5792;1.029639;True;False
Node;AmplifyShaderEditor.TexCoordVertexDataNode;50;-3793.137,-552.3341;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;33;-3358,107;Inherit;False;Property;_Speed;Speed;1;0;Create;True;0;0;0;False;0;False;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;61;-3626.328,-307.1855;Inherit;False;0;43;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;91;-3513.253,-624.3223;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;92;-3539.821,-466.8282;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;93;-3287.368,-395.679;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;34;-3200,0;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;38;-2992,-160;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,-0.9913;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;39;-2992,-32;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.217,-0.799641;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FractNode;36;-2784,-160;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FractNode;35;-2784,-32;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;43;-2624,-208;Inherit;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;0;False;0;False;-1;65a8c5e7454b8fe45a5edf74bf690048;65a8c5e7454b8fe45a5edf74bf690048;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;42;-2624,0;Inherit;True;Property;_TextureSample1;Texture Sample 1;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;43;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;44;-2304,-128;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;29;-2162,-601;Float;True;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;94;-2526.787,344.1496;Inherit;False;2;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;51;-2048,-128;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.4;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;31;-1664,-385.291;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-1792,-128;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;40;-1536,-384;Inherit;False;screenUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;48;-1540.618,-125.4367;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;47;-1768.618,-258.4367;Inherit;False;40;screenUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;49;-1427.618,-274.4367;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;30;-1143,-390;Inherit;False;FLOAT4;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SurfaceDepthNode;15;-768,-256;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;72;-1461.657,3.5;Inherit;True;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenDepthNode;11;-1024,-384;Inherit;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenDepthNode;52;-1024,-512;Inherit;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;54;-512,-512;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;77;-1236.657,59.5;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;16;-513,-384;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;66;-384,-512;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;-979.6575,48.5;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;67;-384,-384;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;78;-826.6575,40.5;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;55;-212,-513;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.999;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;26;-140,-183;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.999;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;27;20,-183;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;79;-666.6575,41.5;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;56;-84,-513;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;75;-610.6575,-97.5;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;76;-446.6575,-99.5;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;60;80,-340;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;80;-263.6575,-22.5;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;463.3425,-161.5;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;84;197.3425,-585.5;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;83;196.3425,-392.5;Inherit;False;Property;_Color;Color;4;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;5.656854,5.656854,5.656854,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;88;583.3425,-152.5;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;86;440.3425,-581.5;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;68;-293.311,278.6397;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;87;425.3425,-499.5;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-183.6575,433.5;Inherit;False;Property;_push;push;3;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;21;-972.222,334.5889;Inherit;False;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;63;-3788.461,18.62061;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-1100.222,334.5889;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;4,4;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-2544,256;Inherit;False;Property;_RefractionIntensity;Refraction Intensity;2;0;Create;True;0;0;0;False;0;False;0.438;0.112;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewMatrixNode;20;-972.222,462.5889;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;34.34253,146.5;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;69;-25.65747,265.5;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;25;-460.222,334.5889;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ObjectToWorldMatrixNode;22;-972.222,590.5889;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;-3864,-218;Inherit;False;40;screenUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;17;-1484.222,338.5889;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexToFragmentNode;82;-491.6575,61.5;Inherit;False;False;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;62;-3719.461,-97.37939;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-844.222,334.5889;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;90;753.6365,-244.4429;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureTransformNode;89;-3810.961,186.1435;Inherit;False;-1;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-588.222,334.5889;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SurfaceDepthNode;64;-4172.461,18.62061;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-3509.128,-118.0464;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;16,16;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;18;-1228.222,334.5889;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;696.3425,-473.5;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;ExtraPrePass;0;2;ExtraPrePass;6;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;1;MRT Output;0;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;ShadowCaster;0;4;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;21,-137;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;21;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;FullScreenPass;0;1;FullScreenPass;4;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;7;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForwardOnly;True;2;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;939,-350;Half;False;True;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;21;Treeverse/VFX/SoulBody;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;Forward;0;3;Forward;12;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;True;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;2;False;-1;True;7;False;-1;True;False;0;False;-1;0;False;-1;True;1;LightMode=UniversalForwardOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;19;Surface;1;638030500775370365;  Blend;0;0;Two Sided;0;638030525928808980;Cast Shadows;0;638030500816541947;  Use Shadow Threshold;0;0;Receive Shadows;0;638030500801319938;GPU Instancing;1;0;LOD CrossFade;0;0;Treeverse Linear Fog;0;0;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;0;0;Full Screen Pass;0;638030535546214492;Additional Pass;0;0;Scene Selectioin Pass;0;0;Vertex Position,InvertActionOnDeselection;1;0;Vertex Operation Hide Pass Only;0;0;Discard Fragment;0;0;Push SelfShadow to Main Light;0;0;2;MRT Output;0;0;Custom Output Position;0;0;8;False;False;False;True;False;False;False;False;False;;True;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;6;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;SceneSelectionPass;0;6;SceneSelectionPass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=SceneSelectionPass;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;AdditionalPass;0;0;AdditionalPass;6;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;1;MRT Output;0;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;7;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;Meta;0;7;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;5;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;DepthOnly;0;5;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;91;0;50;1
WireConnection;91;1;50;2
WireConnection;92;0;50;3
WireConnection;92;1;50;4
WireConnection;93;0;61;0
WireConnection;93;1;91;0
WireConnection;93;2;92;0
WireConnection;34;0;33;0
WireConnection;38;0;93;0
WireConnection;38;1;34;0
WireConnection;39;0;93;0
WireConnection;39;1;34;0
WireConnection;36;0;38;0
WireConnection;35;0;39;0
WireConnection;43;1;36;0
WireConnection;42;1;35;0
WireConnection;44;0;43;3
WireConnection;44;1;42;3
WireConnection;51;0;44;0
WireConnection;31;0;29;1
WireConnection;31;1;29;2
WireConnection;46;0;51;0
WireConnection;46;1;94;1
WireConnection;40;0;31;0
WireConnection;48;1;46;0
WireConnection;49;0;47;0
WireConnection;49;1;48;0
WireConnection;30;0;49;0
WireConnection;30;2;29;3
WireConnection;30;3;29;4
WireConnection;11;0;30;0
WireConnection;52;0;29;0
WireConnection;54;0;52;0
WireConnection;54;1;15;0
WireConnection;77;0;72;1
WireConnection;16;0;11;0
WireConnection;16;1;15;0
WireConnection;66;0;54;0
WireConnection;81;0;77;0
WireConnection;67;0;16;0
WireConnection;78;0;81;0
WireConnection;55;0;66;0
WireConnection;26;0;67;0
WireConnection;27;0;26;0
WireConnection;79;0;78;0
WireConnection;56;0;55;0
WireConnection;75;0;72;2
WireConnection;76;0;75;0
WireConnection;60;0;27;0
WireConnection;60;1;56;0
WireConnection;80;0;79;0
WireConnection;73;0;60;0
WireConnection;73;1;80;0
WireConnection;73;2;76;0
WireConnection;88;0;73;0
WireConnection;86;0;84;0
WireConnection;87;0;83;0
WireConnection;21;0;19;0
WireConnection;63;0;64;0
WireConnection;19;0;18;0
WireConnection;70;0;68;0
WireConnection;70;1;71;0
WireConnection;25;0;24;0
WireConnection;82;0;79;0
WireConnection;62;0;41;0
WireConnection;62;1;63;0
WireConnection;23;0;21;0
WireConnection;23;1;20;0
WireConnection;90;0;84;4
WireConnection;90;1;83;4
WireConnection;90;2;88;0
WireConnection;24;0;23;0
WireConnection;24;1;22;0
WireConnection;65;0;41;0
WireConnection;18;0;17;0
WireConnection;85;0;86;0
WireConnection;85;1;87;0
WireConnection;3;2;85;0
WireConnection;3;3;90;0
WireConnection;3;5;70;0
ASEEND*/
//CHKSM=33086088AFFA641A5DB00CE6EAD4FAA7BCF8C6D1
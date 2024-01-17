// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Treeverse/Dynamic/Eyes"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[ASEBegin][Header(______Base Preperties______)][Space(10)]_AlbedoColor("Albedo Color", Color) = (1,1,1,1)
		[SingleLineTexture]_AlbedoMap("Albedo Map", 2D) = "white" {}
		[Header(Specular Settings)][Space(10)]_SpecularBrightness("Specular Brightness", Float) = 1
		_Metallic("Metallic", Range( 0 , 1)) = 1
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.938
		[Header(______Shadow______)][Space(10)]_GoochBrightColor("Shadow Light Color", Color) = (1,1,1,1)
		_GoochDarkColor("Shadow Dark Color", Color) = (0,0,0,1)
		[Header(______Blend Mode______)][Enum(UnityEngine.Rendering.BlendMode)][Space(15)]_SRC("Src", Float) = 1
		[Enum(UnityEngine.Rendering.BlendMode)]_DST("Dst", Float) = 0
		_ParallaxScale("Parallax Scale", Float) = 0.25
		[Vector2]_Specular1Offset("Specular 1 Offset", Vector) = (0,0,0,0)
		[Vector2]_Specular1Scale("Specular 1 Scale", Vector) = (1,1,0,0)
		[Vector2]_Specular2Offset("Specular 2 Offset", Vector) = (0.13,-0.1,0,0)
		[Vector2]_Specular2Scale("Specular 2 Scale", Vector) = (1.68,1,0,0)
		[ASEEnd]_SelfShadow("SelfShadow", 2D) = "white" {}

		
	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Geometry" }
		
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
			
			Blend [_SRC] [_DST]
			ZWrite On
			ZTest LEqual
			Offset 0,0
			ColorMask RGBA
			

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
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
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)

			float4 _AlbedoColor;
			float4 _GoochDarkColor;
			float4 _GoochBrightColor;
			float2 _Specular1Scale;
			float2 _Specular1Offset;
			float2 _Specular2Scale;
			float2 _Specular2Offset;
			float _SRC;
			float _DST;
			float _Smoothness;
			float _ParallaxScale;
			float _SpecularBrightness;
			float _Metallic;
			CBUFFER_END
			TEXTURE2D(_AlbedoMap);
			SAMPLER(sampler_AlbedoMap);
			TEXTURE2D(_SelfShadow);
			SAMPLER(sampler_SelfShadow);


						
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 appendResult732 = (float3(_MainLightPosition.xyz.x , 0.01 , _MainLightPosition.xyz.z));
				float3 normalizeResult733 = normalize( appendResult732 );
				float3 objToWorldDir788 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,1 ), 0 ) ).xyz;
				float dotResult792 = dot( -normalizeResult733 , objToWorldDir788 );
				float smoothstepResult870 = smoothstep( 0.0 , 1.0 , ( ( -dotResult792 * 0.5 ) + 0.5 ));
				float4 appendResult791 = (float4(sign( (cross( -normalizeResult733 , objToWorldDir788 )).y ) , ( acos( -dotResult792 ) / PI ) , smoothstepResult870 , step( 0.0 , v.vertex.xyz.x )));
				float4 break849 = appendResult791;
				float cm_v851 = break849.x;
				float angle01_v850 = break849.y;
				float2 appendResult861 = (float2(( v.ase_texcoord.x + ( ( cm_v851 * angle01_v850 ) * 0.125 ) ) , v.ase_texcoord.y));
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				float fresnelNdotV845 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode845 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV845, 1.0 ) );
				float parallaxScale854 = _ParallaxScale;
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 ase_tanViewDir =  tanToWorld0 * ase_worldViewDir.x + tanToWorld1 * ase_worldViewDir.y  + tanToWorld2 * ase_worldViewDir.z;
				ase_tanViewDir = normalize(ase_tanViewDir);
				float3 vertexToFrag654 = ase_tanViewDir;
				float3 ts_viewDir655 = vertexToFrag654;
				float2 Offset843 = ( ( ( 1.0 - fresnelNode845 ) - 1 ) * ts_viewDir655.xy * ( parallaxScale854 * 0.4 ) ) + appendResult861;
				float2 vertexToFrag847 = Offset843;
				o.ase_texcoord3.xy = vertexToFrag847;
				o.ase_texcoord4.xyz = vertexToFrag654;
				float4 vertexToFrag744 = appendResult791;
				o.ase_texcoord5 = vertexToFrag744;
				float4 appendResult406 = (float4(_MainLightColor.rgb , max( max( _MainLightColor.rgb.x , 0.0 ) , 0.0 )));
				float4 vertexToFrag404 = appendResult406;
				o.ase_texcoord6 = vertexToFrag404;
				
				o.ase_texcoord3.zw = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord4.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
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
				float selfShadowPush = 0.2;
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
				float temp_output_687_0 = ( 1.0 - _Smoothness );
				float temp_output_689_0 = ( temp_output_687_0 - 0.01 );
				float temp_output_690_0 = ( temp_output_687_0 + 0.01 );
				float2 vertexToFrag847 = IN.ase_texcoord3.xy;
				float2 temp_output_686_0 = ( ( vertexToFrag847 - float2( 0.5,0.5 ) ) * float2( 2,2 ) );
				float smoothstepResult840 = smoothstep( temp_output_689_0 , temp_output_690_0 , length( ( ( temp_output_686_0 / _Specular1Scale ) + -_Specular1Offset ) ));
				float smoothstepResult688 = smoothstep( temp_output_689_0 , temp_output_690_0 , length( ( ( temp_output_686_0 / _Specular2Scale ) + -_Specular2Offset ) ));
				float3 appendResult135 = (float3(_AlbedoColor.rgb));
				float parallaxScale854 = _ParallaxScale;
				float3 vertexToFrag654 = IN.ase_texcoord4.xyz;
				float3 ts_viewDir655 = vertexToFrag654;
				float2 Offset653 = ( ( (SAMPLE_TEXTURE2D( _AlbedoMap, sampler_AlbedoMap, IN.ase_texcoord3.zw ).a).x - 1 ) * ts_viewDir655.xy * parallaxScale854 ) + IN.ase_texcoord3.zw;
				float2 parallaxUV698 = Offset653;
				float4 tex2DNode137 = SAMPLE_TEXTURE2D( _AlbedoMap, sampler_AlbedoMap, parallaxUV698 );
				float3 appendResult8 = (float3(tex2DNode137.rgb));
				float3 albedoColor170 = ( appendResult135 * appendResult8 );
				float3 normalizeResult623 = normalize( max( albedoColor170 , float3( 0.01,0.01,0.01 ) ) );
				float temp_output_530_0 = ( 1.0 - _Metallic );
				float3 lerpResult526 = lerp( float3( 1,1,1 ) , ( normalizeResult623 * ( _SpecularBrightness + 1.0 ) ) , ( 1.0 - ( temp_output_530_0 * temp_output_530_0 ) ));
				float4 vertexToFrag744 = IN.ase_texcoord5;
				float4 break799 = vertexToFrag744;
				float odl_f803 = break799.z;
				float ase_lightAtten = 0;
				Light ase_mainLight = GetMainLight( ShadowCoords );
				ase_lightAtten = ase_mainLight.distanceAttenuation * ase_mainLight.shadowAttenuation;
				float temp_output_519_0 = ( 1.0 - saturate( ( ( ( ( _Smoothness * odl_f803 * ase_lightAtten ) - 0.5 ) * 2.0 ) * -1.0 ) ) );
				float temp_output_520_0 = ( temp_output_519_0 * temp_output_519_0 );
				float3 Out_Specular447 = ( ( 1.0 - ( smoothstepResult840 * smoothstepResult688 ) ) * ( lerpResult526 * ( temp_output_520_0 * temp_output_520_0 ) ) * ( _SpecularBrightness * _SpecularBrightness ) * odl_f803 );
				float4 lerpResult124 = lerp( float4( 1,1,1,1 ) , _GoochDarkColor , _GoochDarkColor.a);
				float3 appendResult101 = (float3(lerpResult124.rgb));
				float4 lerpResult125 = lerp( float4( 1,1,1,1 ) , _GoochBrightColor , _GoochBrightColor.a);
				float3 appendResult100 = (float3(lerpResult125.rgb));
				float cm_f800 = break799.x;
				float angle01_f801 = break799.y;
				float temp_output_828_0 = ( IN.ase_texcoord3.zw.x + ( cm_f800 * 0.0625 * angle01_f801 ) );
				float mirror_f822 = break799.w;
				float lerpResult826 = lerp( temp_output_828_0 , ( 1.0 - temp_output_828_0 ) , mirror_f822);
				float2 appendResult815 = (float2(lerpResult826 , IN.ase_texcoord3.zw.y));
				float diff676 = ( ase_lightAtten * SAMPLE_TEXTURE2D( _SelfShadow, sampler_SelfShadow, appendResult815 ).r * odl_f803 );
				float4 vertexToFrag404 = IN.ase_texcoord6;
				float4 break407 = vertexToFrag404;
				float LightIntensity405 = max( break407.w , 0.5 );
				float3 lerpResult99 = lerp( appendResult101 , appendResult100 , ( diff676 * LightIntensity405 ));
				float3 shadowColor178 = lerpResult99;
				
				float alpha419 = ( _AlbedoColor.a * tex2DNode137.a );
				
#ifdef DISCARD_FRAGMENT
				float DiscardValue = 1.0;
				float DiscardThreshold = 0;

				if(DiscardValue < DiscardThreshold)discard;
#endif
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( Out_Specular447 + ( albedoColor170 * shadowColor178 ) );
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

	
	}
	CustomEditorForRenderPipeline "CustomDrawersShaderEditor" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
	CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=18935
330;902;1920;792;2764.971;4045.351;1;True;False
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;707;-2688,-3712;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;732;-2416,-3712;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0.01;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;733;-2288,-3712;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformDirectionNode;788;-2688,-3584;Inherit;False;Object;World;False;Fast;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NegateNode;734;-2160,-3712;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;792;-1920,-3584;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;793;-1792,-3584;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;804;-1664,-3840;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.CrossProductOpNode;748;-1936,-3712;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;789;-1744,-3712;Inherit;False;FLOAT;1;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ACosOpNode;794;-1664,-3584;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;820;-2688,-3200;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PiNode;795;-1792,-3456;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;805;-1536,-3840;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;796;-1536,-3584;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SignOpNode;872;-1536,-3712;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;870;-1408,-3840;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;821;-2432,-3200;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;657;-2738,-2626;Inherit;False;786;238;View Tangent;3;654;655;656;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;791;-1280,-3712;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;656;-2688,-2576;Inherit;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.BreakToComponentsNode;849;-1152,-3456;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.TexCoordVertexDataNode;659;-3328,-1792;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;136;-2880,-1963;Inherit;True;Property;_AlbedoMap;Albedo Map;1;1;[SingleLineTexture];Create;False;0;0;0;False;0;False;None;b00fdf2dad17e5d4eb34118ca648b9d6;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.VertexToFragmentNode;654;-2432,-2576;Inherit;False;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;850;-1024,-3456;Inherit;False;angle01_v;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;851;-1024,-3584;Inherit;False;cm_v;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;744;-1408,-3968;Inherit;False;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;662;-2634.999,-1803.538;Inherit;True;Property;_TextureSample2;Texture Sample 2;21;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;867;-3584,1408;Inherit;False;850;angle01_v;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;661;-3584,-1664;Inherit;False;Property;_ParallaxScale;Parallax Scale;11;0;Create;True;0;0;0;False;0;False;0.25;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;856;-3584,1280;Inherit;False;851;cm_v;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;655;-2176,-2576;Inherit;False;ts_viewDir;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;854;-3328,-1664;Inherit;False;parallaxScale;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;858;-3328,1280;Inherit;False;2;2;0;FLOAT;1;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;799;-1152,-3968;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;658;-3281.999,-1479.538;Inherit;False;655;ts_viewDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;660;-3051.999,-1455.538;Inherit;True;FLOAT;0;1;2;3;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;801;-1024,-3968;Inherit;False;angle01_f;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;842;-3200,1024;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;410;-2738,-2994;Inherit;False;1558;334;Light;11;401;400;402;399;406;404;407;409;408;405;549;Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;859;-3200,1280;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.125;False;1;FLOAT;0
Node;AmplifyShaderEditor.ParallaxMappingNode;653;-2816,-1664;Inherit;False;Normal;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;800;-1024,-4096;Inherit;False;cm_f;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;845;-3528,1650;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;698;-2560,-1536;Inherit;False;parallaxUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;812;-1920,1280;Inherit;False;801;angle01_f;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;860;-2944,1024;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;399;-2688,-2944;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;811;-1920,1024;Inherit;False;800;cm_f;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;855;-3200,1536;Inherit;False;854;parallaxScale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;816;-1664,1152;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0.0625;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;846;-2944,1792;Inherit;False;655;ts_viewDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;171;-2482,-2098;Inherit;False;1170;536;Albedo Color;8;134;8;137;133;135;170;419;652;Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;848;-3202.989,1661.52;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;861;-2816,1152;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;699;-2392.926,-1619.914;Inherit;False;698;parallaxUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;458;-2686.076,1870;Inherit;False;2250.979;1595.016;Specular;45;43;512;511;624;447;518;444;622;482;523;442;520;517;519;532;521;441;526;531;530;623;499;621;683;692;701;686;702;696;687;695;684;689;690;688;691;829;830;831;832;833;834;840;841;862;Specular;1,0.8389269,0,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;844;-3016.501,1539.055;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.4;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;803;-1024,-3840;Inherit;False;odl_f;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;809;-1920,768;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;400;-2560,-2816;Inherit;False;FLOAT;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.LightAttenuation;865;-2612.784,3594.143;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;401;-2432,-2816;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;822;-1024,-3712;Inherit;False;mirror_f;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ParallaxMappingNode;843;-2688,1536;Inherit;True;Normal;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;828;-1536,768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-2560,3328;Inherit;False;Property;_Smoothness;Smoothness;4;0;Create;False;0;0;0;False;0;False;0.938;0.958;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;133;-2432,-2048;Inherit;False;Property;_AlbedoColor;Albedo Color;0;1;[Header];Create;False;1;______Base Preperties______;0;0;False;1;Space(10);False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;137;-2208,-1817;Inherit;True;Property;_TextureSample0;Texture Sample 0;15;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;869;-2602.796,3477.01;Inherit;False;803;odl_f;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;864;-2362.898,3425.412;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;847;-2304,1536;Inherit;False;False;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;402;-2304,-2816;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;823;-1408,768;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;135;-1920,-2048;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;666;-1248,560;Inherit;False;1220.843;698.9229;Light Threshold;7;703;676;673;678;806;815;826;Light Threshold;0.9434034,0.9811321,0.4118904,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;827;-1920,896;Inherit;False;822;mirror_f;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;8;-1792,-1920;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;134;-1664,-2048;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;1,1,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;683;-2304,1920;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;406;-2048,-2944;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;511;-2176,3328;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;826;-1152,896;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;701;-2560,2560;Inherit;False;Property;_Specular2Scale;Specular 2 Scale;15;0;Create;True;0;0;0;False;1;Vector2;False;1.68,1;0.84,0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DynamicAppendNode;815;-951.8757,919.0298;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;829;-2561.149,2272.849;Inherit;False;Property;_Specular1Scale;Specular 1 Scale;13;0;Create;True;0;0;0;False;1;Vector2;False;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;512;-2048,3328;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;686;-2176,1920;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;2,2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;170;-1536,-2048;Inherit;False;albedoColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexToFragmentNode;404;-1920,-2944;Inherit;False;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector2Node;830;-2562.149,2144.849;Inherit;False;Property;_Specular1Offset;Specular 1 Offset;12;0;Create;True;0;0;0;False;1;Vector2;False;0,0;-0.1,0.05;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;692;-2560,2432;Inherit;False;Property;_Specular2Offset;Specular 2 Offset;14;0;Create;True;0;0;0;False;1;Vector2;False;0.13,-0.1;0.19,-0.23;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleDivideOpNode;831;-1920,2176;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;407;-1664,-2944;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleDivideOpNode;702;-1920,2304;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;703;-768,896;Inherit;True;Property;_SelfShadow;SelfShadow;16;0;Create;True;0;0;0;False;0;False;-1;9b30727f9975fd2449a8a93c18b3df4b;9b30727f9975fd2449a8a93c18b3df4b;True;1;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightAttenuation;678;-1152,640;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;523;-2560,3200;Inherit;False;Property;_Metallic;Metallic;3;0;Create;False;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;806;-1152,768;Inherit;False;803;odl_f;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;517;-1920,3328;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;696;-2176,2432;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;444;-2560,2944;Inherit;False;170;albedoColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NegateNode;833;-2176,2304;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;549;-1563.315,-2789.483;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;832;-1792,2176;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;482;-1792,1920;Inherit;False;Property;_SpecularBrightness;Specular Brightness;2;1;[Header];Create;False;1;Specular Settings;0;0;False;1;Space(10);False;1;1.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;530;-2304,3200;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;177;-2480,-560;Inherit;False;1202.727;937.5439;Shadow Color;11;412;411;101;97;100;99;124;178;125;98;680;Shadow Color;0,0,0,1;0;0
Node;AmplifyShaderEditor.SaturateNode;518;-1792,3328;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;673;-512,640;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;687;-1664,3072;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;624;-2304,2944;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0.01,0.01,0.01;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;695;-1792,2304;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;676;-384,640;Inherit;False;diff;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;623;-2176,2944;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LengthOpNode;834;-1664,2176;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;690;-1408,3184;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;622;-1536,2048;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;405;-1408,-2816;Inherit;False;LightIntensity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;684;-1664,2304;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;531;-2048,3200;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;97;-2432,-128;Inherit;False;Property;_GoochBrightColor;Shadow Light Color;5;1;[Header];Create;False;1;______Shadow______;0;0;False;1;Space(10);False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;689;-1408,3072;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;98;-2432,128;Inherit;False;Property;_GoochDarkColor;Shadow Dark Color;6;0;Create;False;0;0;0;False;0;False;0,0,0,1;0.6,0.6,0.6,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;519;-1664,3328;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;125;-2176,-128;Inherit;False;3;0;COLOR;1,1,1,1;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;532;-1920,3200;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;520;-1408,3328;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;680;-2400,-510;Inherit;False;676;diff;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;412;-2304,-384;Inherit;False;405;LightIntensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;840;-1152,2080;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;688;-1152,2305.431;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;124;-2176,128;Inherit;False;3;0;COLOR;1,1,1,1;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;621;-2048,2944;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;841;-896,2176;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;101;-1920,0;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;526;-1792,2944;Inherit;False;3;0;FLOAT3;1,1,1;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;411;-2048,-512;Inherit;False;2;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;100;-1920,-128;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;521;-1280,3328;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;442;-1106.915,2575.314;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;99;-1788,-505;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;499;-1152,1920;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;862;-1024,2688;Inherit;False;803;odl_f;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;691;-768,2304;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;441;-708.7775,2588.724;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;180;-1132.573,-2130.625;Inherit;False;852;721;;3;172;143;179;It's MK Shader Diffuse;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;178;-1536,-512;Inherit;False;shadowColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;447;-640,2048;Inherit;False;Out_Specular;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;172;-1024,-2048;Inherit;False;170;albedoColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;179;-1024,-1920;Inherit;False;178;shadowColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;652;-1792,-1792;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;419;-1536,-1792;Inherit;False;alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;418;848,-1840;Inherit;False;216;293;BlendMode;2;415;416;BlendMode;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;466;285.3,-1390.4;Inherit;False;918;234;vertex Distance;4;325;328;329;464;Vertex Distance;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;457;0,-1792;Inherit;False;447;Out_Specular;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;579;-4476.073,1974.982;Inherit;False;1682;678;Custom Light Angles;9;588;586;585;583;582;581;580;595;629;Custom Light Angles;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;143;-768,-2048;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;585;-4426.073,2536.982;Inherit;False;Property;_CustomizeLightAngle;Customize Light Angle;9;1;[Toggle];Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;325;335.3,-1340.4;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;421;535,-1792;Inherit;False;419;alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;408;-1408,-2944;Inherit;False;LightColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;328;591.3,-1340.4;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DistanceOpNode;329;847.3,-1340.4;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;464;975.3,-1340.4;Inherit;False;vertexDist;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;416;896,-1664;Inherit;False;Property;_DST;Dst;8;1;[Enum];Create;False;0;0;1;UnityEngine.Rendering.BlendMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;798;-2688,-3456;Inherit;False;Object;World;False;Fast;False;1;0;FLOAT3;0,1,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;29;782,-2068;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;581;-3523,2050;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;853;-1024,-3328;Inherit;False;odl_v;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;705;1044,-2410;Inherit;False;Constant;_Float0;Float 0;21;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;415;896,-1792;Inherit;False;Property;_SRC;Src;7;2;[Header];[Enum];Create;False;1;______Blend Mode______;0;1;UnityEngine.Rendering.BlendMode;True;1;Space(15);False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;584;-4803,2041;Inherit;False;Property;_CustomLightRotate;Custom Light Rotate;10;0;Create;True;0;0;0;False;0;False;45,-45,0;6.1,151.3,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;588;-4411.073,2268.982;Inherit;False;Constant;_Vector5;Vector 5;30;0;Create;True;0;0;0;False;0;False;0,0,-1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;586;-3072,2048;Inherit;False;lightDir;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexToFragmentNode;583;-3328,2048;Inherit;False;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;582;-4426.073,2408.982;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;629;-4170.1,2049.3;Inherit;False;Transform Euler to RotationMatrix;-1;;49;2cd743ba17aa86741a9126a507ee8fb5;1,12,1;1;5;FLOAT3;0,0,0;False;1;FLOAT3x3;0
Node;AmplifyShaderEditor.DynamicAppendNode;409;-1536,-2944;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;580;-3840,2048;Inherit;False;2;2;0;FLOAT3x3;0,0,0,1,1,1,1,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;852;-1024,-3200;Inherit;False;mirror_v;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RadiansOpNode;595;-4382,2092;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;728;1206.471,-2086.973;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;117;1408,1792;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;21;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;ExtraPrePass;0;2;Outline;6;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;True;True;1;1;True;415;0;True;416;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;True;1;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;True;True;True;128;False;-1;255;False;-1;255;False;-1;2;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;1;MRT Output;0;637974302310119949;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;119;512,-640;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;21;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;ShadowCaster;0;4;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;118;1280,-2304;Half;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;21;Treeverse/Dynamic/Eyes;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;Forward;0;3;Forward;12;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;True;True;0;False;-1;False;False;False;False;False;False;False;False;True;True;False;128;False;-1;255;False;-1;255;False;-1;7;False;-1;3;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;True;True;2;5;True;415;10;True;416;0;5;False;-1;1;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;0;False;-1;True;3;False;-1;True;False;0;False;-1;0;False;-1;True;1;LightMode=UniversalForwardOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;18;Surface;1;637934776135466903;  Blend;0;0;Two Sided;1;0;Cast Shadows;0;637980588952675093;  Use Shadow Threshold;0;0;Receive Shadows;1;637981160685889640;GPU Instancing;1;637980589210358202;LOD CrossFade;0;0;Treeverse Linear Fog;1;637993452961755517;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;0;637980438101004493;Full Screen Pass;0;0;Additional Pass;0;637980438091384457;Scene Selectioin Pass;0;637980438086241095;Vertex Position,InvertActionOnDeselection;1;0;Discard Fragment;0;0;Push SelfShadow to Main Light;1;637981441709845543;2;MRT Output;0;637974258937078243;Custom Output Position;0;0;8;False;False;False;True;False;False;False;False;False;;True;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;121;1408,2048;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;21;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;SceneSelectionPass;0;6;SceneSelectionPass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=SceneSelectionPass;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;651;1901.282,-49.99389;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;21;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;FullScreenPass;0;1;FullScreenPass;4;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;7;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForwardOnly;True;2;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;122;512,-640;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;21;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;Meta;0;7;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;314;768,-3840;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;21;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;AdditionalPass;0;0;ToonPostProcessing;6;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;True;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;1;False;-1;True;3;False;-1;True;False;0;False;-1;0;False;-1;True;1;LightMode=ToonPostProcessing;False;False;0;Hidden/InternalErrorShader;0;0;Standard;1;MRT Output;0;637933887809711874;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;120;512,-640;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;21;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;DepthOnly;0;5;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;732;0;707;1
WireConnection;732;2;707;3
WireConnection;733;0;732;0
WireConnection;734;0;733;0
WireConnection;792;0;734;0
WireConnection;792;1;788;0
WireConnection;793;0;792;0
WireConnection;804;0;793;0
WireConnection;748;0;734;0
WireConnection;748;1;788;0
WireConnection;789;0;748;0
WireConnection;794;0;793;0
WireConnection;805;0;804;0
WireConnection;796;0;794;0
WireConnection;796;1;795;0
WireConnection;872;0;789;0
WireConnection;870;0;805;0
WireConnection;821;1;820;1
WireConnection;791;0;872;0
WireConnection;791;1;796;0
WireConnection;791;2;870;0
WireConnection;791;3;821;0
WireConnection;849;0;791;0
WireConnection;654;0;656;0
WireConnection;850;0;849;1
WireConnection;851;0;849;0
WireConnection;744;0;791;0
WireConnection;662;0;136;0
WireConnection;662;1;659;0
WireConnection;655;0;654;0
WireConnection;854;0;661;0
WireConnection;858;0;856;0
WireConnection;858;1;867;0
WireConnection;799;0;744;0
WireConnection;660;0;662;4
WireConnection;801;0;799;1
WireConnection;859;0;858;0
WireConnection;653;0;659;0
WireConnection;653;1;660;0
WireConnection;653;2;854;0
WireConnection;653;3;658;0
WireConnection;800;0;799;0
WireConnection;698;0;653;0
WireConnection;860;0;842;1
WireConnection;860;1;859;0
WireConnection;816;0;811;0
WireConnection;816;2;812;0
WireConnection;848;0;845;0
WireConnection;861;0;860;0
WireConnection;861;1;842;2
WireConnection;844;0;855;0
WireConnection;803;0;799;2
WireConnection;400;0;399;1
WireConnection;401;0;400;0
WireConnection;822;0;799;3
WireConnection;843;0;861;0
WireConnection;843;1;848;0
WireConnection;843;2;844;0
WireConnection;843;3;846;0
WireConnection;828;0;809;1
WireConnection;828;1;816;0
WireConnection;137;0;136;0
WireConnection;137;1;699;0
WireConnection;137;7;136;1
WireConnection;864;0;43;0
WireConnection;864;1;869;0
WireConnection;864;2;865;0
WireConnection;847;0;843;0
WireConnection;402;0;401;0
WireConnection;823;0;828;0
WireConnection;135;0;133;0
WireConnection;8;0;137;0
WireConnection;134;0;135;0
WireConnection;134;1;8;0
WireConnection;683;0;847;0
WireConnection;406;0;399;1
WireConnection;406;3;402;0
WireConnection;511;0;864;0
WireConnection;826;0;828;0
WireConnection;826;1;823;0
WireConnection;826;2;827;0
WireConnection;815;0;826;0
WireConnection;815;1;809;2
WireConnection;512;0;511;0
WireConnection;686;0;683;0
WireConnection;170;0;134;0
WireConnection;404;0;406;0
WireConnection;831;0;686;0
WireConnection;831;1;829;0
WireConnection;407;0;404;0
WireConnection;702;0;686;0
WireConnection;702;1;701;0
WireConnection;703;1;815;0
WireConnection;517;0;512;0
WireConnection;696;0;692;0
WireConnection;833;0;830;0
WireConnection;549;0;407;3
WireConnection;832;0;831;0
WireConnection;832;1;833;0
WireConnection;530;0;523;0
WireConnection;518;0;517;0
WireConnection;673;0;678;0
WireConnection;673;1;703;1
WireConnection;673;2;806;0
WireConnection;687;0;43;0
WireConnection;624;0;444;0
WireConnection;695;0;702;0
WireConnection;695;1;696;0
WireConnection;676;0;673;0
WireConnection;623;0;624;0
WireConnection;834;0;832;0
WireConnection;690;0;687;0
WireConnection;622;0;482;0
WireConnection;405;0;549;0
WireConnection;684;0;695;0
WireConnection;531;0;530;0
WireConnection;531;1;530;0
WireConnection;689;0;687;0
WireConnection;519;0;518;0
WireConnection;125;1;97;0
WireConnection;125;2;97;4
WireConnection;532;0;531;0
WireConnection;520;0;519;0
WireConnection;520;1;519;0
WireConnection;840;0;834;0
WireConnection;840;1;689;0
WireConnection;840;2;690;0
WireConnection;688;0;684;0
WireConnection;688;1;689;0
WireConnection;688;2;690;0
WireConnection;124;1;98;0
WireConnection;124;2;98;4
WireConnection;621;0;623;0
WireConnection;621;1;622;0
WireConnection;841;0;840;0
WireConnection;841;1;688;0
WireConnection;101;0;124;0
WireConnection;526;1;621;0
WireConnection;526;2;532;0
WireConnection;411;0;680;0
WireConnection;411;1;412;0
WireConnection;100;0;125;0
WireConnection;521;0;520;0
WireConnection;521;1;520;0
WireConnection;442;0;526;0
WireConnection;442;1;521;0
WireConnection;99;0;101;0
WireConnection;99;1;100;0
WireConnection;99;2;411;0
WireConnection;499;0;482;0
WireConnection;499;1;482;0
WireConnection;691;0;841;0
WireConnection;441;0;691;0
WireConnection;441;1;442;0
WireConnection;441;2;499;0
WireConnection;441;3;862;0
WireConnection;178;0;99;0
WireConnection;447;0;441;0
WireConnection;652;0;133;4
WireConnection;652;1;137;4
WireConnection;419;0;652;0
WireConnection;143;0;172;0
WireConnection;143;1;179;0
WireConnection;408;0;409;0
WireConnection;328;0;325;0
WireConnection;329;0;328;0
WireConnection;464;0;329;0
WireConnection;29;0;457;0
WireConnection;29;1;143;0
WireConnection;581;0;582;0
WireConnection;581;1;580;0
WireConnection;581;2;585;0
WireConnection;853;0;849;2
WireConnection;586;0;583;0
WireConnection;583;0;581;0
WireConnection;629;5;595;0
WireConnection;409;0;407;0
WireConnection;409;1;407;1
WireConnection;409;2;407;2
WireConnection;580;0;629;0
WireConnection;580;1;588;0
WireConnection;852;0;849;3
WireConnection;595;0;584;0
WireConnection;118;30;705;0
WireConnection;118;2;29;0
WireConnection;118;3;421;0
ASEEND*/
//CHKSM=9A5F2524D522D80C3260EFAE14205D32A6A4344F
// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Treeverse/Particle/Additive(Projection)"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[ASEBegin][HDR]_TintColor("Tint Color", Color) = (1,1,1,1)
		_MainTex("MainTex", 2D) = "white" {}
		[IntRange]_StencilRef("StencilRef", Range( 0 , 255)) = 10
		[ASEEnd][Enum(UnityEngine.Rendering.CompareFunction)]_StencilCompare("StencilCompare", Float) = 3

	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
		
		Cull Front
		AlphaToMask Off
		
		HLSLINCLUDE
		#pragma target 2.0

		#pragma prefer_hlslcc gles
		#pragma exclude_renderers d3d11_9x 
		
		ENDHLSL
		
		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }

			Cull Front
			Blend SrcAlpha One
			ZWrite Off
			ZTest GEqual
			Offset 0,0
			ColorMask RGBA
			Stencil
			{
				Ref [_StencilRef]
				Comp [_StencilCompare]
				Pass Keep
				Fail Keep
				ZFail Keep
			}
			
			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define ASE_SRP_VERSION 999999
			#define ASE_USING_SAMPLING_MACROS 1

			
			#pragma vertex vert
			#pragma fragment frag
			
			#define REQUIRE_DEPTH_TEXTURE 1

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_COLOR


			struct VertexInput
			{
				float4 vertex: POSITION;
				float3 ase_normal: NORMAL;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos: SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 worldPos: TEXCOORD0;
				#endif

				float4 screenUV: TEXCOORD1;
				float4 viewRayOS: TEXCOORD2;
				float3 cameraPosOS: TEXCOORD3;

				#ifdef ASE_FOG
					float fogFactor: TEXCOORD4;
				#endif
				float3 ps_Parm :TEXCOORD5;
				float4 ase_color : COLOR;
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)

			float4 _TintColor;
			float _StencilRef;
			float _StencilCompare;
			CBUFFER_END
			float4x4 _w2o;
			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);


			
			float2 rotate2D(float2 uv, half2 pivot, half angle)
			{
				float c = cos(angle);
				float s = sin(angle);
				return mul(uv - pivot, float2x2(c, -s, s, c)) + pivot;
			}

			float2 projectorUV(float4 viewRayOS, float3 cameraPosOS, float4 screenUV, float2 scale, float rotateAngle)
			{
				viewRayOS /= viewRayOS.w;
				screenUV /= screenUV.w;
				#if defined(UNITY_SINGLE_PASS_STEREO)
					screenUV.xy = UnityStereoTransformScreenSpaceTex(screenUV.xy);
				#endif
				float depthQ = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(screenUV.xy), _ZBufferParams);
				
				float depth = depthQ;
				
				
				float3 decalSpaceScenePos = cameraPosOS + viewRayOS.xyz * depth;
				decalSpaceScenePos.xz = rotate2D(decalSpaceScenePos.xz, 0.0.xx, rotateAngle);
				decalSpaceScenePos.xz /= scale;
				float2 decalSpaceUV = decalSpaceScenePos.xz + 0.5;
				
				
				//  Clip decal to volume
				clip(float3(0.5, 0.5, 0.5) - abs(decalSpaceScenePos.xyz));
				
				// sample the decal texture
				return decalSpaceUV.xy;
			}

			VertexOutput vert(VertexInput v)
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float4 appendResult5_g3 = (float4((v.ase_texcoord3).xyz , 1.0));
				
				o.ase_color = v.ase_color;
				o.ase_texcoord6.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord6.zw = 0;
				
				float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
				float4 positionCS = TransformWorldToHClip(positionWS);

				float4 screenPos = ComputeScreenPos(positionCS);
				o.screenUV = screenPos;

				float3 vr = mul(UNITY_MATRIX_V, float4(positionWS, 1.0)).xyz;
				o.viewRayOS.w = vr.z;

				float4x4 w2o = GetWorldToObjectMatrix();

				float4 w2oR0 = _w2o[0];
				float4 w2oR1 = _w2o[1];
				float4 w2oR2 = _w2o[2];
				float4 w2oR3 = _w2o[3];

				w2o._11_12_13_14 = w2oR0;
				w2o._21_22_23_24 = w2oR1;
				w2o._31_32_33_34 = w2oR2;
				w2o._41_42_43_44 = w2oR3;

				float4x4 ViewToObjectMatrix = mul(w2o, UNITY_MATRIX_I_V);
				o.viewRayOS.xyz = mul((float3x3)ViewToObjectMatrix, -vr);

				float3 centerDetla = (mul( _w2o, appendResult5_g3 )).xyz;
				o.cameraPosOS = ViewToObjectMatrix._m03_m13_m23 - centerDetla;
				
				float2 scale = (v.ase_texcoord5).xz;
				float rotate = (v.ase_texcoord4).y;
				o.ps_Parm.xy = scale;
				o.ps_Parm.z = -rotate;

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				#ifdef ASE_FOG
					o.fogFactor = ComputeFogFactor(positionCS.z);
				#endif
				o.clipPos = positionCS;
				return o;
			}

			half4 frag(VertexOutput IN ): SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.worldPos;
				#endif
				
				float2 uv = projectorUV(IN.viewRayOS, IN.cameraPosOS, IN.screenUV, IN.ps_Parm.xy, IN.ps_Parm.z);

				float4 temp_output_8_0 = ( IN.ase_color * _TintColor * SAMPLE_TEXTURE2D( _MainTex, sampler_MainTex, uv ) );
				float3 appendResult9 = (float3(temp_output_8_0.rgb));
				float3 OutColor11 = appendResult9;
				
				float OutAlpha12 = (temp_output_8_0).a;
				
				
				float3 Color = OutColor11;
				float Alpha = OutAlpha12;

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition(IN.clipPos.xyz, unity_LODFade.x);
				#endif

				#ifdef ASE_FOG
					Color = MixFog(Color, IN.fogFactor);
				#endif

				return half4(Color, Alpha);
			}
			
			ENDHLSL
			
		}

		/*ase_pass*/
		Pass
		{
			
			Name "SceneSelectionPass"
			Tags{"LightMode" = "SceneSelectionPass"}

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM
			
			/*ase_pragma_before*/
			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			/*ase_pragma*/

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				/*ase_vdata:p=p;n=n*/
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
				/*ase_interp(2,):sp=sp;wp=tc0;sc=tc1*/
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)

			/*ase_srp_batcher*/
			CBUFFER_END
			/*ase_globals*/

			/*ase_funcs*/

			VertexOutput VertexFunction( VertexInput v /*ase_vert_input*/ )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				/*ase_vert_code:v=VertexInput;o=VertexOutput*/
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = /*ase_vert_out:Vertex Offset;Float3;2;-1;_Vertex*/defaultVertexValue/*end*/;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = /*ase_vert_out:Vertex Normal;Float3;3;-1;_Normal*/v.ase_normal/*end*/;

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

			half4 frag(VertexOutput IN /*ase_frag_input*/ ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif

				/*ase_frag_code:IN=VertexOutput*/
				float Alpha = /*ase_frag_out:Alpha;Float;0;-1;_Alpha*/1/*end*/;

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 1;
			}
			ENDHLSL
		}

	}
	//CustomEditorForRenderPipeline "CustomDrawersShaderEditor" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
	CustomEditor "UnityEditor.ShaderGraphUnlitGUI"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=18935
-1832;13;1765;1039;1072.617;567.0605;1.3;True;False
Node;AmplifyShaderEditor.TexCoordVertexDataNode;4;-1408,0;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;3;-1408,128;Inherit;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.VertexColorNode;7;-1152,-384;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;5;-1152,128;Inherit;True;Property;_TextureSample0;Texture Sample 0;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;6;-1152,-128;Inherit;False;Property;_TintColor;Tint Color;0;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;0.7686275,1.113726,1.317647,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-768,0;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;9;-640,0;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;10;-640,128;Inherit;False;FLOAT;3;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;11;-512,0;Inherit;False;OutColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;12;-512,128;Inherit;False;OutAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-1408,640;Inherit;False;Property;_StencilCompare;StencilCompare;5;1;[Enum];Create;True;0;0;1;UnityEngine.Rendering.CompareFunction;True;0;False;3;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;14;-128,-256;Inherit;False;12;OutAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;13;-128,-384;Inherit;False;11;OutColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-1408,512;Inherit;False;Property;_StencilRef;StencilRef;4;1;[IntRange];Create;True;0;0;0;True;0;False;10;10;0;255;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;53;128,128;Inherit;False;Decal For ParticleSystem;2;;3;09381b5905d840448a3c0d130d62eece;0;0;7;FLOAT4;0;FLOAT4;24;FLOAT4;25;FLOAT4;26;FLOAT3;1;FLOAT2;27;FLOAT;28
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;512,0;Half;False;True;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;16;Treeverse/Particle/Additive(Projection);d9a07a90db7fc20418f0da16c269dae8;True;Forward;0;0;Forward;9;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;1;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;True;True;8;5;False;-1;1;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;True;True;True;255;True;30;255;False;-1;255;False;-1;7;True;31;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;2;False;-1;True;4;False;-1;True;False;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;False;0;Hidden/InternalErrorShader;0;0;Standard;6;  Blend;0;0;GPU Instancing;1;0;LOD CrossFade;0;0;Built-in Fog;1;637923612741010220;DOTS Instancing;0;0;For Particle System;1;637939837485928373;0;2;True;False;False;;True;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;-128,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;60;New Amplify Shader;d9a07a90db7fc20418f0da16c269dae8;True;SceneSelectionPass;0;1;SceneSelectionPass;1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;1;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;5;0;3;0
WireConnection;5;1;4;0
WireConnection;5;7;3;1
WireConnection;8;0;7;0
WireConnection;8;1;6;0
WireConnection;8;2;5;0
WireConnection;9;0;8;0
WireConnection;10;0;8;0
WireConnection;11;0;9;0
WireConnection;12;0;10;0
WireConnection;1;2;13;0
WireConnection;1;3;14;0
WireConnection;1;10;53;0
WireConnection;1;11;53;24
WireConnection;1;12;53;25
WireConnection;1;13;53;26
WireConnection;1;5;53;1
WireConnection;1;7;53;27
WireConnection;1;8;53;28
ASEEND*/
//CHKSM=F21419CACC4DBAB671DB2AB8DDCE2B1FE2A0F138
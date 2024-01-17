// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Treeverse/Particle/Disslove(Projection)"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[ASEBegin]Main_tex("BaseMap", 2D) = "white" {}
		[ASEEnd][HDR]_Color("Color", Color) = (1,1,1,1)

	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
		
		Cull Front
		AlphaToMask Off
		
		HLSLINCLUDE
		#pragma target 3.0

		#pragma prefer_hlslcc gles
		#pragma exclude_renderers d3d11_9x 
		
		ENDHLSL
		
		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }

			Cull Front
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			ZTest GEqual
			Offset 0 , 0
			ColorMask RGBA
			Stencil
			{
				Ref 10
				Comp Equal
				Pass Keep
				Fail Keep
				ZFail Keep
			}
			
			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define ASE_SRP_VERSION 999999

			
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
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord1 : TEXCOORD1;
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
				float4 ase_texcoord7 : TEXCOORD7;
				float4 ase_texcoord8 : TEXCOORD8;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)

			float4 _Color;
			CBUFFER_END
			float4x4 _w2o;
			sampler2D Main_tex;


			
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

				float4 appendResult5_g1 = (float4((v.ase_texcoord3).xyz , 1.0));
				
				o.ase_color = v.ase_color;
				o.ase_texcoord6.xy = v.ase_texcoord.xy;
				o.ase_texcoord7 = v.ase_texcoord2;
				o.ase_texcoord8 = v.ase_texcoord1;
				
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

				float3 centerDetla = (mul( _w2o, appendResult5_g1 )).xyz;
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

				float3 appendResult28 = (float3(_Color.rgb));
				float3 appendResult29 = (float3(IN.ase_color.rgb));
				float2 appendResult51 = (float2(IN.ase_texcoord7.x , IN.ase_texcoord7.y));
				float2 appendResult52 = (float2(IN.ase_texcoord7.z , IN.ase_texcoord7.w));
				float4 tex2DNode6 = tex2D( Main_tex, ( ( ( uv * appendResult51 ) + appendResult52 ) + (( tex2D( Main_tex, ( ( uv * appendResult51 ) + appendResult52 ) ).b * IN.ase_texcoord8.z )).xx ) );
				float temp_output_25_0 = ( saturate( (0.0 + (tex2DNode6.r - 0.0) * (1.0 - 0.0) / (0.5 - 0.0)) ) * saturate( (( ( IN.ase_texcoord8.x * IN.ase_texcoord8.y ) * -1.0 ) + (( tex2DNode6.g + ( 1.0 - IN.ase_texcoord8.x ) ) - 0.0) * (1.0 - ( ( IN.ase_texcoord8.x * IN.ase_texcoord8.y ) * -1.0 )) / (( ( IN.ase_texcoord8.x * 0.1 ) + 1.0 ) - 0.0)) ) );
				
				
				float3 Color = ( appendResult28 * appendResult29 * temp_output_25_0 );
				float Alpha = ( temp_output_25_0 * IN.ase_color.a * _Color.a );

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

		
		Pass
		{
			
			Name "SceneSelectionPass"
			Tags { "LightMode"="SceneSelectionPass" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define ASE_SRP_VERSION 999999

			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord1 : TEXCOORD1;
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
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)

			float4 _Color;
			CBUFFER_END
			float4x4 _w2o;
			sampler2D Main_tex;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float4 appendResult5_g1 = (float4((v.ase_texcoord3).xyz , 1.0));
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_texcoord3 = v.ase_texcoord2;
				o.ase_texcoord4 = v.ase_texcoord1;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = (mul( _w2o, appendResult5_g1 )).xyz;
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

				float2 appendResult51 = (float2(IN.ase_texcoord3.x , IN.ase_texcoord3.y));
				float2 appendResult52 = (float2(IN.ase_texcoord3.z , IN.ase_texcoord3.w));
				float4 tex2DNode6 = tex2D( Main_tex, ( ( ( IN.ase_texcoord2.xy * appendResult51 ) + appendResult52 ) + (( tex2D( Main_tex, ( ( IN.ase_texcoord2.xy * appendResult51 ) + appendResult52 ) ).b * IN.ase_texcoord4.z )).xx ) );
				float temp_output_25_0 = ( saturate( (0.0 + (tex2DNode6.r - 0.0) * (1.0 - 0.0) / (0.5 - 0.0)) ) * saturate( (( ( IN.ase_texcoord4.x * IN.ase_texcoord4.y ) * -1.0 ) + (( tex2DNode6.g + ( 1.0 - IN.ase_texcoord4.x ) ) - 0.0) * (1.0 - ( ( IN.ase_texcoord4.x * IN.ase_texcoord4.y ) * -1.0 )) / (( ( IN.ase_texcoord4.x * 0.1 ) + 1.0 ) - 0.0)) ) );
				
				float Alpha = ( temp_output_25_0 * IN.ase_color.a * _Color.a );

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
2560;307;2048;1100.6;2168.872;577.2942;1;True;False
Node;AmplifyShaderEditor.TexCoordVertexDataNode;36;-2176,256;Inherit;False;2;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;37;-1920,0;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;51;-1792,256;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;52;-1792,384;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;-1664,0;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;5;-2176,-256;Inherit;True;Property;Main_tex;BaseMap;0;0;Create;False;0;0;0;False;0;False;None;ce65e84ec609f4745918705129cb45f5;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleAddOpNode;43;-1536,0;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;11;-1408,128;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;7;-1408,-128;Inherit;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;8;-1792,-384;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-1536,-384;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-1024,0;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;45;-1408,-384;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;13;-896,0;Inherit;False;FLOAT2;0;0;2;3;1;0;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;9;-768,-128;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-640,256;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-640,384;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;6;-640,-256;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;17;-640,128;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;20;-512,256;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;16;-384,0;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-512,384;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;14;-256,-256;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;19;0,0;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;24;256,0;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;15;0,-256;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;26;256,-384;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;384,-128;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;27;256,-640;Inherit;False;Property;_Color;Color;3;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;6.498019,6.498019,6.498019,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;-253.7808,643.3301;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;39;640,0;Inherit;False;Decal For ParticleSystem;1;;1;09381b5905d840448a3c0d130d62eece;0;0;7;FLOAT4;0;FLOAT4;24;FLOAT4;25;FLOAT4;26;FLOAT3;1;FLOAT2;27;FLOAT;28
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;767,-256;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SurfaceDepthNode;47;-640,768;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;50;-128,640;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;29;510.7,-385.3;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScreenDepthNode;46;-640,640;Inherit;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;48;-384,640;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;768,-384;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;28;512,-640;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;33;1024,-256;Float;False;True;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;17;Treeverse/Particle/Disslove(Projection);d9a07a90db7fc20418f0da16c269dae8;True;Forward;0;0;Forward;9;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;1;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;True;True;True;10;False;-1;255;False;-1;255;False;-1;5;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;4;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;False;0;Hidden/InternalErrorShader;0;0;Standard;6;  Blend;0;0;GPU Instancing;1;0;LOD CrossFade;0;0;Built-in Fog;0;0;DOTS Instancing;0;0;For Particle System;1;637939884703482459;0;2;True;True;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;34;1024,-256;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;18;New Amplify Shader;d9a07a90db7fc20418f0da16c269dae8;True;SceneSelectionPass;0;1;SceneSelectionPass;1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;1;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;51;0;36;1
WireConnection;51;1;36;2
WireConnection;52;0;36;3
WireConnection;52;1;36;4
WireConnection;42;0;37;0
WireConnection;42;1;51;0
WireConnection;43;0;42;0
WireConnection;43;1;52;0
WireConnection;7;0;5;0
WireConnection;7;1;43;0
WireConnection;7;7;5;1
WireConnection;44;0;8;0
WireConnection;44;1;51;0
WireConnection;10;0;7;3
WireConnection;10;1;11;3
WireConnection;45;0;44;0
WireConnection;45;1;52;0
WireConnection;13;0;10;0
WireConnection;9;0;45;0
WireConnection;9;1;13;0
WireConnection;18;0;11;1
WireConnection;22;0;11;1
WireConnection;22;1;11;2
WireConnection;6;0;5;0
WireConnection;6;1;9;0
WireConnection;17;0;11;1
WireConnection;20;0;18;0
WireConnection;16;0;6;2
WireConnection;16;1;17;0
WireConnection;23;0;22;0
WireConnection;14;0;6;1
WireConnection;19;0;16;0
WireConnection;19;2;20;0
WireConnection;19;3;23;0
WireConnection;24;0;19;0
WireConnection;15;0;14;0
WireConnection;25;0;15;0
WireConnection;25;1;24;0
WireConnection;49;0;48;0
WireConnection;49;1;11;4
WireConnection;31;0;25;0
WireConnection;31;1;26;4
WireConnection;31;2;27;4
WireConnection;50;0;49;0
WireConnection;29;0;26;0
WireConnection;48;0;46;0
WireConnection;48;1;47;0
WireConnection;30;0;28;0
WireConnection;30;1;29;0
WireConnection;30;2;25;0
WireConnection;28;0;27;0
WireConnection;33;2;30;0
WireConnection;33;3;31;0
WireConnection;33;10;39;0
WireConnection;33;11;39;24
WireConnection;33;12;39;25
WireConnection;33;13;39;26
WireConnection;33;5;39;1
WireConnection;33;7;39;27
WireConnection;33;8;39;28
ASEEND*/
//CHKSM=D5AE09A4B1D885CB3A8A4ED94D93FC2969098102
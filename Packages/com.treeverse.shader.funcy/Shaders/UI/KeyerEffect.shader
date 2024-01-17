// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Treeverse/UI/Keyer Effect"
{
	Properties
	{
		[PerRendererData]_MainTex("MainTex", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

		
		_StencilComp ("Stencil Comparison", Float) = 8
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
		_StencilReadMask ("Stencil Read Mask", Float) = 255
		
		_ColorMask ("Color Mask", Float) = 15
		
		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
	}
	
	SubShader
	{
		LOD 0

		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" "CanUseSpriteAtlas"="True" }
		
		Stencil
		{
			Ref [_Stencil]
			ReadMask [_StencilReadMask]
			WriteMask [_StencilWriteMask]
			CompFront [_StencilComp]
			PassFront [_StencilOp]
			FailFront Keep
			ZFailFront Keep
			CompBack Always
			PassBack Keep
			FailBack Keep
			ZFailBack Keep
		}

		
		Cull Off
		Lighting Off
		ZWrite Off
		ZTest [unity_GUIZTestMode]
		Blend One OneMinusSrcAlpha
		ColorMask [_ColorMask]
		
		
		Pass
		{
			Name "Forward"
			Tags { "LightMode"="SRPDefaultUnlit" }
			
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off
			ZWrite Off
			ZTest Always
			Offset 0 , 0
			ColorMask RGBA
			
			CGPROGRAM
			
			#define ASE_USING_SAMPLING_MACROS 1

			
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			
			#include "UnityCG.cginc"
			#include "UnityUI.cginc"
			
			#pragma multi_compile_local _ UNITY_UI_CLIP_RECT
			#pragma multi_compile_local _ UNITY_UI_ALPHACLIP
			
			#if defined(SHADER_API_D3D11) || defined(SHADER_API_XBOXONE) || defined(UNITY_COMPILER_HLSLCC) || defined(SHADER_API_PSSL) || (defined(SHADER_TARGET_SURFACE_ANALYSIS) && !defined(SHADER_TARGET_SURFACE_ANALYSIS_MOJOSHADER))//ASE Sampler Macros
			#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex.Sample(samplerTex,coord)
			#else//ASE Sampling Macros
			#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex2D(tex,coord)
			#endif//ASE Sampling Macros
			

			struct appdata_t
			{
				float4 vertex: POSITION;
				float4 color    : COLOR;
				float2 texcoord: TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				
			};
			
			struct v2f
			{
				float4 vertex: SV_POSITION;
				fixed4 color    : COLOR;
				float2 texcoord: TEXCOORD0;
				float4 worldPosition: TEXCOORD1;
				float4 mask: TEXCOORD2;
				float3 maskUV: TEXCOORD3;
				UNITY_VERTEX_OUTPUT_STEREO
				
			};
			
			float4 _ClipRect;
			float _UIMaskSoftnessX;
			float _UIMaskSoftnessY;
			UNITY_DECLARE_TEX2D_NOSAMPLER(_MainTex);
			uniform half4 _MainTex_ST;
			SamplerState sampler_MainTex;
			UNITY_DECLARE_TEX2D_NOSAMPLER(_UI_KeyerEffectMask);
			uniform half4 _UI_KeyerEffectMask_ST;
			SamplerState sampler_UI_KeyerEffectMask;

			
						
			v2f vert(appdata_t input )
			{
				v2f output = (v2f)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
				float4 vPosition = UnityObjectToClipPos(input.vertex);
				
				float2 pixelSize = vPosition.w;
				pixelSize /= float2(1, 1) * abs(mul((float2x2)UNITY_MATRIX_P, _ScreenParams.xy));
				
				float4 clampedRect = clamp(_ClipRect, -2e10, 2e10);
				output.maskUV = float3((input.vertex.xy - clampedRect.xy) / (clampedRect.zw - clampedRect.xy), 0.0);
				output.mask = float4(input.vertex.xy * 2 - clampedRect.xy - clampedRect.zw, 0.25 / (0.25 * half2(_UIMaskSoftnessX, _UIMaskSoftnessY) + abs(pixelSize.xy)));
				
				
				output.worldPosition = input.vertex;
				output.vertex = vPosition;
				output.texcoord = input.texcoord;
				output.color = input.color;
				return output;
			}
			
			fixed4 frag(v2f IN ): SV_Target
			{
				//Round up the alpha color coming from the interpolator (to 1.0/256.0 steps)
				//The incoming alpha could have numerical instability, which makes it very sensible to
				//HDR color transparency blend, when it blends with the world's texture.
				const half alphaPrecision = half(0xff);
				const half invAlphaPrecision = half(1.0 / alphaPrecision);
				IN.color.a = round(IN.color.a * alphaPrecision) * invAlphaPrecision;
				
				float3 worldPosition = IN.maskUV;

				float2 uv_MainTex = IN.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				half4 tex2DNode48 = SAMPLE_TEXTURE2D( _MainTex, sampler_MainTex, uv_MainTex );
				half3 appendResult53 = (half3(tex2DNode48.rgb));
				half temp_output_52_0 = max( max( max( tex2DNode48.r , tex2DNode48.g ) , tex2DNode48.b ) , 0.0001 );
				float2 uv_UI_KeyerEffectMask = IN.texcoord.xy * _UI_KeyerEffectMask_ST.xy + _UI_KeyerEffectMask_ST.zw;
				half4 tex2DNode62 = SAMPLE_TEXTURE2D( _UI_KeyerEffectMask, sampler_UI_KeyerEffectMask, uv_UI_KeyerEffectMask );
				half4 appendResult54 = (half4(appendResult53 , max( temp_output_52_0 , tex2DNode62.a )));
				
				
				fixed4 color = appendResult54;
				
				#ifdef UNITY_UI_CLIP_RECT
					half2 m = saturate((_ClipRect.zw - _ClipRect.xy - abs(IN.mask.xy)) * IN.mask.zw);
					color.a *= m.x * m.y;
				#endif
				
				#ifdef UNITY_UI_ALPHACLIP
					clip(color.a - 0.001);
				#endif

				return color;
			}

			ENDCG
			
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18935
-1913;42;1920;1003;1581.556;927.4165;1;True;False
Node;AmplifyShaderEditor.SamplerNode;48;-1152,-640;Inherit;True;Property;_MainTex;MainTex;0;1;[PerRendererData];Create;True;0;0;0;True;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;50;-768,-512;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;61;-1664,-128;Inherit;True;Global;_UI_KeyerEffectMask;_UI_KeyerEffectMask;1;0;Create;True;0;0;0;False;0;False;None;;False;black;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleMaxOpNode;51;-640,-512;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;62;-1408,-128;Inherit;True;Property;_TextureSample3;Texture Sample 3;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;52;-512,-512;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.0001;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;53;-768,-640;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;81;-384,-512;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.0001;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;82;-445.7314,-688.6692;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;83;-256,-640;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;54;0,-512;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.VertexColorNode;12;-173,-864;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;11;256,-512;Half;False;True;-1;2;ASEMaterialInspector;0;20;Treeverse/UI/Keyer Effect;ce0bf6a6e544803479533b89b14999b1;True;Forward;0;0;Forward;1;False;True;3;1;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;True;0;True;-7;False;False;False;False;False;False;False;True;True;0;True;-3;255;True;-6;255;True;-5;0;True;-2;0;True;-4;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;0;True;-9;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;False;0;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;2;False;-1;True;7;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=SRPDefaultUnlit;True;0;False;0;;0;0;Standard;0;0;1;True;False;;True;0
WireConnection;50;0;48;1
WireConnection;50;1;48;2
WireConnection;51;0;50;0
WireConnection;51;1;48;3
WireConnection;62;0;61;0
WireConnection;52;0;51;0
WireConnection;53;0;48;0
WireConnection;81;0;52;0
WireConnection;81;1;62;4
WireConnection;82;0;53;0
WireConnection;82;1;52;0
WireConnection;83;0;82;0
WireConnection;83;1;53;0
WireConnection;83;2;62;4
WireConnection;54;0;53;0
WireConnection;54;3;81;0
WireConnection;11;1;54;0
ASEEND*/
//CHKSM=E0876BC47E55B64B6D9AE2D2A69DB7F890498436
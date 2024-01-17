// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Treeverse/UI/Blur Background"
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
			
			
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			
			#include "UnityCG.cginc"
			#include "UnityUI.cginc"
			
			#pragma multi_compile_local _ UNITY_UI_CLIP_RECT
			#pragma multi_compile_local _ UNITY_UI_ALPHACLIP
			
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_FRAG_WORLD_POSITION

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
			uniform sampler2D _BlurBackgroundBufffer;
			uniform sampler2D _MainTex;
			uniform half4 _MainTex_ST;

			
						
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

				half3 appendResult16 = (half3(tex2D( _BlurBackgroundBufffer, worldPosition.xy ).rgb));
				float2 uv_MainTex = IN.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				half4 appendResult44 = (half4(( (IN.color).rgb * appendResult16 ) , ( IN.color.a * tex2D( _MainTex, uv_MainTex ).a )));
				
				
				fixed4 color = appendResult44;
				
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
-2240;452;1920;1009;1266.841;728.3016;1;True;False
Node;AmplifyShaderEditor.TexturePropertyNode;10;-896,-128;Inherit;True;Global;_BlurBackgroundBufffer;_BlurBackgroundBufffer;0;1;[PerRendererData];Create;True;0;0;0;False;0;False;None;;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.WorldPosInputsNode;47;-1024,128;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.VertexColorNode;12;-512,-384;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;15;-640,-128;Inherit;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;16;-304,-176;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;45;-256,-384;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;48;-640,-640;Inherit;True;Property;_MainTex;MainTex;1;1;[PerRendererData];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-128,-256;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;-128,-128;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;44;74.64235,-247.8377;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;11;286,-290;Half;False;True;-1;2;ASEMaterialInspector;0;20;Treeverse/UI/Blur Background;ce0bf6a6e544803479533b89b14999b1;True;Forward;0;0;Forward;1;False;True;3;1;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;True;0;True;-7;False;False;False;False;False;False;False;True;True;0;True;-3;255;True;-6;255;True;-5;0;True;-2;0;True;-4;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;0;True;-9;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;False;0;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;2;False;-1;True;7;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=SRPDefaultUnlit;True;0;False;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;15;0;10;0
WireConnection;15;1;47;0
WireConnection;16;0;15;0
WireConnection;45;0;12;0
WireConnection;46;0;45;0
WireConnection;46;1;16;0
WireConnection;49;0;12;4
WireConnection;49;1;48;4
WireConnection;44;0;46;0
WireConnection;44;3;49;0
WireConnection;11;1;44;0
ASEEND*/
//CHKSM=899A3DB6E8A2CE85458FA9CEE7BAF1D1EB1D6433
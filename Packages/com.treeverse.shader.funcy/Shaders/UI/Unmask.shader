// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Treeverse/UI/Unmask"
{
	Properties
	{
		[PerRendererData]_MainTex("MainTex", 2D) = "white" {}

		
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
			Offset 0,0
			ColorMask RGBA
			
			CGPROGRAM
			
			
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			
			#include "UnityCG.cginc"
			#include "UnityUI.cginc"
			#ifdef SUPPORT_CLIP_RECT
			#pragma multi_compile_local _ UNITY_UI_CLIP_RECT
			#endif
			#pragma multi_compile_local _ UNITY_UI_ALPHACLIP
			
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_FRAG_WORLD_POSITION

			struct appdata_t
			{
				float4 vertex: POSITION;
				float4 color    : COLOR;
				float2 texcoord: TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				half3 ase_normal : NORMAL;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
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
				float3 ase_normal : NORMAL;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
			};
			
			float4 _ClipRect;
			float _UIMaskSoftnessX;
			float _UIMaskSoftnessY;
			uniform sampler2D _MainTex;
			float4 _MainTex_TexelSize;

			
			half2 UV9Slice71( half2 uv, half2 s, half4 b )
			{
				float2 t = saturate((s * uv - b.xy) / (s - b.xy - b.zw));
				return lerp(uv * s, 1. - s * (1. - uv), t);
			}
			
			
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
				output.ase_normal = input.ase_normal;
				output.ase_texcoord4 = input.ase_texcoord1;
				output.ase_texcoord5.xyz = input.ase_texcoord2.xyz;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord5.w = 0;
				
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

				half2 appendResult72 = (half2(worldPosition.xy));
				half2 uv71 = appendResult72;
				half2 appendResult74 = (half2(_ClipRect.z , _ClipRect.w));
				half2 appendResult52 = (half2(_ClipRect.x , _ClipRect.y));
				half2 appendResult50 = (half2(( appendResult74 - appendResult52 )));
				half2 appendResult60 = (half2(_MainTex_TexelSize.x , _MainTex_TexelSize.y));
				half2 s71 = ( appendResult50 * appendResult60 * IN.ase_texcoord5.xyz.z );
				half4 appendResult63 = (half4(IN.ase_texcoord4.xy.xy , IN.ase_texcoord5.xyz.xy));
				half4 border65 = appendResult63;
				half4 appendResult67 = (half4(appendResult60 , appendResult60));
				half4 temp_cast_3 = (0.499).xxxx;
				half4 b71 = min( ( border65 * appendResult67 ) , temp_cast_3 );
				half2 localUV9Slice71 = UV9Slice71( uv71 , s71 , b71 );
				half4 tex2DNode48 = tex2D( _MainTex, localUV9Slice71 );
				half smoothstepResult80 = smoothstep( IN.ase_texcoord4.z , IN.ase_texcoord4.w , tex2DNode48.r);
				half temp_output_84_0 = ( smoothstepResult80 * tex2DNode48.a );
				half3 lerpResult86 = lerp( (IN.color).rgb , IN.ase_normal , temp_output_84_0);
				half4 appendResult44 = (half4(lerpResult86 , ( IN.color.a * ( 1.0 - temp_output_84_0 ) )));
				
				
				fixed4 color = appendResult44;

				half2 m = saturate((_ClipRect.zw - _ClipRect.xy - abs(IN.mask.xy)) * IN.mask.zw);
				#ifdef SUPPORT_CLIP_RECT
					#ifdef UNITY_UI_CLIP_RECT
					color.a *= m.x * m.y;
					#endif
				#else
					half rectMask = m.x * m.y;
					color.rgb = lerp(IN.color.rgb, color.rgb, rectMask);
					color.a = max(color.a, (1.0 - rectMask) * IN.color.a);
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
-1827;105;1715;858;1378.917;828.3768;1.046559;True;False
Node;AmplifyShaderEditor.CommentaryNode;76;-2610,-434;Inherit;False;1634;934;UV9Slice;19;59;51;62;64;52;74;60;63;67;75;65;50;47;70;66;69;72;61;71;;1,0.5697687,0,1;0;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;62;-2560,-384;Inherit;False;1;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;64;-2560,-128;Inherit;False;2;3;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;51;-2560,128;Inherit;False;Global;_ClipRect;_ClipRect;1;0;Fetch;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexelSizeNode;59;-1920,128;Inherit;False;48;1;0;SAMPLER2D;;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;74;-2304,126.2424;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;63;-2304,-256;Inherit;False;FLOAT4;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT2;0,0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;60;-1664,128;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;52;-2304,256;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;75;-2129.496,182.2226;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;67;-1536,256;Inherit;False;FLOAT4;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT2;0,0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;65;-2176,-256;Inherit;False;border;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldPosInputsNode;47;-1664,-384;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;70;-1536,384;Inherit;False;Constant;_Float0;Float 0;1;0;Create;True;0;0;0;False;0;False;0.499;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-1408,128;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;50;-1664,-128;Inherit;False;FLOAT2;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMinOpNode;69;-1280,128;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0.499;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;72;-1408,-384;Inherit;False;FLOAT2;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-1536,-128;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CustomExpressionNode;71;-1152,-384;Inherit;False;float2 t = saturate((s * uv - b.xy) / (s - b.xy - b.zw))@$return lerp(uv * s, 1. - s * (1. - uv), t)@;2;Create;3;True;uv;FLOAT2;0,0;In;;Inherit;False;True;s;FLOAT2;0,0;In;;Inherit;False;True;b;FLOAT4;0,0,0,0;In;;Inherit;False;UV9Slice;True;False;0;;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;78;-653.3168,-876.4672;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;48;-768,-640;Inherit;True;Property;_MainTex;MainTex;0;1;[PerRendererData];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;80;-391.6455,-663.7629;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;-306.6234,-535.6008;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;12;-768,-384;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;56;-565,-120;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;85;-811.5174,-204.2115;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;45;-506,-394;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;-238,-172;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;86;-87.271,-542.4823;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;44;74.64235,-247.8377;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;79;-397.3168,-876.4672;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;11;286,-290;Half;False;True;-1;2;ASEMaterialInspector;0;20;Treeverse/UI/Unmask;ce0bf6a6e544803479533b89b14999b1;True;Forward;0;0;Forward;1;False;True;3;1;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;True;0;True;-7;False;False;False;False;False;False;False;True;True;0;True;-3;255;True;-6;255;True;-5;0;True;-2;0;True;-4;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;0;True;-9;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;False;0;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;False;True;True;2;False;-1;True;7;False;-1;True;False;0;False;-1;0;False;-1;True;1;LightMode=SRPDefaultUnlit;True;0;False;0;;0;0;Standard;1;Support Clip Rect;0;638018543941014620;0;1;True;False;;False;0
WireConnection;74;0;51;3
WireConnection;74;1;51;4
WireConnection;63;0;62;0
WireConnection;63;2;64;0
WireConnection;60;0;59;1
WireConnection;60;1;59;2
WireConnection;52;0;51;1
WireConnection;52;1;51;2
WireConnection;75;0;74;0
WireConnection;75;1;52;0
WireConnection;67;0;60;0
WireConnection;67;2;60;0
WireConnection;65;0;63;0
WireConnection;66;0;65;0
WireConnection;66;1;67;0
WireConnection;50;0;75;0
WireConnection;69;0;66;0
WireConnection;69;1;70;0
WireConnection;72;0;47;0
WireConnection;61;0;50;0
WireConnection;61;1;60;0
WireConnection;61;2;64;3
WireConnection;71;0;72;0
WireConnection;71;1;61;0
WireConnection;71;2;69;0
WireConnection;48;1;71;0
WireConnection;80;0;48;1
WireConnection;80;1;78;3
WireConnection;80;2;78;4
WireConnection;84;0;80;0
WireConnection;84;1;48;4
WireConnection;56;0;84;0
WireConnection;45;0;12;0
WireConnection;49;0;12;4
WireConnection;49;1;56;0
WireConnection;86;0;45;0
WireConnection;86;1;85;0
WireConnection;86;2;84;0
WireConnection;44;0;86;0
WireConnection;44;3;49;0
WireConnection;79;0;78;3
WireConnection;79;1;78;4
WireConnection;11;1;44;0
ASEEND*/
//CHKSM=FB3735314F92998CEEAC4B5C9A8CA1BF423EC242
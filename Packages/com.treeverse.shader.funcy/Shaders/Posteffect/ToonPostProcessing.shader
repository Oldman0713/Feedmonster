// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Hidden/Treeverse/ToonPostProcessing"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector]_MainTex("MainTex", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	
	}
	
	SubShader
	{
		LOD 0

		Tags { "RenderPipeline"="UniversalPipeline" "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }

		
		Pass
		{
			Name "Forward"
			Tags { "LightMode"="SRPDefaultUnlit" }
		
			Blend Off
			Cull Off
			ZWrite Off
			ZTest Always
			Offset 0,0
			ColorMask RGBA
			Fog
			{
				Mode off
			}

			HLSLPROGRAM
			
			#define ASE_SRP_VERSION 999999
			#define ASE_USING_SAMPLING_MACROS 1

			
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma target 3.0
			
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			
			#pragma multi_compile _ _RadiusBlur
			
			struct appdata_t
			{
				float4 vertex: POSITION;
				float2 texcoord: TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				
			};
			
			struct v2f
			{
				float4 vertex: SV_POSITION;
				float2 texcoord: TEXCOORD0;
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord2 : TEXCOORD2;
			#if _RadiusBlur
            	half4 dirAndDistAndT: TEXCOORD3;
            	half2 pushUV[10]: TEXCOORD4;
        	#endif
			};
			
			float4 _ClipRect;
			float _UIMaskSoftnessX;
			float _UIMaskSoftnessY;
			TEXTURE2D(_MainTex);
			TEXTURE2D(_RefractionBuffer);
			SAMPLER(sampler_RefractionBuffer);
			SAMPLER(sampler_MainTex);
			half _ToonAdjustContrast;
			TEXTURE2D(_ToonPPSBuffer);
			SAMPLER(sampler_ToonPPSBuffer);

			#if _RadiusBlur
        		uniform half4x4 _VPMatrix;
        		uniform half _BlurStrength;
        		uniform half _BlurWidth;
        		uniform half3 _BlurWorldPosition;
    		#endif
			half3 HSVToRGB( half3 c )
			{
				half4 K = half4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
				half3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
				return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
			}
			

			v2f vert(appdata_t input )
			{
				v2f output = (v2f)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
				float4 vPosition = TransformObjectToHClip(input.vertex.xyz);
				
				half2 uv415 = input.texcoord.xy;
				half2 temp_output_420_0 = ( uv415 - float2( 0.5,0.5 ) );
				half2 vertexToFrag430 = ( temp_output_420_0 * float2( 2,2 ) );
				output.ase_texcoord2.xy = vertexToFrag430;
				half vertexToFrag431 = ( 1.0 - length( temp_output_420_0 ) );
				output.ase_texcoord2.z = vertexToFrag431;
				
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord2.w = 0;

				output.vertex = vPosition;
				output.texcoord = input.texcoord;
        #if _RadiusBlur
            half4 projPos = mul(_VPMatrix, half4(_BlurWorldPosition.xyz, 1.0));
            half3 ndcPos = projPos.xyz / projPos.w;
            half3 viewportPos = half3(ndcPos.x * 0.5 + 0.5, 1.0 - (ndcPos.y * 0.5 + 0.5), 0.0);
            half2 center = viewportPos.xy;
            half2 dir = center - output.texcoord.xy;
            half dist = sqrt(dir.x * dir.x + dir.y * dir.y);
            output.dirAndDistAndT = half4(dir / dist, dist, saturate(dist * _BlurStrength));
            // some sample positions
            half samples[10] = {
                - 0.08, -0.05, -0.03, -0.02, -0.01, 0.01, 0.02, 0.03, 0.05, 0.08
            };
            for (int n = 0; n < 10; n ++)
            {
                output.pushUV[n] = dir * samples[n] * _BlurWidth;
            }
        #endif
				return output;
			}
			
			half4 frag(v2f IN ): SV_Target
			{
				half2 uv415 = IN.texcoord.xy;
				half2 vertexToFrag430 = IN.ase_texcoord2.xy;
				float2 uv_RefractionBuffer419 = IN.texcoord.xy;
				half4 tex2DNode419 = SAMPLE_TEXTURE2D( _RefractionBuffer, sampler_RefractionBuffer, uv_RefractionBuffer419 );
				half vertexToFrag431 = IN.ase_texcoord2.z;
				half2 distortionUV511 = ( vertexToFrag430 * max( max( tex2DNode419.r , tex2DNode419.g ) , tex2DNode419.b ) * vertexToFrag431 );
				half2 distortedUV455 = ( uv415 + distortionUV511 );
				half4 appendResult298 = SAMPLE_TEXTURE2D( _MainTex, sampler_MainTex, distortedUV455 );
				half3 baseColor169 = appendResult298.rgb;
				half temp_output_3_0_g4 = _ToonAdjustContrast;
				half3 lerpResult5_g4 = lerp( (0.214).xxx , baseColor169 , ( temp_output_3_0_g4 * temp_output_3_0_g4 ));
				half3 temp_output_412_0 = lerpResult5_g4;
				half3 worldToViewDir335 = mul( UNITY_MATRIX_V, float4( _MainLightPosition.xyz, 0 ) ).xyz;
				half2 normalizeResult367 = normalize( (worldToViewDir335).xy );
				half2 appendResult365 = (half2(( _ScreenParams.y / _ScreenParams.x ) , 1.0));
				half4 tex2DNode304 = SAMPLE_TEXTURE2D( _ToonPPSBuffer, sampler_ToonPPSBuffer, uv415 );
				half RimLightSize360 = tex2DNode304.r;
				half SufraceDepth362 = tex2DNode304.g;
				half temp_output_355_0 = ( SAMPLE_TEXTURE2D( _ToonPPSBuffer, sampler_ToonPPSBuffer, ( IN.texcoord.xy + ( normalizeResult367 * appendResult365 * RimLightSize360 ) ) ).g - SufraceDepth362 );
				half3 hsvTorgb401 = HSVToRGB( half3(tex2DNode304.b,tex2DNode304.a,1.0) );
				half3 lerpResult372 = lerp( baseColor169 , ( temp_output_412_0 + ( temp_output_412_0 * abs( temp_output_355_0 ) * hsvTorgb401 ) ) , ( 1.0 - step( SufraceDepth362 , 0.0 ) ));
				half3 toonPostColor564 = lerpResult372;
				half4 appendResult580 = (half4(toonPostColor564 , appendResult298.a));
				
				
				half4 color = appendResult580;
			#if _RadiusBlur
            	half4 sum = color;
            	for (int n = 0; n < 10; n ++)
            	{
                	sum += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, distortedUV455 + IN.pushUV[n]);
            	}
            
            	//eleven samples...
            	sum *= 0.0909;
            
            	color.rgb = lerp(color.rgb, sum.rgb, IN.dirAndDistAndT.w);
        	#endif
				return color;
			}

			ENDHLSL
			
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18935
282;174;2047;1094;367.969;1974.233;1.633412;True;False
Node;AmplifyShaderEditor.TexCoordVertexDataNode;13;-1536,-896;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;428;-50,206;Inherit;False;1437;688;Distortion;12;419;420;421;422;423;424;425;426;429;430;431;511;;0.7122642,0.8993988,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;415;-1280,-896;Inherit;False;uv;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;429;0,512;Inherit;False;415;uv;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;420;256,512;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;419;0,256;Inherit;True;Global;_RefractionBuffer;_RefractionBuffer;2;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LengthOpNode;422;384,640;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;424;384,512;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;2,2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;425;512,512;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;421;384,256;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;423;512,256;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;430;512,384;Inherit;False;False;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VertexToFragmentNode;431;640,512;Inherit;False;False;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;426;896,384;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;57;-1046.136,-903.0126;Inherit;False;1832.345;1061.479;SobelOutline;12;357;355;304;303;363;373;387;401;376;413;416;318;SobelOutline;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;511;1024,384;Inherit;False;distortionUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;334;-2304,-384;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;416;-896,-864;Inherit;False;415;uv;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;417;1280,0;Inherit;False;415;uv;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;512;1280,128;Inherit;False;511;distortionUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;303;-959,-549;Inherit;True;Global;_ToonPPSBuffer;_ToonPPSBuffer;0;0;Create;True;0;0;0;False;0;False;None;None;False;black;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TransformDirectionNode;335;-2048,-384;Inherit;False;World;View;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ScreenParams;328;-2304,-128;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;304;-703,-837;Inherit;True;Property;_TextureSample1;Texture Sample 1;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;427;1536,0;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;455;1792,0;Inherit;False;distortedUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;339;-1792,-384;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;366;-2048,-80;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;360;-256,-1152;Inherit;False;RimLightSize;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;361;-2048,128;Inherit;False;360;RimLightSize;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;456;1280,-256;Inherit;False;455;distortedUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;365;-1792,-96;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NormalizeNode;367;-1600,-336;Inherit;False;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;333;-1536,-128;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;6;1536,-256;Inherit;True;Property;_MainTex;MainTex;1;1;[HideInInspector];Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;317;-2304,-512;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;318;-1040,-544;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;298;1920,-256;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;362;-256,-910;Inherit;False;SufraceDepth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;169;2048,-256;Inherit;False;baseColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;387;-575,-453;Inherit;True;Property;_TextureSample3;Texture Sample 3;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;363;-512,-256;Inherit;False;362;SufraceDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;299;322,-1444;Inherit;False;169;baseColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;406;-288.2674,-1291.249;Inherit;False;Global;_ToonAdjustContrast;_ToonAdjustContrast;2;0;Create;True;0;0;0;False;0;False;1;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;355;-75.40002,-447.8;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;373;482,-607;Inherit;False;362;SufraceDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;357;193,-453;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;401;-191,-709;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;412;368.6966,-1076.136;Inherit;False;AdjustContrast;-1;;4;ab5193b6daea32241b2f15212fb99963;0;2;1;FLOAT3;0,0,0;False;3;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;376;561.2145,-892.4974;Inherit;False;3;3;0;FLOAT3;1,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StepOpNode;374;896,-768;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;407;1024,-896;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;375;847.3095,-1132.593;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;372;1152,-1152;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;509;-2960,976;Inherit;False;4417.151;2564.595;Radius Blur Effect;129;554;553;552;551;550;549;548;547;513;535;534;533;532;531;530;529;528;527;525;546;545;544;543;542;541;540;539;537;538;526;510;524;523;522;521;520;519;518;517;516;515;514;504;506;490;472;497;505;500;496;482;493;492;480;503;485;481;483;488;502;487;491;471;495;507;489;432;486;501;465;468;473;474;467;434;499;436;479;470;444;461;453;450;446;439;498;448;454;459;462;463;447;457;438;449;460;441;451;452;445;442;466;437;458;464;443;440;494;469;555;556;557;558;559;560;563;565;566;567;568;569;570;572;573;574;575;576;577;578;Radius Blur Effect;1,0.4754717,0.8453727,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;564;1408,-1280;Inherit;False;toonPostColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;466;-1664,2560;Inherit;False;464;radius_blur_dist;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;550;0,2816;Inherit;True;Property;_TextureSample10;Texture Sample 10;1;0;Create;True;0;0;0;False;0;False;6;None;None;True;0;False;white;Auto;False;Instance;6;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;528;-384,1920;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;569;768,1536;Inherit;False;FLOAT;3;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;552;0,3072;Inherit;True;Property;_TextureSample11;Texture Sample 11;1;0;Create;True;0;0;0;False;0;False;6;None;None;True;0;False;white;Auto;False;Instance;6;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;540;0,1536;Inherit;True;Property;_TextureSample5;Texture Sample 5;1;0;Create;True;0;0;0;False;0;False;6;None;None;True;0;False;white;Auto;False;Instance;6;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;566;896,1280;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;533;-384,2560;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;542;0,1792;Inherit;True;Property;_TextureSample6;Texture Sample 6;1;0;Create;True;0;0;0;False;0;False;6;None;None;True;0;False;white;Auto;False;Instance;6;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;567;640,1408;Inherit;False;563;radius_blur_sum;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;565;640,1280;Inherit;False;564;toonPostColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;543;0,2048;Inherit;True;Property;_TextureSample7;Texture Sample 7;1;0;Create;True;0;0;0;False;0;False;6;None;None;True;0;False;white;Auto;False;Instance;6;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;554;0,3328;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;6;None;None;True;0;False;white;Auto;False;Instance;6;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;563;1152,1792;Inherit;False;radius_blur_sum;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;530;-384,2176;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;525;-384,1664;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;570;1152,1024;Inherit;False;radius_blur_Color;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;571;1408,-1152;Inherit;False;570;radius_blur_Color;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;413;174.972,-588.2177;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;531;-384,2304;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;529;-384,2048;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;535;-384,2816;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;546;0,2304;Inherit;True;Property;_TextureSample8;Texture Sample 8;1;0;Create;True;0;0;0;False;0;False;6;None;None;True;0;False;white;Auto;False;Instance;6;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;568;640,1664;Inherit;False;468;dirAndDistAndT;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;471;-1664,2688;Inherit;False;Global;_BlurStrength;_BlurStrength;3;0;Create;True;0;0;0;False;0;False;0;0.6684899;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;548;0,2560;Inherit;True;Property;_TextureSample9;Texture Sample 9;1;0;Create;True;0;0;0;False;0;False;6;None;None;True;0;False;white;Auto;False;Instance;6;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;557;768,2304;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;465;-1152,2560;Inherit;False;FLOAT4;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SaturateNode;470;-1280,2688;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;474;-1408,2432;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;556;640,3328;Inherit;False;5;5;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;541;384,1792;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;515;-640,1152;Inherit;False;FLOAT2;2;3;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;473;-1664,2432;Inherit;False;469;radius_blur_dir;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;472;-1408,2688;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;527;-384,1792;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;539;384,1536;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;558;1024,2176;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;526;384,1024;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;560;1024,2304;Inherit;False;Constant;_00909;0.0909;12;0;Create;True;0;0;0;False;0;False;0.0909;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;467;-896,2560;Inherit;False;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;553;384,3328;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;551;384,3072;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;545;384,2304;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;549;384,2816;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;547;384,2560;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;559;1152,2176;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;544;384,2048;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;490;-1664,1920;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;578;-1024,2688;Inherit;False;Property;_Keyword6;Keyword 1;7;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;561;True;True;All;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;537;0,1280;Inherit;True;Property;_TextureSample4;Texture Sample 4;1;0;Create;True;0;0;0;False;0;False;6;None;None;True;0;False;white;Auto;False;Instance;6;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;510;0,1024;Inherit;True;Property;_TextureSample2;Texture Sample 2;1;0;Create;True;0;0;0;False;0;False;6;None;None;True;0;False;white;Auto;False;Instance;6;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;468;-640,2560;Inherit;False;dirAndDistAndT;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StaticSwitch;572;1024,1920;Inherit;False;Property;_Keyword0;Keyword 0;12;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;561;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;524;768,2048;Inherit;False;169;baseColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;516;-640,1280;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;532;-384,2432;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;469;-2560,1920;Inherit;False;radius_blur_dir;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;434;-2816,1280;Inherit;False;Constant;_Float1;Float 1;3;0;Create;True;0;0;0;False;0;False;-0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;486;-2816,1664;Inherit;False;Constant;_Float2;Float 2;3;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;487;-2816,1792;Inherit;False;Constant;_Vector1;Vector 1;3;0;Create;True;0;0;0;False;0;False;0.02,0.03,0.05,0.08;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;432;-2816,1024;Inherit;False;Constant;_Vector0;Vector 0;3;0;Create;True;0;0;0;False;0;False;-0.08,-0.05,-0.03,-0.02;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;436;-2816,1536;Inherit;False;Global;_BlurWidth;_BlurWidth;3;0;Create;True;0;0;0;False;0;False;0;0.1672369;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;479;-2816,1408;Inherit;False;469;radius_blur_dir;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;580;1920,-1280;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;491;-1664,2048;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;494;-1408,1280;Inherit;False;FLOAT4;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT2;0,0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StaticSwitch;577;-1152,2176;Inherit;False;Property;_Keyword5;Keyword 1;6;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;561;True;True;All;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;480;-1664,1024;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;481;-1664,1152;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;492;-1664,2176;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;488;-1664,1664;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;458;-2688,2048;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;454;-2944,2048;Inherit;False;453;radius_blur_viewPos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;457;-2944,2176;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;453;-1920,2304;Inherit;False;radius_blur_viewPos;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector3Node;438;-2944,2688;Inherit;False;Global;_BlurWorldPosition;_BlurWorldPosition;3;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,-0.15;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;483;-1664,1408;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Matrix4X4Node;437;-2944,2560;Inherit;False;Global;_VPMatrix;_VPMatrix;3;0;Create;True;0;0;0;False;0;False;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;439;-2560,2560;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SwizzleNode;442;-2432,2688;Inherit;False;FLOAT;3;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;441;-2432,2560;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;443;-2304,2560;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;519;-640,1664;Inherit;False;FLOAT2;2;3;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;503;-896,1024;Inherit;False;pushUV01;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.OneMinusNode;452;-2304,2432;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;449;-2048,2304;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;450;-2560,2432;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;447;-2560,2304;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;451;-2432,2432;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;448;-2432,2304;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;444;-2688,2304;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;446;-2944,2304;Inherit;False;445;radius_blur_ndcPos;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;489;-1664,1792;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;496;-1408,1792;Inherit;False;FLOAT4;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT2;0,0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;445;-1920,2560;Inherit;False;radius_blur_ndcPos;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;507;-896,2048;Inherit;False;pushUV89;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;534;-384,2688;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;440;-2688,2688;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;485;-1664,1536;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;482;-1664,1280;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;561;1775,-1037;Inherit;True;Property;_RadiusBlur;RadiusBlur;12;0;Create;False;0;0;0;False;0;False;1;0;0;False;_RadiusBlur;Toggle;2;Key0;Key1;Create;True;False;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;514;-640,1024;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;522;-640,2048;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;520;-640,1792;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;517;-640,1408;Inherit;False;FLOAT2;2;3;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SqrtOpNode;463;-2176,2048;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;513;-768,2304;Inherit;False;455;distortedUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;523;-768,2176;Inherit;False;FLOAT2;2;3;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;518;-640,1536;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;464;-1920,2048;Inherit;False;radius_blur_dist;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;504;-896,1280;Inherit;False;pushUV23;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;495;-1408,1536;Inherit;False;FLOAT4;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT2;0,0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;506;-896,1792;Inherit;False;pushUV67;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;505;-896,1536;Inherit;False;pushUV45;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;497;-1408,2048;Inherit;False;FLOAT4;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT2;0,0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;538;384,1280;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;493;-1408,1024;Inherit;False;FLOAT4;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT2;0,0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.BreakToComponentsNode;459;-2560,2048;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.VertexToFragmentNode;502;-1280,2048;Inherit;False;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.VertexToFragmentNode;501;-1280,1792;Inherit;False;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.VertexToFragmentNode;499;-1280,1280;Inherit;False;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;462;-2304,2048;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;500;-1280,1536;Inherit;False;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StaticSwitch;573;-1152,1152;Inherit;False;Property;_Keyword1;Keyword 1;12;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;561;True;True;All;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StaticSwitch;575;-1152,1664;Inherit;False;Property;_Keyword3;Keyword 1;4;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;561;True;True;All;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StaticSwitch;576;-1152,1920;Inherit;False;Property;_Keyword4;Keyword 1;5;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;561;True;True;All;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;555;640,2048;Inherit;False;5;5;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;574;-1152,1408;Inherit;False;Property;_Keyword2;Keyword 1;3;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;561;True;True;All;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;460;-2432,2048;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;461;-2432,2176;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;498;-1280,1024;Inherit;False;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SwizzleNode;521;-640,1920;Inherit;False;FLOAT2;2;3;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;581;2304,-1280;Half;False;True;-1;2;ASEMaterialInspector;0;21;Hidden/Treeverse/ToonPostProcessing;940fe07787f047847b8fd8aad343b39c;True;Forward;0;0;Forward;1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;False;False;0;True;True;0;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;False;True;True;2;False;-1;True;7;False;-1;True;False;0;False;-1;0;False;-1;True;1;LightMode=SRPDefaultUnlit;True;2;False;0;;0;0;Standard;0;0;1;True;False;;True;0
WireConnection;415;0;13;0
WireConnection;420;0;429;0
WireConnection;422;0;420;0
WireConnection;424;0;420;0
WireConnection;425;0;422;0
WireConnection;421;0;419;1
WireConnection;421;1;419;2
WireConnection;423;0;421;0
WireConnection;423;1;419;3
WireConnection;430;0;424;0
WireConnection;431;0;425;0
WireConnection;426;0;430;0
WireConnection;426;1;423;0
WireConnection;426;2;431;0
WireConnection;511;0;426;0
WireConnection;335;0;334;0
WireConnection;304;0;303;0
WireConnection;304;1;416;0
WireConnection;304;7;303;1
WireConnection;427;0;417;0
WireConnection;427;1;512;0
WireConnection;455;0;427;0
WireConnection;339;0;335;0
WireConnection;366;0;328;2
WireConnection;366;1;328;1
WireConnection;360;0;304;1
WireConnection;365;0;366;0
WireConnection;367;0;339;0
WireConnection;333;0;367;0
WireConnection;333;1;365;0
WireConnection;333;2;361;0
WireConnection;6;1;456;0
WireConnection;318;0;317;0
WireConnection;318;1;333;0
WireConnection;298;0;6;0
WireConnection;362;0;304;2
WireConnection;169;0;298;0
WireConnection;387;0;303;0
WireConnection;387;1;318;0
WireConnection;355;0;387;2
WireConnection;355;1;363;0
WireConnection;357;0;355;0
WireConnection;401;0;304;3
WireConnection;401;1;304;4
WireConnection;412;1;299;0
WireConnection;412;3;406;0
WireConnection;376;0;412;0
WireConnection;376;1;357;0
WireConnection;376;2;401;0
WireConnection;374;0;373;0
WireConnection;407;0;374;0
WireConnection;375;0;412;0
WireConnection;375;1;376;0
WireConnection;372;0;299;0
WireConnection;372;1;375;0
WireConnection;372;2;407;0
WireConnection;564;0;372;0
WireConnection;550;1;533;0
WireConnection;528;0;513;0
WireConnection;528;1;516;0
WireConnection;569;0;568;0
WireConnection;552;1;534;0
WireConnection;540;1;528;0
WireConnection;566;0;565;0
WireConnection;566;1;567;0
WireConnection;566;2;569;0
WireConnection;533;0;513;0
WireConnection;533;1;521;0
WireConnection;542;1;529;0
WireConnection;543;1;530;0
WireConnection;554;1;535;0
WireConnection;563;0;572;0
WireConnection;530;0;513;0
WireConnection;530;1;518;0
WireConnection;525;0;513;0
WireConnection;525;1;514;0
WireConnection;570;0;566;0
WireConnection;413;0;355;0
WireConnection;531;0;513;0
WireConnection;531;1;519;0
WireConnection;529;0;513;0
WireConnection;529;1;517;0
WireConnection;535;0;513;0
WireConnection;535;1;523;0
WireConnection;546;1;531;0
WireConnection;548;1;532;0
WireConnection;557;0;555;0
WireConnection;557;1;556;0
WireConnection;465;0;474;0
WireConnection;465;2;466;0
WireConnection;465;3;470;0
WireConnection;470;0;472;0
WireConnection;474;0;473;0
WireConnection;474;1;466;0
WireConnection;556;0;545;0
WireConnection;556;1;547;0
WireConnection;556;2;549;0
WireConnection;556;3;551;0
WireConnection;556;4;553;0
WireConnection;541;0;542;0
WireConnection;515;0;503;0
WireConnection;472;0;466;0
WireConnection;472;1;471;0
WireConnection;527;0;513;0
WireConnection;527;1;515;0
WireConnection;539;0;540;0
WireConnection;558;0;524;0
WireConnection;558;1;557;0
WireConnection;526;0;510;0
WireConnection;467;0;578;0
WireConnection;553;0;554;0
WireConnection;551;0;552;0
WireConnection;545;0;546;0
WireConnection;549;0;550;0
WireConnection;547;0;548;0
WireConnection;559;0;558;0
WireConnection;559;1;560;0
WireConnection;544;0;543;0
WireConnection;490;0;479;0
WireConnection;490;1;487;2
WireConnection;490;2;436;0
WireConnection;578;0;465;0
WireConnection;537;1;527;0
WireConnection;510;1;525;0
WireConnection;468;0;467;0
WireConnection;572;0;559;0
WireConnection;516;0;504;0
WireConnection;532;0;513;0
WireConnection;532;1;520;0
WireConnection;469;0;458;0
WireConnection;580;0;564;0
WireConnection;491;0;479;0
WireConnection;491;1;487;3
WireConnection;491;2;436;0
WireConnection;494;0;482;0
WireConnection;494;2;483;0
WireConnection;577;0;502;0
WireConnection;480;0;479;0
WireConnection;480;1;432;1
WireConnection;480;2;436;0
WireConnection;481;0;479;0
WireConnection;481;1;432;2
WireConnection;481;2;436;0
WireConnection;492;0;479;0
WireConnection;492;1;487;4
WireConnection;492;2;436;0
WireConnection;488;0;479;0
WireConnection;488;1;486;0
WireConnection;488;2;436;0
WireConnection;458;0;454;0
WireConnection;458;1;457;0
WireConnection;453;0;449;0
WireConnection;483;0;479;0
WireConnection;483;1;432;4
WireConnection;483;2;436;0
WireConnection;439;0;437;0
WireConnection;439;1;440;0
WireConnection;442;0;439;0
WireConnection;441;0;439;0
WireConnection;443;0;441;0
WireConnection;443;1;442;0
WireConnection;519;0;505;0
WireConnection;503;0;573;0
WireConnection;452;0;451;0
WireConnection;449;0;448;0
WireConnection;449;1;452;0
WireConnection;450;0;444;1
WireConnection;447;0;444;0
WireConnection;451;0;450;0
WireConnection;448;0;447;0
WireConnection;444;0;446;0
WireConnection;489;0;479;0
WireConnection;489;1;487;1
WireConnection;489;2;436;0
WireConnection;496;0;489;0
WireConnection;496;2;490;0
WireConnection;445;0;443;0
WireConnection;507;0;577;0
WireConnection;534;0;513;0
WireConnection;534;1;522;0
WireConnection;440;0;438;0
WireConnection;485;0;479;0
WireConnection;485;1;434;0
WireConnection;485;2;436;0
WireConnection;482;0;479;0
WireConnection;482;1;432;3
WireConnection;482;2;436;0
WireConnection;561;1;564;0
WireConnection;561;0;571;0
WireConnection;514;0;503;0
WireConnection;522;0;507;0
WireConnection;520;0;506;0
WireConnection;517;0;504;0
WireConnection;463;0;462;0
WireConnection;523;0;507;0
WireConnection;518;0;505;0
WireConnection;464;0;463;0
WireConnection;504;0;574;0
WireConnection;495;0;485;0
WireConnection;495;2;488;0
WireConnection;506;0;576;0
WireConnection;505;0;575;0
WireConnection;497;0;491;0
WireConnection;497;2;492;0
WireConnection;538;0;537;0
WireConnection;493;0;480;0
WireConnection;493;2;481;0
WireConnection;459;0;458;0
WireConnection;502;0;497;0
WireConnection;501;0;496;0
WireConnection;499;0;494;0
WireConnection;462;0;460;0
WireConnection;462;1;461;0
WireConnection;500;0;495;0
WireConnection;573;0;498;0
WireConnection;575;0;500;0
WireConnection;576;0;501;0
WireConnection;555;0;526;0
WireConnection;555;1;538;0
WireConnection;555;2;539;0
WireConnection;555;3;541;0
WireConnection;555;4;544;0
WireConnection;574;0;499;0
WireConnection;460;0;459;0
WireConnection;460;1;459;0
WireConnection;461;0;459;1
WireConnection;461;1;459;1
WireConnection;498;0;493;0
WireConnection;521;0;506;0
WireConnection;581;1;580;0
ASEEND*/
//CHKSM=7B26D04E74EBC9844797D0A3D1E438D68AA3B7B4
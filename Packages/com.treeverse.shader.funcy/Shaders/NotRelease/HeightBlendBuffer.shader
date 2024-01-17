// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Hidden/Treeverse/HeightBlendBuffers"
{
	Properties
	{
		[Header(______Albedo______)][Space(10)]_SplatBase("Albedo Base", 2D) = "white" {}
		_Splat0("Albedo 1", 2D) = "white" {}
		[Toggle]_IsFur0("IsFur", Float) = 0
		_Splat1("Albedo 2", 2D) = "white" {}
		[Toggle]_IsFur1("IsFur", Float) = 0
		_Splat2("Albedo 3", 2D) = "white" {}
		[Toggle]_IsFur2("IsFur", Float) = 0
		_Splat3("Albedo 4", 2D) = "white" {}
		[Toggle]_IsFur3("IsFur", Float) = 1
		[Header(______Physicals______)][NoScaleOffset][Normal][SingleLineTexture][Space(10)]_NormalBase("Normal Base", 2D) = "bump" {}
		_NormalIntensityBase("Normal Scale", Range( 0 , 10)) = 1
		[NoScaleOffset][SingleLineTexture]_MetallicGlossBase("Metallic Base", 2D) = "white" {}
		_SmoothnessBase("Smoothness Base", Range( 0 , 1)) = 1
		_MetallicBase("Metallic Base", Range( 0 , 1)) = 1
		_AOBase("AO Base", Range( 0 , 1)) = 0
		[NoScaleOffset][Normal][SingleLineTexture]_Normal0("Normal 1", 2D) = "bump" {}
		_NormalIntensity0("Normal Scale", Range( 0 , 10)) = 1
		[NoScaleOffset][SingleLineTexture]_MetallicGloss0("Metallic 1", 2D) = "white" {}
		_AO0("AO 1", Range( 0 , 1)) = 0
		_Smoothness0("Smoothness 1", Range( 0 , 1)) = 0
		_Metallic0("Metallic 1", Range( 0 , 1)) = 1
		[NoScaleOffset][Normal][SingleLineTexture]_Normal1("Normal 2", 2D) = "bump" {}
		_NormalIntensity1("Normal Scale", Range( 0 , 10)) = 1
		[NoScaleOffset][SingleLineTexture]_MetallicGloss1("Metallic 2", 2D) = "white" {}
		_Smoothness1("Smoothness 2", Range( 0 , 1)) = 1
		_Metallic1("Metallic 2", Range( 0 , 1)) = 1
		_AO1("AO 2", Range( 0 , 1)) = 0
		[NoScaleOffset][Normal][SingleLineTexture]_Normal2("Normal 3", 2D) = "bump" {}
		_NormalIntensity2("Normal Scale", Range( 0 , 10)) = 1
		[NoScaleOffset][SingleLineTexture]_MetallicGloss2("Metallic 3", 2D) = "white" {}
		_AO2("AO 3", Range( 0 , 1)) = 0
		_Smoothness2("Smoothness 3", Range( 0 , 1)) = 1
		_Metallic2("Metallic 3", Range( 0 , 1)) = 1
		[NoScaleOffset][Normal][SingleLineTexture]_Normal3("Normal 4", 2D) = "bump" {}
		_NormalIntensity3("Normal Scale", Range( 0 , 10)) = 1
		[NoScaleOffset][SingleLineTexture]_MetallicGloss3("Metallic 4", 2D) = "white" {}
		_Smoothness3("Smoothness 4", Range( 0 , 1)) = 1
		_AO3("AO 4", Range( 0 , 1)) = 0
		_Metallic3("Metallic 4", Range( 0 , 1)) = 1
		[Header(______Height Scale______)][Space(10)]_ParallaxHeightScaleBase("Scale Base", Float) = 0
		_ParallaxHeightScale0("Scale 0", Float) = 0
		_ParallaxHeightScale1("Scale 1", Float) = 0
		_ParallaxHeightScale2("Scale 2", Float) = 0
		_ParallaxHeightScale3("Scale 3", Float) = 0
		[Toggle]_SwitchBuffer("SwitchBuffer", Float) = 0

	}
	
	SubShader
	{
		LOD 0

		Tags { "Queue"="Overlay+1000" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" "CanUseSpriteAtlas"="True" }
		Cull Off
		Lighting Off
		ZWrite Off
		ZTest Always
		
		
		Pass
		{
			Name "Forward"
			Tags { "LightMode"="HeightBlendWeightExport" }
			
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off
			ZWrite Off
			ZTest Always
			Offset 0,0
			ColorMask RGBA
			

			HLSLPROGRAM
			
			
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			
			struct Attributes
			{
				float4 vertex : POSITION;
				float4 texcoord0 : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
			};

			struct Varyings
			{
				float4 positionCS	: SV_POSITION;
				float4 texcoord0 : TEXCOORD0;
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord2 : TEXCOORD2;
			};
			
			CBUFFER_START(UnityPerMaterial)
			/*ase_srp_batcher*/
			CBUFFER_END
			uniform float _IsFur2;
			uniform sampler2D _MetallicGlossBase;
			uniform float _IsFur0;
			uniform sampler2D _Splat3;
			uniform sampler2D _Splat1;
			uniform sampler2D _Splat2;
			uniform float _MetallicBase;
			uniform sampler2D _Normal2;
			uniform float _Metallic3;
			uniform float _ParallaxHeightScaleBase;
			uniform float _IsFur3;
			uniform sampler2D _Splat0;
			uniform float _NormalIntensity0;
			uniform float _NormalIntensity2;
			uniform sampler2D _Normal3;
			uniform float _Metallic1;
			uniform float _AO2;
			uniform float _ParallaxHeightScale0;
			uniform float _Metallic0;
			uniform float _ParallaxHeightScale1;
			uniform float _ParallaxHeightScale3;
			uniform float _NormalIntensity1;
			uniform sampler2D _MetallicGloss2;
			uniform float _AOBase;
			uniform sampler2D _SplatBase;
			uniform float _Smoothness3;
			uniform float _Smoothness2;
			uniform float _IsFur1;
			uniform sampler2D _MetallicGloss1;
			uniform float _Metallic2;
			uniform float _NormalIntensity3;
			uniform sampler2D _Normal0;
			uniform float _AO1;
			uniform sampler2D _MetallicGloss3;
			uniform float _SmoothnessBase;
			uniform float _AO3;
			uniform sampler2D _MetallicGloss0;
			uniform sampler2D _NormalBase;
			uniform float _NormalIntensityBase;
			uniform float _AO0;
			uniform sampler2D _Normal1;
			uniform float _Smoothness0;
			uniform float _ParallaxHeightScale2;
			uniform float _Smoothness1;
			uniform float _SwitchBuffer;


						Varyings vert(Attributes input )
			{
				Varyings output = (Varyings)0;
				float2 break2_g182 = input.ase_texcoord1.xy;
				float2 appendResult4_g182 = (float2(break2_g182.x , ( 1.0 - break2_g182.y )));
				float3 appendResult6_g182 = (float3((appendResult4_g182*2.0 + -1.0) , 0.0));
				
				float weight_1592 = input.ase_texcoord2.x;
				float weight_2593 = input.ase_texcoord2.y;
				float weight_3594 = input.ase_texcoord2.z;
				float4 appendResult1677 = (float4(weight_1592 , weight_2593 , weight_3594 , 1.0));
				float weight_b1426 = input.ase_texcoord3.z;
				float weight_4595 = input.ase_texcoord2.w;
				float4 appendResult1687 = (float4(weight_b1426 , weight_4595 , 0.0 , 1.0));
				float4 lerpResult1686 = lerp( appendResult1677 , appendResult1687 , _SwitchBuffer);
				float4 vertexToFrag1689 = lerpResult1686;
				output.ase_texcoord2 = vertexToFrag1689;
				
				float3 vertexValue = appendResult6_g182;
				output.texcoord0 = input.texcoord0;
				output.positionCS = float4(vertexValue, 1.0);
				return output;
			}
			
			half4 frag(Varyings varyings ): SV_Target
			{
				float4 screenCoord = varyings.texcoord0;
				float2 uv0 = varyings.texcoord0.xy;
				float4 screenPosNrm = float4(uv0, 0, 1);

				float4 vertexToFrag1689 = varyings.ase_texcoord2;
				

				half4 color = vertexToFrag1689;
				return color;
			}
			ENDHLSL
			
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18935
-1920;0;1920;1059;668.825;3389.032;1.3;True;False
Node;AmplifyShaderEditor.CommentaryNode;984;-3072,-4992;Inherit;False;1413.999;1140.476;Prepare Valibale;26;587;586;519;576;638;637;995;992;993;994;986;985;988;987;1148;1426;1427;1147;594;593;595;592;639;1616;1617;1618;Prepare Valibale;0.5235849,0.9644278,1,1;0;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;639;-2976,-4656;Inherit;False;2;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;1427;-2976,-4912;Inherit;False;3;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;1426;-2688,-4864;Inherit;False;weight_b;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;595;-2688,-4352;Inherit;False;weight_4;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;593;-2688,-4608;Inherit;False;weight_2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;592;-2688,-4736;Inherit;False;weight_1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;594;-2688,-4480;Inherit;False;weight_3;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1683;-209.2965,-2830.606;Inherit;False;593;weight_2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1685;-209.2965,-2574.606;Inherit;False;595;weight_4;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1681;-209.2965,-2446.606;Inherit;False;1426;weight_b;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1682;-209.2965,-2958.606;Inherit;False;592;weight_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1684;-209.2965,-2702.606;Inherit;False;594;weight_3;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;1677;641.3,-2817.3;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;1687;640,-2560;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;1688;620.7747,-2371.134;Inherit;False;Property;_SwitchBuffer;SwitchBuffer;50;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;776;-1202,-818;Inherit;False;923.4272;2066.094;Blend Normal;12;771;773;770;769;1571;762;763;766;765;775;764;1605;Blend Normal;0,0.2901961,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;625;-3104,-3504;Inherit;False;1615.178;1420.132;Height Blend;20;1441;1440;1563;1443;602;613;588;609;1560;1562;1564;1561;601;1313;1244;1312;1324;1433;1323;1243;Height Blend;0,0,0,1;0;0
Node;AmplifyShaderEditor.LerpOp;1686;896,-2816;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;540;-4912,-3504;Inherit;False;1748.812;2573.133;Albedo;51;1350;1643;1642;1641;1637;1635;1636;1640;1639;1631;1629;1630;1624;1346;1348;1627;1626;1625;1620;1619;1622;1334;568;1326;534;538;530;518;504;533;537;529;517;503;532;536;528;516;502;531;535;527;514;501;1623;565;563;564;569;578;1645;Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;689;-6848,-2880;Inherit;False;1454.513;2037.335;Grass Move;42;686;685;684;682;677;674;675;676;683;678;680;681;659;666;672;671;661;662;663;664;665;660;667;668;669;670;679;673;652;651;650;649;648;647;654;653;657;658;655;656;1083;1091;Grass Move;0.6588235,1,0.07058824,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;754;-4786,-818;Inherit;False;1471.25;2334.76;Normal;31;750;749;756;751;710;698;753;719;752;690;718;716;693;717;706;697;702;699;692;691;715;709;760;759;758;757;1647;1648;1649;1650;1651;Normal;0,0.5843138,1,1;0;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;499;1152,-2304;Inherit;False;1;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;635;-1327.529,-3506;Inherit;False;1038.321;1988.506;Comment;12;634;541;1213;626;632;629;630;633;543;590;1444;1607;Blend Albedo;1,0.5230491,0.3811321,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;928;974,-818;Inherit;False;1066.435;1972.128;Blend Smoothness;22;915;908;920;916;907;925;918;911;926;919;917;906;910;904;913;912;922;927;921;923;1587;1604;Blend Smoothness;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;720;-2994,-1843;Inherit;False;977.3999;732.4;Parallax Scale;20;1657;723;722;724;725;721;567;552;549;553;554;1658;1659;1660;1661;1662;1663;1664;1665;1666;Parallax Scale;0.5471698,0.5471698,0.5471698,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;953;2126,-818;Inherit;False;1058.785;1954.905;Blend AO;32;934;951;957;961;960;939;948;946;950;945;959;933;947;955;967;940;958;968;962;936;944;964;949;970;965;966;952;963;969;943;1591;1606;Blend AO;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;792;-178,-818;Inherit;False;1096.009;1982.971;Metallic;22;1573;783;902;787;899;785;778;898;903;900;789;780;779;781;897;901;896;791;790;894;895;1603;Blend Metallic;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;646;-6832,-3504;Inherit;False;914.8;510;Grass Layer;7;640;641;642;643;645;644;1047;Grass Layer;0.6584597,1,0.06981128,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1035;846,-4914;Inherit;False;1587.186;1195.225;Discard Mask;29;1036;1056;1046;1034;1052;1022;1051;1033;1045;1026;1032;1039;1020;1042;1029;1027;1041;1030;1024;839;1038;1028;1021;1025;1031;1061;1129;1130;1131;Discard Mask;0.3529937,1,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;883;-3120,-816;Inherit;False;1456.777;2086;Metallic;31;892;893;891;890;889;888;887;886;879;885;884;867;846;864;855;863;854;851;860;881;871;876;874;869;857;844;1652;1653;1654;1655;1656;Metallic;0.6745283,1,0.8973428,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;1648;-4736,-128;Inherit;False;1625;parallax_uv_1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;948;2176,896;Inherit;False;893;map_ao_4;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;911;1152,-128;Inherit;False;602;height_compare_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ParallaxMappingNode;1626;-4480,-2688;Inherit;False;Normal;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;918;1024,128;Inherit;False;888;map_smoothness_2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;640;-6656,-3456;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;1617;-2176,-4096;Inherit;False;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;986;-2432,-4736;Inherit;False;Property;_IsFur1;IsFur;5;1;[Toggle];Create;False;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;904;1280,-384;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ParallaxMappingNode;1642;-4480,-1152;Inherit;False;Normal;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;1606;2688,0;Inherit;False;Layer Bend;-1;;181;9e870c3f57de6eb4ba1b273324827f1f;21,79,1,63,1,75,1,65,1,67,1,70,1,71,1,73,1,61,1,35,1,17,1,36,1,27,1,28,1,37,1,29,0,38,0,30,0,39,0,40,0,31,0;24;1;FLOAT3;0,0,0;False;62;FLOAT;0;False;2;FLOAT;0;False;64;FLOAT;0;False;4;FLOAT3;0,0,0;False;3;FLOAT;0;False;66;FLOAT;0;False;5;FLOAT3;0,0,0;False;6;FLOAT;0;False;68;FLOAT;0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT3;0,0,0;False;69;FLOAT;0;False;10;FLOAT;0;False;11;FLOAT3;0,0,0;False;72;FLOAT;0;False;12;FLOAT;0;False;13;FLOAT3;0,0,0;False;74;FLOAT;0;False;14;FLOAT;0;False;15;FLOAT3;0,0,0;False;76;FLOAT;0;False;16;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;896;128,-384;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;1034;1536,-4736;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1573;0,-512;Inherit;False;1441;height_compare_b;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;951;2176,-256;Inherit;False;887;map_ao_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;653;-6784,-2816;Inherit;False;642;grass_heightOffset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1624;-3968,-2944;Inherit;True;Property;_TextureSample6;Texture Sample 6;54;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;939;2304,1024;Inherit;False;613;height_compare_4;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1129;1664,-4864;Inherit;False;1061;isFirstLayer;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;888;-1920,128;Inherit;False;map_smoothness_2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;869;-2816,0;Inherit;True;Property;_MetallicGloss1;Metallic 2;24;2;[NoScaleOffset];[SingleLineTexture];Create;False;0;0;0;True;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;780;-128,384;Inherit;False;Property;_Metallic2;Metallic 3;33;0;Create;False;1;______Height Scale______;0;0;True;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;966;2432,512;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;746;-5120,-1280;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;692;-4481,-384;Inherit;True;Property;_Normal0;Normal 1;16;3;[NoScaleOffset];[Normal];[SingleLineTexture];Create;False;0;0;0;True;0;False;fe7e3a61bdd0cb643a933ead35f07cc0;fe7e3a61bdd0cb643a933ead35f07cc0;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.ParallaxMappingNode;1619;-4480,-3200;Inherit;False;Normal;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;760;-4736,1152;Inherit;False;Property;_NormalIntensity3;Normal Scale;35;0;Create;False;0;0;0;True;0;False;1;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;670;-6784,-1536;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;739;-4992,-2816;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;908;1024,384;Inherit;False;Property;_Smoothness2;Smoothness 3;32;0;Create;False;1;______Height Scale______;0;0;True;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;717;-3840,384;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;678;-6144,-1152;Inherit;False;642;grass_heightOffset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;867;-1920,-768;Inherit;False;map_metallic_base;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;741;-4992,-2304;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;783;0,-128;Inherit;False;602;height_compare_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;897;-128,-256;Inherit;False;874;map_metallic_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1655;-3072,640;Inherit;False;1636;parallax_uv_3;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;952;2944,0;Inherit;False;Out_AO;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ParallaxMappingNode;1630;-4480,-2176;Inherit;False;Normal;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;1647;-4736,-512;Inherit;False;1622;parallax_uv_b;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;887;-1920,-128;Inherit;False;map_ao_1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1656;-3072,1024;Inherit;False;1641;parallax_uv_4;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;940;2176,-640;Inherit;False;885;map_ao_base;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;899;128,384;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1243;-3008,-2944;Inherit;False;593;weight_2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;891;-1920,640;Inherit;False;map_ao_3;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ParallaxMappingNode;1635;-4480,-1664;Inherit;False;Normal;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;864;-2816,384;Inherit;True;Property;_MetallicGloss2;Metallic 3;30;2;[NoScaleOffset];[SingleLineTexture];Create;False;0;0;0;True;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;750;-3584,-384;Inherit;False;map_normal_1;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1620;-4736,-3072;Inherit;False;1618;ts_viewDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;723;-2304,-1536;Inherit;False;scale_1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;871;-1920,384;Inherit;False;map_metallic_3;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;684;-5888,-1792;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;892;-1920,896;Inherit;False;map_smoothness_4;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;907;1280,0;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;758;-4736,384;Inherit;False;Property;_NormalIntensity1;Normal Scale;23;0;Create;False;0;0;0;True;0;False;1;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;901;-128,128;Inherit;False;879;map_metallic_2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1627;-4736,-2560;Inherit;False;1618;ts_viewDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;863;-2560,-768;Inherit;True;Property;_TextureSample13;Texture Sample 13;11;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;1591;2304,-512;Inherit;False;1441;height_compare_b;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;1664;-2560,-1536;Inherit;False;False;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1440;-3008,-3328;Inherit;False;563;map_height_base;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1651;-4736,1024;Inherit;False;1641;parallax_uv_4;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;1639;-3968,-2432;Inherit;True;Property;_TextureSample7;Texture Sample 7;54;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;679;-6400,-1152;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;9;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1083;-6528,-1536;Inherit;False;1061;isFirstLayer;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;933;2304,256;Inherit;False;588;height_compare_2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;961;2560,-384;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;785;0,256;Inherit;False;588;height_compare_2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;915;1024,768;Inherit;False;Property;_Smoothness3;Smoothness 4;37;0;Create;False;1;______Height Scale______;0;0;True;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;791;640,0;Inherit;False;Out_Metallic;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;669;-6784,-1376;Inherit;False;667;move;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1618;-1920,-4096;Inherit;False;ts_viewDir;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1028;896,-4672;Inherit;False;993;isfur_2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;652;-6784,-2176;Inherit;False;Property;_WindMove;Wind Move;48;0;Create;False;0;0;0;False;0;False;0.8,0.4,0.4,1;0.8,0.4,0.4,1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;569;-4608,-3456;Inherit;True;Property;_SplatBase;Albedo Base;0;1;[Header];Create;False;1;______Albedo______;0;0;True;1;Space(10);False;164732ecebdde9b47aa1687f107ed779;164732ecebdde9b47aa1687f107ed779;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;943;2176,-768;Inherit;False;Property;_AOBase;AO Base;15;0;Create;False;1;______Height Scale______;0;0;True;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;752;-3584,384;Inherit;False;map_normal_3;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;787;0,640;Inherit;False;609;height_compare_3;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;851;-2560,384;Inherit;True;Property;_TextureSample10;Texture Sample 10;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;839;896,-4480;Inherit;False;613;height_compare_4;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;650;-6400,-2432;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1571;-1152,-513;Inherit;False;1441;height_compare_b;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1636;-4224,-1664;Inherit;False;parallax_uv_3;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;1131;896,-3964.933;Inherit;True;Property;_FurMap;Fur Map;1;0;Create;False;0;0;0;False;0;False;d0c4443f7a7823140a302dc6652d806c;d0c4443f7a7823140a302dc6652d806c;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.VertexToFragmentNode;1666;-2560,-1280;Inherit;False;False;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1631;-4736,-2048;Inherit;False;1618;ts_viewDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1654;-3072,256;Inherit;False;1629;parallax_uv_2;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;564;-3456,-3456;Inherit;False;map_color_base;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;744;-4992,-1792;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;541;-1280,-3072;Inherit;True;535;map_color_1;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;681;-6016,-1536;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;697;-4480,0;Inherit;True;Property;_Normal1;Normal 2;22;3;[NoScaleOffset];[Normal];[SingleLineTexture];Create;False;0;0;0;True;0;False;b6c1646974877914dabd9204db83a317;b6c1646974877914dabd9204db83a317;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;693;-4224,-384;Inherit;True;Property;_TextureSample14;Texture Sample 14;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;1637;-4736,-1536;Inherit;False;1618;ts_viewDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;1640;-3968,-1920;Inherit;True;Property;_TextureSample8;Texture Sample 8;54;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;528;-3456,-2304;Inherit;False;map_height_2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;893;-1920,1024;Inherit;False;map_ao_4;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;633;-1280,-1664;Inherit;False;613;height_compare_4;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;944;2176,-384;Inherit;False;Property;_AO0;AO 1;19;0;Create;False;1;______Height Scale______;0;0;True;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;568;-4352,-3456;Inherit;True;Property;_TextureSample4;Texture Sample 4;11;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;674;-6784,-1152;Inherit;False;Property;_WindIntensity;Wind Intensity;49;0;Create;True;0;0;0;False;0;False;0.2;0.017;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;1046;1792,-3840;Inherit;False;False;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;881;-1920,768;Inherit;False;map_metallic_4;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1026;1280,-4608;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;645;-6144,-3328;Inherit;False;grass_curvature;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;675;-6272,-1408;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;1,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1213;-1280,-2816;Inherit;False;602;height_compare_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;994;-2176,-4608;Inherit;False;isfur_3;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;725;-2304,-1280;Inherit;False;scale_3;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;936;2304,640;Inherit;False;609;height_compare_3;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;749;-3584,-768;Inherit;False;map_normal_base;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;764;-1152,-768;Inherit;True;749;map_normal_base;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;721;-2304,-1792;Inherit;False;scale_b;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;923;1280,-768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;533;-3584,-1920;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;771;-1152,768;Inherit;True;753;map_normal_4;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;637;-2176,-4352;Inherit;True;Property;_HeightBlendDefaultGradient;HeightBlendDefaultGradient;45;4;[HideInInspector];[HDR];[NoScaleOffset];[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1623;-3968,-3456;Inherit;True;Property;_TextureSample5;Texture Sample 5;54;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;906;1024,0;Inherit;False;Property;_Smoothness1;Smoothness 2;25;0;Create;False;1;______Height Scale______;0;0;True;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;647;-6784,-2432;Inherit;False;Property;_WindFreq;Wind Freq;47;0;Create;False;0;0;0;False;0;False;1.2,0.4,1,1;1.2,0.4,1,1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;716;-3840,0;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1052;1792,-4736;Inherit;False;1051;hasFur;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;894;-128,-640;Inherit;False;867;map_metallic_base;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;630;-1280,-2048;Inherit;False;609;height_compare_3;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;553;-2944,-1409;Inherit;False;Property;_ParallaxHeightScale2;Scale 2;43;0;Create;False;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1603;384,0;Inherit;False;Layer Bend;-1;;184;9e870c3f57de6eb4ba1b273324827f1f;21,79,1,63,1,75,1,65,1,67,1,70,1,71,1,73,1,61,1,35,1,17,1,36,1,27,1,28,1,37,1,29,0,38,0,30,0,39,0,40,0,31,0;24;1;FLOAT3;0,0,0;False;62;FLOAT;0;False;2;FLOAT;0;False;64;FLOAT;0;False;4;FLOAT3;0,0,0;False;3;FLOAT;0;False;66;FLOAT;0;False;5;FLOAT3;0,0,0;False;6;FLOAT;0;False;68;FLOAT;0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT3;0,0,0;False;69;FLOAT;0;False;10;FLOAT;0;False;11;FLOAT3;0,0,0;False;72;FLOAT;0;False;12;FLOAT;0;False;13;FLOAT3;0,0,0;False;74;FLOAT;0;False;14;FLOAT;0;False;15;FLOAT3;0,0,0;False;76;FLOAT;0;False;16;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;536;-3456,-2432;Inherit;False;map_color_2;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;766;-1152,256;Inherit;False;588;height_compare_2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;667;-6272,-2560;Inherit;False;move;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;895;128,-768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;565;-3584,-3456;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;917;1152,1024;Inherit;False;613;height_compare_4;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;925;1024,-384;Inherit;False;Property;_Smoothness0;Smoothness 1;20;0;Create;False;1;______Height Scale______;0;0;True;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1604;1536,0;Inherit;False;Layer Bend;-1;;183;9e870c3f57de6eb4ba1b273324827f1f;21,79,1,63,1,75,1,65,1,67,1,70,1,71,1,73,1,61,1,35,1,17,1,36,1,27,1,28,1,37,1,29,0,38,0,30,0,39,0,40,0,31,0;24;1;FLOAT3;0,0,0;False;62;FLOAT;0;False;2;FLOAT;0;False;64;FLOAT;0;False;4;FLOAT3;0,0,0;False;3;FLOAT;0;False;66;FLOAT;0;False;5;FLOAT3;0,0,0;False;6;FLOAT;0;False;68;FLOAT;0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT3;0,0,0;False;69;FLOAT;0;False;10;FLOAT;0;False;11;FLOAT3;0,0,0;False;72;FLOAT;0;False;12;FLOAT;0;False;13;FLOAT3;0,0,0;False;74;FLOAT;0;False;14;FLOAT;0;False;15;FLOAT3;0,0,0;False;76;FLOAT;0;False;16;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;957;2432,-768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;638;-2432,-4352;Inherit;False;587;clampSampler;1;0;OBJECT;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.VertexToFragmentNode;1039;1536,-4224;Inherit;False;False;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1147;-2976,-4272;Inherit;False;Constant;_Float1;Float 1;54;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;926;1024,896;Inherit;False;892;map_smoothness_4;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1641;-4224,-1152;Inherit;False;parallax_uv_4;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;885;-1920,-512;Inherit;False;map_ao_base;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;643;-6144,-3072;Inherit;False;grass_furLayerNum;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1605;-768,0;Inherit;False;Layer Bend;-1;;180;9e870c3f57de6eb4ba1b273324827f1f;21,79,0,63,0,75,0,65,0,67,0,70,0,71,0,73,0,61,0,35,1,17,1,36,1,27,1,28,1,37,1,29,0,38,0,30,0,39,0,40,0,31,0;24;1;FLOAT3;0,0,0;False;62;FLOAT;0;False;2;FLOAT;0;False;64;FLOAT;0;False;4;FLOAT3;0,0,0;False;3;FLOAT;0;False;66;FLOAT;0;False;5;FLOAT3;0,0,0;False;6;FLOAT;0;False;68;FLOAT;0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT3;0,0,0;False;69;FLOAT;0;False;10;FLOAT;0;False;11;FLOAT3;0,0,0;False;72;FLOAT;0;False;12;FLOAT;0;False;13;FLOAT3;0,0,0;False;74;FLOAT;0;False;14;FLOAT;0;False;15;FLOAT3;0,0,0;False;76;FLOAT;0;False;16;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1350;-4864,-1152;Inherit;False;725;scale_3;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1607;-894.9976,-2944;Inherit;False;Layer Bend;-1;;179;9e870c3f57de6eb4ba1b273324827f1f;21,79,0,63,0,75,0,65,0,67,0,70,0,71,0,73,0,61,0,35,1,17,1,36,1,27,1,28,1,37,1,29,0,38,0,30,0,39,0,40,0,31,0;24;1;FLOAT3;0,0,0;False;62;FLOAT;0;False;2;FLOAT;0;False;64;FLOAT;0;False;4;FLOAT3;0,0,0;False;3;FLOAT;0;False;66;FLOAT;0;False;5;FLOAT3;0,0,0;False;6;FLOAT;0;False;68;FLOAT;0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT3;0,0,0;False;69;FLOAT;0;False;10;FLOAT;0;False;11;FLOAT3;0,0,0;False;72;FLOAT;0;False;12;FLOAT;0;False;13;FLOAT3;0,0,0;False;74;FLOAT;0;False;14;FLOAT;0;False;15;FLOAT3;0,0,0;False;76;FLOAT;0;False;16;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;922;1024,-768;Inherit;False;Property;_SmoothnessBase;Smoothness Base;13;0;Create;False;1;______Height Scale______;0;0;True;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;531;-3584,-2944;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1587;1152,-512;Inherit;False;1441;height_compare_b;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1653;-3072,-128;Inherit;False;1625;parallax_uv_1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;1645;-3968,-1408;Inherit;True;Property;_TextureSample20;Texture Sample 20;54;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;1616;-2432,-4096;Inherit;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TexturePropertyNode;855;-2816,768;Inherit;True;Property;_MetallicGloss3;Metallic 4;36;2;[NoScaleOffset];[SingleLineTexture];Create;False;0;0;0;True;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;945;2176,0;Inherit;False;Property;_AO1;AO 2;27;0;Create;False;1;______Height Scale______;0;0;True;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;789;0,1024;Inherit;False;613;height_compare_4;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;690;-4736,-768;Inherit;False;576;repeatSampler;1;0;OBJECT;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.TransformPositionNode;685;-5632,-1920;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;1643;-4736,-1024;Inherit;False;1618;ts_viewDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1024;896,-4608;Inherit;False;609;height_compare_3;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;644;-6784,-3200;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;1031;896,-4800;Inherit;False;992;isfur_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;563;-3456,-3328;Inherit;False;map_height_base;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;683;-5888,-1152;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;968;2432,768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;657;-6656,-1664;Inherit;False;651;windAngle;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1326;-4864,-3200;Inherit;False;721;scale_b;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;676;-6656,-1024;Inherit;False;642;grass_heightOffset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;950;2176,128;Inherit;False;889;map_ao_2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;659;-6272,-2688;Inherit;False;moveFactor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;1689;1152,-2816;Inherit;False;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;734;-5120,-3200;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;1022;1408,-4736;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;655;-6784,-1792;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1032;1280,-4864;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;719;-4480,-768;Inherit;True;Property;_NormalBase;Normal Base;10;4;[Header];[NoScaleOffset];[Normal];[SingleLineTexture];Create;False;1;______Physicals______;0;0;True;1;Space(10);False;43b17829d3888c641a08f48bb5f788d1;43b17829d3888c641a08f48bb5f788d1;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleAddOpNode;970;2560,768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1122;1408,-2304;Inherit;False;Transform Texcoord to View;-1;;182;41bf6756ce741a44e90104a5a300b690;0;1;1;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;762;-1152,-128;Inherit;False;602;height_compare_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;844;-2816,-384;Inherit;True;Property;_MetallicGloss0;Metallic 1;18;2;[NoScaleOffset];[SingleLineTexture];Create;False;0;0;0;True;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;947;2176,768;Inherit;False;Property;_AO3;AO 4;38;0;Create;False;1;______Height Scale______;0;0;True;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;756;-4736,-384;Inherit;False;Property;_NormalIntensityBase;Normal Scale;11;0;Create;False;0;0;0;True;0;False;1;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;534;-3584,-1408;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;672;-6528,-1408;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;500;1408,-2176;Inherit;False;uv0;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;1021;896,-4416;Inherit;False;995;isfur_4;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;537;-3456,-1920;Inherit;False;map_color_3;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;1056;1920,-4864;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;699;-4480,384;Inherit;True;Property;_Normal2;Normal 3;28;3;[NoScaleOffset];[Normal];[SingleLineTexture];Create;False;0;0;0;True;0;False;a9836387f720c374f9e21e1a4672f7c6;a9836387f720c374f9e21e1a4672f7c6;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;1348;-4864,-1664;Inherit;False;724;scale_2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;790;-128,-768;Inherit;False;Property;_MetallicBase;Metallic Base;14;0;Create;False;1;______Height Scale______;0;0;True;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;530;-3456,-1280;Inherit;False;map_height_4;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;740;-5120,-2304;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;733;-5376,-3328;Inherit;False;500;uv0;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;698;-4224,-768;Inherit;True;Property;_TextureSample15;Texture Sample 15;11;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;919;1024,512;Inherit;False;890;map_smoothness_3;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;613;-2304,-2432;Inherit;False;height_compare_4;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;1663;-2560,-1664;Inherit;False;False;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1560;-2624,-2432;Inherit;False;Height Compare;-1;;177;ebca28d054964964db0ceb775df491e8;0;2;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;503;-4608,-1920;Inherit;True;Property;_Splat2;Albedo 3;6;0;Create;False;0;0;0;True;0;False;b7115849e71d5294da137726ce5a8a08;b7115849e71d5294da137726ce5a8a08;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1662;-2688,-1280;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1562;-2624,-2688;Inherit;False;Height Compare;-1;;176;ebca28d054964964db0ceb775df491e8;0;2;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1650;-4736,640;Inherit;False;1636;parallax_uv_3;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;656;-6528,-2688;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;993;-2176,-4736;Inherit;False;isfur_2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;543;-1280,-2688;Inherit;True;536;map_color_2;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;673;-6400,-1408;Inherit;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;1561;-2624,-2944;Inherit;False;Height Compare;-1;;175;ebca28d054964964db0ceb775df491e8;0;2;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;668;-6016,-2176;Inherit;False;windMove;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1313;-3008,-2688;Inherit;False;594;weight_3;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;753;-3584,768;Inherit;False;map_normal_4;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;1130;896,-4224;Inherit;True;Property;_TextureSample19;Texture Sample 19;17;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1029;1280,-4736;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;649;-6784,-2272;Inherit;False;1;0;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;988;-2432,-4480;Inherit;False;Property;_IsFur3;IsFur;9;1;[Toggle];Create;False;0;0;0;True;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;588;-2304,-2944;Inherit;False;height_compare_2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;775;-512,0;Inherit;False;Out_Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;769;-1152,384;Inherit;True;752;map_normal_3;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1038;1280,-4224;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;634;-512,-2944;Inherit;False;Out_Albedo;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;671;-6784,-1248;Inherit;False;668;windMove;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1324;-3008,-2432;Inherit;False;595;weight_4;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;900;128,768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;602;-2304,-3200;Inherit;False;height_compare_1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1629;-4224,-2176;Inherit;False;parallax_uv_2;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;1025;896,-4544;Inherit;False;994;isfur_3;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;567;-2944,-1793;Inherit;False;Property;_ParallaxHeightScaleBase;Scale Base;40;1;[Header];Create;False;1;______Height Scale______;0;0;True;1;Space(10);False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;648;-6528,-2432;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;629;-1280,-2304;Inherit;True;537;map_color_3;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1312;-3008,-2560;Inherit;False;529;map_height_3;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1661;-2688,-1408;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;722;-2304,-1664;Inherit;False;scale_0;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;910;1152,256;Inherit;False;588;height_compare_2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;860;-2560,768;Inherit;True;Property;_TextureSample12;Texture Sample 12;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;960;2432,-256;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;516;-4352,-2432;Inherit;True;Property;_TextureSample1;Texture Sample 1;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;576;-2688,-4224;Inherit;False;repeatSampler;-1;True;1;0;SAMPLERSTATE;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.SamplerStateNode;519;-2976,-4144;Inherit;False;0;0;0;1;-1;None;1;0;SAMPLER2D;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.TextureTransformNode;731;-5376,-3200;Inherit;False;569;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.GetLocalVarNode;903;-128,896;Inherit;False;881;map_metallic_4;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;876;-2816,-768;Inherit;True;Property;_MetallicGlossBase;Metallic Base;12;2;[NoScaleOffset];[SingleLineTexture];Create;False;1;______Normal______;0;0;True;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.WorldNormalVector;680;-6144,-1024;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;578;-4864,-3456;Inherit;False;576;repeatSampler;1;0;OBJECT;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.FunctionNode;1564;-2624,-3200;Inherit;False;Height Compare;-1;;174;ebca28d054964964db0ceb775df491e8;0;2;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;718;-3840,768;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1323;-3008,-2304;Inherit;False;530;map_height_4;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1047;-6144,-3200;Inherit;False;grass_currentLayer;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;854;-2560,-384;Inherit;True;Property;_TextureSample11;Texture Sample 11;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;682;-6400,-1792;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;677;-6144,-1408;Inherit;False;shellDir;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;702;-4224,0;Inherit;True;Property;_TextureSample16;Texture Sample 16;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexToFragmentNode;641;-6400,-3456;Inherit;False;False;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;987;-2432,-4608;Inherit;False;Property;_IsFur2;IsFur;7;1;[Toggle];Create;False;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;916;1280,768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1334;-4864,-2688;Inherit;False;722;scale_0;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;884;-1920,-640;Inherit;False;map_smoothness_base;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;502;-4608,-2432;Inherit;True;Property;_Splat1;Albedo 2;4;0;Create;False;0;0;0;True;0;False;a601e40aea98a0748911eabddadf1787;a601e40aea98a0748911eabddadf1787;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;517;-4352,-1920;Inherit;True;Property;_TextureSample2;Texture Sample 2;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;1444;-1280,-3200;Inherit;False;1441;height_compare_b;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;995;-2176,-4480;Inherit;False;isfur_4;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;609;-2304,-2688;Inherit;False;height_compare_3;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;912;1280,384;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1244;-3008,-2816;Inherit;False;528;map_height_2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1346;-4864,-2176;Inherit;False;723;scale_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;964;2560,0;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;514;-4352,-2944;Inherit;True;Property;_TextureSample0;Texture Sample 0;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;504;-4608,-1408;Inherit;True;Property;_Splat3;Albedo 4;8;0;Create;False;0;0;0;True;0;False;954e46e16660dd54f8096593cb37b2a3;954e46e16660dd54f8096593cb37b2a3;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;992;-2176,-4864;Inherit;False;isfur_1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureTransformNode;745;-5376,-1792;Inherit;False;503;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.RangedFloatNode;985;-2432,-4864;Inherit;False;Property;_IsFur0;IsFur;3;1;[Toggle];Create;False;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;601;-3008,-3072;Inherit;False;527;map_height_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;1658;-2560,-1792;Inherit;False;False;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;770;-1152,640;Inherit;False;609;height_compare_3;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureTransformNode;742;-5376,-2304;Inherit;False;502;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;1061;2048,-3840;Inherit;False;isFirstLayer;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;661;-6272,-2048;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;666;-6400,-2560;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;663;-6528,-2560;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerStateNode;586;-2976,-4016;Inherit;False;1;1;1;1;-1;None;1;0;SAMPLER2D;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.GetLocalVarNode;934;2304,-128;Inherit;False;602;height_compare_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;632;-1280,-1920;Inherit;True;538;map_color_4;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;965;2432,384;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;898;128,0;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;846;-2560,0;Inherit;True;Property;_TextureSample9;Texture Sample 9;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMinOpNode;1041;1408,-4224;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;890;-1920,512;Inherit;False;map_smoothness_3;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;549;-2944,-1665;Inherit;False;Property;_ParallaxHeightScale0;Scale 0;41;0;Create;False;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;532;-3584,-2432;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;527;-3456,-2816;Inherit;False;map_height_1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;946;2176,384;Inherit;False;Property;_AO2;AO 3;31;0;Create;False;1;______Height Scale______;0;0;True;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;529;-3456,-1792;Inherit;False;map_height_3;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;738;-5120,-2816;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;879;-1920,0;Inherit;False;map_metallic_2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;781;-128,768;Inherit;False;Property;_Metallic3;Metallic 4;39;0;Create;False;1;______Height Scale______;0;0;True;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1020;1280,-4480;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;535;-3456,-2944;Inherit;False;map_color_1;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;779;-128,0;Inherit;False;Property;_Metallic1;Metallic 2;26;0;Create;False;1;______Height Scale______;0;0;True;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;1665;-2560,-1408;Inherit;False;False;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1030;896,-4864;Inherit;False;602;height_compare_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1036;2176,-4864;Inherit;False;Out_DiscardMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;736;-4992,-3200;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;660;-6400,-2048;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;949;2176,512;Inherit;False;891;map_ao_3;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1027;896,-4736;Inherit;False;588;height_compare_2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;743;-5120,-1792;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;1042;1280,-3840;Inherit;False;1047;grass_currentLayer;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;554;-2944,-1281;Inherit;False;Property;_ParallaxHeightScale3;Scale 3;44;0;Create;False;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1625;-4224,-2688;Inherit;False;parallax_uv_1;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;686;-5632,-2304;Inherit;False;Out_Position;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;913;1152,640;Inherit;False;609;height_compare_3;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;889;-1920,256;Inherit;False;map_ao_2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;552;-2944,-1537;Inherit;False;Property;_ParallaxHeightScale1;Scale 1;42;0;Create;False;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1660;-2688,-1536;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;962;2432,0;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1051;1792,-4224;Inherit;False;hasFur;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;654;-6784,-2688;Inherit;False;Property;_BaseMove;Base Move;46;1;[Header];Create;False;1;______Fur Layer Winding______;0;0;False;1;Space(10);False;-0.19,0,0,0.2;-0.19,0,0,0.2;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;1441;-2304,-3456;Inherit;False;height_compare_b;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;958;2432,-640;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureTransformNode;737;-5376,-2816;Inherit;False;501;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.RangedFloatNode;778;-128,-384;Inherit;False;Property;_Metallic0;Metallic 1;21;0;Create;False;1;______Height Scale______;0;0;True;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;963;2432,128;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;955;2560,-768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;920;1024,-256;Inherit;False;886;map_smoothness_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;1033;1408,-4608;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;902;-128,512;Inherit;False;871;map_metallic_3;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;959;2432,-384;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1657;-2688,-1792;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;724;-2304,-1408;Inherit;False;scale_2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;1045;1536,-3840;Inherit;False;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;590;-1280,-3456;Inherit;True;564;map_color_base;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;773;-1152,1024;Inherit;False;613;height_compare_4;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1433;-3008,-3200;Inherit;False;592;weight_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;927;1792,0;Inherit;False;Out_Smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;757;-4736,0;Inherit;False;Property;_NormalIntensity0;Normal Scale;17;0;Create;False;0;0;0;True;0;False;1;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;662;-6400,-2176;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;765;-1152,0;Inherit;True;751;map_normal_2;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;501;-4608,-2944;Inherit;True;Property;_Splat0;Albedo 1;2;0;Create;False;0;0;0;True;0;False;764331310c5ba434d8e1719eb44ac696;764331310c5ba434d8e1719eb44ac696;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.DynamicAppendNode;715;-3840,-384;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureTransformNode;748;-5376,-1280;Inherit;False;504;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;874;-1920,-384;Inherit;False;map_metallic_1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;751;-3584,0;Inherit;False;map_normal_2;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1649;-4736,256;Inherit;False;1629;parallax_uv_2;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1659;-2688,-1664;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;710;-4224,768;Inherit;True;Property;_TextureSample18;Texture Sample 18;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;642;-6144,-3440;Inherit;False;grass_heightOffset;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;759;-4736,768;Inherit;False;Property;_NormalIntensity2;Normal Scale;29;0;Create;False;0;0;0;True;0;False;1;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1091;-6272,-1536;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1652;-3072,-512;Inherit;False;1622;parallax_uv_b;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;651;-6272,-2432;Inherit;False;windAngle;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;626;-1280,-2432;Inherit;False;588;height_compare_2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;665;-6144,-2176;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;1563;-2624,-3456;Inherit;False;Height Compare;-1;;178;ebca28d054964964db0ceb775df491e8;0;2;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;538;-3456,-1408;Inherit;False;map_color_4;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1443;-3008,-3456;Inherit;False;1426;weight_b;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;969;2432,896;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;921;1024,-640;Inherit;False;884;map_smoothness_base;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;747;-4992,-1280;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;706;-4480,768;Inherit;True;Property;_Normal3;Normal 4;34;3;[NoScaleOffset];[Normal];[SingleLineTexture];Create;False;0;0;0;True;0;False;572d4920073265042a0dc9cac25b9f24;572d4920073265042a0dc9cac25b9f24;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;763;-1152,-384;Inherit;True;750;map_normal_1;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1622;-4224,-3200;Inherit;False;parallax_uv_b;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;518;-4352,-1408;Inherit;True;Property;_TextureSample3;Texture Sample 3;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;587;-2688,-4096;Inherit;False;clampSampler;-1;True;1;0;SAMPLERSTATE;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.GetLocalVarNode;664;-6784,-1920;Inherit;False;659;moveFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;658;-6528,-2048;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;967;2560,384;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;691;-3840,-768;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;886;-1920,-256;Inherit;False;map_smoothness_1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1148;-2976,-4400;Inherit;False;Constant;_Float2;Float 2;54;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;857;-3072,-768;Inherit;False;576;repeatSampler;1;0;OBJECT;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.SamplerNode;709;-4224,384;Inherit;True;Property;_TextureSample17;Texture Sample 17;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1676;1819.888,-2815.018;Float;False;True;-1;2;ASEMaterialInspector;0;16;Hidden/Treeverse/HeightBlendBuffers;578f414257b5fe64d944a21fb545d567;True;Forward;0;0;Forward;2;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;True;7;False;-1;False;True;5;Queue=Overlay=Queue=1000;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;False;0;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;2;False;-1;True;7;False;-1;True;False;0;False;-1;0;False;-1;True;1;LightMode=HeightBlendWeightExport;True;2;False;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;1426;0;1427;3
WireConnection;595;0;639;4
WireConnection;593;0;639;2
WireConnection;592;0;639;1
WireConnection;594;0;639;3
WireConnection;1677;0;1682;0
WireConnection;1677;1;1683;0
WireConnection;1677;2;1684;0
WireConnection;1687;0;1681;0
WireConnection;1687;1;1685;0
WireConnection;1686;0;1677;0
WireConnection;1686;1;1687;0
WireConnection;1686;2;1688;0
WireConnection;1626;0;739;0
WireConnection;1626;1;514;4
WireConnection;1626;2;1334;0
WireConnection;1626;3;1627;0
WireConnection;640;0;644;1
WireConnection;1617;0;1616;0
WireConnection;904;0;925;0
WireConnection;904;1;920;0
WireConnection;1642;0;747;0
WireConnection;1642;1;518;4
WireConnection;1642;2;1350;0
WireConnection;1642;3;1643;0
WireConnection;1606;62;955;0
WireConnection;1606;2;1591;0
WireConnection;1606;64;961;0
WireConnection;1606;3;934;0
WireConnection;1606;66;964;0
WireConnection;1606;6;933;0
WireConnection;1606;68;967;0
WireConnection;1606;8;936;0
WireConnection;1606;69;970;0
WireConnection;1606;10;939;0
WireConnection;896;0;778;0
WireConnection;896;1;897;0
WireConnection;1034;0;1022;0
WireConnection;1034;1;1033;0
WireConnection;1624;0;501;0
WireConnection;1624;1;1625;0
WireConnection;1624;7;578;0
WireConnection;888;0;846;2
WireConnection;966;0;946;0
WireConnection;746;0;733;0
WireConnection;746;1;748;0
WireConnection;1619;0;736;0
WireConnection;1619;1;568;4
WireConnection;1619;2;1326;0
WireConnection;1619;3;1620;0
WireConnection;739;0;738;0
WireConnection;739;1;737;1
WireConnection;717;0;709;0
WireConnection;867;0;863;1
WireConnection;741;0;740;0
WireConnection;741;1;742;1
WireConnection;952;0;1606;0
WireConnection;1630;0;741;0
WireConnection;1630;1;516;4
WireConnection;1630;2;1346;0
WireConnection;1630;3;1631;0
WireConnection;887;0;854;3
WireConnection;899;0;780;0
WireConnection;899;1;902;0
WireConnection;891;0;851;3
WireConnection;1635;0;744;0
WireConnection;1635;1;517;4
WireConnection;1635;2;1348;0
WireConnection;1635;3;1637;0
WireConnection;750;0;715;0
WireConnection;723;0;1664;0
WireConnection;871;0;851;1
WireConnection;684;0;682;0
WireConnection;684;1;681;0
WireConnection;684;2;683;0
WireConnection;892;0;860;2
WireConnection;907;0;906;0
WireConnection;907;1;918;0
WireConnection;863;0;876;0
WireConnection;863;1;1652;0
WireConnection;863;7;857;0
WireConnection;1664;0;1660;0
WireConnection;1639;0;502;0
WireConnection;1639;1;1629;0
WireConnection;1639;7;578;0
WireConnection;679;0;676;0
WireConnection;679;2;674;0
WireConnection;961;0;959;0
WireConnection;961;1;960;0
WireConnection;791;0;1603;0
WireConnection;1618;0;1617;0
WireConnection;752;0;717;0
WireConnection;851;0;864;0
WireConnection;851;1;1655;0
WireConnection;851;7;857;0
WireConnection;650;0;648;0
WireConnection;650;1;649;0
WireConnection;1636;0;1635;0
WireConnection;1666;0;1662;0
WireConnection;564;0;565;0
WireConnection;744;0;743;0
WireConnection;744;1;745;1
WireConnection;681;0;677;0
WireConnection;681;1;679;0
WireConnection;693;0;692;0
WireConnection;693;1;1648;0
WireConnection;693;5;757;0
WireConnection;693;7;690;0
WireConnection;1640;0;503;0
WireConnection;1640;1;1636;0
WireConnection;1640;7;578;0
WireConnection;528;0;516;4
WireConnection;893;0;860;3
WireConnection;568;0;569;0
WireConnection;568;7;578;0
WireConnection;1046;0;1045;0
WireConnection;881;0;860;1
WireConnection;1026;0;1024;0
WireConnection;1026;1;1025;0
WireConnection;1026;2;1130;1
WireConnection;645;0;644;2
WireConnection;675;0;673;0
WireConnection;994;0;987;0
WireConnection;725;0;1666;0
WireConnection;749;0;691;0
WireConnection;721;0;1658;0
WireConnection;923;0;922;0
WireConnection;923;1;921;0
WireConnection;533;0;1640;0
WireConnection;637;7;638;0
WireConnection;1623;0;569;0
WireConnection;1623;1;1622;0
WireConnection;1623;7;578;0
WireConnection;716;0;702;0
WireConnection;1603;62;895;0
WireConnection;1603;2;1573;0
WireConnection;1603;64;896;0
WireConnection;1603;3;783;0
WireConnection;1603;66;898;0
WireConnection;1603;6;785;0
WireConnection;1603;68;899;0
WireConnection;1603;8;787;0
WireConnection;1603;69;900;0
WireConnection;1603;10;789;0
WireConnection;536;0;532;0
WireConnection;667;0;666;0
WireConnection;895;0;790;0
WireConnection;895;1;894;0
WireConnection;565;0;1623;0
WireConnection;1604;62;923;0
WireConnection;1604;2;1587;0
WireConnection;1604;64;904;0
WireConnection;1604;3;911;0
WireConnection;1604;66;907;0
WireConnection;1604;6;910;0
WireConnection;1604;68;912;0
WireConnection;1604;8;913;0
WireConnection;1604;69;916;0
WireConnection;1604;10;917;0
WireConnection;957;0;940;0
WireConnection;957;1;943;0
WireConnection;1039;0;1041;0
WireConnection;1641;0;1642;0
WireConnection;885;0;863;3
WireConnection;643;0;644;4
WireConnection;1605;1;764;0
WireConnection;1605;2;1571;0
WireConnection;1605;4;763;0
WireConnection;1605;3;762;0
WireConnection;1605;5;765;0
WireConnection;1605;6;766;0
WireConnection;1605;7;769;0
WireConnection;1605;8;770;0
WireConnection;1605;9;771;0
WireConnection;1605;10;773;0
WireConnection;1607;1;590;0
WireConnection;1607;2;1444;0
WireConnection;1607;4;541;0
WireConnection;1607;3;1213;0
WireConnection;1607;5;543;0
WireConnection;1607;6;626;0
WireConnection;1607;7;629;0
WireConnection;1607;8;630;0
WireConnection;1607;9;632;0
WireConnection;1607;10;633;0
WireConnection;531;0;1624;0
WireConnection;1645;0;504;0
WireConnection;1645;1;1641;0
WireConnection;685;0;684;0
WireConnection;563;0;568;4
WireConnection;683;0;678;0
WireConnection;683;1;680;0
WireConnection;968;0;948;0
WireConnection;968;1;947;0
WireConnection;659;0;656;0
WireConnection;1689;0;1686;0
WireConnection;734;0;733;0
WireConnection;734;1;731;0
WireConnection;1022;0;1032;0
WireConnection;1022;1;1029;0
WireConnection;1032;0;1030;0
WireConnection;1032;1;1031;0
WireConnection;1032;2;1130;1
WireConnection;970;0;968;0
WireConnection;970;1;969;0
WireConnection;1122;1;499;0
WireConnection;534;0;1645;0
WireConnection;672;0;670;0
WireConnection;672;1;669;0
WireConnection;672;2;671;0
WireConnection;500;0;499;0
WireConnection;537;0;533;0
WireConnection;1056;0;1129;0
WireConnection;1056;1;1034;0
WireConnection;1056;2;1052;0
WireConnection;530;0;518;4
WireConnection;740;0;733;0
WireConnection;740;1;742;0
WireConnection;698;0;719;0
WireConnection;698;1;1647;0
WireConnection;698;5;756;0
WireConnection;698;7;690;0
WireConnection;613;0;1560;0
WireConnection;1663;0;1659;0
WireConnection;1560;1;1324;0
WireConnection;1560;2;1323;0
WireConnection;1662;0;554;0
WireConnection;1562;1;1313;0
WireConnection;1562;2;1312;0
WireConnection;656;0;653;0
WireConnection;656;1;654;4
WireConnection;993;0;986;0
WireConnection;673;0;672;0
WireConnection;1561;1;1243;0
WireConnection;1561;2;1244;0
WireConnection;668;0;665;0
WireConnection;753;0;718;0
WireConnection;1130;0;1131;0
WireConnection;1130;7;1131;1
WireConnection;1029;0;1027;0
WireConnection;1029;1;1028;0
WireConnection;1029;2;1130;1
WireConnection;588;0;1561;0
WireConnection;775;0;1605;0
WireConnection;1038;0;1031;0
WireConnection;1038;1;1028;0
WireConnection;1038;2;1025;0
WireConnection;1038;3;1021;0
WireConnection;634;0;1607;0
WireConnection;900;0;781;0
WireConnection;900;1;903;0
WireConnection;602;0;1564;0
WireConnection;1629;0;1630;0
WireConnection;648;0;647;0
WireConnection;1661;0;553;0
WireConnection;722;0;1663;0
WireConnection;860;0;855;0
WireConnection;860;1;1656;0
WireConnection;860;7;857;0
WireConnection;960;0;944;0
WireConnection;516;0;502;0
WireConnection;516;7;578;0
WireConnection;576;0;519;0
WireConnection;1564;1;1433;0
WireConnection;1564;2;601;0
WireConnection;718;0;710;0
WireConnection;1047;0;644;3
WireConnection;854;0;844;0
WireConnection;854;1;1653;0
WireConnection;854;7;857;0
WireConnection;677;0;675;0
WireConnection;702;0;697;0
WireConnection;702;1;1649;0
WireConnection;702;5;758;0
WireConnection;702;7;690;0
WireConnection;641;0;640;0
WireConnection;916;0;915;0
WireConnection;916;1;926;0
WireConnection;884;0;863;2
WireConnection;517;0;503;0
WireConnection;517;7;578;0
WireConnection;995;0;988;0
WireConnection;609;0;1562;0
WireConnection;912;0;908;0
WireConnection;912;1;919;0
WireConnection;964;0;962;0
WireConnection;964;1;963;0
WireConnection;514;0;501;0
WireConnection;514;7;578;0
WireConnection;992;0;985;0
WireConnection;1658;0;1657;0
WireConnection;1061;0;1046;0
WireConnection;661;0;660;0
WireConnection;666;0;656;0
WireConnection;666;1;663;0
WireConnection;663;0;654;0
WireConnection;965;0;949;0
WireConnection;965;1;946;0
WireConnection;898;0;779;0
WireConnection;898;1;901;0
WireConnection;846;0;869;0
WireConnection;846;1;1654;0
WireConnection;846;7;857;0
WireConnection;1041;0;1038;0
WireConnection;890;0;851;2
WireConnection;532;0;1639;0
WireConnection;527;0;514;4
WireConnection;529;0;517;4
WireConnection;738;0;733;0
WireConnection;738;1;737;0
WireConnection;879;0;846;1
WireConnection;1020;0;839;0
WireConnection;1020;1;1021;0
WireConnection;1020;2;1130;1
WireConnection;535;0;531;0
WireConnection;1665;0;1661;0
WireConnection;1036;0;1056;0
WireConnection;736;0;734;0
WireConnection;736;1;731;1
WireConnection;660;0;658;0
WireConnection;660;1;657;0
WireConnection;743;0;733;0
WireConnection;743;1;745;0
WireConnection;1625;0;1626;0
WireConnection;686;0;685;0
WireConnection;889;0;846;3
WireConnection;1660;0;552;0
WireConnection;962;0;950;0
WireConnection;962;1;945;0
WireConnection;1051;0;1039;0
WireConnection;1441;0;1563;0
WireConnection;958;0;943;0
WireConnection;963;0;945;0
WireConnection;955;0;957;0
WireConnection;955;1;958;0
WireConnection;1033;0;1026;0
WireConnection;1033;1;1020;0
WireConnection;959;0;951;0
WireConnection;959;1;944;0
WireConnection;1657;0;567;0
WireConnection;724;0;1665;0
WireConnection;1045;0;1042;0
WireConnection;927;0;1604;0
WireConnection;662;0;652;0
WireConnection;715;0;693;0
WireConnection;874;0;854;1
WireConnection;751;0;716;0
WireConnection;1659;0;549;0
WireConnection;710;0;706;0
WireConnection;710;1;1651;0
WireConnection;710;5;760;0
WireConnection;710;7;690;0
WireConnection;642;0;641;0
WireConnection;1091;0;1083;0
WireConnection;651;0;650;0
WireConnection;665;0;662;0
WireConnection;665;1;664;0
WireConnection;665;2;661;0
WireConnection;1563;1;1443;0
WireConnection;1563;2;1440;0
WireConnection;538;0;534;0
WireConnection;969;0;947;0
WireConnection;747;0;746;0
WireConnection;747;1;748;1
WireConnection;1622;0;1619;0
WireConnection;518;0;504;0
WireConnection;518;7;578;0
WireConnection;587;0;586;0
WireConnection;658;0;652;4
WireConnection;658;1;655;0
WireConnection;967;0;965;0
WireConnection;967;1;966;0
WireConnection;691;0;698;0
WireConnection;886;0;854;2
WireConnection;709;0;699;0
WireConnection;709;1;1650;0
WireConnection;709;5;759;0
WireConnection;709;7;690;0
WireConnection;1676;1;1689;0
WireConnection;1676;0;1122;0
ASEEND*/
//CHKSM=023C414D577DA9996AB7A968007EDB3A8E6965B0
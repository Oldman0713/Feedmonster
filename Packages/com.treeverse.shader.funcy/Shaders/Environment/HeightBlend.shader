// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Treeverse/Static/Environment/HeightBlend"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[Header(______Albedo______)][Space(10)]_SplatBase("Albedo Base", 2D) = "white" {}
		_FurMap("Fur Map", 2D) = "white" {}
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
		[Header(______Fur Layer Winding______)][Space(10)]_BaseMove("Base Move", Vector) = (-0.19,0,0,0.2)
		_WindFreq("Wind Freq", Vector) = (1.2,0.4,1,1)
		_WindMove("Wind Move", Vector) = (0.8,0.4,0.4,1)
		_WindIntensity("Wind Intensity", Range( 0 , 1)) = 0.2
		_AlphaCutout("Fur Cutout", Range( 0.01 , 1)) = 1
		_CutoutMap("CutoutMap", 2D) = "white" {}
		[Toggle]_LightCutoutResslover_Solo("_LightCutoutResslover_Solo", Float) = 0
		[Toggle]_FurEditing("FurEditing", Float) = 0
		_Baked_Paint_W123("Baked_Paint_W123", 2D) = "white" {}
		_Baked_Paint_WB4("Baked_Paint_WB4", 2D) = "white" {}
		[ASEEnd][Toggle]_WeightUsingMaps("WeightUsingMaps", Float) = 0
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

		[HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
	}

	SubShader
	{
		LOD 0

		
		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
		Cull Back
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		AlphaToMask Off
		
		HLSLINCLUDE
		#pragma target 4.0

		#pragma prefer_hlslcc gles
		#pragma exclude_renderers d3d11_9x 

		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForwardOnly" }
			
			Blend Off
			ColorMask RGBA
			

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#define DISCARD_FRAGMENT
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define TREEVERSE_LINEAR_FOG 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 999999
			#define ASE_USING_SAMPLING_MACROS 1


			//#pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
			#define _ADDITIONAL_LIGHT_SHADOWS 1
			//#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
			#define _SHADOWS_SOFT 1
			//#pragma multi_compile _ _SHADOWS_SOFT
			//#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
			
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#define SHADOWS_SHADOWMASK 1
			//#pragma multi_compile _ SHADOWS_SHADOWMASK

			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON
			//#pragma multi_compile _ DYNAMICLIGHTMAP_ON

			#define _REFLECTION_PROBE_BLENDING 1
			//#pragma multi_compile _ _REFLECTION_PROBE_BLENDING
			//#pragma multi_compile _ _REFLECTION_PROBE_BOX_PROJECTION
			//#pragma multi_compile _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			//#pragma multi_compile _ _LIGHT_LAYERS
			
			//#pragma multi_compile _ _LIGHT_COOKIES
			//#pragma multi_compile _ _CLUSTERED_RENDERING

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_FORWARD

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(UNITY_INSTANCING_ENABLED) && defined(_TERRAIN_INSTANCED_PERPIXEL_NORMAL)
			    #define ENABLE_TERRAIN_PERPIXEL_NORMAL
			#endif

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_VERT_TANGENT


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 lightmapUVOrVertexSH : TEXCOORD0;
				half4 fogFactorAndVertexLight : TEXCOORD1;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				float4 shadowCoord : TEXCOORD2;
				#endif
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				float4 screenPos : TEXCOORD6;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON)
				float2 dynamicLightmapUV : TEXCOORD7;
				#endif
				float4 ase_texcoord8 : TEXCOORD8;
				float4 ase_texcoord9 : TEXCOORD9;
				float4 ase_texcoord10 : TEXCOORD10;
				float4 ase_texcoord11 : TEXCOORD11;
				float4 ase_texcoord12 : TEXCOORD12;
				float4 ase_texcoord13 : TEXCOORD13;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BaseMove;
			float4 _SplatBase_ST;
			float4 _CutoutMap_ST;
			float4 _Splat3_ST;
			float4 _Splat2_ST;
			float4 _Splat1_ST;
			float4 _FurMap_ST;
			float4 _Baked_Paint_WB4_ST;
			float4 _Splat0_ST;
			float4 _Baked_Paint_W123_ST;
			float4 _WindFreq;
			float4 _WindMove;
			float _MetallicBase;
			float _Metallic0;
			float _Metallic1;
			float _Metallic2;
			float _Metallic3;
			float _SmoothnessBase;
			float _Smoothness1;
			float _AO0;
			float _Smoothness2;
			float _AO2;
			float _NormalIntensity3;
			float _Smoothness3;
			float _AOBase;
			float _AO1;
			float _Smoothness0;
			float _NormalIntensity2;
			float _ParallaxHeightScale1;
			float _NormalIntensity0;
			float _WindIntensity;
			float _WeightUsingMaps;
			float _IsFur0;
			float _IsFur1;
			float _IsFur2;
			float _IsFur3;
			float _NormalIntensity1;
			float _FurEditing;
			float _ParallaxHeightScaleBase;
			float _ParallaxHeightScale0;
			float _AO3;
			float _ParallaxHeightScale2;
			float _ParallaxHeightScale3;
			float _NormalIntensityBase;
			float _AlphaCutout;
			float _LightCutoutResslover_Solo;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			TEXTURE2D(_Baked_Paint_W123);
			SAMPLER(sampler_Baked_Paint_W123);
			TEXTURE2D(_Splat0);
			SAMPLER(sampler_linear_repeat);
			TEXTURE2D(_FurMap);
			SAMPLER(sampler_FurMap);
			TEXTURE2D(_Splat1);
			TEXTURE2D(_Splat2);
			TEXTURE2D(_Baked_Paint_WB4);
			SAMPLER(sampler_Baked_Paint_WB4);
			TEXTURE2D(_Splat3);
			TEXTURE2D(_CutoutMap);
			SAMPLER(sampler_CutoutMap);
			TEXTURE2D(_SplatBase);
			SAMPLER(sampler_Splat3);
			TEXTURE2D(_NormalBase);
			TEXTURE2D(_Normal0);
			TEXTURE2D(_Normal1);
			TEXTURE2D(_Normal2);
			TEXTURE2D(_Normal3);
			TEXTURE2D(_MetallicGlossBase);
			TEXTURE2D(_MetallicGloss0);
			TEXTURE2D(_MetallicGloss1);
			TEXTURE2D(_MetallicGloss2);
			TEXTURE2D(_MetallicGloss3);


			real3 ASESafeNormalize(float3 inVec)
			{
				real dp3 = max(FLT_MIN, dot(inVec, inVec));
				return inVec* rsqrt( dp3);
			}
			

			VertexOutput vert ( VertexInput v )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				float vertexToFrag641 = ( v.ase_color.r - 1.0 );
				float grass_heightOffset642 = vertexToFrag641;
				float saferPower656 = abs( grass_heightOffset642 );
				float temp_output_656_0 = pow( saferPower656 , _BaseMove.w );
				float3 appendResult663 = (float3(_BaseMove.xyz));
				float3 move667 = ( temp_output_656_0 * appendResult663 );
				float3 appendResult662 = (float3(_WindMove.xyz));
				float moveFactor659 = temp_output_656_0;
				float3 appendResult648 = (float3(_WindFreq.xyz));
				float mulTime649 = _TimeParameters.x * 3.0;
				float3 windAngle651 = ( appendResult648 * mulTime649 );
				float3 windMove668 = ( appendResult662 * moveFactor659 * sin( ( ( _WindMove.w * v.vertex.xyz ) + windAngle651 ) ) );
				float3 normalizeResult673 = ASESafeNormalize( ( ase_worldNormal + move667 + windMove668 ) );
				float3 shellDir677 = ( normalizeResult673 * float3( 1,0,1 ) );
				float3 worldToObj685 = mul( GetWorldToObjectMatrix(), float4( ( ase_worldPos + ( shellDir677 * ( grass_heightOffset642 * 9.0 * _WindIntensity ) ) + ( grass_heightOffset642 * ase_worldNormal ) ), 1 ) ).xyz;
				float3 Out_Position686 = worldToObj685;
				
				float grass_currentLayer1047 = v.ase_color.b;
				float vertexToFrag1046 = step( grass_currentLayer1047 , 0.0 );
				o.ase_texcoord8.x = vertexToFrag1046;
				float isfur_1992 = _IsFur0;
				float isfur_2993 = _IsFur1;
				float isfur_3994 = _IsFur2;
				float isfur_4995 = _IsFur3;
				float vertexToFrag1039 = min( ( isfur_1992 + isfur_2993 + isfur_3994 + isfur_4995 ) , 1.0 );
				o.ase_texcoord8.w = vertexToFrag1039;
				
				float grass_curvature645 = v.ase_color.g;
				float hasFur1051 = vertexToFrag1039;
				float lerpResult1054 = lerp( 1.0 , grass_curvature645 , hasFur1051);
				float vertexToFrag1055 = lerpResult1054;
				o.ase_texcoord10.z = vertexToFrag1055;
				
				float vertexToFrag1658 = ( _ParallaxHeightScaleBase * 0.1 );
				o.ase_texcoord10.w = vertexToFrag1658;
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_tanViewDir =  tanToWorld0 * ase_worldViewDir.x + tanToWorld1 * ase_worldViewDir.y  + tanToWorld2 * ase_worldViewDir.z;
				ase_tanViewDir = normalize(ase_tanViewDir);
				float3 vertexToFrag1617 = ase_tanViewDir;
				o.ase_texcoord12.xyz = vertexToFrag1617;
				float vertexToFrag1663 = ( _ParallaxHeightScale0 * 0.1 );
				o.ase_texcoord12.w = vertexToFrag1663;
				float vertexToFrag1664 = ( _ParallaxHeightScale1 * 0.1 );
				o.ase_texcoord13.x = vertexToFrag1664;
				float vertexToFrag1665 = ( _ParallaxHeightScale2 * 0.1 );
				o.ase_texcoord13.y = vertexToFrag1665;
				float vertexToFrag1666 = ( _ParallaxHeightScale3 * 0.1 );
				o.ase_texcoord13.z = vertexToFrag1666;
				
				o.ase_texcoord9 = v.texcoord2;
				o.ase_texcoord8.yz = v.texcoord1.xy;
				o.ase_texcoord10.xy = v.texcoord.xy;
				o.ase_texcoord11 = v.ase_texcoord3;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord13.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = Out_Position686;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 positionVS = TransformWorldToView( positionWS );
				float4 positionCS = TransformWorldToHClip( positionWS );

				VertexNormalInputs normalInput = GetVertexNormalInputs( v.ase_normal, v.ase_tangent );

				o.tSpace0 = float4( normalInput.normalWS, positionWS.x);
				o.tSpace1 = float4( normalInput.tangentWS, positionWS.y);
				o.tSpace2 = float4( normalInput.bitangentWS, positionWS.z);

				#if defined(LIGHTMAP_ON)
				OUTPUT_LIGHTMAP_UV( v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy );
				#endif

				#if defined(DYNAMICLIGHTMAP_ON)
				o.dynamicLightmapUV.xy = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
				#endif

				#if !defined(LIGHTMAP_ON)
				OUTPUT_SH( normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz );
				#endif

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					o.lightmapUVOrVertexSH.zw = v.texcoord;
					o.lightmapUVOrVertexSH.xy = v.texcoord * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif

				half3 vertexLight = VertexLighting( positionWS, normalInput.normalWS );

				#ifdef TREEVERSE_LINEAR_FOG
					float fz = UNITY_Z_0_FAR_FROM_CLIPSPACE(positionCS.z);
					real fogFactor =  saturate( fz * unity_FogParams.z + unity_FogParams.w);
					fogFactor = lerp(1.0, fogFactor, unity_FogColor.a * step(0.001, -1.0 / unity_FogParams.z));
				#else
					half fogFactor = 0.0;
				#endif
				o.fogFactorAndVertexLight = half4( fogFactor, vertexLight);
				
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				
				o.clipPos = positionCS;
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				o.screenPos = ComputeScreenPos(positionCS);
				#endif
				return o;
			}

			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE)
				#define ASE_SV_DEPTH SV_DepthLessEqual  
			#else
				#define ASE_SV_DEPTH SV_Depth
			#endif

			half4 frag ( VertexOutput IN 
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);
				InputData inputData = (InputData)0;
				inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(IN.clipPos);
				inputData.shadowMask = SAMPLE_SHADOWMASK(IN.lightmapUVOrVertexSH.xy);
				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float2 sampleCoords = (IN.lightmapUVOrVertexSH.zw / _TerrainHeightmapRecipSize.zw + 0.5f) * _TerrainHeightmapRecipSize.xy;
					float3 WorldNormal = TransformObjectToWorldNormal(normalize(SAMPLE_TEXTURE2D(_TerrainNormalmapTexture, sampler_TerrainNormalmapTexture, sampleCoords).rgb * 2 - 1));
					float3 WorldTangent = -cross(GetObjectToWorldMatrix()._13_23_33, WorldNormal);
					float3 WorldBiTangent = cross(WorldNormal, -WorldTangent);
				#else
					float3 WorldNormal = normalize( IN.tSpace0.xyz );
					float3 WorldTangent = IN.tSpace1.xyz;
					float3 WorldBiTangent = IN.tSpace2.xyz;
				#endif
				float3 WorldPosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldViewDirection = _WorldSpaceCameraPos.xyz  - WorldPosition;
				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				#ifdef PUSH_SELFSHADOW_TO_MAIN_LIGHT
				float selfShadowPush = 0.0;
				float3 pushRatio = _MainLightPosition.xyz * selfShadowPush;
				#else
				float3 pushRatio = 0.0;
				#endif
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				float4 ScreenPos = IN.screenPos;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					ShadowCoords = IN.shadowCoord;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					ShadowCoords = TransformWorldToShadowCoord( WorldPosition + pushRatio );
				#endif
				
				WorldViewDirection = SafeNormalize( WorldViewDirection );

				float vertexToFrag1046 = IN.ase_texcoord8.x;
				float isFirstLayer1061 = vertexToFrag1046;
				float2 uv2_Baked_Paint_W123 = IN.ase_texcoord8.yz * _Baked_Paint_W123_ST.xy + _Baked_Paint_W123_ST.zw;
				float4 tex2DNode1676 = SAMPLE_TEXTURE2D( _Baked_Paint_W123, sampler_Baked_Paint_W123, uv2_Baked_Paint_W123 );
				float lerpResult1681 = lerp( IN.ase_texcoord9.x , tex2DNode1676.r , _WeightUsingMaps);
				float weight_1592 = lerpResult1681;
				float temp_output_1_0_g113 = weight_1592;
				float2 uv_Splat0 = IN.ase_texcoord10.xy * _Splat0_ST.xy + _Splat0_ST.zw;
				float4 tex2DNode514 = SAMPLE_TEXTURE2D( _Splat0, sampler_linear_repeat, uv_Splat0 );
				float map_height_1527 = tex2DNode514.a;
				float temp_output_6_0_g113 = ( 1.0 - map_height_1527 );
				float lerpResult7_g113 = lerp( temp_output_1_0_g113 , ( max( temp_output_1_0_g113 , temp_output_6_0_g113 ) - temp_output_6_0_g113 ) , 0.95);
				float height_compare_1602 = lerpResult7_g113;
				float isfur_1992 = _IsFur0;
				float2 uv_FurMap = IN.ase_texcoord10.xy * _FurMap_ST.xy + _FurMap_ST.zw;
				float4 tex2DNode1130 = SAMPLE_TEXTURE2D( _FurMap, sampler_FurMap, uv_FurMap );
				float lerpResult1682 = lerp( IN.ase_texcoord9.y , tex2DNode1676.g , _WeightUsingMaps);
				float weight_2593 = lerpResult1682;
				float temp_output_1_0_g112 = weight_2593;
				float2 uv_Splat1 = IN.ase_texcoord10.xy * _Splat1_ST.xy + _Splat1_ST.zw;
				float4 tex2DNode516 = SAMPLE_TEXTURE2D( _Splat1, sampler_linear_repeat, uv_Splat1 );
				float map_height_2528 = tex2DNode516.a;
				float temp_output_6_0_g112 = ( 1.0 - map_height_2528 );
				float lerpResult7_g112 = lerp( temp_output_1_0_g112 , ( max( temp_output_1_0_g112 , temp_output_6_0_g112 ) - temp_output_6_0_g112 ) , 0.95);
				float height_compare_2588 = lerpResult7_g112;
				float isfur_2993 = _IsFur1;
				float lerpResult1683 = lerp( IN.ase_texcoord9.z , tex2DNode1676.b , _WeightUsingMaps);
				float weight_3594 = lerpResult1683;
				float temp_output_1_0_g114 = weight_3594;
				float2 uv_Splat2 = IN.ase_texcoord10.xy * _Splat2_ST.xy + _Splat2_ST.zw;
				float4 tex2DNode517 = SAMPLE_TEXTURE2D( _Splat2, sampler_linear_repeat, uv_Splat2 );
				float map_height_3529 = tex2DNode517.a;
				float temp_output_6_0_g114 = ( 1.0 - map_height_3529 );
				float lerpResult7_g114 = lerp( temp_output_1_0_g114 , ( max( temp_output_1_0_g114 , temp_output_6_0_g114 ) - temp_output_6_0_g114 ) , 0.95);
				float height_compare_3609 = lerpResult7_g114;
				float isfur_3994 = _IsFur2;
				float2 uv2_Baked_Paint_WB4 = IN.ase_texcoord8.yz * _Baked_Paint_WB4_ST.xy + _Baked_Paint_WB4_ST.zw;
				float4 tex2DNode1677 = SAMPLE_TEXTURE2D( _Baked_Paint_WB4, sampler_Baked_Paint_WB4, uv2_Baked_Paint_WB4 );
				float lerpResult1684 = lerp( IN.ase_texcoord9.w , tex2DNode1677.g , _WeightUsingMaps);
				float weight_4595 = lerpResult1684;
				float temp_output_1_0_g111 = weight_4595;
				float2 uv_Splat3 = IN.ase_texcoord10.xy * _Splat3_ST.xy + _Splat3_ST.zw;
				float4 tex2DNode518 = SAMPLE_TEXTURE2D( _Splat3, sampler_linear_repeat, uv_Splat3 );
				float map_height_4530 = tex2DNode518.a;
				float temp_output_6_0_g111 = ( 1.0 - map_height_4530 );
				float lerpResult7_g111 = lerp( temp_output_1_0_g111 , ( max( temp_output_1_0_g111 , temp_output_6_0_g111 ) - temp_output_6_0_g111 ) , 0.95);
				float height_compare_4613 = lerpResult7_g111;
				float isfur_4995 = _IsFur3;
				float vertexToFrag1039 = IN.ase_texcoord8.w;
				float hasFur1051 = vertexToFrag1039;
				float lerpResult1056 = lerp( isFirstLayer1061 , max( max( ( height_compare_1602 * isfur_1992 * tex2DNode1130.r ) , ( height_compare_2588 * isfur_2993 * tex2DNode1130.r ) ) , max( ( height_compare_3609 * isfur_3994 * tex2DNode1130.r ) , ( height_compare_4613 * isfur_4995 * tex2DNode1130.r ) ) ) , hasFur1051);
				float Out_DiscardMask1036 = lerpResult1056;
				float2 uv_CutoutMap = IN.ase_texcoord10.xy * _CutoutMap_ST.xy + _CutoutMap_ST.zw;
				float temp_output_1119_0 = ( SAMPLE_TEXTURE2D( _CutoutMap, sampler_CutoutMap, uv_CutoutMap ).a + 0.002 );
				float lerpResult1093 = lerp( min( Out_DiscardMask1036 , ( 1.0 - IN.ase_texcoord11.xy.x ) ) , ( 1.0 - ( ( IN.ase_texcoord11.xy.x * temp_output_1119_0 ) + ( 1.0 - temp_output_1119_0 ) ) ) , isFirstLayer1061);
				float lerpResult1141 = lerp( lerpResult1093 , 0.0 , _FurEditing);
				
				float vertexToFrag1055 = IN.ase_texcoord10.z;
				float lerpResult1094 = lerp( ( _AlphaCutout * vertexToFrag1055 ) , 0.001 , isFirstLayer1061);
				
				float2 uv0500 = IN.ase_texcoord10.xy;
				float2 uv_SplatBase = IN.ase_texcoord10.xy * _SplatBase_ST.xy + _SplatBase_ST.zw;
				float4 tex2DNode568 = SAMPLE_TEXTURE2D( _SplatBase, sampler_linear_repeat, uv_SplatBase );
				float vertexToFrag1658 = IN.ase_texcoord10.w;
				float scale_b721 = vertexToFrag1658;
				float3 vertexToFrag1617 = IN.ase_texcoord12.xyz;
				float3 ts_viewDir1618 = vertexToFrag1617;
				float2 Offset1619 = ( ( tex2DNode568.a - 1 ) * ts_viewDir1618.xy * scale_b721 ) + ( ( uv0500 * _SplatBase_ST.xy ) + _SplatBase_ST.zw );
				float2 parallax_uv_b1622 = Offset1619;
				float3 appendResult565 = (float3(SAMPLE_TEXTURE2D( _SplatBase, sampler_linear_repeat, parallax_uv_b1622 ).rgb));
				float3 map_color_base564 = appendResult565;
				float lerpResult1679 = lerp( IN.ase_texcoord11.z , tex2DNode1677.r , _WeightUsingMaps);
				float weight_b1426 = lerpResult1679;
				float temp_output_1_0_g157 = weight_b1426;
				float map_height_base563 = tex2DNode568.a;
				float temp_output_6_0_g157 = ( 1.0 - map_height_base563 );
				float lerpResult7_g157 = lerp( temp_output_1_0_g157 , ( max( temp_output_1_0_g157 , temp_output_6_0_g157 ) - temp_output_6_0_g157 ) , 0.95);
				float height_compare_b1441 = lerpResult7_g157;
				float temp_output_2_0_g175 = height_compare_b1441;
				float vertexToFrag1663 = IN.ase_texcoord12.w;
				float scale_0722 = vertexToFrag1663;
				float2 Offset1626 = ( ( tex2DNode514.a - 1 ) * ts_viewDir1618.xy * scale_0722 ) + ( ( uv0500 * _Splat0_ST.xy ) + _Splat0_ST.zw );
				float2 parallax_uv_11625 = Offset1626;
				float3 appendResult531 = (float3(SAMPLE_TEXTURE2D( _Splat0, sampler_linear_repeat, parallax_uv_11625 ).rgb));
				float3 map_color_1535 = appendResult531;
				float temp_output_3_0_g175 = height_compare_1602;
				float vertexToFrag1664 = IN.ase_texcoord13.x;
				float scale_1723 = vertexToFrag1664;
				float2 Offset1630 = ( ( tex2DNode516.a - 1 ) * ts_viewDir1618.xy * scale_1723 ) + ( ( uv0500 * _Splat1_ST.xy ) + _Splat1_ST.zw );
				float2 parallax_uv_21629 = Offset1630;
				float3 appendResult532 = (float3(SAMPLE_TEXTURE2D( _Splat1, sampler_linear_repeat, parallax_uv_21629 ).rgb));
				float3 map_color_2536 = appendResult532;
				float vertexToFrag1665 = IN.ase_texcoord13.y;
				float scale_2724 = vertexToFrag1665;
				float2 Offset1635 = ( ( tex2DNode517.a - 1 ) * ts_viewDir1618.xy * scale_2724 ) + ( ( uv0500 * _Splat2_ST.xy ) + _Splat2_ST.zw );
				float2 parallax_uv_31636 = Offset1635;
				float3 appendResult533 = (float3(SAMPLE_TEXTURE2D( _Splat2, sampler_linear_repeat, parallax_uv_31636 ).rgb));
				float3 map_color_3537 = appendResult533;
				float vertexToFrag1666 = IN.ase_texcoord13.z;
				float scale_3725 = vertexToFrag1666;
				float2 Offset1642 = ( ( tex2DNode518.a - 1 ) * ts_viewDir1618.xy * scale_3725 ) + ( ( uv0500 * _Splat3_ST.xy ) + _Splat3_ST.zw );
				float2 parallax_uv_41641 = Offset1642;
				float3 appendResult534 = (float3(SAMPLE_TEXTURE2D( _Splat3, sampler_Splat3, parallax_uv_41641 ).rgb));
				float3 map_color_4538 = appendResult534;
				float3 sum_Color33_g175 = ( ( map_color_base564 * temp_output_2_0_g175 ) + ( map_color_1535 * temp_output_3_0_g175 ) + ( map_color_2536 * height_compare_2588 ) + ( map_color_3537 * height_compare_3609 ) + ( map_color_4538 * height_compare_4613 ) + float3(0,0,0) + float3(0,0,0) + float3(0,0,0) );
				float weights41_g175 = ( temp_output_2_0_g175 + temp_output_3_0_g175 + height_compare_2588 + height_compare_3609 + height_compare_4613 + 0.0 + 0.0 + 0.0 );
				float3 Out_Albedo634 = ( sum_Color33_g175 / weights41_g175 );
				
				float3 unpack698 = UnpackNormalScale( SAMPLE_TEXTURE2D( _NormalBase, sampler_linear_repeat, parallax_uv_b1622 ), _NormalIntensityBase );
				unpack698.z = lerp( 1, unpack698.z, saturate(_NormalIntensityBase) );
				float3 appendResult691 = (float3(unpack698));
				float3 map_normal_base749 = appendResult691;
				float temp_output_2_0_g170 = height_compare_b1441;
				float3 unpack693 = UnpackNormalScale( SAMPLE_TEXTURE2D( _Normal0, sampler_linear_repeat, parallax_uv_11625 ), _NormalIntensity0 );
				unpack693.z = lerp( 1, unpack693.z, saturate(_NormalIntensity0) );
				float3 appendResult715 = (float3(unpack693));
				float3 map_normal_1750 = appendResult715;
				float temp_output_3_0_g170 = height_compare_1602;
				float3 unpack702 = UnpackNormalScale( SAMPLE_TEXTURE2D( _Normal1, sampler_linear_repeat, parallax_uv_21629 ), _NormalIntensity1 );
				unpack702.z = lerp( 1, unpack702.z, saturate(_NormalIntensity1) );
				float3 appendResult716 = (float3(unpack702));
				float3 map_normal_2751 = appendResult716;
				float3 unpack709 = UnpackNormalScale( SAMPLE_TEXTURE2D( _Normal2, sampler_linear_repeat, parallax_uv_31636 ), _NormalIntensity2 );
				unpack709.z = lerp( 1, unpack709.z, saturate(_NormalIntensity2) );
				float3 appendResult717 = (float3(unpack709));
				float3 map_normal_3752 = appendResult717;
				float3 unpack710 = UnpackNormalScale( SAMPLE_TEXTURE2D( _Normal3, sampler_linear_repeat, parallax_uv_41641 ), _NormalIntensity3 );
				unpack710.z = lerp( 1, unpack710.z, saturate(_NormalIntensity3) );
				float3 appendResult718 = (float3(unpack710));
				float3 map_normal_4753 = appendResult718;
				float3 sum_Color33_g170 = ( ( map_normal_base749 * temp_output_2_0_g170 ) + ( map_normal_1750 * temp_output_3_0_g170 ) + ( map_normal_2751 * height_compare_2588 ) + ( map_normal_3752 * height_compare_3609 ) + ( map_normal_4753 * height_compare_4613 ) + float3(0,0,0) + float3(0,0,0) + float3(0,0,0) );
				float weights41_g170 = ( temp_output_2_0_g170 + temp_output_3_0_g170 + height_compare_2588 + height_compare_3609 + height_compare_4613 + 0.0 + 0.0 + 0.0 );
				float3 Out_Normal775 = ( sum_Color33_g170 / weights41_g170 );
				
				float4 tex2DNode863 = SAMPLE_TEXTURE2D( _MetallicGlossBase, sampler_linear_repeat, parallax_uv_b1622 );
				float map_metallic_base867 = tex2DNode863.r;
				float temp_output_2_0_g172 = height_compare_b1441;
				float4 tex2DNode854 = SAMPLE_TEXTURE2D( _MetallicGloss0, sampler_linear_repeat, parallax_uv_11625 );
				float map_metallic_1874 = tex2DNode854.r;
				float temp_output_3_0_g172 = height_compare_1602;
				float4 tex2DNode846 = SAMPLE_TEXTURE2D( _MetallicGloss1, sampler_linear_repeat, parallax_uv_21629 );
				float map_metallic_2879 = tex2DNode846.r;
				float4 tex2DNode851 = SAMPLE_TEXTURE2D( _MetallicGloss2, sampler_linear_repeat, parallax_uv_31636 );
				float map_metallic_3871 = tex2DNode851.r;
				float4 tex2DNode860 = SAMPLE_TEXTURE2D( _MetallicGloss3, sampler_linear_repeat, parallax_uv_41641 );
				float map_metallic_4881 = tex2DNode860.r;
				float sum_Color33_g172 = ( ( ( _MetallicBase * map_metallic_base867 ) * temp_output_2_0_g172 ) + ( ( _Metallic0 * map_metallic_1874 ) * temp_output_3_0_g172 ) + ( ( _Metallic1 * map_metallic_2879 ) * height_compare_2588 ) + ( ( _Metallic2 * map_metallic_3871 ) * height_compare_3609 ) + ( ( _Metallic3 * map_metallic_4881 ) * height_compare_4613 ) + 0.0 + 0.0 + 0.0 );
				float weights41_g172 = ( temp_output_2_0_g172 + temp_output_3_0_g172 + height_compare_2588 + height_compare_3609 + height_compare_4613 + 0.0 + 0.0 + 0.0 );
				float Out_Metallic791 = ( sum_Color33_g172 / weights41_g172 );
				
				float map_smoothness_base884 = tex2DNode863.g;
				float temp_output_2_0_g174 = height_compare_b1441;
				float map_smoothness_1886 = tex2DNode854.g;
				float temp_output_3_0_g174 = height_compare_1602;
				float map_smoothness_2888 = tex2DNode846.g;
				float map_smoothness_3890 = tex2DNode851.g;
				float map_smoothness_4892 = tex2DNode860.g;
				float sum_Color33_g174 = ( ( ( _SmoothnessBase * map_smoothness_base884 ) * temp_output_2_0_g174 ) + ( ( _Smoothness0 * map_smoothness_1886 ) * temp_output_3_0_g174 ) + ( ( _Smoothness1 * map_smoothness_2888 ) * height_compare_2588 ) + ( ( _Smoothness2 * map_smoothness_3890 ) * height_compare_3609 ) + ( ( _Smoothness3 * map_smoothness_4892 ) * height_compare_4613 ) + 0.0 + 0.0 + 0.0 );
				float weights41_g174 = ( temp_output_2_0_g174 + temp_output_3_0_g174 + height_compare_2588 + height_compare_3609 + height_compare_4613 + 0.0 + 0.0 + 0.0 );
				float Out_Smoothness927 = ( sum_Color33_g174 / weights41_g174 );
				
				float map_ao_base885 = tex2DNode863.b;
				float temp_output_2_0_g171 = height_compare_b1441;
				float map_ao_1887 = tex2DNode854.b;
				float temp_output_3_0_g171 = height_compare_1602;
				float map_ao_2889 = tex2DNode846.b;
				float map_ao_3891 = tex2DNode851.b;
				float map_ao_4893 = tex2DNode860.b;
				float sum_Color33_g171 = ( ( ( ( map_ao_base885 * _AOBase ) + ( 1.0 - _AOBase ) ) * temp_output_2_0_g171 ) + ( ( ( map_ao_1887 * _AO0 ) + ( 1.0 - _AO0 ) ) * temp_output_3_0_g171 ) + ( ( ( map_ao_2889 * _AO1 ) + ( 1.0 - _AO1 ) ) * height_compare_2588 ) + ( ( ( map_ao_3891 * _AO2 ) + ( 1.0 - _AO2 ) ) * height_compare_3609 ) + ( ( ( map_ao_4893 * _AO3 ) + ( 1.0 - _AO3 ) ) * height_compare_4613 ) + 0.0 + 0.0 + 0.0 );
				float weights41_g171 = ( temp_output_2_0_g171 + temp_output_3_0_g171 + height_compare_2588 + height_compare_3609 + height_compare_4613 + 0.0 + 0.0 + 0.0 );
				float Out_AO952 = ( sum_Color33_g171 / weights41_g171 );
				
#ifdef DISCARD_FRAGMENT
				float DiscardValue = lerpResult1141;
				float DiscardThreshold = lerpResult1094;

				if(DiscardValue < DiscardThreshold)discard;
#endif
				float3 Albedo = Out_Albedo634;
				float3 Normal = Out_Normal775;
				float3 Emission = 0;
				float3 Specular = 0.0;
				float Metallic = Out_Metallic791;
				float Smoothness = Out_Smoothness927;
				float Occlusion = Out_AO952;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float3 RefractionNormal = WorldNormal;
				float RefractionAlpha = 1;
				float RefractionIndex = 1;
				float3 ThinFilm = 0.5;
				float3 Transmission = 1;
				float3 Translucency = 1;
				#ifdef ASE_DEPTH_WRITE_ON
				float DepthValue = 0;
				#endif
				
				#ifdef _CLEARCOAT
				float CoatMask = 0;
				float CoatSmoothness = 0;
				#endif


				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				inputData.positionWS = WorldPosition;
				inputData.viewDirectionWS = WorldViewDirection;
				

				#ifdef _NORMALMAP
					#if _NORMAL_DROPOFF_TS
					inputData.normalWS = TransformTangentToWorld(Normal, half3x3( WorldTangent, WorldBiTangent, WorldNormal ));
					#elif _NORMAL_DROPOFF_OS
					inputData.normalWS = TransformObjectToWorldNormal(Normal);
					#elif _NORMAL_DROPOFF_WS
					inputData.normalWS = Normal;
					#endif
					inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
				#else
					inputData.normalWS = WorldNormal;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					inputData.shadowCoord = ShadowCoords;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
				#else
					inputData.shadowCoord = float4(0, 0, 0, 0);
				#endif


				inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;
				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float3 SH = SampleSH(inputData.normalWS.xyz);
				#else
					float3 SH = IN.lightmapUVOrVertexSH.xyz;
				#endif

				#if defined(DYNAMICLIGHTMAP_ON)
				inputData.bakedGI = SAMPLE_GI(IN.lightmapUVOrVertexSH.xy, IN.dynamicLightmapUV.xy, SH, inputData.normalWS);
				#else
				inputData.bakedGI = SAMPLE_GI( IN.lightmapUVOrVertexSH.xy, SH, inputData.normalWS );
				#endif

				#ifdef _ASE_BAKEDGI
					inputData.bakedGI = BakedGI;
				#endif
				

				#if defined(DEBUG_DISPLAY)
					#if defined(DYNAMICLIGHTMAP_ON)
						inputData.dynamicLightmapUV = IN.dynamicLightmapUV.xy;
					#endif

					#if defined(LIGHTMAP_ON)
						inputData.staticLightmapUV = IN.lightmapUVOrVertexSH.xy;
					#else
						inputData.vertexSH = SH;
					#endif
				#endif

				SurfaceData surfaceData;
				surfaceData.albedo              = Albedo;
				surfaceData.metallic            = saturate(Metallic);
				surfaceData.specular            = Specular;
				surfaceData.smoothness          = saturate(Smoothness),
				surfaceData.occlusion           = Occlusion,
				surfaceData.emission            = Emission,
				surfaceData.alpha               = saturate(Alpha);
				surfaceData.normalTS            = Normal;
				surfaceData.clearCoatMask       = 0;
				surfaceData.clearCoatSmoothness = 1;

				float ShadowMaskOcclusion = 0;
				inputData.shadowMask.r = lerp(inputData.shadowMask.r, 1.0, ShadowMaskOcclusion);
				#ifdef EMISSION_X_SHADOWMASK
				surfaceData.emission *= inputData.shadowMask.xxx;
				#endif

				#ifdef _CLEARCOAT
					surfaceData.clearCoatMask       = saturate(CoatMask);
					surfaceData.clearCoatSmoothness = saturate(CoatSmoothness);
				#endif

				#ifdef _DBUFFER
					ApplyDecalToSurfaceData(IN.clipPos, surfaceData, inputData);
				#endif

				half4 color = UniversalFragmentPBR( inputData, surfaceData);

				#ifdef _TRANSMISSION_ASE
				{
					float shadow = _TransmissionShadow;

					Light mainLight = GetMainLight( inputData.shadowCoord );
					float3 mainAtten = mainLight.color * mainLight.distanceAttenuation;
					mainAtten = lerp( mainAtten, mainAtten * mainLight.shadowAttenuation, shadow );
					half3 mainTransmission = max(0 , -dot(inputData.normalWS, mainLight.direction)) * mainAtten * Transmission;
					color.rgb += Albedo * mainTransmission;

					#ifdef _ADDITIONAL_LIGHTS
						int transPixelLightCount = GetAdditionalLightsCount();
						for (int i = 0; i < transPixelLightCount; ++i)
						{
							Light light = GetAdditionalLight(i, inputData.positionWS);
							float3 atten = light.color * light.distanceAttenuation;
							atten = lerp( atten, atten * light.shadowAttenuation, shadow );

							half3 transmission = max(0 , -dot(inputData.normalWS, light.direction)) * atten * Transmission;
							color.rgb += Albedo * transmission;
						}
					#endif
				}
				#endif

				#ifdef _TRANSLUCENCY_ASE
				{
					float shadow = _TransShadow;
					float normal = _TransNormal;
					float scattering = _TransScattering;
					float direct = _TransDirect;
					float ambient = _TransAmbient;
					float strength = _TransStrength;

					Light mainLight = GetMainLight( inputData.shadowCoord );
					float3 mainAtten = mainLight.color * mainLight.distanceAttenuation;
					mainAtten = lerp( mainAtten, mainAtten * mainLight.shadowAttenuation, shadow );

					half3 mainLightDir = mainLight.direction + inputData.normalWS * normal;
					half mainVdotL = pow( saturate( dot( inputData.viewDirectionWS, -mainLightDir ) ), scattering );
					half3 mainTranslucency = mainAtten * ( mainVdotL * direct + inputData.bakedGI * ambient ) * Translucency;
					color.rgb += Albedo * mainTranslucency * strength;

					#ifdef _ADDITIONAL_LIGHTS
						int transPixelLightCount = GetAdditionalLightsCount();
						for (int i = 0; i < transPixelLightCount; ++i)
						{
							Light light = GetAdditionalLight(i, inputData.positionWS);
							float3 atten = light.color * light.distanceAttenuation;
							atten = lerp( atten, atten * light.shadowAttenuation, shadow );

							half3 lightDir = light.direction + inputData.normalWS * normal;
							half VdotL = pow( saturate( dot( inputData.viewDirectionWS, -lightDir ) ), scattering );
							half3 translucency = atten * ( VdotL * direct + inputData.bakedGI * ambient ) * Translucency;
							color.rgb += Albedo * translucency * strength;
						}
					#endif
				}
				#endif
				
				#ifdef _REFRACTION_ASE
					float3 projScreenPos = ScreenPos.xyz / ScreenPos.w;
					float3 refractionOffset = ( RefractionIndex - 1.0 ) * mul( UNITY_MATRIX_V, float4( RefractionNormal, 0 ) ).xyz * ( 1.0 - dot( RefractionNormal, WorldViewDirection ) );
					//projScreenPos.xy += refractionOffset.xy;
					#ifdef _REFRACTION_THIN_FILM
					float3 thinfilm = lerp(1.0.xxx, _MainLightPosition.xyz + RefractionNormal + WorldViewDirection, ThinFilm);
					float refractionR = SHADERGRAPH_SAMPLE_SCENE_COLOR( projScreenPos.xy + refractionOffset.xy * thinfilm.x).r;
					float refractionG = SHADERGRAPH_SAMPLE_SCENE_COLOR( projScreenPos.xy + refractionOffset.xy * thinfilm.y).g;
					float refractionB = SHADERGRAPH_SAMPLE_SCENE_COLOR( projScreenPos.xy + refractionOffset.xy * thinfilm.z).b;
					float3 refraction = float3(refractionR, refractionG, refractionB) * RefractionColor.rgb;
					#else
					float3 refraction =  SHADERGRAPH_SAMPLE_SCENE_COLOR( projScreenPos.xy + refractionOffset.xy) * RefractionColor.rgb;
					#endif
					color.rgb = lerp( refraction, color.rgb, color.a * RefractionAlpha );
					color.a = 1;
				#endif

				#ifdef ASE_FINAL_COLOR_ALPHA_MULTIPLY
					color.rgb *= color.a;
				#endif

				#ifdef ASE_FOG
					#ifdef TERRAIN_SPLAT_ADDPASS
						color.rgb = MixFogColor(color.rgb, half3( 0, 0, 0 ), IN.fogFactorAndVertexLight.x );
					#else
						color.rgb = MixFog(color.rgb, IN.fogFactorAndVertexLight.x);
					#endif
				#endif

				#ifdef TREEVERSE_LINEAR_FOG
					color.rgb = lerp(unity_FogColor.rgb, color.rgb, IN.fogFactorAndVertexLight.x);
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif
				
				#ifdef _DEBUG
					float4 Debug = 0;
					return Debug;
				#endif
				return color;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off
			ColorMask 0

			HLSLPROGRAM
			
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#define DISCARD_FRAGMENT
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define TREEVERSE_LINEAR_FOG 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 999999
			#define ASE_USING_SAMPLING_MACROS 1

			
			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW

			#define SHADERPASS SHADERPASS_SHADOWCASTER

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_VERT_POSITION


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord3 : TEXCOORD3;
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
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BaseMove;
			float4 _SplatBase_ST;
			float4 _CutoutMap_ST;
			float4 _Splat3_ST;
			float4 _Splat2_ST;
			float4 _Splat1_ST;
			float4 _FurMap_ST;
			float4 _Baked_Paint_WB4_ST;
			float4 _Splat0_ST;
			float4 _Baked_Paint_W123_ST;
			float4 _WindFreq;
			float4 _WindMove;
			float _MetallicBase;
			float _Metallic0;
			float _Metallic1;
			float _Metallic2;
			float _Metallic3;
			float _SmoothnessBase;
			float _Smoothness1;
			float _AO0;
			float _Smoothness2;
			float _AO2;
			float _NormalIntensity3;
			float _Smoothness3;
			float _AOBase;
			float _AO1;
			float _Smoothness0;
			float _NormalIntensity2;
			float _ParallaxHeightScale1;
			float _NormalIntensity0;
			float _WindIntensity;
			float _WeightUsingMaps;
			float _IsFur0;
			float _IsFur1;
			float _IsFur2;
			float _IsFur3;
			float _NormalIntensity1;
			float _FurEditing;
			float _ParallaxHeightScaleBase;
			float _ParallaxHeightScale0;
			float _AO3;
			float _ParallaxHeightScale2;
			float _ParallaxHeightScale3;
			float _NormalIntensityBase;
			float _AlphaCutout;
			float _LightCutoutResslover_Solo;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			TEXTURE2D(_Baked_Paint_W123);
			SAMPLER(sampler_Baked_Paint_W123);
			TEXTURE2D(_Splat0);
			SAMPLER(sampler_linear_repeat);
			TEXTURE2D(_FurMap);
			SAMPLER(sampler_FurMap);
			TEXTURE2D(_Splat1);
			TEXTURE2D(_Splat2);
			TEXTURE2D(_Baked_Paint_WB4);
			SAMPLER(sampler_Baked_Paint_WB4);
			TEXTURE2D(_Splat3);
			TEXTURE2D(_CutoutMap);
			SAMPLER(sampler_CutoutMap);


			real3 ASESafeNormalize(float3 inVec)
			{
				real dp3 = max(FLT_MIN, dot(inVec, inVec));
				return inVec* rsqrt( dp3);
			}
			

			float3 _LightDirection;
			float3 _LightPosition;

			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				float vertexToFrag641 = ( v.ase_color.r - 1.0 );
				float grass_heightOffset642 = vertexToFrag641;
				float saferPower656 = abs( grass_heightOffset642 );
				float temp_output_656_0 = pow( saferPower656 , _BaseMove.w );
				float3 appendResult663 = (float3(_BaseMove.xyz));
				float3 move667 = ( temp_output_656_0 * appendResult663 );
				float3 appendResult662 = (float3(_WindMove.xyz));
				float moveFactor659 = temp_output_656_0;
				float3 appendResult648 = (float3(_WindFreq.xyz));
				float mulTime649 = _TimeParameters.x * 3.0;
				float3 windAngle651 = ( appendResult648 * mulTime649 );
				float3 windMove668 = ( appendResult662 * moveFactor659 * sin( ( ( _WindMove.w * v.vertex.xyz ) + windAngle651 ) ) );
				float3 normalizeResult673 = ASESafeNormalize( ( ase_worldNormal + move667 + windMove668 ) );
				float3 shellDir677 = ( normalizeResult673 * float3( 1,0,1 ) );
				float3 worldToObj685 = mul( GetWorldToObjectMatrix(), float4( ( ase_worldPos + ( shellDir677 * ( grass_heightOffset642 * 9.0 * _WindIntensity ) ) + ( grass_heightOffset642 * ase_worldNormal ) ), 1 ) ).xyz;
				float3 Out_Position686 = worldToObj685;
				
				float grass_currentLayer1047 = v.ase_color.b;
				float vertexToFrag1046 = step( grass_currentLayer1047 , 0.0 );
				o.ase_texcoord2.x = vertexToFrag1046;
				float isfur_1992 = _IsFur0;
				float isfur_2993 = _IsFur1;
				float isfur_3994 = _IsFur2;
				float isfur_4995 = _IsFur3;
				float vertexToFrag1039 = min( ( isfur_1992 + isfur_2993 + isfur_3994 + isfur_4995 ) , 1.0 );
				o.ase_texcoord2.w = vertexToFrag1039;
				
				float grass_curvature645 = v.ase_color.g;
				float hasFur1051 = vertexToFrag1039;
				float lerpResult1054 = lerp( 1.0 , grass_curvature645 , hasFur1051);
				float vertexToFrag1055 = lerpResult1054;
				o.ase_texcoord5.x = vertexToFrag1055;
				
				o.ase_texcoord3 = v.ase_texcoord2;
				o.ase_texcoord2.yz = v.ase_texcoord1.xy;
				o.ase_texcoord4.xy = v.ase_texcoord.xy;
				o.ase_texcoord4.zw = v.ase_texcoord3.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord5.yzw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = Out_Position686;
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
				float3 normalWS = TransformObjectToWorldDir(v.ase_normal);


			#if _CASTING_PUNCTUAL_LIGHT_SHADOW
				float3 lightDirectionWS = normalize(_LightPosition - positionWS);
			#else
				float3 lightDirectionWS = _LightDirection;
			#endif

				float4 clipPos = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));
			
			#if UNITY_REVERSED_Z
				clipPos.z = min(clipPos.z, UNITY_NEAR_CLIP_VALUE);
			#else
				clipPos.z = max(clipPos.z, UNITY_NEAR_CLIP_VALUE);
			#endif


				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				o.clipPos = clipPos;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord3 : TEXCOORD3;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_color = v.ase_color;
				o.ase_texcoord2 = v.ase_texcoord2;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord3 = v.ase_texcoord3;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord3 = patch[0].ase_texcoord3 * bary.x + patch[1].ase_texcoord3 * bary.y + patch[2].ase_texcoord3 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE)
				#define ASE_SV_DEPTH SV_DepthLessEqual  
			#else
				#define ASE_SV_DEPTH SV_Depth
			#endif

			half4 frag(	VertexOutput IN 
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );
				
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float vertexToFrag1046 = IN.ase_texcoord2.x;
				float isFirstLayer1061 = vertexToFrag1046;
				float2 uv2_Baked_Paint_W123 = IN.ase_texcoord2.yz * _Baked_Paint_W123_ST.xy + _Baked_Paint_W123_ST.zw;
				float4 tex2DNode1676 = SAMPLE_TEXTURE2D( _Baked_Paint_W123, sampler_Baked_Paint_W123, uv2_Baked_Paint_W123 );
				float lerpResult1681 = lerp( IN.ase_texcoord3.x , tex2DNode1676.r , _WeightUsingMaps);
				float weight_1592 = lerpResult1681;
				float temp_output_1_0_g113 = weight_1592;
				float2 uv_Splat0 = IN.ase_texcoord4.xy * _Splat0_ST.xy + _Splat0_ST.zw;
				float4 tex2DNode514 = SAMPLE_TEXTURE2D( _Splat0, sampler_linear_repeat, uv_Splat0 );
				float map_height_1527 = tex2DNode514.a;
				float temp_output_6_0_g113 = ( 1.0 - map_height_1527 );
				float lerpResult7_g113 = lerp( temp_output_1_0_g113 , ( max( temp_output_1_0_g113 , temp_output_6_0_g113 ) - temp_output_6_0_g113 ) , 0.95);
				float height_compare_1602 = lerpResult7_g113;
				float isfur_1992 = _IsFur0;
				float2 uv_FurMap = IN.ase_texcoord4.xy * _FurMap_ST.xy + _FurMap_ST.zw;
				float4 tex2DNode1130 = SAMPLE_TEXTURE2D( _FurMap, sampler_FurMap, uv_FurMap );
				float lerpResult1682 = lerp( IN.ase_texcoord3.y , tex2DNode1676.g , _WeightUsingMaps);
				float weight_2593 = lerpResult1682;
				float temp_output_1_0_g112 = weight_2593;
				float2 uv_Splat1 = IN.ase_texcoord4.xy * _Splat1_ST.xy + _Splat1_ST.zw;
				float4 tex2DNode516 = SAMPLE_TEXTURE2D( _Splat1, sampler_linear_repeat, uv_Splat1 );
				float map_height_2528 = tex2DNode516.a;
				float temp_output_6_0_g112 = ( 1.0 - map_height_2528 );
				float lerpResult7_g112 = lerp( temp_output_1_0_g112 , ( max( temp_output_1_0_g112 , temp_output_6_0_g112 ) - temp_output_6_0_g112 ) , 0.95);
				float height_compare_2588 = lerpResult7_g112;
				float isfur_2993 = _IsFur1;
				float lerpResult1683 = lerp( IN.ase_texcoord3.z , tex2DNode1676.b , _WeightUsingMaps);
				float weight_3594 = lerpResult1683;
				float temp_output_1_0_g114 = weight_3594;
				float2 uv_Splat2 = IN.ase_texcoord4.xy * _Splat2_ST.xy + _Splat2_ST.zw;
				float4 tex2DNode517 = SAMPLE_TEXTURE2D( _Splat2, sampler_linear_repeat, uv_Splat2 );
				float map_height_3529 = tex2DNode517.a;
				float temp_output_6_0_g114 = ( 1.0 - map_height_3529 );
				float lerpResult7_g114 = lerp( temp_output_1_0_g114 , ( max( temp_output_1_0_g114 , temp_output_6_0_g114 ) - temp_output_6_0_g114 ) , 0.95);
				float height_compare_3609 = lerpResult7_g114;
				float isfur_3994 = _IsFur2;
				float2 uv2_Baked_Paint_WB4 = IN.ase_texcoord2.yz * _Baked_Paint_WB4_ST.xy + _Baked_Paint_WB4_ST.zw;
				float4 tex2DNode1677 = SAMPLE_TEXTURE2D( _Baked_Paint_WB4, sampler_Baked_Paint_WB4, uv2_Baked_Paint_WB4 );
				float lerpResult1684 = lerp( IN.ase_texcoord3.w , tex2DNode1677.g , _WeightUsingMaps);
				float weight_4595 = lerpResult1684;
				float temp_output_1_0_g111 = weight_4595;
				float2 uv_Splat3 = IN.ase_texcoord4.xy * _Splat3_ST.xy + _Splat3_ST.zw;
				float4 tex2DNode518 = SAMPLE_TEXTURE2D( _Splat3, sampler_linear_repeat, uv_Splat3 );
				float map_height_4530 = tex2DNode518.a;
				float temp_output_6_0_g111 = ( 1.0 - map_height_4530 );
				float lerpResult7_g111 = lerp( temp_output_1_0_g111 , ( max( temp_output_1_0_g111 , temp_output_6_0_g111 ) - temp_output_6_0_g111 ) , 0.95);
				float height_compare_4613 = lerpResult7_g111;
				float isfur_4995 = _IsFur3;
				float vertexToFrag1039 = IN.ase_texcoord2.w;
				float hasFur1051 = vertexToFrag1039;
				float lerpResult1056 = lerp( isFirstLayer1061 , max( max( ( height_compare_1602 * isfur_1992 * tex2DNode1130.r ) , ( height_compare_2588 * isfur_2993 * tex2DNode1130.r ) ) , max( ( height_compare_3609 * isfur_3994 * tex2DNode1130.r ) , ( height_compare_4613 * isfur_4995 * tex2DNode1130.r ) ) ) , hasFur1051);
				float Out_DiscardMask1036 = lerpResult1056;
				float2 uv_CutoutMap = IN.ase_texcoord4.xy * _CutoutMap_ST.xy + _CutoutMap_ST.zw;
				float temp_output_1119_0 = ( SAMPLE_TEXTURE2D( _CutoutMap, sampler_CutoutMap, uv_CutoutMap ).a + 0.002 );
				float lerpResult1093 = lerp( min( Out_DiscardMask1036 , ( 1.0 - IN.ase_texcoord4.zw.x ) ) , ( 1.0 - ( ( IN.ase_texcoord4.zw.x * temp_output_1119_0 ) + ( 1.0 - temp_output_1119_0 ) ) ) , isFirstLayer1061);
				float lerpResult1141 = lerp( lerpResult1093 , 0.0 , _FurEditing);
				
				float vertexToFrag1055 = IN.ase_texcoord5.x;
				float lerpResult1094 = lerp( ( _AlphaCutout * vertexToFrag1055 ) , 0.001 , isFirstLayer1061);
				
#ifdef DISCARD_FRAGMENT
				float DiscardValue = lerpResult1141;
				float DiscardThreshold = lerpResult1094;

				if(DiscardValue < DiscardThreshold)discard;
#endif
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;
				#ifdef ASE_DEPTH_WRITE_ON
				float DepthValue = 0;
				#endif

				#ifdef _ALPHATEST_ON
					#ifdef _ALPHATEST_SHADOW_ON
						clip(Alpha - AlphaClipThresholdShadow);
					#else
						clip(Alpha - AlphaClipThreshold);
					#endif
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif
				return 0;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM
			
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#define DISCARD_FRAGMENT
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define TREEVERSE_LINEAR_FOG 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 999999
			#define ASE_USING_SAMPLING_MACROS 1

			
			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_DEPTHONLY
        
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_VERT_POSITION


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord3 : TEXCOORD3;
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
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BaseMove;
			float4 _SplatBase_ST;
			float4 _CutoutMap_ST;
			float4 _Splat3_ST;
			float4 _Splat2_ST;
			float4 _Splat1_ST;
			float4 _FurMap_ST;
			float4 _Baked_Paint_WB4_ST;
			float4 _Splat0_ST;
			float4 _Baked_Paint_W123_ST;
			float4 _WindFreq;
			float4 _WindMove;
			float _MetallicBase;
			float _Metallic0;
			float _Metallic1;
			float _Metallic2;
			float _Metallic3;
			float _SmoothnessBase;
			float _Smoothness1;
			float _AO0;
			float _Smoothness2;
			float _AO2;
			float _NormalIntensity3;
			float _Smoothness3;
			float _AOBase;
			float _AO1;
			float _Smoothness0;
			float _NormalIntensity2;
			float _ParallaxHeightScale1;
			float _NormalIntensity0;
			float _WindIntensity;
			float _WeightUsingMaps;
			float _IsFur0;
			float _IsFur1;
			float _IsFur2;
			float _IsFur3;
			float _NormalIntensity1;
			float _FurEditing;
			float _ParallaxHeightScaleBase;
			float _ParallaxHeightScale0;
			float _AO3;
			float _ParallaxHeightScale2;
			float _ParallaxHeightScale3;
			float _NormalIntensityBase;
			float _AlphaCutout;
			float _LightCutoutResslover_Solo;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			TEXTURE2D(_Baked_Paint_W123);
			SAMPLER(sampler_Baked_Paint_W123);
			TEXTURE2D(_Splat0);
			SAMPLER(sampler_linear_repeat);
			TEXTURE2D(_FurMap);
			SAMPLER(sampler_FurMap);
			TEXTURE2D(_Splat1);
			TEXTURE2D(_Splat2);
			TEXTURE2D(_Baked_Paint_WB4);
			SAMPLER(sampler_Baked_Paint_WB4);
			TEXTURE2D(_Splat3);
			TEXTURE2D(_CutoutMap);
			SAMPLER(sampler_CutoutMap);


			real3 ASESafeNormalize(float3 inVec)
			{
				real dp3 = max(FLT_MIN, dot(inVec, inVec));
				return inVec* rsqrt( dp3);
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				float vertexToFrag641 = ( v.ase_color.r - 1.0 );
				float grass_heightOffset642 = vertexToFrag641;
				float saferPower656 = abs( grass_heightOffset642 );
				float temp_output_656_0 = pow( saferPower656 , _BaseMove.w );
				float3 appendResult663 = (float3(_BaseMove.xyz));
				float3 move667 = ( temp_output_656_0 * appendResult663 );
				float3 appendResult662 = (float3(_WindMove.xyz));
				float moveFactor659 = temp_output_656_0;
				float3 appendResult648 = (float3(_WindFreq.xyz));
				float mulTime649 = _TimeParameters.x * 3.0;
				float3 windAngle651 = ( appendResult648 * mulTime649 );
				float3 windMove668 = ( appendResult662 * moveFactor659 * sin( ( ( _WindMove.w * v.vertex.xyz ) + windAngle651 ) ) );
				float3 normalizeResult673 = ASESafeNormalize( ( ase_worldNormal + move667 + windMove668 ) );
				float3 shellDir677 = ( normalizeResult673 * float3( 1,0,1 ) );
				float3 worldToObj685 = mul( GetWorldToObjectMatrix(), float4( ( ase_worldPos + ( shellDir677 * ( grass_heightOffset642 * 9.0 * _WindIntensity ) ) + ( grass_heightOffset642 * ase_worldNormal ) ), 1 ) ).xyz;
				float3 Out_Position686 = worldToObj685;
				
				float grass_currentLayer1047 = v.ase_color.b;
				float vertexToFrag1046 = step( grass_currentLayer1047 , 0.0 );
				o.ase_texcoord2.x = vertexToFrag1046;
				float isfur_1992 = _IsFur0;
				float isfur_2993 = _IsFur1;
				float isfur_3994 = _IsFur2;
				float isfur_4995 = _IsFur3;
				float vertexToFrag1039 = min( ( isfur_1992 + isfur_2993 + isfur_3994 + isfur_4995 ) , 1.0 );
				o.ase_texcoord2.w = vertexToFrag1039;
				
				float grass_curvature645 = v.ase_color.g;
				float hasFur1051 = vertexToFrag1039;
				float lerpResult1054 = lerp( 1.0 , grass_curvature645 , hasFur1051);
				float vertexToFrag1055 = lerpResult1054;
				o.ase_texcoord5.x = vertexToFrag1055;
				
				o.ase_texcoord3 = v.ase_texcoord2;
				o.ase_texcoord2.yz = v.ase_texcoord1.xy;
				o.ase_texcoord4.xy = v.ase_texcoord.xy;
				o.ase_texcoord4.zw = v.ase_texcoord3.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord5.yzw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = Out_Position686;
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
				o.clipPos = positionCS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord3 : TEXCOORD3;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_color = v.ase_color;
				o.ase_texcoord2 = v.ase_texcoord2;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord3 = v.ase_texcoord3;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord3 = patch[0].ase_texcoord3 * bary.x + patch[1].ase_texcoord3 * bary.y + patch[2].ase_texcoord3 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE)
				#define ASE_SV_DEPTH SV_DepthLessEqual  
			#else
				#define ASE_SV_DEPTH SV_Depth
			#endif
			half4 frag(	VertexOutput IN 
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float vertexToFrag1046 = IN.ase_texcoord2.x;
				float isFirstLayer1061 = vertexToFrag1046;
				float2 uv2_Baked_Paint_W123 = IN.ase_texcoord2.yz * _Baked_Paint_W123_ST.xy + _Baked_Paint_W123_ST.zw;
				float4 tex2DNode1676 = SAMPLE_TEXTURE2D( _Baked_Paint_W123, sampler_Baked_Paint_W123, uv2_Baked_Paint_W123 );
				float lerpResult1681 = lerp( IN.ase_texcoord3.x , tex2DNode1676.r , _WeightUsingMaps);
				float weight_1592 = lerpResult1681;
				float temp_output_1_0_g113 = weight_1592;
				float2 uv_Splat0 = IN.ase_texcoord4.xy * _Splat0_ST.xy + _Splat0_ST.zw;
				float4 tex2DNode514 = SAMPLE_TEXTURE2D( _Splat0, sampler_linear_repeat, uv_Splat0 );
				float map_height_1527 = tex2DNode514.a;
				float temp_output_6_0_g113 = ( 1.0 - map_height_1527 );
				float lerpResult7_g113 = lerp( temp_output_1_0_g113 , ( max( temp_output_1_0_g113 , temp_output_6_0_g113 ) - temp_output_6_0_g113 ) , 0.95);
				float height_compare_1602 = lerpResult7_g113;
				float isfur_1992 = _IsFur0;
				float2 uv_FurMap = IN.ase_texcoord4.xy * _FurMap_ST.xy + _FurMap_ST.zw;
				float4 tex2DNode1130 = SAMPLE_TEXTURE2D( _FurMap, sampler_FurMap, uv_FurMap );
				float lerpResult1682 = lerp( IN.ase_texcoord3.y , tex2DNode1676.g , _WeightUsingMaps);
				float weight_2593 = lerpResult1682;
				float temp_output_1_0_g112 = weight_2593;
				float2 uv_Splat1 = IN.ase_texcoord4.xy * _Splat1_ST.xy + _Splat1_ST.zw;
				float4 tex2DNode516 = SAMPLE_TEXTURE2D( _Splat1, sampler_linear_repeat, uv_Splat1 );
				float map_height_2528 = tex2DNode516.a;
				float temp_output_6_0_g112 = ( 1.0 - map_height_2528 );
				float lerpResult7_g112 = lerp( temp_output_1_0_g112 , ( max( temp_output_1_0_g112 , temp_output_6_0_g112 ) - temp_output_6_0_g112 ) , 0.95);
				float height_compare_2588 = lerpResult7_g112;
				float isfur_2993 = _IsFur1;
				float lerpResult1683 = lerp( IN.ase_texcoord3.z , tex2DNode1676.b , _WeightUsingMaps);
				float weight_3594 = lerpResult1683;
				float temp_output_1_0_g114 = weight_3594;
				float2 uv_Splat2 = IN.ase_texcoord4.xy * _Splat2_ST.xy + _Splat2_ST.zw;
				float4 tex2DNode517 = SAMPLE_TEXTURE2D( _Splat2, sampler_linear_repeat, uv_Splat2 );
				float map_height_3529 = tex2DNode517.a;
				float temp_output_6_0_g114 = ( 1.0 - map_height_3529 );
				float lerpResult7_g114 = lerp( temp_output_1_0_g114 , ( max( temp_output_1_0_g114 , temp_output_6_0_g114 ) - temp_output_6_0_g114 ) , 0.95);
				float height_compare_3609 = lerpResult7_g114;
				float isfur_3994 = _IsFur2;
				float2 uv2_Baked_Paint_WB4 = IN.ase_texcoord2.yz * _Baked_Paint_WB4_ST.xy + _Baked_Paint_WB4_ST.zw;
				float4 tex2DNode1677 = SAMPLE_TEXTURE2D( _Baked_Paint_WB4, sampler_Baked_Paint_WB4, uv2_Baked_Paint_WB4 );
				float lerpResult1684 = lerp( IN.ase_texcoord3.w , tex2DNode1677.g , _WeightUsingMaps);
				float weight_4595 = lerpResult1684;
				float temp_output_1_0_g111 = weight_4595;
				float2 uv_Splat3 = IN.ase_texcoord4.xy * _Splat3_ST.xy + _Splat3_ST.zw;
				float4 tex2DNode518 = SAMPLE_TEXTURE2D( _Splat3, sampler_linear_repeat, uv_Splat3 );
				float map_height_4530 = tex2DNode518.a;
				float temp_output_6_0_g111 = ( 1.0 - map_height_4530 );
				float lerpResult7_g111 = lerp( temp_output_1_0_g111 , ( max( temp_output_1_0_g111 , temp_output_6_0_g111 ) - temp_output_6_0_g111 ) , 0.95);
				float height_compare_4613 = lerpResult7_g111;
				float isfur_4995 = _IsFur3;
				float vertexToFrag1039 = IN.ase_texcoord2.w;
				float hasFur1051 = vertexToFrag1039;
				float lerpResult1056 = lerp( isFirstLayer1061 , max( max( ( height_compare_1602 * isfur_1992 * tex2DNode1130.r ) , ( height_compare_2588 * isfur_2993 * tex2DNode1130.r ) ) , max( ( height_compare_3609 * isfur_3994 * tex2DNode1130.r ) , ( height_compare_4613 * isfur_4995 * tex2DNode1130.r ) ) ) , hasFur1051);
				float Out_DiscardMask1036 = lerpResult1056;
				float2 uv_CutoutMap = IN.ase_texcoord4.xy * _CutoutMap_ST.xy + _CutoutMap_ST.zw;
				float temp_output_1119_0 = ( SAMPLE_TEXTURE2D( _CutoutMap, sampler_CutoutMap, uv_CutoutMap ).a + 0.002 );
				float lerpResult1093 = lerp( min( Out_DiscardMask1036 , ( 1.0 - IN.ase_texcoord4.zw.x ) ) , ( 1.0 - ( ( IN.ase_texcoord4.zw.x * temp_output_1119_0 ) + ( 1.0 - temp_output_1119_0 ) ) ) , isFirstLayer1061);
				float lerpResult1141 = lerp( lerpResult1093 , 0.0 , _FurEditing);
				
				float vertexToFrag1055 = IN.ase_texcoord5.x;
				float lerpResult1094 = lerp( ( _AlphaCutout * vertexToFrag1055 ) , 0.001 , isFirstLayer1061);
				
#ifdef DISCARD_FRAGMENT
				float DiscardValue = lerpResult1141;
				float DiscardThreshold = lerpResult1094;

				if(DiscardValue < DiscardThreshold)discard;
#endif
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				#ifdef ASE_DEPTH_WRITE_ON
				float DepthValue = 0;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				#ifdef ASE_DEPTH_WRITE_ON
				outputDepth = DepthValue;
				#endif

				return 0;
			}
			ENDHLSL
		}
		
		
		Pass
		{
			Name "FullScreenPass"
			Tags { "LightMode"="LightCutoutResslover" }
			
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off
			ZWrite Off
			ZTest Always
			Offset 0,0
			ColorMask RGBA
			

			HLSLPROGRAM
			
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#define DISCARD_FRAGMENT
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define TREEVERSE_LINEAR_FOG 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 999999
			#define ASE_USING_SAMPLING_MACROS 1

			
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0

			struct Attributes
			{
				float4 vertex : POSITION;
				float4 texcoord0 : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float4 ase_color : COLOR;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord3 : TEXCOORD3;
			};

			struct Varyings
			{
				float4 positionCS	: SV_POSITION;
				float4 texcoord0 : TEXCOORD0;
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
			};
			
			CBUFFER_START(UnityPerMaterial)
			float4 _BaseMove;
			float4 _SplatBase_ST;
			float4 _CutoutMap_ST;
			float4 _Splat3_ST;
			float4 _Splat2_ST;
			float4 _Splat1_ST;
			float4 _FurMap_ST;
			float4 _Baked_Paint_WB4_ST;
			float4 _Splat0_ST;
			float4 _Baked_Paint_W123_ST;
			float4 _WindFreq;
			float4 _WindMove;
			float _MetallicBase;
			float _Metallic0;
			float _Metallic1;
			float _Metallic2;
			float _Metallic3;
			float _SmoothnessBase;
			float _Smoothness1;
			float _AO0;
			float _Smoothness2;
			float _AO2;
			float _NormalIntensity3;
			float _Smoothness3;
			float _AOBase;
			float _AO1;
			float _Smoothness0;
			float _NormalIntensity2;
			float _ParallaxHeightScale1;
			float _NormalIntensity0;
			float _WindIntensity;
			float _WeightUsingMaps;
			float _IsFur0;
			float _IsFur1;
			float _IsFur2;
			float _IsFur3;
			float _NormalIntensity1;
			float _FurEditing;
			float _ParallaxHeightScaleBase;
			float _ParallaxHeightScale0;
			float _AO3;
			float _ParallaxHeightScale2;
			float _ParallaxHeightScale3;
			float _NormalIntensityBase;
			float _AlphaCutout;
			float _LightCutoutResslover_Solo;
			CBUFFER_END
			TEXTURE2D(_Baked_Paint_W123);
			SAMPLER(sampler_Baked_Paint_W123);
			TEXTURE2D(_Splat0);
			SAMPLER(sampler_linear_repeat);
			TEXTURE2D(_FurMap);
			SAMPLER(sampler_FurMap);
			TEXTURE2D(_Splat1);
			TEXTURE2D(_Splat2);
			TEXTURE2D(_Baked_Paint_WB4);
			SAMPLER(sampler_Baked_Paint_WB4);
			TEXTURE2D(_Splat3);
			TEXTURE2D(_CutoutMap);
			SAMPLER(sampler_CutoutMap);


						Varyings vert(Attributes input )
			{
				Varyings output = (Varyings)0;
				float2 break2_g173 = input.texcoord0.xy;
				float2 appendResult4_g173 = (float2(break2_g173.x , ( 1.0 - break2_g173.y )));
				float3 appendResult6_g173 = (float3((appendResult4_g173*2.0 + -1.0) , 0.0));
				
				float grass_currentLayer1047 = input.ase_color.b;
				float vertexToFrag1046 = step( grass_currentLayer1047 , 0.0 );
				output.ase_texcoord2.x = vertexToFrag1046;
				float isfur_1992 = _IsFur0;
				float isfur_2993 = _IsFur1;
				float isfur_3994 = _IsFur2;
				float isfur_4995 = _IsFur3;
				float vertexToFrag1039 = min( ( isfur_1992 + isfur_2993 + isfur_3994 + isfur_4995 ) , 1.0 );
				output.ase_texcoord2.w = vertexToFrag1039;
				
				float grass_curvature645 = input.ase_color.g;
				float hasFur1051 = vertexToFrag1039;
				float lerpResult1054 = lerp( 1.0 , grass_curvature645 , hasFur1051);
				float vertexToFrag1055 = lerpResult1054;
				output.ase_texcoord4.z = vertexToFrag1055;
				
				output.ase_texcoord3 = input.ase_texcoord2;
				output.ase_texcoord2.yz = input.ase_texcoord1.xy;
				output.ase_texcoord4.xy = input.ase_texcoord3.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord4.w = 0;
				float3 vertexValue = appendResult6_g173;
				output.texcoord0 = input.texcoord0;
				output.positionCS = float4(vertexValue, 1.0);
				return output;
			}
			
			half4 frag(Varyings varyings ): SV_Target
			{
				float4 screenCoord = varyings.texcoord0;
				float2 uv0 = varyings.texcoord0.xy;
				float4 screenPosNrm = float4(uv0, 0, 1);

				float vertexToFrag1046 = varyings.ase_texcoord2.x;
				float isFirstLayer1061 = vertexToFrag1046;
				float2 uv2_Baked_Paint_W123 = varyings.ase_texcoord2.yz * _Baked_Paint_W123_ST.xy + _Baked_Paint_W123_ST.zw;
				float4 tex2DNode1676 = SAMPLE_TEXTURE2D( _Baked_Paint_W123, sampler_Baked_Paint_W123, uv2_Baked_Paint_W123 );
				float lerpResult1681 = lerp( varyings.ase_texcoord3.x , tex2DNode1676.r , _WeightUsingMaps);
				float weight_1592 = lerpResult1681;
				float temp_output_1_0_g113 = weight_1592;
				float2 uv_Splat0 = uv0 * _Splat0_ST.xy + _Splat0_ST.zw;
				float4 tex2DNode514 = SAMPLE_TEXTURE2D( _Splat0, sampler_linear_repeat, uv_Splat0 );
				float map_height_1527 = tex2DNode514.a;
				float temp_output_6_0_g113 = ( 1.0 - map_height_1527 );
				float lerpResult7_g113 = lerp( temp_output_1_0_g113 , ( max( temp_output_1_0_g113 , temp_output_6_0_g113 ) - temp_output_6_0_g113 ) , 0.95);
				float height_compare_1602 = lerpResult7_g113;
				float isfur_1992 = _IsFur0;
				float2 uv_FurMap = uv0 * _FurMap_ST.xy + _FurMap_ST.zw;
				float4 tex2DNode1130 = SAMPLE_TEXTURE2D( _FurMap, sampler_FurMap, uv_FurMap );
				float lerpResult1682 = lerp( varyings.ase_texcoord3.y , tex2DNode1676.g , _WeightUsingMaps);
				float weight_2593 = lerpResult1682;
				float temp_output_1_0_g112 = weight_2593;
				float2 uv_Splat1 = uv0 * _Splat1_ST.xy + _Splat1_ST.zw;
				float4 tex2DNode516 = SAMPLE_TEXTURE2D( _Splat1, sampler_linear_repeat, uv_Splat1 );
				float map_height_2528 = tex2DNode516.a;
				float temp_output_6_0_g112 = ( 1.0 - map_height_2528 );
				float lerpResult7_g112 = lerp( temp_output_1_0_g112 , ( max( temp_output_1_0_g112 , temp_output_6_0_g112 ) - temp_output_6_0_g112 ) , 0.95);
				float height_compare_2588 = lerpResult7_g112;
				float isfur_2993 = _IsFur1;
				float lerpResult1683 = lerp( varyings.ase_texcoord3.z , tex2DNode1676.b , _WeightUsingMaps);
				float weight_3594 = lerpResult1683;
				float temp_output_1_0_g114 = weight_3594;
				float2 uv_Splat2 = uv0 * _Splat2_ST.xy + _Splat2_ST.zw;
				float4 tex2DNode517 = SAMPLE_TEXTURE2D( _Splat2, sampler_linear_repeat, uv_Splat2 );
				float map_height_3529 = tex2DNode517.a;
				float temp_output_6_0_g114 = ( 1.0 - map_height_3529 );
				float lerpResult7_g114 = lerp( temp_output_1_0_g114 , ( max( temp_output_1_0_g114 , temp_output_6_0_g114 ) - temp_output_6_0_g114 ) , 0.95);
				float height_compare_3609 = lerpResult7_g114;
				float isfur_3994 = _IsFur2;
				float2 uv2_Baked_Paint_WB4 = varyings.ase_texcoord2.yz * _Baked_Paint_WB4_ST.xy + _Baked_Paint_WB4_ST.zw;
				float4 tex2DNode1677 = SAMPLE_TEXTURE2D( _Baked_Paint_WB4, sampler_Baked_Paint_WB4, uv2_Baked_Paint_WB4 );
				float lerpResult1684 = lerp( varyings.ase_texcoord3.w , tex2DNode1677.g , _WeightUsingMaps);
				float weight_4595 = lerpResult1684;
				float temp_output_1_0_g111 = weight_4595;
				float2 uv_Splat3 = uv0 * _Splat3_ST.xy + _Splat3_ST.zw;
				float4 tex2DNode518 = SAMPLE_TEXTURE2D( _Splat3, sampler_linear_repeat, uv_Splat3 );
				float map_height_4530 = tex2DNode518.a;
				float temp_output_6_0_g111 = ( 1.0 - map_height_4530 );
				float lerpResult7_g111 = lerp( temp_output_1_0_g111 , ( max( temp_output_1_0_g111 , temp_output_6_0_g111 ) - temp_output_6_0_g111 ) , 0.95);
				float height_compare_4613 = lerpResult7_g111;
				float isfur_4995 = _IsFur3;
				float vertexToFrag1039 = varyings.ase_texcoord2.w;
				float hasFur1051 = vertexToFrag1039;
				float lerpResult1056 = lerp( isFirstLayer1061 , max( max( ( height_compare_1602 * isfur_1992 * tex2DNode1130.r ) , ( height_compare_2588 * isfur_2993 * tex2DNode1130.r ) ) , max( ( height_compare_3609 * isfur_3994 * tex2DNode1130.r ) , ( height_compare_4613 * isfur_4995 * tex2DNode1130.r ) ) ) , hasFur1051);
				float Out_DiscardMask1036 = lerpResult1056;
				float2 uv_CutoutMap = uv0 * _CutoutMap_ST.xy + _CutoutMap_ST.zw;
				float temp_output_1119_0 = ( SAMPLE_TEXTURE2D( _CutoutMap, sampler_CutoutMap, uv_CutoutMap ).a + 0.002 );
				float lerpResult1093 = lerp( min( Out_DiscardMask1036 , ( 1.0 - varyings.ase_texcoord4.xy.x ) ) , ( 1.0 - ( ( varyings.ase_texcoord4.xy.x * temp_output_1119_0 ) + ( 1.0 - temp_output_1119_0 ) ) ) , isFirstLayer1061);
				float lerpResult1124 = lerp( 0.0 , lerpResult1093 , _LightCutoutResslover_Solo);
				
				float vertexToFrag1055 = varyings.ase_texcoord4.z;
				float lerpResult1094 = lerp( ( _AlphaCutout * vertexToFrag1055 ) , 0.001 , isFirstLayer1061);
				float lerpResult1126 = lerp( 1.0 , lerpResult1094 , _LightCutoutResslover_Solo);
				
				float4 appendResult1125 = (float4(1.0 , 1.0 , 1.0 , 1.0));
				
#ifdef DISCARD_FRAGMENT
				float DiscardValue = lerpResult1124;
				float DiscardThreshold = lerpResult1126;

				if(DiscardValue < DiscardThreshold)discard;
#endif
				half4 color = appendResult1125;
				return color;
			}
			ENDHLSL
			
		}
		
	}
	
	//CustomEditorForRenderPipeline "CustomDrawersShaderEditor" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
	CustomEditor "Treeverse.Shader.Editor.ShaderGUI.HeightBlend"
	Fallback "Hidden/InternalErrorShader"
	
}/*ASEBEGIN
Version=18935
2560;307;1706.667;908.3334;5776.606;5498.732;3.277701;True;False
Node;AmplifyShaderEditor.CommentaryNode;984;-3403.606,-4992;Inherit;False;1744.113;1269.349;Prepare Valibale;34;1427;1677;1148;1147;1676;639;1678;586;519;1426;587;1616;637;1618;638;1617;993;995;994;992;594;595;986;985;593;592;987;988;576;1679;1681;1682;1683;1684;Prepare Valibale;0.5235849,0.9644278,1,1;0;0
Node;AmplifyShaderEditor.SamplerStateNode;519;-2944,-4096;Inherit;False;0;0;0;1;-1;None;1;0;SAMPLER2D;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.CommentaryNode;540;-4912,-3504;Inherit;False;1748.812;2573.133;Albedo;51;1350;1643;1642;1641;1637;1635;1636;1640;1639;1631;1629;1630;1624;1346;1348;1627;1626;1625;1620;1619;1622;1334;568;1326;534;538;530;518;504;533;537;529;517;503;532;536;528;516;502;531;535;527;514;501;1623;565;563;564;569;578;1645;Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;576;-2689.492,-4224;Inherit;False;repeatSampler;-1;True;1;0;SAMPLERSTATE;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.GetLocalVarNode;578;-4864,-3456;Inherit;False;576;repeatSampler;1;0;OBJECT;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.TexturePropertyNode;501;-4608,-2944;Inherit;True;Property;_Splat0;Albedo 1;2;0;Create;False;0;0;0;True;0;False;764331310c5ba434d8e1719eb44ac696;7f53712be0b5cb64fb09def11d27cfe6;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;504;-4608,-1408;Inherit;True;Property;_Splat3;Albedo 4;8;0;Create;False;0;0;0;True;0;False;954e46e16660dd54f8096593cb37b2a3;40b136dbd9e5fe1428611cb5cd6aa84d;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;502;-4608,-2432;Inherit;True;Property;_Splat1;Albedo 2;4;0;Create;False;0;0;0;True;0;False;a601e40aea98a0748911eabddadf1787;dfda1a35413514546b72971a582fdafc;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;1678;-3328,-3840;Inherit;False;Property;_WeightUsingMaps;WeightUsingMaps;56;1;[Toggle];Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;639;-3328,-4352;Inherit;False;2;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;503;-4608,-1920;Inherit;True;Property;_Splat2;Albedo 3;6;0;Create;False;0;0;0;True;0;False;b7115849e71d5294da137726ce5a8a08;0e00d2befab619144b27df7be2d9261d;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;1677;-3328,-4608;Inherit;True;Property;_Baked_Paint_WB4;Baked_Paint_WB4;55;0;Create;False;0;0;0;False;0;False;-1;None;None;True;1;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1676;-3328,-4096;Inherit;True;Property;_Baked_Paint_W123;Baked_Paint_W123;54;0;Create;False;0;0;0;False;0;False;-1;None;None;True;1;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;518;-4352,-1408;Inherit;True;Property;_TextureSample3;Texture Sample 3;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;516;-4352,-2432;Inherit;True;Property;_TextureSample1;Texture Sample 1;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;1683;-2944,-4480;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1684;-2944,-4352;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;517;-4352,-1920;Inherit;True;Property;_TextureSample2;Texture Sample 2;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;514;-4352,-2944;Inherit;True;Property;_TextureSample0;Texture Sample 0;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;1682;-2944,-4608;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1681;-2944,-4736;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;595;-2689.492,-4352;Inherit;False;weight_4;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;985;-2433.492,-4864;Inherit;False;Property;_IsFur0;IsFur;3;1;[Toggle];Create;False;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;987;-2433.492,-4608;Inherit;False;Property;_IsFur2;IsFur;7;1;[Toggle];Create;False;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;986;-2433.492,-4736;Inherit;False;Property;_IsFur1;IsFur;5;1;[Toggle];Create;False;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;593;-2689.492,-4608;Inherit;False;weight_2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;594;-2689.492,-4480;Inherit;False;weight_3;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;592;-2689.492,-4736;Inherit;False;weight_1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;527;-3456,-2816;Inherit;False;map_height_1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;529;-3456,-1792;Inherit;False;map_height_3;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;646;-6832,-3504;Inherit;False;914.8;510;Grass Layer;7;640;641;642;643;645;644;1047;Grass Layer;0.6584597,1,0.06981128,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;625;-3104,-3504;Inherit;False;1615.178;1420.132;Height Blend;20;1441;1440;1563;1443;602;613;588;609;1560;1562;1564;1561;601;1313;1244;1312;1324;1433;1323;1243;Height Blend;0,0,0,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;988;-2433.492,-4480;Inherit;False;Property;_IsFur3;IsFur;9;1;[Toggle];Create;False;0;0;0;True;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;528;-3456,-2304;Inherit;False;map_height_2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;530;-3456,-1280;Inherit;False;map_height_4;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;644;-6784,-3200;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;1433;-3008,-3200;Inherit;False;592;weight_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;992;-2177.492,-4864;Inherit;False;isfur_1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;1035;846,-4914;Inherit;False;1587.186;1195.225;Discard Mask;29;1036;1056;1046;1034;1052;1022;1051;1033;1045;1026;1032;1039;1020;1042;1029;1027;1041;1030;1024;839;1038;1028;1021;1025;1031;1061;1129;1130;1131;Discard Mask;0.3529937,1,0,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;995;-2177.492,-4480;Inherit;False;isfur_4;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;601;-3008,-3072;Inherit;False;527;map_height_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1313;-3008,-2688;Inherit;False;594;weight_3;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1323;-3008,-2304;Inherit;False;530;map_height_4;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1312;-3008,-2560;Inherit;False;529;map_height_3;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1244;-3008,-2816;Inherit;False;528;map_height_2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1243;-3008,-2944;Inherit;False;593;weight_2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;994;-2177.492,-4608;Inherit;False;isfur_3;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1324;-3008,-2432;Inherit;False;595;weight_4;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;993;-2177.492,-4736;Inherit;False;isfur_2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1031;896,-4800;Inherit;False;992;isfur_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1047;-6144,-3200;Inherit;False;grass_currentLayer;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1025;896,-4544;Inherit;False;994;isfur_3;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1561;-2624,-2944;Inherit;False;Height Compare;-1;;112;ebca28d054964964db0ceb775df491e8;0;2;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1562;-2624,-2688;Inherit;False;Height Compare;-1;;114;ebca28d054964964db0ceb775df491e8;0;2;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1021;896,-4416;Inherit;False;995;isfur_4;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1560;-2624,-2432;Inherit;False;Height Compare;-1;;111;ebca28d054964964db0ceb775df491e8;0;2;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1564;-2624,-3200;Inherit;False;Height Compare;-1;;113;ebca28d054964964db0ceb775df491e8;0;2;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1028;896,-4672;Inherit;False;993;isfur_2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;1131;896,-3964.933;Inherit;True;Property;_FurMap;Fur Map;1;0;Create;False;0;0;0;False;0;False;d0c4443f7a7823140a302dc6652d806c;d0c4443f7a7823140a302dc6652d806c;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleAddOpNode;1038;1280,-4224;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1042;1280,-3840;Inherit;False;1047;grass_currentLayer;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;613;-2304,-2432;Inherit;False;height_compare_4;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;588;-2304,-2944;Inherit;False;height_compare_2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;602;-2304,-3200;Inherit;False;height_compare_1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;609;-2304,-2688;Inherit;False;height_compare_3;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;839;896,-4480;Inherit;False;613;height_compare_4;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1024;896,-4608;Inherit;False;609;height_compare_3;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;1041;1408,-4224;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1130;896,-4224;Inherit;True;Property;_TextureSample19;Texture Sample 19;17;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;1027;896,-4736;Inherit;False;588;height_compare_2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1030;896,-4864;Inherit;False;602;height_compare_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;1045;1536,-3840;Inherit;False;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;1039;1536,-4224;Inherit;False;False;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1032;1280,-4864;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;1046;1792,-3840;Inherit;False;False;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1026;1280,-4608;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1020;1280,-4480;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1029;1280,-4736;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;1033;1408,-4608;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;1022;1408,-4736;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1061;2048,-3840;Inherit;False;isFirstLayer;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1051;1792,-4224;Inherit;False;hasFur;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1052;1792,-4736;Inherit;False;1051;hasFur;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1059;-256,-3328;Inherit;True;Property;_CutoutMap;CutoutMap;51;0;Create;True;0;0;0;True;0;False;-1;e269c7ecdbe4a8f439d354de06ab7199;e269c7ecdbe4a8f439d354de06ab7199;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;1129;1664,-4864;Inherit;False;1061;isFirstLayer;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;1034;1536,-4736;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;645;-6144,-3328;Inherit;False;grass_curvature;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;1069;-256,-3072;Inherit;False;3;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;831;-256,-2432;Inherit;False;645;grass_curvature;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1119;128,-3328;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.002;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1053;-256,-2304;Inherit;False;1051;hasFur;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1056;1920,-4864;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1054;256,-2560;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1036;2176,-4864;Inherit;False;Out_DiscardMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1112;384,-3328;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1113;384,-3200;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1111;512,-3328;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1037;512,-3584;Inherit;False;1036;Out_DiscardMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;1055;512,-2560;Inherit;False;False;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;833;256,-2688;Inherit;False;Property;_AlphaCutout;Fur Cutout;50;0;Create;False;0;0;0;True;0;False;1;0.5;0.01;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1135;303.8947,-3047.489;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1071;254,-2814;Inherit;False;1061;isFirstLayer;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;1134;680,-3408;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;830;768,-2688;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1114;640,-3201.046;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;754;-4786,-818;Inherit;False;1471.25;2334.76;Normal;31;750;749;756;751;710;698;753;719;752;690;718;716;693;717;706;697;702;699;692;691;715;709;760;759;758;757;1647;1648;1649;1650;1651;Normal;0,0.5843138,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;928;974,-818;Inherit;False;1066.435;1972.128;Blend Smoothness;21;915;908;920;916;907;925;918;911;926;919;917;906;910;904;913;912;922;927;921;923;1587;Blend Smoothness;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;1094;896,-2816;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0.001;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;953;2126,-818;Inherit;False;1058.785;1954.905;Blend AO;31;934;951;957;961;960;939;948;946;950;945;959;933;947;955;967;940;958;968;962;936;944;964;949;970;965;966;952;963;969;943;1591;Blend AO;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;499;1280,-2560;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;1121;768,-3072;Inherit;False;Property;_LightCutoutResslover_Solo;_LightCutoutResslover_Solo;52;1;[Toggle];Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1093;896,-3200;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;792;-178,-818;Inherit;False;1096.009;1982.971;Metallic;21;1573;783;902;787;899;785;778;898;903;900;789;780;779;781;897;901;896;791;790;894;895;Blend Metallic;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;883;-3120,-816;Inherit;False;1456.777;2086;Metallic;31;892;893;891;890;889;888;887;886;879;885;884;867;846;864;855;863;854;851;860;881;871;876;874;869;857;844;1652;1653;1654;1655;1656;Metallic;0.6745283,1,0.8973428,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;635;-1327.529,-3506;Inherit;False;1038.321;1988.506;Comment;11;634;541;1213;626;632;629;630;633;543;590;1444;Blend Albedo;1,0.5230491,0.3811321,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;776;-1202,-818;Inherit;False;923.4272;2066.094;Blend Normal;11;771;773;770;769;1571;762;763;766;765;775;764;Blend Normal;0,0.2901961,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;720;-2994,-1843;Inherit;False;977.3999;732.4;Parallax Scale;20;1657;723;722;724;725;721;567;552;549;553;554;1658;1659;1660;1661;1662;1663;1664;1665;1666;Parallax Scale;0.5471698,0.5471698,0.5471698,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;689;-6848,-2880;Inherit;False;1454.513;2037.335;Grass Move;42;686;685;684;682;677;674;675;676;683;678;680;681;659;666;672;671;661;662;663;664;665;660;667;668;669;670;679;673;652;651;650;649;648;647;654;653;657;658;655;656;1083;1091;Grass Move;0.6588235,1,0.07058824,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;912;1280,384;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;757;-4736,0;Inherit;False;Property;_NormalIntensity0;Normal Scale;17;0;Create;False;0;0;0;True;0;False;1;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1126;1104,-3072;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;740;-5120,-2304;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;763;-1152,-384;Inherit;True;750;map_normal_1;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;668;-6016,-2176;Inherit;False;windMove;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;773;-1152,1024;Inherit;False;613;height_compare_4;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;916;1280,768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;886;-1920,-256;Inherit;False;map_smoothness_1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;743;-5120,-1792;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;666;-6400,-2560;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexToFragmentNode;1663;-2560,-1664;Inherit;False;False;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;643;-6144,-3072;Inherit;False;grass_furLayerNum;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;747;-4992,-1280;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;775;-512,0;Inherit;False;Out_Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;699;-4480,384;Inherit;True;Property;_Normal2;Normal 3;28;3;[NoScaleOffset];[Normal];[SingleLineTexture];Create;False;0;0;0;True;0;False;a9836387f720c374f9e21e1a4672f7c6;a9836387f720c374f9e21e1a4672f7c6;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;1648;-4736,-128;Inherit;False;1625;parallax_uv_1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;921;1024,-640;Inherit;False;884;map_smoothness_base;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;500;1536,-2560;Inherit;False;uv0;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;629;-1280,-2304;Inherit;True;537;map_color_3;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;541;-1280,-3072;Inherit;True;535;map_color_1;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;690;-4736,-768;Inherit;False;576;repeatSampler;1;0;OBJECT;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.OneMinusNode;958;2432,-640;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1350;-4864,-1152;Inherit;False;725;scale_3;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;860;-2560,768;Inherit;True;Property;_TextureSample12;Texture Sample 12;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;660;-6400,-2048;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;949;2176,512;Inherit;False;891;map_ao_3;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;724;-2304,-1408;Inherit;False;scale_2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;871;-1920,384;Inherit;False;map_metallic_3;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;1658;-2560,-1792;Inherit;False;False;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;682;-6400,-1792;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;543;-1280,-2688;Inherit;True;536;map_color_2;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;890;-1920,512;Inherit;False;map_smoothness_3;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;677;-6144,-1408;Inherit;False;shellDir;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;753;-3584,768;Inherit;False;map_normal_4;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;779;-128,0;Inherit;False;Property;_Metallic1;Metallic 2;26;0;Create;False;1;______Height Scale______;0;0;True;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;769;-1152,384;Inherit;True;752;map_normal_3;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1652;-3072,-512;Inherit;False;1622;parallax_uv_b;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldNormalVector;680;-6144,-1024;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMaxOpNode;1671;283,-1345;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;658;-6528,-2048;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;650;-6400,-2432;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;648;-6528,-2432;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;719;-4480,-768;Inherit;True;Property;_NormalBase;Normal Base;10;4;[Header];[NoScaleOffset];[Normal];[SingleLineTexture];Create;False;1;______Physicals______;0;0;True;1;Space(10);False;43b17829d3888c641a08f48bb5f788d1;43b17829d3888c641a08f48bb5f788d1;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleAddOpNode;967;2560,384;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1625;-4224,-2688;Inherit;False;parallax_uv_1;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;642;-6144,-3440;Inherit;False;grass_heightOffset;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;863;-2560,-768;Inherit;True;Property;_TextureSample13;Texture Sample 13;11;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;1441;-2304,-3456;Inherit;False;height_compare_b;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;927;1792,0;Inherit;False;Out_Smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;664;-6784,-1920;Inherit;False;659;moveFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1661;-2688,-1408;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1124;1104,-3200;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;752;-3584,384;Inherit;False;map_normal_3;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1674;640,-1408;Inherit;False;1061;isFirstLayer;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1649;-4736,256;Inherit;False;1629;parallax_uv_2;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;709;-4224,384;Inherit;True;Property;_TextureSample17;Texture Sample 17;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;778;-128,-384;Inherit;False;Property;_Metallic0;Metallic 1;21;0;Create;False;1;______Height Scale______;0;0;True;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;854;-2560,-384;Inherit;True;Property;_TextureSample11;Texture Sample 11;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;733;-5376,-3328;Inherit;False;500;uv0;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;874;-1920,-384;Inherit;False;map_metallic_1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;681;-6016,-1536;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;846;-2560,0;Inherit;True;Property;_TextureSample9;Texture Sample 9;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;691;-3840,-768;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;963;2432,128;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;876;-2816,-768;Inherit;True;Property;_MetallicGlossBase;Metallic Base;12;2;[NoScaleOffset];[SingleLineTexture];Create;False;1;______Normal______;0;0;True;0;False;None;ccc4392cd69508a439f1e87793dc1861;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;626;-1280,-2432;Inherit;False;588;height_compare_2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;879;-1920,0;Inherit;False;map_metallic_2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;671;-6784,-1248;Inherit;False;668;windMove;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;1146;1614,-3250;Inherit;False;313;238;Comment;1;1120;This Pass for fix Lightmap Cutout problem，so only using in EditorMode.;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;706;-4480,768;Inherit;True;Property;_Normal3;Normal 4;34;3;[NoScaleOffset];[Normal];[SingleLineTexture];Create;False;0;0;0;True;0;False;572d4920073265042a0dc9cac25b9f24;572d4920073265042a0dc9cac25b9f24;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;549;-2944,-1665;Inherit;False;Property;_ParallaxHeightScale0;Scale 0;41;0;Create;False;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;940;2176,-640;Inherit;False;885;map_ao_base;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;702;-4224,0;Inherit;True;Property;_TextureSample16;Texture Sample 16;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;736;-4992,-3200;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VertexToFragmentNode;1617;-2177.492,-4096;Inherit;False;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1620;-4736,-3072;Inherit;False;1618;ts_viewDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;718;-3840,768;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;955;2560,-768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;749;-3584,-768;Inherit;False;map_normal_base;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;944;2176,-384;Inherit;False;Property;_AO0;AO 1;19;0;Create;False;1;______Height Scale______;0;0;True;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;661;-6272,-2048;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;672;-6528,-1408;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1675;256,-1536;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;759;-4736,768;Inherit;False;Property;_NormalIntensity2;Normal Scale;29;0;Create;False;0;0;0;True;0;False;1;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;1125;1280,-2944;Inherit;False;FLOAT4;4;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;857;-3072,-768;Inherit;False;576;repeatSampler;1;0;OBJECT;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.TextureTransformNode;745;-5376,-1792;Inherit;False;503;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;722;-2304,-1664;Inherit;False;scale_0;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1673;896,-1536;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;888;-1920,128;Inherit;False;map_smoothness_2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;641;-6400,-3456;Inherit;False;False;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;651;-6272,-2432;Inherit;False;windAngle;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;1122;1400.265,-2753.803;Inherit;False;Transform Texcoord to View;-1;;173;41bf6756ce741a44e90104a5a300b690;0;1;1;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1657;-2688,-1792;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1444;-1280,-3200;Inherit;False;1441;height_compare_b;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureTransformNode;742;-5376,-2304;Inherit;False;502;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.RangedFloatNode;567;-2944,-1793;Inherit;False;Property;_ParallaxHeightScaleBase;Scale Base;40;1;[Header];Create;False;1;______Height Scale______;0;0;True;1;Space(10);False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;649;-6784,-2272;Inherit;False;1;0;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;791;640,0;Inherit;False;Out_Metallic;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1695;-894.9976,-2944;Inherit;False;Layer Bend;-1;;175;9e870c3f57de6eb4ba1b273324827f1f;21,79,0,65,0,67,0,70,0,71,0,73,0,63,0,75,0,61,0,35,1,17,1,27,1,36,1,37,1,28,1,38,0,29,0,30,0,39,0,40,0,31,0;24;1;FLOAT3;0,0,0;False;62;FLOAT;0;False;2;FLOAT;0;False;64;FLOAT;0;False;4;FLOAT3;0,0,0;False;3;FLOAT;0;False;66;FLOAT;0;False;5;FLOAT3;0,0,0;False;6;FLOAT;0;False;68;FLOAT;0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT3;0,0,0;False;69;FLOAT;0;False;10;FLOAT;0;False;11;FLOAT3;0,0,0;False;72;FLOAT;0;False;12;FLOAT;0;False;13;FLOAT3;0,0,0;False;74;FLOAT;0;False;14;FLOAT;0;False;15;FLOAT3;0,0,0;False;76;FLOAT;0;False;16;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ParallaxMappingNode;1630;-4480,-2176;Inherit;False;Normal;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;746;-5120,-1280;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1622;-4224,-3200;Inherit;False;parallax_uv_b;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;721;-2304,-1792;Inherit;False;scale_b;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1696;1536,0;Inherit;False;Layer Bend;-1;;174;9e870c3f57de6eb4ba1b273324827f1f;21,79,1,65,1,67,1,70,1,71,1,73,1,63,1,75,1,61,1,35,1,17,1,27,1,36,1,37,1,28,1,38,0,29,0,30,0,39,0,40,0,31,0;24;1;FLOAT3;0,0,0;False;62;FLOAT;0;False;2;FLOAT;0;False;64;FLOAT;0;False;4;FLOAT3;0,0,0;False;3;FLOAT;0;False;66;FLOAT;0;False;5;FLOAT3;0,0,0;False;6;FLOAT;0;False;68;FLOAT;0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT3;0,0,0;False;69;FLOAT;0;False;10;FLOAT;0;False;11;FLOAT3;0,0,0;False;72;FLOAT;0;False;12;FLOAT;0;False;13;FLOAT3;0,0,0;False;74;FLOAT;0;False;14;FLOAT;0;False;15;FLOAT3;0,0,0;False;76;FLOAT;0;False;16;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;734;-5120,-3200;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;656;-6528,-2688;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1651;-4736,1024;Inherit;False;1641;parallax_uv_4;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;964;2560,0;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;893;-1920,1024;Inherit;False;map_ao_4;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;787;0,640;Inherit;False;609;height_compare_3;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1660;-2688,-1536;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1647;-4736,-512;Inherit;False;1622;parallax_uv_b;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;1136;768,-2560;Inherit;False;Property;_FurEditing;FurEditing;53;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1075;1904.985,-2215.764;Inherit;False;Constant;_Float0;Float 0;51;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;751;-3584,0;Inherit;False;map_normal_2;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;552;-2944,-1537;Inherit;False;Property;_ParallaxHeightScale1;Scale 1;42;0;Create;False;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;662;-6400,-2176;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1443;-3008,-3456;Inherit;False;1426;weight_b;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureTransformNode;737;-5376,-2816;Inherit;False;501;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1659;-2688,-1664;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1083;-6528,-1536;Inherit;False;1061;isFirstLayer;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;885;-1920,-512;Inherit;False;map_ao_base;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;892;-1920,896;Inherit;False;map_smoothness_4;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;739;-4992,-2816;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;665;-6144,-2176;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;969;2432,896;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;770;-1152,640;Inherit;False;609;height_compare_3;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;698;-4224,-768;Inherit;True;Property;_TextureSample15;Texture Sample 15;11;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalizeNode;673;-6400,-1408;Inherit;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;684;-5888,-1792;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;657;-6656,-1664;Inherit;False;651;windAngle;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;936;2304,640;Inherit;False;609;height_compare_3;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;569;-4608,-3456;Inherit;True;Property;_SplatBase;Albedo Base;0;1;[Header];Create;False;1;______Albedo______;0;0;True;1;Space(10);False;164732ecebdde9b47aa1687f107ed779;eb382f5f6cc97da44bc76165e6506138;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleAddOpNode;961;2560,-384;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;685;-5632,-1920;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;553;-2944,-1409;Inherit;False;Property;_ParallaxHeightScale2;Scale 2;43;0;Create;False;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;952;2944,0;Inherit;False;Out_AO;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1091;-6272,-1536;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;663;-6528,-2560;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureTransformNode;748;-5376,-1280;Inherit;False;504;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.SamplerNode;1645;-3968,-1408;Inherit;True;Property;_TextureSample20;Texture Sample 20;54;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;894;-128,-640;Inherit;False;867;map_metallic_base;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;741;-4992,-2304;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;638;-2433.492,-4352;Inherit;False;587;clampSampler;1;0;OBJECT;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;968;2432,768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;634;-512,-2944;Inherit;False;Out_Albedo;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;790;-128,-768;Inherit;False;Property;_MetallicBase;Metallic Base;14;0;Create;False;1;______Height Scale______;0;0;True;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;901;-128,128;Inherit;False;879;map_metallic_2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;533;-3584,-1920;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;1624;-3968,-2944;Inherit;True;Property;_TextureSample6;Texture Sample 6;54;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;910;1152,256;Inherit;False;588;height_compare_2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;710;-4224,768;Inherit;True;Property;_TextureSample18;Texture Sample 18;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;669;-6784,-1376;Inherit;False;667;move;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;777;896,-2304;Inherit;False;775;Out_Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;632;-1280,-1920;Inherit;True;538;map_color_4;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;959;2432,-384;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;715;-3840,-384;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;889;-1920,256;Inherit;False;map_ao_2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;738;-5120,-2816;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;1326;-4864,-3200;Inherit;False;721;scale_b;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;723;-2304,-1536;Inherit;False;scale_1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;896;128,-384;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;688;896,-1792;Inherit;False;686;Out_Position;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;919;1024,512;Inherit;False;890;map_smoothness_3;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;678;-6144,-1152;Inherit;False;642;grass_heightOffset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;971;896,-1920;Inherit;False;952;Out_AO;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;537;-3456,-1920;Inherit;False;map_color_3;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;750;-3584,-384;Inherit;False;map_normal_1;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;758;-4736,384;Inherit;False;Property;_NormalIntensity1;Normal Scale;23;0;Create;False;0;0;0;True;0;False;1;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;945;2176,0;Inherit;False;Property;_AO1;AO 2;27;0;Create;False;1;______Height Scale______;0;0;True;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;908;1024,384;Inherit;False;Property;_Smoothness2;Smoothness 3;32;0;Create;False;1;______Height Scale______;0;0;True;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1668;0,-1408;Inherit;False;613;height_compare_4;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1627;-4736,-2560;Inherit;False;1618;ts_viewDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;655;-6784,-1792;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;653;-6784,-2816;Inherit;False;642;grass_heightOffset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;960;2432,-256;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;654;-6784,-2688;Inherit;False;Property;_BaseMove;Base Move;46;1;[Header];Create;False;1;______Fur Layer Winding______;0;0;False;1;Space(10);False;-0.19,0,0,0.2;-0.19,0,0,0.2;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerStateNode;586;-2944,-3968;Inherit;False;1;1;1;1;-1;None;1;0;SAMPLER2D;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.GetLocalVarNode;1650;-4736,640;Inherit;False;1636;parallax_uv_3;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;554;-2944,-1281;Inherit;False;Property;_ParallaxHeightScale3;Scale 3;44;0;Create;False;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1629;-4224,-2176;Inherit;False;parallax_uv_2;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;855;-2816,768;Inherit;True;Property;_MetallicGloss3;Metallic 4;36;2;[NoScaleOffset];[SingleLineTexture];Create;False;0;0;0;True;0;False;None;0397e8e04c772e84d86d4a6d7006a325;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1662;-2688,-1280;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1440;-3008,-3328;Inherit;False;563;map_height_base;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;939;2304,1024;Inherit;False;613;height_compare_4;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;925;1024,-384;Inherit;False;Property;_Smoothness0;Smoothness 1;20;0;Create;False;1;______Height Scale______;0;0;True;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;950;2176,128;Inherit;False;889;map_ao_2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;756;-4736,-384;Inherit;False;Property;_NormalIntensityBase;Normal Scale;11;0;Create;False;0;0;0;True;0;False;1;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;907;1280,0;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;867;-1920,-768;Inherit;False;map_metallic_base;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1679;-2944,-4864;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;766;-1152,256;Inherit;False;588;height_compare_2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;647;-6784,-2432;Inherit;False;Property;_WindFreq;Wind Freq;47;0;Create;False;0;0;0;False;0;False;1.2,0.4,1,1;1.2,0.4,1,1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;1591;2304,-512;Inherit;False;1441;height_compare_b;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;966;2432,512;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;899;128,384;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;933;2304,256;Inherit;False;588;height_compare_2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ParallaxMappingNode;1619;-4480,-3200;Inherit;False;Normal;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;1654;-3072,256;Inherit;False;1629;parallax_uv_2;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;917;1152,1024;Inherit;False;613;height_compare_4;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;717;-3840,384;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;951;2176,-256;Inherit;False;887;map_ao_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1643;-4736,-1024;Inherit;False;1618;ts_viewDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;538;-3456,-1408;Inherit;False;map_color_4;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;692;-4481,-384;Inherit;True;Property;_Normal0;Normal 1;16;3;[NoScaleOffset];[Normal];[SingleLineTexture];Create;False;0;0;0;True;0;False;fe7e3a61bdd0cb643a933ead35f07cc0;fe7e3a61bdd0cb643a933ead35f07cc0;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;781;-128,768;Inherit;False;Property;_Metallic3;Metallic 4;39;0;Create;False;1;______Height Scale______;0;0;True;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;780;-128,384;Inherit;False;Property;_Metallic2;Metallic 3;33;0;Create;False;1;______Height Scale______;0;0;True;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;532;-3584,-2432;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1573;0,-512;Inherit;False;1441;height_compare_b;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1655;-3072,640;Inherit;False;1636;parallax_uv_3;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;915;1024,768;Inherit;False;Property;_Smoothness3;Smoothness 4;37;0;Create;False;1;______Height Scale______;0;0;True;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;887;-1920,-128;Inherit;False;map_ao_1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;744;-4992,-1792;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;1587;1152,-512;Inherit;False;1441;height_compare_b;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1213;-1280,-2816;Inherit;False;602;height_compare_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;676;-6656,-1024;Inherit;False;642;grass_heightOffset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;534;-3584,-1408;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;1141;1088,-2688;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;697;-4480,0;Inherit;True;Property;_Normal1;Normal 2;22;3;[NoScaleOffset];[Normal];[SingleLineTexture];Create;False;0;0;0;True;0;False;b6c1646974877914dabd9204db83a317;b6c1646974877914dabd9204db83a317;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;1618;-1921.492,-4096;Inherit;False;ts_viewDir;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;906;1024,0;Inherit;False;Property;_Smoothness1;Smoothness 2;25;0;Create;False;1;______Height Scale______;0;0;True;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;762;-1152,-128;Inherit;False;602;height_compare_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;957;2432,-768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;965;2432,384;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;970;2560,768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;564;-3456,-3456;Inherit;False;map_color_base;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;920;1024,-256;Inherit;False;886;map_smoothness_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;897;-128,-256;Inherit;False;874;map_metallic_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;884;-1920,-640;Inherit;False;map_smoothness_base;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;565;-3584,-3456;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ParallaxMappingNode;1642;-4480,-1152;Inherit;False;Normal;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;1563;-2624,-3456;Inherit;False;Height Compare;-1;;157;ebca28d054964964db0ceb775df491e8;0;2;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;785;0,256;Inherit;False;588;height_compare_2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;637;-2177.492,-4352;Inherit;True;Property;_HeightBlendDefaultGradient;HeightBlendDefaultGradient;45;4;[HideInInspector];[HDR];[NoScaleOffset];[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;922;1024,-768;Inherit;False;Property;_SmoothnessBase;Smoothness Base;13;0;Create;False;1;______Height Scale______;0;0;True;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;891;-1920,640;Inherit;False;map_ao_3;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1623;-3968,-3456;Inherit;True;Property;_TextureSample5;Texture Sample 5;54;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;652;-6784,-2176;Inherit;False;Property;_WindMove;Wind Move;48;0;Create;False;0;0;0;False;0;False;0.8,0.4,0.4,1;0.8,0.4,0.4,1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;1348;-4864,-1664;Inherit;False;724;scale_2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;918;1024,128;Inherit;False;888;map_smoothness_2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;902;-128,512;Inherit;False;871;map_metallic_3;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1686;675.3445,-2128.897;Inherit;False;-1;;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1631;-4736,-2048;Inherit;False;1618;ts_viewDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;563;-3456,-3328;Inherit;False;map_height_base;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ParallaxMappingNode;1635;-4480,-1664;Inherit;False;Normal;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;590;-1280,-3456;Inherit;True;564;map_color_base;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;686;-5632,-2304;Inherit;False;Out_Position;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1636;-4224,-1664;Inherit;False;parallax_uv_3;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;693;-4224,-384;Inherit;True;Property;_TextureSample14;Texture Sample 14;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;946;2176,384;Inherit;False;Property;_AO2;AO 3;31;0;Create;False;1;______Height Scale______;0;0;True;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;771;-1152,768;Inherit;True;753;map_normal_4;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;904;1280,-384;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;716;-3840,0;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;934;2304,-128;Inherit;False;602;height_compare_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;923;1280,-768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;1665;-2560,-1408;Inherit;False;False;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;640;-6656,-3456;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;667;-6272,-2560;Inherit;False;move;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ParallaxMappingNode;1626;-4480,-2688;Inherit;False;Normal;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;793;896,-2176;Inherit;False;791;Out_Metallic;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;764;-1152,-768;Inherit;True;749;map_normal_base;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1571;-1152,-513;Inherit;False;1441;height_compare_b;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1346;-4864,-2176;Inherit;False;723;scale_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;898;128,0;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;869;-2816,0;Inherit;True;Property;_MetallicGloss1;Metallic 2;24;2;[NoScaleOffset];[SingleLineTexture];Create;False;0;0;0;True;0;False;None;315e63326af98504fb82f3ee392b1325;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;903;-128,896;Inherit;False;881;map_metallic_4;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1334;-4864,-2688;Inherit;False;722;scale_0;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;851;-2560,384;Inherit;True;Property;_TextureSample10;Texture Sample 10;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexToFragmentNode;1664;-2560,-1536;Inherit;False;False;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1641;-4224,-1152;Inherit;False;parallax_uv_4;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;947;2176,768;Inherit;False;Property;_AO3;AO 4;38;0;Create;False;1;______Height Scale______;0;0;True;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;962;2432,0;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;536;-3456,-2432;Inherit;False;map_color_2;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;794;896,-2048;Inherit;False;927;Out_Smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;895;128,-768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1640;-3968,-1920;Inherit;True;Property;_TextureSample8;Texture Sample 8;54;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;765;-1152,0;Inherit;True;751;map_normal_2;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;659;-6272,-2688;Inherit;False;moveFactor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;943;2176,-768;Inherit;False;Property;_AOBase;AO Base;15;0;Create;False;1;______Height Scale______;0;0;True;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;844;-2816,-384;Inherit;True;Property;_MetallicGloss0;Metallic 1;18;2;[NoScaleOffset];[SingleLineTexture];Create;False;0;0;0;True;0;False;None;54437931f28bae748a0c8b197a0c5598;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.OneMinusNode;1672;554,-1563;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1639;-3968,-2432;Inherit;True;Property;_TextureSample7;Texture Sample 7;54;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;679;-6400,-1152;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;9;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;900;128,768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;1427;-3328,-4864;Inherit;False;3;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;535;-3456,-2944;Inherit;False;map_color_1;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;630;-1280,-2048;Inherit;False;609;height_compare_3;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;531;-3584,-2944;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;670;-6784,-1536;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.VertexToFragmentNode;1666;-2560,-1280;Inherit;False;False;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;1616;-2433.492,-4096;Inherit;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;789;0,1024;Inherit;False;613;height_compare_4;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1426;-2689.492,-4864;Inherit;False;weight_b;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;783;0,-128;Inherit;False;602;height_compare_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;881;-1920,768;Inherit;False;map_metallic_4;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;913;1152,640;Inherit;False;609;height_compare_3;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;568;-4352,-3456;Inherit;True;Property;_TextureSample4;Texture Sample 4;11;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;926;1024,896;Inherit;False;892;map_smoothness_4;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;725;-2304,-1280;Inherit;False;scale_3;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureTransformNode;731;-5376,-3200;Inherit;False;569;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;587;-2689.492,-4096;Inherit;False;clampSampler;-1;True;1;0;SAMPLERSTATE;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.RangedFloatNode;674;-6784,-1152;Inherit;False;Property;_WindIntensity;Wind Intensity;49;0;Create;True;0;0;0;False;0;False;0.2;0.017;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1147;-2688,-3840;Inherit;False;Constant;_Float1;Float 1;54;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;636;896,-2432;Inherit;False;634;Out_Albedo;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;683;-5888,-1152;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;633;-1280,-1664;Inherit;False;613;height_compare_4;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1667;0,-1536;Inherit;False;609;height_compare_3;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;675;-6272,-1408;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;1,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;1694;-768,0;Inherit;False;Layer Bend;-1;;170;9e870c3f57de6eb4ba1b273324827f1f;21,79,0,65,0,67,0,70,0,71,0,73,0,63,0,75,0,61,0,35,1,17,1,27,1,36,1,37,1,28,1,38,0,29,0,30,0,39,0,40,0,31,0;24;1;FLOAT3;0,0,0;False;62;FLOAT;0;False;2;FLOAT;0;False;64;FLOAT;0;False;4;FLOAT3;0,0,0;False;3;FLOAT;0;False;66;FLOAT;0;False;5;FLOAT3;0,0,0;False;6;FLOAT;0;False;68;FLOAT;0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT3;0,0,0;False;69;FLOAT;0;False;10;FLOAT;0;False;11;FLOAT3;0,0,0;False;72;FLOAT;0;False;12;FLOAT;0;False;13;FLOAT3;0,0,0;False;74;FLOAT;0;False;14;FLOAT;0;False;15;FLOAT3;0,0,0;False;76;FLOAT;0;False;16;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StepOpNode;1670;395,-1561;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1148;-2688,-3968;Inherit;False;Constant;_Float2;Float 2;54;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1656;-3072,1024;Inherit;False;1641;parallax_uv_4;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;1653;-3072,-128;Inherit;False;1625;parallax_uv_1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;911;1152,-128;Inherit;False;602;height_compare_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1693;2688,0;Inherit;False;Layer Bend;-1;;171;9e870c3f57de6eb4ba1b273324827f1f;21,79,1,65,1,67,1,70,1,71,1,73,1,63,1,75,1,61,1,35,1,17,1,27,1,36,1,37,1,28,1,38,0,29,0,30,0,39,0,40,0,31,0;24;1;FLOAT3;0,0,0;False;62;FLOAT;0;False;2;FLOAT;0;False;64;FLOAT;0;False;4;FLOAT3;0,0,0;False;3;FLOAT;0;False;66;FLOAT;0;False;5;FLOAT3;0,0,0;False;6;FLOAT;0;False;68;FLOAT;0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT3;0,0,0;False;69;FLOAT;0;False;10;FLOAT;0;False;11;FLOAT3;0,0,0;False;72;FLOAT;0;False;12;FLOAT;0;False;13;FLOAT3;0,0,0;False;74;FLOAT;0;False;14;FLOAT;0;False;15;FLOAT3;0,0,0;False;76;FLOAT;0;False;16;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1692;384,0;Inherit;False;Layer Bend;-1;;172;9e870c3f57de6eb4ba1b273324827f1f;21,79,1,65,1,67,1,70,1,71,1,73,1,63,1,75,1,61,1,35,1,17,1,27,1,36,1,37,1,28,1,38,0,29,0,30,0,39,0,40,0,31,0;24;1;FLOAT3;0,0,0;False;62;FLOAT;0;False;2;FLOAT;0;False;64;FLOAT;0;False;4;FLOAT3;0,0,0;False;3;FLOAT;0;False;66;FLOAT;0;False;5;FLOAT3;0,0,0;False;6;FLOAT;0;False;68;FLOAT;0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT3;0,0,0;False;69;FLOAT;0;False;10;FLOAT;0;False;11;FLOAT3;0,0,0;False;72;FLOAT;0;False;12;FLOAT;0;False;13;FLOAT3;0,0,0;False;74;FLOAT;0;False;14;FLOAT;0;False;15;FLOAT3;0,0,0;False;76;FLOAT;0;False;16;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1637;-4736,-1536;Inherit;False;1618;ts_viewDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;1669;1152,-1792;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;864;-2816,384;Inherit;True;Property;_MetallicGloss2;Metallic 3;30;2;[NoScaleOffset];[SingleLineTexture];Create;False;0;0;0;True;0;False;None;0b4dfa8f559aa0640932afbdb40de0a8;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;760;-4736,1152;Inherit;False;Property;_NormalIntensity3;Normal Scale;35;0;Create;False;0;0;0;True;0;False;1;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;948;2176,896;Inherit;False;893;map_ao_4;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;507;1024,-2304;Float;False;False;-1;2;ASEMaterialInspector;0;18;New Amplify Shader;9f53fdc6bec2ee94397ba2956dd3cfbc;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;505;1024,-2304;Float;False;False;-1;2;ASEMaterialInspector;0;18;New Amplify Shader;9f53fdc6bec2ee94397ba2956dd3cfbc;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;510;1024,-2304;Float;False;False;-1;2;ASEMaterialInspector;0;18;New Amplify Shader;9f53fdc6bec2ee94397ba2956dd3cfbc;True;DepthNormals;0;5;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=DepthNormals;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;509;1024,-2304;Float;False;False;-1;2;ASEMaterialInspector;0;18;New Amplify Shader;9f53fdc6bec2ee94397ba2956dd3cfbc;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;506;1280,-2304;Half;False;True;-1;2;Treeverse.Shader.Editor.ShaderGUI.HeightBlend;0;18;Treeverse/Static/Environment/HeightBlend;9f53fdc6bec2ee94397ba2956dd3cfbc;True;Forward;0;1;Forward;27;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;4;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;True;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;1;LightMode=UniversalForwardOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;26;Surface;0;0;  Refraction Model;0;0;  Blend;0;0;Two Sided;1;0;Fragment Normal Space,InvertActionOnDeselection;0;0;Cast Shadows;1;637962305935942445;  Use Shadow Threshold;0;0;Receive Shadows;1;637963058810419172;GPU Instancing;1;0;LOD CrossFade;0;637962300968147089;Treeverse Linear Fog;1;637993452533799078;_FinalColorxAlpha;0;0;Meta Pass;0;637961585392981235;Override Baked GI;0;637962304856385472;Extra Pre Pass;0;0;Full Screen Pass;1;637961583272706742;DOTS Instancing;0;0;Write Depth;0;0;  Early Z;0;0;Vertex Position,InvertActionOnDeselection;0;637950176345941761;Debug Display;0;0;Clear Coat;0;0;Discard Fragment;1;637950198810486484;Discard Use Variant;0;0;Push SelfShadow to Main Light;0;0;Emission x ShadowMask;0;0;0;9;False;True;True;True;False;False;False;False;True;False;;True;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;513;1024,-2304;Float;False;False;-1;2;ASEMaterialInspector;0;18;New Amplify Shader;9f53fdc6bec2ee94397ba2956dd3cfbc;True;ScenePickingPass;0;7;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;True;4;d3d11;glcore;gles;gles3;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;508;1024,-2304;Float;False;False;-1;2;ASEMaterialInspector;0;18;New Amplify Shader;9f53fdc6bec2ee94397ba2956dd3cfbc;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1120;1664,-1844;Float;False;False;-1;2;ASEMaterialInspector;0;18;New Amplify Shader;9f53fdc6bec2ee94397ba2956dd3cfbc;True;FullScreenPass;0;8;FullScreenPass;4;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;2;False;-1;True;7;False;-1;True;False;0;False;-1;0;False;-1;True;1;LightMode=LightCutoutResslover;True;2;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;512;1024,-2304;Float;False;False;-1;2;ASEMaterialInspector;0;18;New Amplify Shader;9f53fdc6bec2ee94397ba2956dd3cfbc;True;SceneSelectionPass;0;6;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;True;4;d3d11;glcore;gles;gles3;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;576;0;519;0
WireConnection;518;0;504;0
WireConnection;518;7;578;0
WireConnection;516;0;502;0
WireConnection;516;7;578;0
WireConnection;1683;0;639;3
WireConnection;1683;1;1676;3
WireConnection;1683;2;1678;0
WireConnection;1684;0;639;4
WireConnection;1684;1;1677;2
WireConnection;1684;2;1678;0
WireConnection;517;0;503;0
WireConnection;517;7;578;0
WireConnection;514;0;501;0
WireConnection;514;7;578;0
WireConnection;1682;0;639;2
WireConnection;1682;1;1676;2
WireConnection;1682;2;1678;0
WireConnection;1681;0;639;1
WireConnection;1681;1;1676;1
WireConnection;1681;2;1678;0
WireConnection;595;0;1684;0
WireConnection;593;0;1682;0
WireConnection;594;0;1683;0
WireConnection;592;0;1681;0
WireConnection;527;0;514;4
WireConnection;529;0;517;4
WireConnection;528;0;516;4
WireConnection;530;0;518;4
WireConnection;992;0;985;0
WireConnection;995;0;988;0
WireConnection;994;0;987;0
WireConnection;993;0;986;0
WireConnection;1047;0;644;3
WireConnection;1561;1;1243;0
WireConnection;1561;2;1244;0
WireConnection;1562;1;1313;0
WireConnection;1562;2;1312;0
WireConnection;1560;1;1324;0
WireConnection;1560;2;1323;0
WireConnection;1564;1;1433;0
WireConnection;1564;2;601;0
WireConnection;1038;0;1031;0
WireConnection;1038;1;1028;0
WireConnection;1038;2;1025;0
WireConnection;1038;3;1021;0
WireConnection;613;0;1560;0
WireConnection;588;0;1561;0
WireConnection;602;0;1564;0
WireConnection;609;0;1562;0
WireConnection;1041;0;1038;0
WireConnection;1130;0;1131;0
WireConnection;1130;7;1131;1
WireConnection;1045;0;1042;0
WireConnection;1039;0;1041;0
WireConnection;1032;0;1030;0
WireConnection;1032;1;1031;0
WireConnection;1032;2;1130;1
WireConnection;1046;0;1045;0
WireConnection;1026;0;1024;0
WireConnection;1026;1;1025;0
WireConnection;1026;2;1130;1
WireConnection;1020;0;839;0
WireConnection;1020;1;1021;0
WireConnection;1020;2;1130;1
WireConnection;1029;0;1027;0
WireConnection;1029;1;1028;0
WireConnection;1029;2;1130;1
WireConnection;1033;0;1026;0
WireConnection;1033;1;1020;0
WireConnection;1022;0;1032;0
WireConnection;1022;1;1029;0
WireConnection;1061;0;1046;0
WireConnection;1051;0;1039;0
WireConnection;1034;0;1022;0
WireConnection;1034;1;1033;0
WireConnection;645;0;644;2
WireConnection;1119;0;1059;4
WireConnection;1056;0;1129;0
WireConnection;1056;1;1034;0
WireConnection;1056;2;1052;0
WireConnection;1054;1;831;0
WireConnection;1054;2;1053;0
WireConnection;1036;0;1056;0
WireConnection;1112;0;1069;1
WireConnection;1112;1;1119;0
WireConnection;1113;0;1119;0
WireConnection;1111;0;1112;0
WireConnection;1111;1;1113;0
WireConnection;1055;0;1054;0
WireConnection;1135;0;1069;1
WireConnection;1134;0;1037;0
WireConnection;1134;1;1135;0
WireConnection;830;0;833;0
WireConnection;830;1;1055;0
WireConnection;1114;0;1111;0
WireConnection;1094;0;830;0
WireConnection;1094;2;1071;0
WireConnection;1093;0;1134;0
WireConnection;1093;1;1114;0
WireConnection;1093;2;1071;0
WireConnection;912;0;908;0
WireConnection;912;1;919;0
WireConnection;1126;1;1094;0
WireConnection;1126;2;1121;0
WireConnection;740;0;733;0
WireConnection;740;1;742;0
WireConnection;668;0;665;0
WireConnection;916;0;915;0
WireConnection;916;1;926;0
WireConnection;886;0;854;2
WireConnection;743;0;733;0
WireConnection;743;1;745;0
WireConnection;666;0;656;0
WireConnection;666;1;663;0
WireConnection;1663;0;1659;0
WireConnection;643;0;644;4
WireConnection;747;0;746;0
WireConnection;747;1;748;1
WireConnection;775;0;1694;0
WireConnection;500;0;499;0
WireConnection;958;0;943;0
WireConnection;860;0;855;0
WireConnection;860;1;1656;0
WireConnection;860;7;857;0
WireConnection;660;0;658;0
WireConnection;660;1;657;0
WireConnection;724;0;1665;0
WireConnection;871;0;851;1
WireConnection;1658;0;1657;0
WireConnection;890;0;851;2
WireConnection;677;0;675;0
WireConnection;753;0;718;0
WireConnection;1671;0;1667;0
WireConnection;1671;1;1668;0
WireConnection;658;0;652;4
WireConnection;658;1;655;0
WireConnection;650;0;648;0
WireConnection;650;1;649;0
WireConnection;648;0;647;0
WireConnection;967;0;965;0
WireConnection;967;1;966;0
WireConnection;1625;0;1626;0
WireConnection;642;0;641;0
WireConnection;863;0;876;0
WireConnection;863;1;1652;0
WireConnection;863;7;857;0
WireConnection;1441;0;1563;0
WireConnection;927;0;1696;0
WireConnection;1661;0;553;0
WireConnection;1124;1;1093;0
WireConnection;1124;2;1121;0
WireConnection;752;0;717;0
WireConnection;709;0;699;0
WireConnection;709;1;1650;0
WireConnection;709;5;759;0
WireConnection;709;7;690;0
WireConnection;854;0;844;0
WireConnection;854;1;1653;0
WireConnection;854;7;857;0
WireConnection;874;0;854;1
WireConnection;681;0;677;0
WireConnection;681;1;679;0
WireConnection;846;0;869;0
WireConnection;846;1;1654;0
WireConnection;846;7;857;0
WireConnection;691;0;698;0
WireConnection;963;0;945;0
WireConnection;879;0;846;1
WireConnection;702;0;697;0
WireConnection;702;1;1649;0
WireConnection;702;5;758;0
WireConnection;702;7;690;0
WireConnection;736;0;734;0
WireConnection;736;1;731;1
WireConnection;1617;0;1616;0
WireConnection;718;0;710;0
WireConnection;955;0;957;0
WireConnection;955;1;958;0
WireConnection;749;0;691;0
WireConnection;661;0;660;0
WireConnection;672;0;670;0
WireConnection;672;1;669;0
WireConnection;672;2;671;0
WireConnection;1675;0;1667;0
WireConnection;1675;1;1668;0
WireConnection;722;0;1663;0
WireConnection;1673;0;1672;0
WireConnection;1673;2;1674;0
WireConnection;888;0;846;2
WireConnection;641;0;640;0
WireConnection;651;0;650;0
WireConnection;1122;1;499;0
WireConnection;1657;0;567;0
WireConnection;791;0;1692;0
WireConnection;1695;1;590;0
WireConnection;1695;2;1444;0
WireConnection;1695;4;541;0
WireConnection;1695;3;1213;0
WireConnection;1695;5;543;0
WireConnection;1695;6;626;0
WireConnection;1695;7;629;0
WireConnection;1695;8;630;0
WireConnection;1695;9;632;0
WireConnection;1695;10;633;0
WireConnection;1630;0;741;0
WireConnection;1630;1;516;4
WireConnection;1630;2;1346;0
WireConnection;1630;3;1631;0
WireConnection;746;0;733;0
WireConnection;746;1;748;0
WireConnection;1622;0;1619;0
WireConnection;721;0;1658;0
WireConnection;1696;62;923;0
WireConnection;1696;2;1587;0
WireConnection;1696;64;904;0
WireConnection;1696;3;911;0
WireConnection;1696;66;907;0
WireConnection;1696;6;910;0
WireConnection;1696;68;912;0
WireConnection;1696;8;913;0
WireConnection;1696;69;916;0
WireConnection;1696;10;917;0
WireConnection;734;0;733;0
WireConnection;734;1;731;0
WireConnection;656;0;653;0
WireConnection;656;1;654;4
WireConnection;964;0;962;0
WireConnection;964;1;963;0
WireConnection;893;0;860;3
WireConnection;1660;0;552;0
WireConnection;751;0;716;0
WireConnection;662;0;652;0
WireConnection;1659;0;549;0
WireConnection;885;0;863;3
WireConnection;892;0;860;2
WireConnection;739;0;738;0
WireConnection;739;1;737;1
WireConnection;665;0;662;0
WireConnection;665;1;664;0
WireConnection;665;2;661;0
WireConnection;969;0;947;0
WireConnection;698;0;719;0
WireConnection;698;1;1647;0
WireConnection;698;5;756;0
WireConnection;698;7;690;0
WireConnection;673;0;672;0
WireConnection;684;0;682;0
WireConnection;684;1;681;0
WireConnection;684;2;683;0
WireConnection;961;0;959;0
WireConnection;961;1;960;0
WireConnection;685;0;684;0
WireConnection;952;0;1693;0
WireConnection;1091;0;1083;0
WireConnection;663;0;654;0
WireConnection;1645;0;504;0
WireConnection;1645;1;1641;0
WireConnection;741;0;740;0
WireConnection;741;1;742;1
WireConnection;968;0;948;0
WireConnection;968;1;947;0
WireConnection;634;0;1695;0
WireConnection;533;0;1640;0
WireConnection;1624;0;501;0
WireConnection;1624;1;1625;0
WireConnection;1624;7;578;0
WireConnection;710;0;706;0
WireConnection;710;1;1651;0
WireConnection;710;5;760;0
WireConnection;710;7;690;0
WireConnection;959;0;951;0
WireConnection;959;1;944;0
WireConnection;715;0;693;0
WireConnection;889;0;846;3
WireConnection;738;0;733;0
WireConnection;738;1;737;0
WireConnection;723;0;1664;0
WireConnection;896;0;778;0
WireConnection;896;1;897;0
WireConnection;537;0;533;0
WireConnection;750;0;715;0
WireConnection;960;0;944;0
WireConnection;1629;0;1630;0
WireConnection;1662;0;554;0
WireConnection;907;0;906;0
WireConnection;907;1;918;0
WireConnection;867;0;863;1
WireConnection;1679;0;1427;3
WireConnection;1679;1;1677;1
WireConnection;1679;2;1678;0
WireConnection;966;0;946;0
WireConnection;899;0;780;0
WireConnection;899;1;902;0
WireConnection;1619;0;736;0
WireConnection;1619;1;568;4
WireConnection;1619;2;1326;0
WireConnection;1619;3;1620;0
WireConnection;717;0;709;0
WireConnection;538;0;534;0
WireConnection;532;0;1639;0
WireConnection;887;0;854;3
WireConnection;744;0;743;0
WireConnection;744;1;745;1
WireConnection;534;0;1645;0
WireConnection;1141;0;1093;0
WireConnection;1141;2;1136;0
WireConnection;1618;0;1617;0
WireConnection;957;0;940;0
WireConnection;957;1;943;0
WireConnection;965;0;949;0
WireConnection;965;1;946;0
WireConnection;970;0;968;0
WireConnection;970;1;969;0
WireConnection;564;0;565;0
WireConnection;884;0;863;2
WireConnection;565;0;1623;0
WireConnection;1642;0;747;0
WireConnection;1642;1;518;4
WireConnection;1642;2;1350;0
WireConnection;1642;3;1643;0
WireConnection;1563;1;1443;0
WireConnection;1563;2;1440;0
WireConnection;637;7;638;0
WireConnection;891;0;851;3
WireConnection;1623;0;569;0
WireConnection;1623;1;1622;0
WireConnection;1623;7;578;0
WireConnection;563;0;568;4
WireConnection;1635;0;744;0
WireConnection;1635;1;517;4
WireConnection;1635;2;1348;0
WireConnection;1635;3;1637;0
WireConnection;686;0;685;0
WireConnection;1636;0;1635;0
WireConnection;693;0;692;0
WireConnection;693;1;1648;0
WireConnection;693;5;757;0
WireConnection;693;7;690;0
WireConnection;904;0;925;0
WireConnection;904;1;920;0
WireConnection;716;0;702;0
WireConnection;923;0;922;0
WireConnection;923;1;921;0
WireConnection;1665;0;1661;0
WireConnection;640;0;644;1
WireConnection;667;0;666;0
WireConnection;1626;0;739;0
WireConnection;1626;1;514;4
WireConnection;1626;2;1334;0
WireConnection;1626;3;1627;0
WireConnection;898;0;779;0
WireConnection;898;1;901;0
WireConnection;851;0;864;0
WireConnection;851;1;1655;0
WireConnection;851;7;857;0
WireConnection;1664;0;1660;0
WireConnection;1641;0;1642;0
WireConnection;962;0;950;0
WireConnection;962;1;945;0
WireConnection;536;0;532;0
WireConnection;895;0;790;0
WireConnection;895;1;894;0
WireConnection;1640;0;503;0
WireConnection;1640;1;1636;0
WireConnection;1640;7;578;0
WireConnection;659;0;656;0
WireConnection;1672;0;1670;0
WireConnection;1639;0;502;0
WireConnection;1639;1;1629;0
WireConnection;1639;7;578;0
WireConnection;679;0;676;0
WireConnection;679;2;674;0
WireConnection;900;0;781;0
WireConnection;900;1;903;0
WireConnection;535;0;531;0
WireConnection;531;0;1624;0
WireConnection;1666;0;1662;0
WireConnection;1426;0;1679;0
WireConnection;881;0;860;1
WireConnection;568;0;569;0
WireConnection;568;7;578;0
WireConnection;725;0;1666;0
WireConnection;587;0;586;0
WireConnection;683;0;678;0
WireConnection;683;1;680;0
WireConnection;675;0;673;0
WireConnection;1694;1;764;0
WireConnection;1694;2;1571;0
WireConnection;1694;4;763;0
WireConnection;1694;3;762;0
WireConnection;1694;5;765;0
WireConnection;1694;6;766;0
WireConnection;1694;7;769;0
WireConnection;1694;8;770;0
WireConnection;1694;9;771;0
WireConnection;1694;10;773;0
WireConnection;1670;0;1675;0
WireConnection;1693;62;955;0
WireConnection;1693;2;1591;0
WireConnection;1693;64;961;0
WireConnection;1693;3;934;0
WireConnection;1693;66;964;0
WireConnection;1693;6;933;0
WireConnection;1693;68;967;0
WireConnection;1693;8;936;0
WireConnection;1693;69;970;0
WireConnection;1693;10;939;0
WireConnection;1692;62;895;0
WireConnection;1692;2;1573;0
WireConnection;1692;64;896;0
WireConnection;1692;3;783;0
WireConnection;1692;66;898;0
WireConnection;1692;6;785;0
WireConnection;1692;68;899;0
WireConnection;1692;8;787;0
WireConnection;1692;69;900;0
WireConnection;1692;10;789;0
WireConnection;1669;0;688;0
WireConnection;1669;1;1673;0
WireConnection;506;21;1141;0
WireConnection;506;22;1094;0
WireConnection;506;0;636;0
WireConnection;506;1;777;0
WireConnection;506;3;793;0
WireConnection;506;4;794;0
WireConnection;506;5;971;0
WireConnection;506;8;688;0
WireConnection;1120;23;1124;0
WireConnection;1120;24;1126;0
WireConnection;1120;1;1125;0
WireConnection;1120;0;1122;0
ASEEND*/
//CHKSM=9DC7080B409D73477522D759056E9E2F54B13C22
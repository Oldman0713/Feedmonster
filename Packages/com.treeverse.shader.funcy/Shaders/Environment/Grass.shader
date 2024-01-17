// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Treeverse/Static/Environment/Grass"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		_BaseMap("Albedo", 2D) = "white" {}
		_FurMap("Fur Map", 2D) = "white" {}
		_FurMaskMap("Fur Mask Map", 2D) = "white" {}
		_NormalMap("Normal Map", 2D) = "bump" {}
		_NormalScale("Normal Scale", Float) = 0
		_NormalMapDetal("Normal Map Detal", 2D) = "bump" {}
		_NormalDetalScale("Normal Detal Scale", Float) = 0
		[HDR]_SpecularColor("Specular Color", Color) = (0.07058824,0.09019608,0.01568628,1)
		[Toggle]_Specular("Specular", Float) = 0
		_Gloss("Gloss", Range( 0 , 1)) = 0.5
		[Toggle]_RimLight("RimLight", Float) = 0
		_RimLightPower("Rim Light Power", Float) = 0
		_RimLightIntensity("Rim Light Intensity", Float) = 0
		_Occlusion("Occlusion", Range( 0 , 1)) = 0
		_AlphaCutout("Max Cutout", Range( 0 , 1)) = 0
		_BaseMove("Base Move", Vector) = (0,0,0,3)
		_WindFreq("Wind Freq", Vector) = (0.5,0.7,0.9,1)
		_WindMove("Wind Move", Vector) = (0.2,0.3,0.2,1)
		_WindIntensity("Wind Intensity", Range( 0 , 1)) = 0.2
		_SpecularFlowScale("Wind Specular", Float) = 0.5
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

		
		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="TransparentCutout" "Queue"="AlphaTest" }
		Cull Back
		ZWrite On
		ZTest LEqual
		Offset 0,0
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
			
			Blend Off
			ColorMask RGBA
			

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#define DISCARD_FRAGMENT
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define EMISSION_X_SHADOWMASK
			#define TREEVERSE_LINEAR_FOG 1
			#define _EMISSION
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
			#define ASE_NEEDS_FRAG_WORLD_VIEW_DIR
			#define ASE_NEEDS_FRAG_WORLD_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_TANGENT
			#define ASE_NEEDS_FRAG_WORLD_BITANGENT
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_SHADOWCOORDS
			#pragma multi_compile _ _SHADOWS_SOFT


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				half4 ase_color : COLOR;
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
				float4 ase_color : COLOR;
				float4 ase_texcoord9 : TEXCOORD9;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			half4 _BaseMove;
			half4 _WindMove;
			half4 _WindFreq;
			half4 _FurMap_ST;
			half4 _FurMaskMap_ST;
			half4 _BaseMap_ST;
			half4 _NormalMap_ST;
			half4 _SpecularColor;
			half4 _NormalMapDetal_ST;
			half _Gloss;
			half _Specular;
			half _RimLightPower;
			half _RimLightIntensity;
			half _NormalScale;
			half _NormalDetalScale;
			half _RimLight;
			half _AlphaCutout;
			half _WindIntensity;
			half _SpecularFlowScale;
			half _Occlusion;
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
			TEXTURE2D(_FurMap);
			SAMPLER(sampler_FurMap);
			TEXTURE2D(_FurMaskMap);
			SAMPLER(sampler_FurMaskMap);
			TEXTURE2D(_BaseMap);
			SAMPLER(sampler_BaseMap);
			TEXTURE2D(_NormalMap);
			SAMPLER(sampler_NormalMap);
			TEXTURE2D(_NormalMapDetal);
			SAMPLER(sampler_NormalMapDetal);


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
				half3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				half vertexToFrag231 = ( v.ase_color.r - 1.0 );
				half heightOffset8 = vertexToFrag231;
				half saferPower49 = abs( heightOffset8 );
				half temp_output_49_0 = pow( saferPower49 , _BaseMove.w );
				half3 appendResult65 = (half3(_BaseMove.xyz));
				half3 move67 = ( temp_output_49_0 * appendResult65 );
				half3 appendResult57 = (half3(_WindMove.xyz));
				half moveFactor51 = temp_output_49_0;
				half3 appendResult54 = (half3(_WindFreq.xyz));
				half mulTime50 = _TimeParameters.x * 3.0;
				half3 windAngle53 = ( appendResult54 * mulTime50 );
				half3 windMove64 = ( appendResult57 * moveFactor51 * sin( ( ( _WindMove.w * v.vertex.xyz ) + windAngle53 ) ) );
				half3 normalizeResult74 = ASESafeNormalize( ( ase_worldNormal + move67 + windMove64 ) );
				half3 shellDir70 = ( normalizeResult74 * float3( 1,0,1 ) );
				half3 worldToObj105 = mul( GetWorldToObjectMatrix(), float4( ( ase_worldPos + ( shellDir70 * ( heightOffset8 * 9.0 * _WindIntensity ) ) + ( heightOffset8 * ase_worldNormal ) ), 1 ) ).xyz;
				half3 Out_Position88 = worldToObj105;
				
				o.ase_texcoord8.z = vertexToFrag231;
				
				o.ase_texcoord8.xy = v.texcoord.xy;
				o.ase_color = v.ase_color;
				o.ase_texcoord9 = v.vertex;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord8.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = Out_Position88;
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

				float2 uv_FurMap = IN.ase_texcoord8.xy * _FurMap_ST.xy + _FurMap_ST.zw;
				half4 tex2DNode28 = SAMPLE_TEXTURE2D( _FurMap, sampler_FurMap, uv_FurMap );
				float2 uv_FurMaskMap = IN.ase_texcoord8.xy * _FurMaskMap_ST.xy + _FurMaskMap_ST.zw;
				half4 tex2DNode29 = SAMPLE_TEXTURE2D( _FurMaskMap, sampler_FurMaskMap, uv_FurMaskMap );
				half vertexToFrag231 = IN.ase_texcoord8.z;
				half heightOffset8 = vertexToFrag231;
				half Out_Discard41 = max( ( tex2DNode28.r * tex2DNode29.r ) , step( heightOffset8 , 0.0001 ) );
				float2 uv_BaseMap = IN.ase_texcoord8.xy * _BaseMap_ST.xy + _BaseMap_ST.zw;
				half4 tex2DNode14 = SAMPLE_TEXTURE2D( _BaseMap, sampler_BaseMap, uv_BaseMap );
				half albedo_alpha233 = tex2DNode14.a;
				
				half curvature113 = max( IN.ase_color.g , 0.001 );
				
				half3 appendResult218 = (half3(tex2DNode14.rgb));
				half3 Out_Albedo216 = appendResult218;
				
				half2 uv_NormalMap = IN.ase_texcoord8.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;
				half2 panner193 = ( 0.0 * _Time.y * float2( 0.01,0.01 ) + uv_NormalMap);
				half3 unpack199 = UnpackNormalScale( SAMPLE_TEXTURE2D( _NormalMap, sampler_NormalMap, panner193 ), _NormalScale );
				unpack199.z = lerp( 1, unpack199.z, saturate(_NormalScale) );
				half3 tex2DNode199 = unpack199;
				half3 normal1221 = tex2DNode199;
				
				float2 uv_NormalMapDetal = IN.ase_texcoord8.xy * _NormalMapDetal_ST.xy + _NormalMapDetal_ST.zw;
				half3 unpack213 = UnpackNormalScale( SAMPLE_TEXTURE2D( _NormalMapDetal, sampler_NormalMapDetal, uv_NormalMapDetal ), _NormalDetalScale );
				unpack213.z = lerp( 1, unpack213.z, saturate(_NormalDetalScale) );
				half saferPower49 = abs( heightOffset8 );
				half temp_output_49_0 = pow( saferPower49 , _BaseMove.w );
				half3 appendResult65 = (half3(_BaseMove.xyz));
				half3 move67 = ( temp_output_49_0 * appendResult65 );
				half3 appendResult57 = (half3(_WindMove.xyz));
				half moveFactor51 = temp_output_49_0;
				half3 appendResult54 = (half3(_WindFreq.xyz));
				half mulTime50 = _TimeParameters.x * 3.0;
				half3 windAngle53 = ( appendResult54 * mulTime50 );
				half3 windMove64 = ( appendResult57 * moveFactor51 * sin( ( ( _WindMove.w * IN.ase_texcoord9.xyz ) + windAngle53 ) ) );
				half3 normalizeResult74 = ASESafeNormalize( ( WorldNormal + move67 + windMove64 ) );
				half3 shellDir70 = ( normalizeResult74 * float3( 1,0,1 ) );
				half3x3 ase_tangentToWorldFast = float3x3(WorldTangent.x,WorldBiTangent.x,WorldNormal.x,WorldTangent.y,WorldBiTangent.y,WorldNormal.y,WorldTangent.z,WorldBiTangent.z,WorldNormal.z);
				half3 tangentToWorldDir167 = mul( ase_tangentToWorldFast, BlendNormal( tex2DNode199 , ( unpack213 + ( _SpecularFlowScale * shellDir70 ) ) ) );
				half fresnelNdotV181 = dot( tangentToWorldDir167, WorldViewDirection );
				half fresnelNode181 = ( 0.0 + _RimLightIntensity * pow( max( 1.0 - fresnelNdotV181 , 0.0001 ), _RimLightPower ) );
				half3 normalizeResult155 = normalize( ( WorldViewDirection + _MainLightPosition.xyz ) );
				half dotResult157 = dot( normalizeResult155 , tangentToWorldDir167 );
				half saferPower165 = abs( max( 0.0 , ( ( _RimLight * fresnelNode181 ) + ( dotResult157 * _Specular ) ) ) );
				half lerpResult161 = lerp( 1.0 , 11.0 , _Gloss);
				half3 appendResult187 = (half3(_SpecularColor.rgb));
				float ase_lightAtten = 0;
				Light ase_mainLight = GetMainLight( ShadowCoords );
				ase_lightAtten = ase_mainLight.distanceAttenuation * ase_mainLight.shadowAttenuation;
				half3 Out_Specular185 = ( pow( saferPower165 , exp2( lerpResult161 ) ) * ( appendResult187 * Out_Albedo216 ) * ase_lightAtten );
				
				half3 temp_cast_5 = (0.0).xxx;
				
				half3 temp_cast_6 = (( tex2DNode28.r * ( 1.0 - tex2DNode29.r ) )).xxx;
				half temp_output_2_0_g7 = _Occlusion;
				half temp_output_3_0_g7 = ( 1.0 - temp_output_2_0_g7 );
				half3 appendResult7_g7 = (half3(temp_output_3_0_g7 , temp_output_3_0_g7 , temp_output_3_0_g7));
				half3 Out_AO146 = ( ( temp_cast_6 * temp_output_2_0_g7 ) + appendResult7_g7 );
				
#ifdef DISCARD_FRAGMENT
				float DiscardValue = ( Out_Discard41 * albedo_alpha233 );
				float DiscardThreshold = ( _AlphaCutout * curvature113 );

				if(DiscardValue < DiscardThreshold)discard;
#endif
				float3 Albedo = Out_Albedo216;
				float3 Normal = normal1221;
				float3 Emission = Out_Specular185;
				float3 Specular = temp_cast_5;
				float Metallic = 0.0;
				float Smoothness = 0.0;
				float Occlusion = Out_AO146.x;
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
			#define EMISSION_X_SHADOWMASK
			#define TREEVERSE_LINEAR_FOG 1
			#define _EMISSION
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
				half4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
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
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			half4 _BaseMove;
			half4 _WindMove;
			half4 _WindFreq;
			half4 _FurMap_ST;
			half4 _FurMaskMap_ST;
			half4 _BaseMap_ST;
			half4 _NormalMap_ST;
			half4 _SpecularColor;
			half4 _NormalMapDetal_ST;
			half _Gloss;
			half _Specular;
			half _RimLightPower;
			half _RimLightIntensity;
			half _NormalScale;
			half _NormalDetalScale;
			half _RimLight;
			half _AlphaCutout;
			half _WindIntensity;
			half _SpecularFlowScale;
			half _Occlusion;
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
			TEXTURE2D(_FurMap);
			SAMPLER(sampler_FurMap);
			TEXTURE2D(_FurMaskMap);
			SAMPLER(sampler_FurMaskMap);
			TEXTURE2D(_BaseMap);
			SAMPLER(sampler_BaseMap);


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
				half3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				half vertexToFrag231 = ( v.ase_color.r - 1.0 );
				half heightOffset8 = vertexToFrag231;
				half saferPower49 = abs( heightOffset8 );
				half temp_output_49_0 = pow( saferPower49 , _BaseMove.w );
				half3 appendResult65 = (half3(_BaseMove.xyz));
				half3 move67 = ( temp_output_49_0 * appendResult65 );
				half3 appendResult57 = (half3(_WindMove.xyz));
				half moveFactor51 = temp_output_49_0;
				half3 appendResult54 = (half3(_WindFreq.xyz));
				half mulTime50 = _TimeParameters.x * 3.0;
				half3 windAngle53 = ( appendResult54 * mulTime50 );
				half3 windMove64 = ( appendResult57 * moveFactor51 * sin( ( ( _WindMove.w * v.vertex.xyz ) + windAngle53 ) ) );
				half3 normalizeResult74 = ASESafeNormalize( ( ase_worldNormal + move67 + windMove64 ) );
				half3 shellDir70 = ( normalizeResult74 * float3( 1,0,1 ) );
				half3 worldToObj105 = mul( GetWorldToObjectMatrix(), float4( ( ase_worldPos + ( shellDir70 * ( heightOffset8 * 9.0 * _WindIntensity ) ) + ( heightOffset8 * ase_worldNormal ) ), 1 ) ).xyz;
				half3 Out_Position88 = worldToObj105;
				
				o.ase_texcoord2.z = vertexToFrag231;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = Out_Position88;
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
				half4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;

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
				o.ase_texcoord = v.ase_texcoord;
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
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
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

				float2 uv_FurMap = IN.ase_texcoord2.xy * _FurMap_ST.xy + _FurMap_ST.zw;
				half4 tex2DNode28 = SAMPLE_TEXTURE2D( _FurMap, sampler_FurMap, uv_FurMap );
				float2 uv_FurMaskMap = IN.ase_texcoord2.xy * _FurMaskMap_ST.xy + _FurMaskMap_ST.zw;
				half4 tex2DNode29 = SAMPLE_TEXTURE2D( _FurMaskMap, sampler_FurMaskMap, uv_FurMaskMap );
				half vertexToFrag231 = IN.ase_texcoord2.z;
				half heightOffset8 = vertexToFrag231;
				half Out_Discard41 = max( ( tex2DNode28.r * tex2DNode29.r ) , step( heightOffset8 , 0.0001 ) );
				float2 uv_BaseMap = IN.ase_texcoord2.xy * _BaseMap_ST.xy + _BaseMap_ST.zw;
				half4 tex2DNode14 = SAMPLE_TEXTURE2D( _BaseMap, sampler_BaseMap, uv_BaseMap );
				half albedo_alpha233 = tex2DNode14.a;
				
				half curvature113 = max( IN.ase_color.g , 0.001 );
				
#ifdef DISCARD_FRAGMENT
				float DiscardValue = ( Out_Discard41 * albedo_alpha233 );
				float DiscardThreshold = ( _AlphaCutout * curvature113 );

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
			
			Name "Meta"
			Tags { "LightMode"="Meta" }

			Cull Off

			HLSLPROGRAM
			
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#define DISCARD_FRAGMENT
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define EMISSION_X_SHADOWMASK
			#define TREEVERSE_LINEAR_FOG 1
			#define _EMISSION
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 999999
			#define ASE_USING_SAMPLING_MACROS 1

			
			#pragma vertex vert
			#pragma fragment frag

			#pragma shader_feature _ EDITOR_VISUALIZATION

			#define SHADERPASS SHADERPASS_META

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define _ADDITIONAL_LIGHT_SHADOWS 1
			#define ASE_NEEDS_FRAG_SHADOWCOORDS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _SHADOWS_SOFT


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 texcoord0 : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				half4 ase_color : COLOR;
				half4 ase_tangent : TANGENT;
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
				#ifdef EDITOR_VISUALIZATION
				float4 VizUV : TEXCOORD2;
				float4 LightCoord : TEXCOORD3;
				#endif
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_color : COLOR;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				float4 ase_texcoord7 : TEXCOORD7;
				float4 ase_texcoord8 : TEXCOORD8;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			half4 _BaseMove;
			half4 _WindMove;
			half4 _WindFreq;
			half4 _FurMap_ST;
			half4 _FurMaskMap_ST;
			half4 _BaseMap_ST;
			half4 _NormalMap_ST;
			half4 _SpecularColor;
			half4 _NormalMapDetal_ST;
			half _Gloss;
			half _Specular;
			half _RimLightPower;
			half _RimLightIntensity;
			half _NormalScale;
			half _NormalDetalScale;
			half _RimLight;
			half _AlphaCutout;
			half _WindIntensity;
			half _SpecularFlowScale;
			half _Occlusion;
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
			TEXTURE2D(_FurMap);
			SAMPLER(sampler_FurMap);
			TEXTURE2D(_FurMaskMap);
			SAMPLER(sampler_FurMaskMap);
			TEXTURE2D(_BaseMap);
			SAMPLER(sampler_BaseMap);
			TEXTURE2D(_NormalMap);
			SAMPLER(sampler_NormalMap);
			TEXTURE2D(_NormalMapDetal);
			SAMPLER(sampler_NormalMapDetal);


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
				half3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				half vertexToFrag231 = ( v.ase_color.r - 1.0 );
				half heightOffset8 = vertexToFrag231;
				half saferPower49 = abs( heightOffset8 );
				half temp_output_49_0 = pow( saferPower49 , _BaseMove.w );
				half3 appendResult65 = (half3(_BaseMove.xyz));
				half3 move67 = ( temp_output_49_0 * appendResult65 );
				half3 appendResult57 = (half3(_WindMove.xyz));
				half moveFactor51 = temp_output_49_0;
				half3 appendResult54 = (half3(_WindFreq.xyz));
				half mulTime50 = _TimeParameters.x * 3.0;
				half3 windAngle53 = ( appendResult54 * mulTime50 );
				half3 windMove64 = ( appendResult57 * moveFactor51 * sin( ( ( _WindMove.w * v.vertex.xyz ) + windAngle53 ) ) );
				half3 normalizeResult74 = ASESafeNormalize( ( ase_worldNormal + move67 + windMove64 ) );
				half3 shellDir70 = ( normalizeResult74 * float3( 1,0,1 ) );
				half3 worldToObj105 = mul( GetWorldToObjectMatrix(), float4( ( ase_worldPos + ( shellDir70 * ( heightOffset8 * 9.0 * _WindIntensity ) ) + ( heightOffset8 * ase_worldNormal ) ), 1 ) ).xyz;
				half3 Out_Position88 = worldToObj105;
				
				o.ase_texcoord4.z = vertexToFrag231;
				
				o.ase_texcoord5.xyz = ase_worldNormal;
				half3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord7.xyz = ase_worldTangent;
				half ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord8.xyz = ase_worldBitangent;
				
				o.ase_texcoord4.xy = v.texcoord0.xy;
				o.ase_color = v.ase_color;
				o.ase_texcoord6 = v.vertex;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
				o.ase_texcoord7.w = 0;
				o.ase_texcoord8.w = 0;
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = Out_Position88;
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

				o.clipPos = MetaVertexPosition( v.vertex, v.texcoord1.xy, v.texcoord1.xy, unity_LightmapST, unity_DynamicLightmapST );

			#ifdef EDITOR_VISUALIZATION
				float2 VizUV = 0;
				float4 LightCoord = 0;
				UnityEditorVizData(v.vertex.xyz, v.texcoord0.xy, v.texcoord1.xy, v.texcoord2.xy, VizUV, LightCoord);
				o.VizUV = float4(VizUV, 0, 0);
				o.LightCoord = LightCoord;
			#endif

			#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = o.clipPos;
				o.shadowCoord = GetShadowCoord( vertexInput );
			#endif
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 texcoord0 : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				half4 ase_color : COLOR;
				half4 ase_tangent : TANGENT;

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
				o.texcoord0 = v.texcoord0;
				o.texcoord1 = v.texcoord1;
				o.texcoord2 = v.texcoord2;
				o.ase_color = v.ase_color;
				o.ase_tangent = v.ase_tangent;
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
				o.texcoord0 = patch[0].texcoord0 * bary.x + patch[1].texcoord0 * bary.y + patch[2].texcoord0 * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
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

			half4 frag(VertexOutput IN  ) : SV_TARGET
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

				float2 uv_FurMap = IN.ase_texcoord4.xy * _FurMap_ST.xy + _FurMap_ST.zw;
				half4 tex2DNode28 = SAMPLE_TEXTURE2D( _FurMap, sampler_FurMap, uv_FurMap );
				float2 uv_FurMaskMap = IN.ase_texcoord4.xy * _FurMaskMap_ST.xy + _FurMaskMap_ST.zw;
				half4 tex2DNode29 = SAMPLE_TEXTURE2D( _FurMaskMap, sampler_FurMaskMap, uv_FurMaskMap );
				half vertexToFrag231 = IN.ase_texcoord4.z;
				half heightOffset8 = vertexToFrag231;
				half Out_Discard41 = max( ( tex2DNode28.r * tex2DNode29.r ) , step( heightOffset8 , 0.0001 ) );
				float2 uv_BaseMap = IN.ase_texcoord4.xy * _BaseMap_ST.xy + _BaseMap_ST.zw;
				half4 tex2DNode14 = SAMPLE_TEXTURE2D( _BaseMap, sampler_BaseMap, uv_BaseMap );
				half albedo_alpha233 = tex2DNode14.a;
				
				half curvature113 = max( IN.ase_color.g , 0.001 );
				
				half3 appendResult218 = (half3(tex2DNode14.rgb));
				half3 Out_Albedo216 = appendResult218;
				
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				half2 uv_NormalMap = IN.ase_texcoord4.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;
				half2 panner193 = ( 0.0 * _Time.y * float2( 0.01,0.01 ) + uv_NormalMap);
				half3 unpack199 = UnpackNormalScale( SAMPLE_TEXTURE2D( _NormalMap, sampler_NormalMap, panner193 ), _NormalScale );
				unpack199.z = lerp( 1, unpack199.z, saturate(_NormalScale) );
				half3 tex2DNode199 = unpack199;
				float2 uv_NormalMapDetal = IN.ase_texcoord4.xy * _NormalMapDetal_ST.xy + _NormalMapDetal_ST.zw;
				half3 unpack213 = UnpackNormalScale( SAMPLE_TEXTURE2D( _NormalMapDetal, sampler_NormalMapDetal, uv_NormalMapDetal ), _NormalDetalScale );
				unpack213.z = lerp( 1, unpack213.z, saturate(_NormalDetalScale) );
				half3 ase_worldNormal = IN.ase_texcoord5.xyz;
				half saferPower49 = abs( heightOffset8 );
				half temp_output_49_0 = pow( saferPower49 , _BaseMove.w );
				half3 appendResult65 = (half3(_BaseMove.xyz));
				half3 move67 = ( temp_output_49_0 * appendResult65 );
				half3 appendResult57 = (half3(_WindMove.xyz));
				half moveFactor51 = temp_output_49_0;
				half3 appendResult54 = (half3(_WindFreq.xyz));
				half mulTime50 = _TimeParameters.x * 3.0;
				half3 windAngle53 = ( appendResult54 * mulTime50 );
				half3 windMove64 = ( appendResult57 * moveFactor51 * sin( ( ( _WindMove.w * IN.ase_texcoord6.xyz ) + windAngle53 ) ) );
				half3 normalizeResult74 = ASESafeNormalize( ( ase_worldNormal + move67 + windMove64 ) );
				half3 shellDir70 = ( normalizeResult74 * float3( 1,0,1 ) );
				half3 ase_worldTangent = IN.ase_texcoord7.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord8.xyz;
				half3x3 ase_tangentToWorldFast = float3x3(ase_worldTangent.x,ase_worldBitangent.x,ase_worldNormal.x,ase_worldTangent.y,ase_worldBitangent.y,ase_worldNormal.y,ase_worldTangent.z,ase_worldBitangent.z,ase_worldNormal.z);
				half3 tangentToWorldDir167 = mul( ase_tangentToWorldFast, BlendNormal( tex2DNode199 , ( unpack213 + ( _SpecularFlowScale * shellDir70 ) ) ) );
				half fresnelNdotV181 = dot( tangentToWorldDir167, ase_worldViewDir );
				half fresnelNode181 = ( 0.0 + _RimLightIntensity * pow( max( 1.0 - fresnelNdotV181 , 0.0001 ), _RimLightPower ) );
				half3 normalizeResult155 = normalize( ( ase_worldViewDir + _MainLightPosition.xyz ) );
				half dotResult157 = dot( normalizeResult155 , tangentToWorldDir167 );
				half saferPower165 = abs( max( 0.0 , ( ( _RimLight * fresnelNode181 ) + ( dotResult157 * _Specular ) ) ) );
				half lerpResult161 = lerp( 1.0 , 11.0 , _Gloss);
				half3 appendResult187 = (half3(_SpecularColor.rgb));
				float ase_lightAtten = 0;
				Light ase_mainLight = GetMainLight( ShadowCoords );
				ase_lightAtten = ase_mainLight.distanceAttenuation * ase_mainLight.shadowAttenuation;
				half3 Out_Specular185 = ( pow( saferPower165 , exp2( lerpResult161 ) ) * ( appendResult187 * Out_Albedo216 ) * ase_lightAtten );
				
#ifdef DISCARD_FRAGMENT
				float DiscardValue = ( Out_Discard41 * albedo_alpha233 );
				float DiscardThreshold = ( _AlphaCutout * curvature113 );

				if(DiscardValue < DiscardThreshold)discard;
#endif
				float3 Albedo = Out_Albedo216;
				float3 Emission = Out_Specular185;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				MetaInput metaInput = (MetaInput)0;
				metaInput.Albedo = Albedo;
				metaInput.Emission = Emission;
			#ifdef EDITOR_VISUALIZATION
				metaInput.VizUV = IN.VizUV.xy;
				metaInput.LightCoord = IN.LightCoord;
			#endif
				
				return MetaFragment(metaInput);
			}
			ENDHLSL
		}

		
        Pass
        {
			
            Name "ScenePickingPass"
            Tags { "LightMode"="Picking" }
        
			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#define DISCARD_FRAGMENT
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define EMISSION_X_SHADOWMASK
			#define TREEVERSE_LINEAR_FOG 1
			#define _EMISSION
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 999999
			#define ASE_USING_SAMPLING_MACROS 1


			#pragma only_renderers d3d11 glcore gles gles3 
			#pragma vertex vert
			#pragma fragment frag

        
			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
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
				half4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
        
			CBUFFER_START(UnityPerMaterial)
			half4 _BaseMove;
			half4 _WindMove;
			half4 _WindFreq;
			half4 _FurMap_ST;
			half4 _FurMaskMap_ST;
			half4 _BaseMap_ST;
			half4 _NormalMap_ST;
			half4 _SpecularColor;
			half4 _NormalMapDetal_ST;
			half _Gloss;
			half _Specular;
			half _RimLightPower;
			half _RimLightIntensity;
			half _NormalScale;
			half _NormalDetalScale;
			half _RimLight;
			half _AlphaCutout;
			half _WindIntensity;
			half _SpecularFlowScale;
			half _Occlusion;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			

			real3 ASESafeNormalize(float3 inVec)
			{
				real dp3 = max(FLT_MIN, dot(inVec, inVec));
				return inVec* rsqrt( dp3);
			}
			

        
			float4 _SelectionID;

        
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};
        
			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);


				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				half3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				half vertexToFrag231 = ( v.ase_color.r - 1.0 );
				half heightOffset8 = vertexToFrag231;
				half saferPower49 = abs( heightOffset8 );
				half temp_output_49_0 = pow( saferPower49 , _BaseMove.w );
				half3 appendResult65 = (half3(_BaseMove.xyz));
				half3 move67 = ( temp_output_49_0 * appendResult65 );
				half3 appendResult57 = (half3(_WindMove.xyz));
				half moveFactor51 = temp_output_49_0;
				half3 appendResult54 = (half3(_WindFreq.xyz));
				half mulTime50 = _TimeParameters.x * 3.0;
				half3 windAngle53 = ( appendResult54 * mulTime50 );
				half3 windMove64 = ( appendResult57 * moveFactor51 * sin( ( ( _WindMove.w * v.vertex.xyz ) + windAngle53 ) ) );
				half3 normalizeResult74 = ASESafeNormalize( ( ase_worldNormal + move67 + windMove64 ) );
				half3 shellDir70 = ( normalizeResult74 * float3( 1,0,1 ) );
				half3 worldToObj105 = mul( GetWorldToObjectMatrix(), float4( ( ase_worldPos + ( shellDir70 * ( heightOffset8 * 9.0 * _WindIntensity ) ) + ( heightOffset8 * ase_worldNormal ) ), 1 ) ).xyz;
				half3 Out_Position88 = worldToObj105;
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = Out_Position88;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				o.clipPos = TransformWorldToHClip(positionWS);
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				half4 ase_color : COLOR;

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

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;
				
				surfaceDescription.Alpha = 1;
				surfaceDescription.AlphaClipThreshold = 0.5;


				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = 0;
				outColor = _SelectionID;
				
				return outColor;
			}
        
			ENDHLSL
        }

	
	}
	
	CustomEditorForRenderPipeline "CustomDrawersShaderEditor" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
	CustomEditor "ASEMaterialInspector"
	Fallback "Hidden/InternalErrorShader"
	
}/*ASEBEGIN
Version=18935
330;902;1920;792;1382.024;357.0867;1;True;False
Node;AmplifyShaderEditor.VertexColorNode;7;-1792,-640;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;47;-1792,896;Inherit;False;Property;_WindFreq;Wind Freq;16;0;Create;False;0;0;0;False;0;False;0.5,0.7,0.9,1;1.2,0.4,1,1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;26;-1536,-640;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;231;-1408,-640;Inherit;False;False;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;54;-1536,896;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleTimeNode;50;-1792,1056;Inherit;False;1;0;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;8;-1152,-640;Inherit;False;heightOffset;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-1408,896;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector4Node;46;-1792,640;Inherit;False;Property;_BaseMove;Base Move;15;0;Create;False;0;0;0;False;0;False;0,0,0,3;-0.19,0,0,0.2;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;45;-1792,512;Inherit;False;8;heightOffset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;61;-1792,1536;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;48;-1792,1152;Inherit;False;Property;_WindMove;Wind Move;17;0;Create;False;0;0;0;False;0;False;0.2,0.3,0.2,1;0.8,0.4,0.4,1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;53;-1280,896;Inherit;False;windAngle;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;59;-1664,1664;Inherit;False;53;windAngle;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;49;-1536,640;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;-1536,1536;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;51;-1280,640;Inherit;False;moveFactor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;60;-1408,1536;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SinOpNode;63;-1280,1536;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;55;-1792,1408;Inherit;False;51;moveFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;57;-1408,1152;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;65;-1536,768;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-1408,768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-1152,1152;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;64;-1024,1152;Inherit;False;windMove;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;67;-1280,768;Inherit;False;move;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;103;-1792,1792;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;72;-1792,2080;Inherit;False;64;windMove;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;71;-1792,1952;Inherit;False;67;move;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;73;-1536,1920;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;74;-1408,1920;Inherit;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-1792,2176;Inherit;False;Property;_WindIntensity;Wind Intensity;18;0;Create;True;0;0;0;False;0;False;0.2;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;-1280,1920;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;1,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;99;-1664,2304;Inherit;False;8;heightOffset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;70;-1152,1920;Inherit;False;shellDir;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;10;-1152,2176;Inherit;False;8;heightOffset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;-1408,2176;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;9;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;107;-1152,2304;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-896,2176;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;-896,1920;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;102;-1024,1664;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;79;-640,1664;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;105;-256,1664;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;88;0,1664;Inherit;False;Out_Position;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;184;-5191.763,-14.2715;Inherit;False;2622.79;1723.096;Specular;39;214;213;215;167;164;154;165;183;143;171;185;197;187;181;190;162;182;152;157;199;153;201;219;220;202;203;155;135;189;161;175;193;191;200;221;226;227;228;229;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;201;-4352,384;Inherit;False;Property;_RimLightPower;Rim Light Power;11;0;Create;False;0;0;0;False;0;False;0;3.79;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;215;-4191,902;Inherit;True;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;199;-4495.126,858.749;Inherit;True;Property;_TextureSample3;Texture Sample 3;16;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;152;-4736,128;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PannerNode;206;-1543.248,-1411.022;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;135;-3456,768;Inherit;False;Property;_SpecularColor;Specular Color;7;1;[HDR];Create;True;0;0;0;False;0;False;0.07058824,0.09019608,0.01568628,1;0.4,0.3736842,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;219;-3072,768;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;190;-3584,384;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;155;-4352,512;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-640,-1152;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;214;-4992,1280;Inherit;False;Property;_NormalDetalScale;Normal Detal Scale;6;0;Create;False;0;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;205;-1293.339,-1467.418;Inherit;True;Property;_TextureSample4;Texture Sample 4;17;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;150;-1024,-1024;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;40;-384,-1152;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;210;-1808.049,-1392.253;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;216;-896,-1920;Inherit;False;Out_Albedo;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;228;-4864,1408;Inherit;False;Property;_SpecularFlowScale;Wind Specular;19;0;Create;False;0;0;0;False;0;False;0.5;0.37;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;24;-1792,-1152;Inherit;True;Property;_FurMap;Fur Map;1;0;Create;False;0;0;0;False;0;False;None;d0c4443f7a7823140a302dc6652d806c;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;183;-3968,128;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;154;-4480,512;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StepOpNode;39;-512,-1024;Inherit;False;2;0;FLOAT;0.0001;False;1;FLOAT;0.0001;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;237;-1485.802,-511.7728;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;42;-640,-384;Inherit;False;41;Out_Discard;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;149;-868.1,-1283.9;Inherit;False;Property;_Occlusion;Occlusion;13;0;Create;True;0;0;0;False;0;False;0;0.25;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;123;-640,128;Inherit;False;113;curvature;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;226;-4281.578,1167.99;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;182;-4224,128;Inherit;False;Property;_RimLight;RimLight;10;1;[Toggle];Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;227;-4864,1536;Inherit;False;70;shellDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;222;-256,0;Inherit;False;221;normal1;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;28;-1408,-1152;Inherit;True;Property;_TextureSample1;Texture Sample 1;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;143;-4809.555,659.2407;Inherit;False;Property;_NormalScale;Normal Scale;4;0;Create;False;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;193;-4630.599,789.7682;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.01,0.01;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TransformDirectionNode;167;-4018.723,699.3231;Inherit;False;Tangent;World;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;34;-640,-896;Inherit;False;8;heightOffset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;217;-256,-128;Inherit;False;216;Out_Albedo;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;212;-1573.105,-1260.714;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;235;-640,-256;Inherit;False;233;albedo_alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;148;-512,-1408;Inherit;False;Lerp White To;-1;;7;047d7c189c36a62438973bad9d37b1c2;0;2;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;197;-5103.532,900.2163;Inherit;True;Property;_NormalMap;Normal Map;3;0;Create;False;0;0;0;False;0;False;None;d6bc02c62d1d12447a710c22a81217d7;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;25;-1792,-896;Inherit;True;Property;_FurMaskMap;Fur Mask Map;2;0;Create;False;0;0;0;False;0;False;None;c08936c81d981734791703ce8792283d;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;13;-1792,-1920;Inherit;True;Property;_BaseMap;Albedo;0;0;Create;False;0;0;0;False;0;False;None;b3ac74b76334c4f4981532bc62ce55fb;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;14;-1408,-1920;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;43;-640,0;Inherit;False;Property;_AlphaCutout;Max Cutout;14;0;Create;False;0;0;0;False;0;False;0;0.545;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;221;-4080,1152;Inherit;False;normal1;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;171;-3072,256;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FresnelNode;181;-4097.343,317.7825;Inherit;False;Standard;WorldNormal;ViewDir;False;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;3;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;186;-640,256;Inherit;False;185;Out_Specular;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;151;-846.8448,-1200.907;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;157;-4022.865,530.2888;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;200;-4757.895,917.7648;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;162;-3885,959;Inherit;False;Property;_Gloss;Gloss;9;0;Create;True;0;0;0;False;0;False;0.5;0.4;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;175;-3584,128;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;93;-384,384;Inherit;False;88;Out_Position;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;191;-4352,256;Inherit;False;Property;_RimLightIntensity;Rim Light Intensity;12;0;Create;False;0;0;0;False;0;False;0;0.15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;124;-384,128;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;203;-3893.214,544.2888;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;146;-301.8837,-1301.677;Inherit;False;Out_AO;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;218;-1024,-1920;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;161;-3808,747;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;11;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;113;-1280,-512;Inherit;False;curvature;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;233;-980.8535,-1791.813;Inherit;False;albedo_alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;165;-3456,384;Inherit;True;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;189;-3712,384;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;29;-1536,-896;Inherit;True;Property;_TextureSample2;Texture Sample 2;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;229;-4608,1408;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;213;-4608,1153.092;Inherit;True;Property;_NormalMapDetal;Normal Map Detal;5;0;Create;True;0;0;0;False;0;False;-1;None;fbb1263e527696242872dd6b1b5bf2eb;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;224;-255.0161,215.5788;Inherit;False;Constant;_Float0;Float 0;19;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;147;-512,512;Inherit;False;146;Out_AO;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;187;-3200,768;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;41;-128,-1152;Inherit;False;Out_Discard;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;208;-925.0512,-1467.418;Inherit;False;flow;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;230;-1792,-384;Inherit;False;2;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;82;-1280,-384;Inherit;False;furLayerNum;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;185;-2816,128;Inherit;False;Out_Specular;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;202;-4186.301,657.1456;Inherit;False;Property;_Specular;Specular;8;1;[Toggle];Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;153;-4730.619,507.6438;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;236;-390.3064,-314.7143;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Exp2OpNode;164;-3712,640;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;220;-3200,896;Inherit;False;216;Out_Albedo;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;238;0,0;Float;False;False;-1;2;ASEMaterialInspector;0;1;New Amplify Shader;9f53fdc6bec2ee94397ba2956dd3cfbc;True;FullScreenPass;0;8;FullScreenPass;4;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;7;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForwardOnly;True;2;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;22;0,0;Float;False;False;-1;2;ASEMaterialInspector;0;17;New Amplify Shader;9f53fdc6bec2ee94397ba2956dd3cfbc;True;SceneSelectionPass;0;6;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;True;4;d3d11;glcore;gles;gles3;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;23;0,0;Float;False;False;-1;2;ASEMaterialInspector;0;17;New Amplify Shader;9f53fdc6bec2ee94397ba2956dd3cfbc;True;ScenePickingPass;0;7;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;True;4;d3d11;glcore;gles;gles3;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;15;0,0;Float;False;False;-1;2;ASEMaterialInspector;0;17;New Amplify Shader;9f53fdc6bec2ee94397ba2956dd3cfbc;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;18;0,0;Float;False;False;-1;2;ASEMaterialInspector;0;17;New Amplify Shader;9f53fdc6bec2ee94397ba2956dd3cfbc;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;17;0,0;Float;False;False;-1;2;ASEMaterialInspector;0;17;New Amplify Shader;9f53fdc6bec2ee94397ba2956dd3cfbc;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;19;0,0;Float;False;False;-1;2;ASEMaterialInspector;0;17;New Amplify Shader;9f53fdc6bec2ee94397ba2956dd3cfbc;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;20;0,0;Float;False;False;-1;2;ASEMaterialInspector;0;17;New Amplify Shader;9f53fdc6bec2ee94397ba2956dd3cfbc;True;DepthNormals;0;5;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=DepthNormals;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;16;0,0;Half;False;True;-1;2;ASEMaterialInspector;0;18;Treeverse/Static/Environment/Grass;9f53fdc6bec2ee94397ba2956dd3cfbc;True;Forward;0;1;Forward;26;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;1;False;-1;True;3;False;-1;True;False;0;False;-1;0;False;-1;True;3;RenderPipeline=UniversalPipeline;RenderType=TransparentCutout=RenderType;Queue=AlphaTest=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;True;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;1;LightMode=UniversalForwardOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;26;Surface;0;0;  Refraction Model;0;0;  Blend;0;0;Two Sided;1;0;Fragment Normal Space,InvertActionOnDeselection;0;0;Cast Shadows;0;637926994909253195;  Use Shadow Threshold;0;0;Receive Shadows;1;0;GPU Instancing;1;0;LOD CrossFade;0;637926838948587399;Treeverse Linear Fog;1;637993452733786999;_FinalColorxAlpha;0;0;Meta Pass;1;0;Override Baked GI;0;0;Extra Pre Pass;0;0;Full Screen Pass;0;0;DOTS Instancing;0;0;Write Depth;0;0;  Early Z;0;0;Vertex Position,InvertActionOnDeselection;0;637926920509220384;Debug Display;0;0;Clear Coat;0;0;Discard Fragment;1;637933815525313925;Discard Use Variant;0;0;Push SelfShadow to Main Light;0;0;Emission x ShadowMask;1;637937258512847957;0;9;False;True;False;True;True;False;False;True;False;False;;True;0
WireConnection;26;0;7;1
WireConnection;231;0;26;0
WireConnection;54;0;47;0
WireConnection;8;0;231;0
WireConnection;52;0;54;0
WireConnection;52;1;50;0
WireConnection;53;0;52;0
WireConnection;49;0;45;0
WireConnection;49;1;46;4
WireConnection;62;0;48;4
WireConnection;62;1;61;0
WireConnection;51;0;49;0
WireConnection;60;0;62;0
WireConnection;60;1;59;0
WireConnection;63;0;60;0
WireConnection;57;0;48;0
WireConnection;65;0;46;0
WireConnection;66;0;49;0
WireConnection;66;1;65;0
WireConnection;58;0;57;0
WireConnection;58;1;55;0
WireConnection;58;2;63;0
WireConnection;64;0;58;0
WireConnection;67;0;66;0
WireConnection;73;0;103;0
WireConnection;73;1;71;0
WireConnection;73;2;72;0
WireConnection;74;0;73;0
WireConnection;110;0;74;0
WireConnection;70;0;110;0
WireConnection;98;0;99;0
WireConnection;98;2;80;0
WireConnection;12;0;10;0
WireConnection;12;1;107;0
WireConnection;81;0;70;0
WireConnection;81;1;98;0
WireConnection;79;0;102;0
WireConnection;79;1;81;0
WireConnection;79;2;12;0
WireConnection;105;0;79;0
WireConnection;88;0;105;0
WireConnection;215;0;199;0
WireConnection;215;1;226;0
WireConnection;199;0;197;0
WireConnection;199;1;193;0
WireConnection;199;5;143;0
WireConnection;199;7;197;1
WireConnection;206;0;212;0
WireConnection;219;0;187;0
WireConnection;219;1;220;0
WireConnection;190;1;189;0
WireConnection;155;0;154;0
WireConnection;30;0;28;1
WireConnection;30;1;29;1
WireConnection;205;0;24;0
WireConnection;205;1;206;0
WireConnection;205;7;24;1
WireConnection;150;0;29;1
WireConnection;40;0;30;0
WireConnection;40;1;39;0
WireConnection;210;2;24;0
WireConnection;216;0;218;0
WireConnection;183;0;182;0
WireConnection;183;1;181;0
WireConnection;154;0;152;0
WireConnection;154;1;153;0
WireConnection;39;0;34;0
WireConnection;237;0;7;2
WireConnection;226;0;213;0
WireConnection;226;1;229;0
WireConnection;28;0;24;0
WireConnection;28;7;24;1
WireConnection;193;0;200;0
WireConnection;167;0;215;0
WireConnection;212;0;210;0
WireConnection;148;1;151;0
WireConnection;148;2;149;0
WireConnection;14;0;13;0
WireConnection;14;7;13;1
WireConnection;221;0;199;0
WireConnection;171;0;165;0
WireConnection;171;1;219;0
WireConnection;171;2;175;0
WireConnection;181;0;167;0
WireConnection;181;2;191;0
WireConnection;181;3;201;0
WireConnection;151;0;28;1
WireConnection;151;1;150;0
WireConnection;157;0;155;0
WireConnection;157;1;167;0
WireConnection;200;2;197;0
WireConnection;124;0;43;0
WireConnection;124;1;123;0
WireConnection;203;0;157;0
WireConnection;203;1;202;0
WireConnection;146;0;148;0
WireConnection;218;0;14;0
WireConnection;161;2;162;0
WireConnection;113;0;237;0
WireConnection;233;0;14;4
WireConnection;165;0;190;0
WireConnection;165;1;164;0
WireConnection;189;0;183;0
WireConnection;189;1;203;0
WireConnection;29;0;25;0
WireConnection;29;7;25;1
WireConnection;229;0;228;0
WireConnection;229;1;227;0
WireConnection;213;5;214;0
WireConnection;187;0;135;0
WireConnection;41;0;40;0
WireConnection;208;0;205;1
WireConnection;82;0;7;4
WireConnection;185;0;171;0
WireConnection;236;0;42;0
WireConnection;236;1;235;0
WireConnection;164;0;161;0
WireConnection;16;21;236;0
WireConnection;16;22;124;0
WireConnection;16;0;217;0
WireConnection;16;1;222;0
WireConnection;16;2;186;0
WireConnection;16;9;224;0
WireConnection;16;3;224;0
WireConnection;16;4;224;0
WireConnection;16;5;147;0
WireConnection;16;8;93;0
ASEEND*/
//CHKSM=334F6647FA3353DF5E21D45B9CDC64A7BA8DFBFE
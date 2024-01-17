using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Unity.Mathematics;
using UnityEditor;
using UnityEngine;
namespace Treeverse.Shader.Editor.ShaderGUI
{
    [InitializeOnLoad]
    public class HeightBlend : BaseFuncyShaderGUI
    {
		
		#region Properties
		MaterialProperty splatBase { get; set; }
		MaterialProperty splat0 { get; set; }
		MaterialProperty splat1 { get; set; }
		MaterialProperty splat2 { get; set; }
		MaterialProperty splat3 { get; set; }
		MaterialProperty isFurBase { get; set; }
		MaterialProperty isFur0 { get; set; }
		MaterialProperty isFur1 { get; set; }
		MaterialProperty isFur2 { get; set; }
		MaterialProperty isFur3 { get; set; }
		MaterialProperty alphaCutout { get; set; }
		MaterialProperty furMap { get; set; }
		MaterialProperty drawCutout { get; set; }
		
		MaterialProperty cutoutMap { get; set; }
		MaterialProperty normalBase { get; set; }
		MaterialProperty normalIntensityBase { get; set; }
		MaterialProperty metallicGlossBase { get; set; }
		MaterialProperty smoothnessBase { get; set; }
		MaterialProperty metallicBase { get; set; }
		MaterialProperty aOBase { get; set; }
		MaterialProperty normal0 { get; set; }
		MaterialProperty normalIntensity0 { get; set; }
		MaterialProperty metallicGloss0 { get; set; }
		MaterialProperty aO0 { get; set; }
		MaterialProperty smoothness0 { get; set; }
		MaterialProperty metallic0 { get; set; }
		MaterialProperty normal1 { get; set; }
		MaterialProperty normalIntensity1 { get; set; }
		MaterialProperty metallicGloss1 { get; set; }
		MaterialProperty smoothness1 { get; set; }
		MaterialProperty metallic1 { get; set; }
		MaterialProperty aO1 { get; set; }
		MaterialProperty normal2 { get; set; }
		MaterialProperty normalIntensity2 { get; set; }
		MaterialProperty metallicGloss2 { get; set; }
		MaterialProperty aO2 { get; set; }
		MaterialProperty smoothness2 { get; set; }
		MaterialProperty metallic2 { get; set; }
		MaterialProperty normal3 { get; set; }
		MaterialProperty normalIntensity3 { get; set; }
		MaterialProperty metallicGloss3 { get; set; }
		MaterialProperty smoothness3 { get; set; }
		MaterialProperty aO3 { get; set; }
		MaterialProperty metallic3 { get; set; }
		MaterialProperty parallaxHeightScaleBase { get; set; }
		MaterialProperty parallaxHeightScale0 { get; set; }
		MaterialProperty parallaxHeightScale1 { get; set; }
		MaterialProperty parallaxHeightScale2 { get; set; }
		MaterialProperty parallaxHeightScale3 { get; set; }
		
		MaterialProperty baseMove { get; set; }
		MaterialProperty windFreq { get; set; }
		MaterialProperty windMove { get; set; }
		MaterialProperty windIntensity { get; set; }
		MaterialProperty cullingMode { get; set; }
		#endregion

		public static System.Action onAlbedoGUIChanged;
		public void FindProperties()
		{
			FindProperties(this);
		}
		public override void OnEnable()
        {
			EditorApplication.update += materialEditor.Repaint;
        }
        public override void OnDisable()
        {
			base.OnDisable();
            EditorApplication.update -= materialEditor.Repaint;
            //Debug.Log("Closed");

        }

        public override void OnMaterialGUI()
        {
			FindProperties();
			DrawArea("Albedo", () =>
			{
				MaterialProperty[] albedos = new MaterialProperty[] { splatBase, splat0, splat1, splat2, splat3 };
				MaterialProperty[] parallaxHeightScales = new MaterialProperty[] { parallaxHeightScaleBase, parallaxHeightScale0, parallaxHeightScale1, parallaxHeightScale2, parallaxHeightScale3 };
				MaterialProperty[] isFurs = new MaterialProperty[] { isFur0, isFur1, isFur2, isFur3 };

				EditorGUI.BeginChangeCheck();
				for (int i = 0; i < albedos.Length; i++)
				{
					EditorGUILayout.BeginHorizontal();
					materialEditor.TexturePropertySingleLine(albedos[i].displayName.ToGUIContent(), albedos[i]);
					if (i > 0)
					{
						GUILayout.Label("is Fur Layer");
						GUILayout.Space(5);
						materialEditor.ShaderProperty(isFurs[i - 1], "");
						GUILayout.FlexibleSpace();
					}
					EditorGUILayout.EndHorizontal();
					EditorGUI.indentLevel++;
					EditorGUILayout.BeginHorizontal();
					materialEditor.FloatProperty(parallaxHeightScales[i], "Parallax Scale");
					GUILayout.Space(130);
					EditorGUILayout.EndHorizontal();
					EditorGUI.indentLevel ++;
					EditorGUILayout.BeginHorizontal();
					materialEditor.TextureScaleOffsetProperty(albedos[i]);
					GUILayout.Space(130);
					EditorGUILayout.EndHorizontal();
					EditorGUI.indentLevel -= 2;
				}
				if (EditorGUI.EndChangeCheck())
				{
					onAlbedoGUIChanged?.Invoke();
				}
				materialEditor.TexturePropertySingleLine(cutoutMap.displayName.ToGUIContent(), cutoutMap);
				EditorGUILayout.BeginHorizontal();
				EditorGUI.indentLevel += 2;
				materialEditor.TextureScaleOffsetProperty(cutoutMap);
				GUILayout.Space(130);
				EditorGUI.indentLevel -= 2;
				EditorGUILayout.EndHorizontal();

				if(drawCutout != null)
                {
					EditorGUILayout.BeginHorizontal();
					materialEditor.ShaderProperty(drawCutout, drawCutout.displayName);
					GUILayout.Space(130);
					EditorGUILayout.EndHorizontal();
				}

				//materialEditor.ShaderProperty(cullingMode, cullingMode.displayName);
				
				GUILayout.Space(20);
			});

			DrawArea("Normal", () =>
			{
				MaterialProperty[] normals = new MaterialProperty[] { normalBase, normal0, normal1, normal2, normal3 };
				MaterialProperty[] normalScales = new MaterialProperty[] { normalIntensityBase, normalIntensity0, normalIntensity1, normalIntensity2, normalIntensity3 };
				for (int i = 0; i < normals.Length; i++)
				{
					materialEditor.TexturePropertySingleLine(normals[i].displayName.ToGUIContent(), normals[i], normalScales[i]);
				}
				GUILayout.Space(20);
			});

			DrawArea("Physicals", () =>
			{
				MaterialProperty[] metallicGlosses = new MaterialProperty[] { metallicGlossBase, metallicGloss0, metallicGloss1, metallicGloss2, metallicGloss3 };
				MaterialProperty[] metallics = new MaterialProperty[] { metallicBase, metallic0, metallic1, metallic2, metallic3 };
				MaterialProperty[] smoothnesses = new MaterialProperty[] { smoothnessBase, smoothness0, smoothness1, smoothness2, smoothness3 };
				MaterialProperty[] aos = new MaterialProperty[] { aOBase, aO0, aO1, aO2, aO3 };
				GUILayout.Space(10);
				for (int i = 0; i < metallicGlosses.Length; i++)
				{
					materialEditor.TexturePropertySingleLine(metallicGlosses[i].displayName.ToGUIContent(), metallicGlosses[i]);
					EditorGUI.indentLevel += 2;
					materialEditor.ShaderProperty(metallics[i], "Metallic");
					materialEditor.ShaderProperty(smoothnesses[i], "Smoothness");
					materialEditor.ShaderProperty(aos[i], "AO");
					EditorGUI.indentLevel -= 2;
				}
				GUILayout.Space(20);
			});

			DrawArea("Fur Settings", () =>
			{
				MaterialProperty[] windings = new MaterialProperty[] { baseMove, windFreq, windMove, windIntensity, alphaCutout };
				
				materialEditor.TexturePropertySingleLine(furMap.displayName.ToGUIContent(), furMap);
				materialEditor.TextureScaleOffsetProperty(furMap);
				for (int i = 0; i < windings.Length; i++)
				{
					materialEditor.ShaderProperty(windings[i], windings[i].displayName);
				}
			});

			//base.OnMaterialGUI();
        }

        public override void MaterialChanged(Material material)
        {
            if (material == null)
                return;
        }

    }
}

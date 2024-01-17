using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Unity.Mathematics;
using UnityEditor;
using UnityEngine;
namespace Treeverse.ShaderGUI
{
    [InitializeOnLoad]
    public class DecalBase : BaseFuncyShaderGUI
    {

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
            base.OnMaterialGUI();
        }

        public override void MaterialChanged(Material material)
        {
            if (material == null)
            {
                return;
            }
        }

    }
}

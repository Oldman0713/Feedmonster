using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ToonShaderOverrideWriteOutline : MonoBehaviour
{
    Renderer[] rens;
    MaterialPropertyBlock block = null;
    public MaterialPropertyBlock GetBlock(){ return block; }

    public float outlineNearWidth = 25f;
    public float outlineFarWidth = 50f;

    private void OnEnable()
    {
        rens = GetComponentsInChildren<Renderer>();
        block = new MaterialPropertyBlock();
        block.Clear();
        UpdateOutline();
    }

    void UpdateOutline()
    {
        block.SetFloat("_OutlineNearWidth", outlineNearWidth);
        block.SetFloat("_OutlineFarWidth", outlineFarWidth);
        if (rens != null && rens.Length > 0)
        {
            foreach (var ren in rens)
            {
                ren.SetPropertyBlock(block);
            }
        }
    }
#if UNITY_EDITOR
    private void OnValidate()
    {
        if (block != null)
        {
            UpdateOutline();
        }
    }
#endif

    void Update()
    {
        
    }

    private void OnDisable()
    {
        if (rens != null && rens.Length > 0)
        {
            foreach(var ren in rens)
            {
                ren.SetPropertyBlock(null);
            }
            block.Clear();
            block = null;
        }
    }
}

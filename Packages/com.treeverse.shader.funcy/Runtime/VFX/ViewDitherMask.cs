using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

[ExecuteInEditMode]
public class ViewDitherMask : MonoBehaviour
{
#if UNITY_EDITOR
    [Space(5)]
    [Header("Drag root GameObject to Assign child Renderer")]
    [Space(5)]
    [SerializeField] GameObject assignRootGameObject;
    [SerializeField] GameObject removeRootGameObject;
    public bool includeInactive = false;
    [Space(15)]
#endif
    [SerializeField] List<MeshRenderer> rens = new List<MeshRenderer>();
    MaterialPropertyBlock ditherBlock;

    private void OnEnable()
    {
        if (ditherBlock == null)
        {
            ditherBlock = new MaterialPropertyBlock();
            ditherBlock.Clear();
        }

        ditherBlock.SetFloat("_DitherMask", 1.0f);
        SetBlockForeach();
    }
#if UNITY_EDITOR
    private void OnValidate()
    {
        if(assignRootGameObject != null)
        {
            rens.AddRange(assignRootGameObject.GetComponentsInChildren<MeshRenderer>(includeInactive));
            assignRootGameObject = null;
        }
        if(removeRootGameObject != null)
        {
            foreach (var ren in removeRootGameObject.GetComponentsInChildren<MeshRenderer>(includeInactive))
            {
                if (rens.IndexOf(ren) >= 0)
                {
                    ren.SetPropertyBlock(null);
                    rens.Remove(ren);
                }
            }
            removeRootGameObject = null;
        }
        //Remove Repeat Object
        rens = new HashSet<MeshRenderer>(rens).ToList();
        rens.RemoveAll(r => r == null);

        if (ditherBlock != null)
        {
            ditherBlock.SetFloat("_DitherMask", 1.0f);
        }
        SetBlockForeach();
    }
#endif

    private void OnDisable()
    {
        if (ditherBlock != null)
        {
            ditherBlock.Clear();
            ditherBlock = null;
        }
        SetBlockForeach();
    }

    void SetBlockForeach()
    {
        if (rens == null) return;

        foreach(var ren in rens)
        {
            if (ren != null)
            {
                ren.SetPropertyBlock(ditherBlock);
            }
        }
    }
}

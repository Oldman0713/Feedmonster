using System.Collections;
using System.Collections.Generic;
using System.Linq;
#if UNITY_EDITOR
using UnityEditor;
#endif
using UnityEngine;
using Unity.Mathematics;
[ExecuteInEditMode]
public class FurMeshGroup : MonoBehaviour
{
    public enum CoreType
    {
        CPU, GPU
    }
    [HideInInspector, SerializeField] List<FurMesh> furMeshs = new List<FurMesh>();
    [HideInInspector, SerializeField] List<FurMeshForPolyBrush> furMeshsPB = new List<FurMeshForPolyBrush>();


    public CoreType useThread = CoreType.GPU;
    public float height = 0.1f;
    public int slice = 9;
    public AnimationCurve threshodCurve = AnimationCurve.Linear(0, 0, 1, 1);
    //public float2 tiltingUV1 = Vector2.one;

    public bool triangleCull = true;

    [SerializeField, HideInInspector] bool isFirstInit = false;

    private void OnEnable()
    {
        try
        {
            UpdateChildsRoot();

            if (!isFirstInit)
            {
                GetFirstFurMeshPropertiesValue();
                isFirstInit = true;
            }

            SyncValue();
            SetAbleForeach(true);
        }
        catch
        {

        }

    }
#if UNITY_EDITOR
    private void OnValidate()
    {
        try
        {
            UpdateChildsRoot();
            SyncValue();
        }
        catch { }
    }
#endif
    private void OnDisable()
    {
        try
        {
            UpdateChildsRoot();
            SyncValue();
            SetAbleForeach(false);
        }
        catch { }
    }

    void CollectChilds()
    {
        furMeshs = GetComponentsInChildren<FurMesh>(true).ToList();
        furMeshsPB = GetComponentsInChildren<FurMeshForPolyBrush>(true).ToList();
    }

    public void UpdateChildsRoot()
    {
        CollectChilds();
        foreach (var f in furMeshs) { f.rootFurMeshGroup = this; }
        foreach (var f in furMeshsPB) { f.rootFurMeshGroup = this; }
    }

    public void SyncValue()
    {
        foreach (var target in furMeshs)
        {
            target.useThread = useThread;
            target.height = height;
            target.slice = slice;
            target.threshodCurve = threshodCurve;
            //target.tiltingUV1 = math.float2(tiltingUV1);
            target.triangleCull = triangleCull;
            if (target.furMesh)
            {
                target.GemUpdate();
            }
        }
        foreach (var target in furMeshsPB)
        {
            target.useThread = useThread;
            target.height = height;
            target.slice = slice;
            target.threshodCurve = threshodCurve;
            //target.tiltingUV1 = math.float2(tiltingUV1);
            target.triangleCull = triangleCull;
            if (target.furMesh)
            {
                target.GemUpdate();
            }
        }
    }

    void SetAbleForeach(bool active)
    {
        foreach (var f in furMeshs) { f.enabled = active; }
        foreach (var f in furMeshsPB) { f.enabled = active; }
    }

    void GetFirstFurMeshPropertiesValue()
    {
        if (furMeshs.Count > 0)
        {
            var copyTarget = furMeshs[0];
            useThread = copyTarget.useThread;
            height = copyTarget.height;
            slice = copyTarget.slice;
            threshodCurve = copyTarget.threshodCurve;
            //tiltingUV1 = math.float2(copyTarget.tiltingUV1);
            triangleCull = copyTarget.triangleCull;
            if (copyTarget.furMesh)
            {
                copyTarget.GemUpdate();
            }
        }
        else
        {
            if (furMeshsPB.Count <= 0) { return; }
            var copyTarget = furMeshsPB[0];
            useThread = copyTarget.useThread;
            height = copyTarget.height;
            slice = copyTarget.slice;
            threshodCurve = copyTarget.threshodCurve;
            //tiltingUV1 = math.float2(copyTarget.tiltingUV1);
            triangleCull = copyTarget.triangleCull;
            if (copyTarget.furMesh)
            {
                copyTarget.GemUpdate();
            }
        }
    }
}
#if UNITY_EDITOR
[InitializeOnLoad]
[CustomEditor(typeof(FurMeshGroup))]
public class FurMeshGroup_Editor : Editor
{
    static FurMeshGroup_Editor()
    {
        EditorApplication.delayCall += () =>
        {
            EditorApplication.hierarchyChanged += () => {
                var groups = FindObjectsOfType<FurMeshGroup>();
                try
                {
                    foreach (var g in groups)
                    {
                        g.UpdateChildsRoot();
                    }
                }
                catch { }
            };
        };
    }
    private void OnEnable()
    {
        
    }
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
    }
    private void OnDisable()
    {
        
    }
}
#endif

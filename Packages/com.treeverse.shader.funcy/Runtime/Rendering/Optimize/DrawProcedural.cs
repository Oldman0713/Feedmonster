using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using System.Linq;

using Unity.Collections;
using Unity.Mathematics;
using Unity.Jobs;
using Unity.Burst;



#if UNITY_EDITOR
using UnityEditor;
#endif
[ExecuteInEditMode]
public class DrawProcedural : MonoBehaviour
{
    Camera mainCamera;
    public void OnEnable()
    {
        InitRendererState();
        System.GC.Collect();
        TreeverseUniversalRenderFeature.asset.execute += OnRenderPiplineExecute;
        //UpdateDrawGroup();
    }
#if UNITY_EDITOR
    private void OnValidate()
    {
        InitRendererState();
        SetRendererActive(!m_active);

        System.GC.Collect();

    }
#endif


    public void OnRenderPiplineExecute(CommandBuffer cmd, RenderingData renderingData, ScriptableRenderContext context)
    {
        if (!m_active || !mainCamera) return;
        if (drawGroups == null) return;

        foreach (var dg in drawGroups)
        {
            foreach (var mg in dg.meshGroups)
            {
                cmd.DrawMeshInstanced(mg.mesh, 0, dg.material, 0, mg.o2wList.ToArray(), mg.o2wList.Count, mg.lightmapBlock);
            }
        }
    }


    private void OnDisable()
    {
        TreeverseUniversalRenderFeature.asset.execute -= OnRenderPiplineExecute;
        SetRendererActive(true);
    }

    int currentFrame = 0;
    private void Update()
    {
        if (currentFrame % cullingDownUpdateFrequency != cullingDownUpdateFrequency - 1) { return; }
        UpdateRendererState();
    }

    private void LateUpdate()
    {
        currentFrame++;
    }

    void InitRendererState()
    {
        mainCamera = Camera.main;

        var rens = GetComponentsInChildren<MeshRenderer>();

        rendererStateList = null;
        rendererStateList = new RendererState[rens.Length];
        for (int i = 0; i < rendererStateList.Length; i++)
        {
            var ren = rens[i];
            Matrix4x4 localToWorld = ren.localToWorldMatrix;
            localToWorld.SetRow(3, math.float4(ren.bounds.extents, 1.0f));

            var rendererState = new RendererState(ren, localToWorld);
            rendererStateList[i] = rendererState;
        }
    }


    void UpdateRendererState()
    {
        var indices = new NativeList<int>(Allocator.Persistent);
        var In_o2w = new NativeArray<Matrix4x4>(rendererStateList.Length, Allocator.TempJob);
        var Out_o2w = new NativeList<Matrix4x4>(Allocator.Persistent);
        var Out_Index = new NativeList<int>(Allocator.Persistent);

        Matrix4x4[] o2w = new Matrix4x4[rendererStateList.Length];

        for (int i = 0; i < rendererStateList.Length; i++)
        {
            o2w[i] = rendererStateList[i].localToWorld;
        }

        In_o2w.CopyFrom(o2w);
        o2w = null;

        FrustumCulling cullingWork = new FrustumCulling
        {
            _VMatrix = mainCamera.worldToCameraMatrix,
            _PMatrix = mainCamera.projectionMatrix,
            In_o2w = In_o2w,
            Out_o2w = Out_o2w,
            Out_Index = Out_Index
        };

        cullingWork.ScheduleAppend(indices, rendererStateList.Length, 64).Complete();


        var culled_o2w_List = Out_o2w.ToArray();
        //var notInViewIndexList = indices.ToArray().ToList();
        
        culledRendererStatesList = null;
        culledRendererStatesList = new RendererState[culled_o2w_List.Length];

        int id = 0;
        foreach (var index in Out_Index)
        {
            //notInViewIndexList.Remove(index);
            culledRendererStatesList[id] = rendererStateList[index];
            id++;
        }
        /*
        foreach (var index in notInViewIndexList)
        {
            
        }
        
        */
        indices.Dispose();
        In_o2w.Dispose();
        Out_o2w.Dispose();
        Out_Index.Dispose();

        OnAfterRendererStateUpdate();
    }

    List<DrawGroup> drawGroups = null;
    void OnAfterRendererStateUpdate()
    {
        if (culledRendererStatesList == null) return;
        var rens = culledRendererStatesList;


        if (drawGroups != null)
        {
            foreach (var dg in drawGroups)
            {
                DestroyImmediate(dg.material);
                foreach (var mg in dg.meshGroups)
                {
                    mg.lightmapBlock = null;
                    mg.lightmapScaleOffsetList = null;
                }
            }

            drawGroups = null;
        }
        drawGroups = new List<DrawGroup>();

        List<Material> collectMaterials = new List<Material>();

        foreach (var ren in rens)
        {
            int sharedMaterialIndex = collectMaterials.IndexOf(ren.renderer.sharedMaterial);
            if (sharedMaterialIndex < 0)
            {
                collectMaterials.Add(ren.renderer.sharedMaterial);
            }
        }

        foreach (var m in collectMaterials)
        {
            var dg = new DrawGroup()
            {
                name = m.name,
                sharedMaterial = m,
                material = Instantiate(m)
            };
            dg.material.enableInstancing = true;
            dg.material.EnableKeyword("DIRLIGHTMAP_COMBINED");
            dg.material.EnableKeyword("LIGHTMAP_SHADOW_MIXING");
            dg.material.EnableKeyword("LIGHTMAP_ON");
            drawGroups.Add(dg);
        }

        foreach (var ren in rens)
        {
            MeshFilter filter = ren.renderer.GetComponent<MeshFilter>();
            int groupIndex = collectMaterials.IndexOf(ren.renderer.sharedMaterial);

            var targetMeshGroups = drawGroups[groupIndex].meshGroups.Find(gp => gp.mesh == filter.sharedMesh);

            if (targetMeshGroups == null)
            {
                targetMeshGroups = new MeshGroup()
                {
                    name = filter.sharedMesh.name,
                    mesh = filter.sharedMesh,
                    lightmapBlock = new MaterialPropertyBlock()
                };

                targetMeshGroups.lightmapBlock.Clear();

                drawGroups[groupIndex].meshGroups.Add(targetMeshGroups);
            }

            Matrix4x4 o2w = ren.renderer.localToWorldMatrix;

            targetMeshGroups.lightmapScaleOffsetList.Add(ren.renderer.lightmapScaleOffset);
            targetMeshGroups.o2wList.Add(o2w);
        }

        foreach (var dg in drawGroups)
        {
            foreach (var mg in dg.meshGroups)
            {
                mg.lightmapBlock.SetFloat("_DrawMeshInstanced", 1.0f);
                mg.lightmapBlock.SetVectorArray("instanced_LightmapST", mg.lightmapScaleOffsetList.ToArray());
            }
        }

        collectMaterials.Clear();
        collectMaterials = null;
    }

    void UpdateDrawGroup()
    {
        
    }
    
    void SetRendererActive(bool active)
    {
        for (int i = 0; i < rendererStateList.Length; i++)
        {
            var state = rendererStateList[i];
            state.renderer.enabled = active;
        }
    }

    #region Attributes

    public bool m_active = false;

    [Range(2, 10)] [SerializeField] int cullingDownUpdateFrequency = 3;

    [HideInInspector] [SerializeField] RendererState[] rendererStateList = null;
    RendererState[] culledRendererStatesList = null;

    [System.Serializable]
    public class RendererState
    {
        public MeshRenderer renderer;
        public Matrix4x4 localToWorld;

        public RendererState(MeshRenderer renderer, Matrix4x4 localToWorld)
        {
            this.renderer = renderer;
            this.localToWorld = localToWorld;
        }
    }

    [System.Serializable]
    public class DrawGroup
    {
        public string name;
        public Material sharedMaterial;
        public Material material;
        public List<MeshGroup> meshGroups = new List<MeshGroup>();
    }

    [System.Serializable]
    public class MeshGroup
    {
        public string name;
        public Mesh mesh;
        public MaterialPropertyBlock lightmapBlock;
        public List<Vector4> lightmapScaleOffsetList = new List<Vector4>();
        public List<Matrix4x4> o2wList = new List<Matrix4x4>();
    }
    #endregion

    #region BurstCompile
    [BurstCompile]
    public struct FrustumCulling : IJobParallelForFilter
    {
        public float4x4 _VMatrix;
        public float4x4 _PMatrix;

        [ReadOnly]
        public NativeArray<Matrix4x4> In_o2w;

        public NativeList<Matrix4x4> Out_o2w;

        public NativeList<int> Out_Index;

        float3 WorldToViewPoint(float4x4 VPMatrix, float3 worldPos)
        {
            float4 result = math.mul(VPMatrix, math.float4(worldPos.xyz, 1.0f));
            result.xyz /= result.w;

            return result.xyz;
        }
        bool BoundsInCamera(float3 _center, float3 _extents)
        {
            float4x4 VPMatrix = math.mul(_PMatrix, _VMatrix);

            float3 p0 = _center;
            float3 p1 = _center + math.float3(+_extents.x, +_extents.y, +_extents.z);
            float3 p2 = _center + math.float3(-_extents.x, -_extents.y, -_extents.z);
            float3 p3 = _center + math.float3(+_extents.x, -_extents.y, +_extents.z);
            float3 p4 = _center + math.float3(-_extents.x, +_extents.y, -_extents.z);
            float3 p5 = _center + math.float3(+_extents.x, +_extents.y, -_extents.z);
            float3 p6 = _center + math.float3(-_extents.x, -_extents.y, +_extents.z);
            float3 p7 = _center + math.float3(-_extents.x, +_extents.y, +_extents.z);
            float3 p8 = _center + math.float3(+_extents.x, -_extents.y, -_extents.z);

            float3 vp0 = WorldToViewPoint(VPMatrix, p0);
            float3 vp1 = WorldToViewPoint(VPMatrix, p1);
            float3 vp2 = WorldToViewPoint(VPMatrix, p2);
            float3 vp3 = WorldToViewPoint(VPMatrix, p3);
            float3 vp4 = WorldToViewPoint(VPMatrix, p4);
            float3 vp5 = WorldToViewPoint(VPMatrix, p5);
            float3 vp6 = WorldToViewPoint(VPMatrix, p6);
            float3 vp7 = WorldToViewPoint(VPMatrix, p7);
            float3 vp8 = WorldToViewPoint(VPMatrix, p8);

            p0 = math.abs(vp0.xyz);
            p1 = math.abs(vp1.xyz);
            p2 = math.abs(vp2.xyz);
            p3 = math.abs(vp3.xyz);
            p4 = math.abs(vp4.xyz);
            p5 = math.abs(vp5.xyz);
            p6 = math.abs(vp6.xyz);
            p7 = math.abs(vp7.xyz);
            p8 = math.abs(vp8.xyz);

            float minX = math.min(math.min(math.min(p1.x, p2.x), math.min(p3.x, p4.x)), math.min(math.min(p5.x, p6.x), math.min(p7.x, p8.x)));
            float minY = math.min(math.min(math.min(p1.y, p2.y), math.min(p3.y, p4.y)), math.min(math.min(p5.y, p6.y), math.min(p7.y, p8.y)));

            float2 allow = math.float2(0.9f, 0.9f);

            return p0.z <= 1.0f && minX <= allow.x && minY <= allow.y;
        }

        bool IJobParallelForFilter.Execute(int id)
        {
            Vector3 _center = In_o2w[id].GetColumn(3);
            Vector3 _extents = In_o2w[id].GetRow(3);
            
            if (BoundsInCamera(_center, _extents)) 
            {
                Out_o2w.Add(In_o2w[id]);
                Out_Index.Add(id);
            }

            return true;
        }
    }
    #endregion
}
#if UNITY_EDITOR
[InitializeOnLoad, CustomEditor(typeof(DrawProcedural))]
public class DrawProcedural_Editor : Editor
{
    static DrawProcedural_Editor()
    {
        if (Application.isPlaying) { return; }
        EditorApplication.delayCall += () =>
         {
             foreach (var dp in FindObjectsOfType<DrawProcedural>())
             {
                 dp.OnEnable();
             }
         };
    }
    private void OnEnable()
    {
        
    }
    
}
#endif
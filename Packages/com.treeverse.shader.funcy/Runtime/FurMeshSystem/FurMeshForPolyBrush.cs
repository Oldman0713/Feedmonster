using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Unity.Mathematics;
using System.Linq;
#if UNITY_EDITOR
using UnityEditor;
using Treeverse.Shader.Editor.ShaderGUI;
#endif
using Unity.Jobs;
using Unity.Burst;
using Unity.Collections;
using System.Threading.Tasks;
using System.Reflection;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using System.IO;
#if UNITY_EDITOR
[ExecuteInEditMode]
#endif
public class FurMeshForPolyBrush : MonoBehaviour
{
    public FurMeshGroup rootFurMeshGroup;

    public FurMeshGroup.CoreType useThread = FurMeshGroup.CoreType.GPU;
	public float height = 0.1f;
	public int slice = 9;
	public AnimationCurve threshodCurve = AnimationCurve.Linear(0, 0, 1, 1);
	public float2 tiltingUV1 = Vector2.one;

    public bool triangleCull = true;

	[HideInInspector]public Mesh srcMesh;
    public Mesh furMesh;

    [HideInInspector] [SerializeField] private MeshFilter mf;
	[HideInInspector] [SerializeField] private SkinnedMeshRenderer smr;
	private Transform rootBone;
	private Transform[] bones;
	private Matrix4x4[] bindPoses;
	private BoneWeight[] boneWeights;

	Renderer ren;
    [HideInInspector] [SerializeField] Material cloneMaterial;
	MaterialPropertyBlock discardOrigRenderer,drawRenderer;
	[HideInInspector][SerializeField] ComputeShader furCompute;

    Texture2D threshodCurveMap = null;
    float[] threshodCurveValue = null;

    public BakedPaintMap bakedPaintMap;
    [System.Serializable]
    public class BakedPaintMap
    {
        public Texture2D w123;
        public Texture2D wb4;
    }

    void Reset()
	{
		
	}
	private void OnEnable()
	{
#if UNITY_EDITOR
		if(furCompute == null)
        {
			furCompute = AssetDatabase.LoadAssetAtPath<ComputeShader>(AssetDatabase.GUIDToAssetPath("df5254f263e1ca2478bedbe409a5e536"));
        }
        HeightBlend.onAlbedoGUIChanged += OnValidate;
#endif

       ren = GetComponent<Renderer>();
        TreeverseUniversalRenderFeature.asset.execute += OnUpdate;

        if (!cloneMaterial)
        {
            cloneMaterial = Instantiate(ren.sharedMaterial);
        }
        DLM_KEYWORD = new UnityEngine.Rendering.LocalKeyword(cloneMaterial.shader, "DIRLIGHTMAP_COMBINED");
        LM_KEYWORD = new UnityEngine.Rendering.LocalKeyword(cloneMaterial.shader, "LIGHTMAP_ON");
        LM_MIX = new UnityEngine.Rendering.LocalKeyword(cloneMaterial.shader, "LIGHTMAP_SHADOW_MIXING");
        discardOrigRenderer = new MaterialPropertyBlock();
		discardOrigRenderer.Clear();
		discardOrigRenderer.SetFloat("_FurEditing", 1.0f);

        ren.SetPropertyBlock(discardOrigRenderer);

        drawRenderer = new MaterialPropertyBlock();
        drawRenderer.Clear();
        //ren.enabled = false;

        srcMesh = GetComponent<UnityEngine.Polybrush.PolybrushMesh>().m_PolyMesh.mesh;
		furMesh = new Mesh();
		sliceCount_temp = -1;
		GemUpdate();
	}

#if UNITY_EDITOR
	private void OnValidate()
	{
        if (ren)
        {
            
        }
        if (furMesh)
        {
            GemUpdate();
        }
    }
#endif

    private void OnDisable()
	{
        TreeverseUniversalRenderFeature.asset.execute -= OnUpdate;
#if UNITY_EDITOR
        HeightBlend.onAlbedoGUIChanged -= OnValidate;
#endif
        ren.SetPropertyBlock(null);
        discardOrigRenderer = null;
        drawRenderer = null;

        ren.enabled = true;
		if (furMesh)
		{
			furMesh.Clear();
			furMesh = null;
		}
        if(cloneMaterial)
        {
            DestroyImmediate(cloneMaterial);
        }
		sliceCount_temp = -1;
	}
	
	private float sliceCount_temp = -1;

	public void GemUpdate()
    {
		if (sliceCount_temp != slice + height + 1)
		{
			sliceCount_temp = slice + height + 1;	
		}
		GemFurMesh(slice + 1);
	}

    UnityEngine.Rendering.LocalKeyword LM_KEYWORD, DLM_KEYWORD,LM_MIX;
    void OnUpdate(CommandBuffer cmd, RenderingData renderingData, ScriptableRenderContext ctx)
	{
		if (slice <= 0) return;
        if(cloneMaterial)
        {
            bool lightmapWorking = ren.lightmapIndex >= 0;
            cloneMaterial.CopyPropertiesFromMaterial(ren.sharedMaterial);
            cloneMaterial.SetKeyword(LM_KEYWORD, lightmapWorking);
            cloneMaterial.SetKeyword(DLM_KEYWORD, lightmapWorking);
            cloneMaterial.SetKeyword(LM_MIX, lightmapWorking);

            if (bakedPaintMap.w123 != null)
            {
                drawRenderer.SetTexture("_Baked_Paint_W123", bakedPaintMap.w123);
            }
            if (bakedPaintMap.wb4 != null)
            {
                drawRenderer.SetTexture("_Baked_Paint_WB4", bakedPaintMap.wb4);
            }

            drawRenderer.SetFloat("_WeightUsingMaps", (bakedPaintMap.w123 != null && bakedPaintMap.wb4 != null) ? 1.0f : 0.0f);
            
            ren.SetPropertyBlock(discardOrigRenderer);
            //drawRenderer.SetVector("unity_LightmapST", ren.lightmapScaleOffset);
            cmd.DrawMesh(furMesh, ren.localToWorldMatrix, cloneMaterial, 0, 0, drawRenderer);
        }
        
	}
#if UNITY_EDITOR
    private void Update()
    {
        if (furMesh && FurMeshForPolyBrush_Editor.selectedGUI)
        {
            if (SceneView.lastActiveSceneView != null && SceneView.lastActiveSceneView.camera != null)
            {
                Graphics.DrawMesh(furMesh, ren.localToWorldMatrix, cloneMaterial, gameObject.layer, SceneView.lastActiveSceneView.camera);
            }
        }
    }
#endif

    float map(float s, float from1, float from2, float to1, float to2)
	{
		return to1 + (s - from1) * (to2 - to1) / (from2 - from1);
	}

    private void GemFurMesh(int furLayerNum = 0)
    {
        if (!srcMesh) { return; }
        if (srcMesh.vertices.Length == 0)
        {
            Debug.LogError("FBX is necessary toggle Read/Write Enabled!");
            return;
        }
        if (smr)
        {
            rootBone = smr.rootBone;
            bones = smr.bones;
            bindPoses = srcMesh.bindposes;
            boneWeights = srcMesh.boneWeights;
        }

        furMesh.Clear();


        int targetCount = srcMesh.vertexCount * furLayerNum;
        int triCount = srcMesh.triangles.Length * furLayerNum;

        bool isMobileOrNotSupportComputeShader = !SystemInfo.supportsComputeShaders || Application.platform == RuntimePlatform.Android || Application.platform == RuntimePlatform.IPhonePlayer;

        if (useThread == FurMeshGroup.CoreType.CPU || true)
        {
            #region CPU Fur

            if (threshodCurveValue == null || threshodCurveValue.Length != furLayerNum)
            {
                if (threshodCurveValue != null)
                {
                    threshodCurveValue = null;
                }
                threshodCurveValue = new float[furLayerNum];
            }

            for (int i = 0; i < furLayerNum; i++)
            {
                float currentValue = map(i, 0, furLayerNum - 1, 0, height) + 1.0f;
                float normalizeCurveValue = (currentValue - 1) / height;
                float curvature = threshodCurve.Evaluate(normalizeCurveValue);
                if (slice <= 1)
                {
                    currentValue = 1.0f;
                }
                threshodCurveValue[i] = curvature;
            }

            float4 isfur = float4.zero;
            if (ren && ren.sharedMaterial && triangleCull)
            {
                isfur = new float4(ren.sharedMaterial.GetFloat("_IsFur0"), ren.sharedMaterial.GetFloat("_IsFur1"), ren.sharedMaterial.GetFloat("_IsFur2"), ren.sharedMaterial.GetFloat("_IsFur3"));
            }

            List<Vector4> uvList0 = new List<Vector4>();
            List<Vector4> uvList1 = new List<Vector4>();
            List<Vector4> uvList2 = new List<Vector4>();
            List<Vector4> uvList3 = new List<Vector4>();
            srcMesh.GetUVs(0, uvList0);
            srcMesh.GetUVs(1, uvList1);
            srcMesh.SetUVs(1, uvList0);
            srcMesh.GetUVs(2, uvList2);
            srcMesh.GetUVs(3, uvList3);

            NativeArray<Vector3> verticeBfr = new NativeArray<Vector3>(srcMesh.vertexCount, Allocator.TempJob);
            verticeBfr.CopyFrom(srcMesh.vertices);
            NativeArray<Vector3> normalBfr = new NativeArray<Vector3>(srcMesh.vertexCount, Allocator.TempJob);
            normalBfr.CopyFrom(srcMesh.normals);
            NativeArray<Vector4> tangentBfr = new NativeArray<Vector4>(srcMesh.vertexCount, Allocator.TempJob);
            tangentBfr.CopyFrom(srcMesh.tangents);
            NativeArray<int> triangleBfr = new NativeArray<int>(srcMesh.triangles.Length, Allocator.TempJob);
            triangleBfr.CopyFrom(srcMesh.triangles);
            NativeArray<Vector4> uv0Bfr = new NativeArray<Vector4>(srcMesh.vertexCount, Allocator.TempJob);
            if (uvList0.Count > 0) { uv0Bfr.CopyFrom(uvList0.ToArray()); }
            NativeArray<Vector4> uv1Bfr = new NativeArray<Vector4>(srcMesh.vertexCount, Allocator.TempJob);
            if (uvList1.Count > 0)
            {
                uv1Bfr.CopyFrom(uvList1.ToArray());
            }
            else
            {
                uv1Bfr.CopyFrom(uvList0.ToArray());
            }
            NativeArray<Vector4> uv2Bfr = new NativeArray<Vector4>(srcMesh.vertexCount, Allocator.TempJob);
            if (uvList2.Count > 0) { uv2Bfr.CopyFrom(uvList2.ToArray()); }
            NativeArray<Vector4> uv3Bfr = new NativeArray<Vector4>(srcMesh.vertexCount, Allocator.TempJob);
            if (uvList3.Count > 0) { uv3Bfr.CopyFrom(uvList3.ToArray()); }
            NativeArray<float> threshodCurveValueBfr = new NativeArray<float>(furLayerNum, Allocator.TempJob);
            threshodCurveValueBfr.CopyFrom(threshodCurveValue);

            NativeArray<Vector3> out_verticeBfr = new NativeArray<Vector3>(targetCount, Allocator.TempJob);
            NativeArray<Vector3> out_normalBfr = new NativeArray<Vector3>(targetCount, Allocator.TempJob);
            NativeArray<Vector4> out_tangentBfr = new NativeArray<Vector4>(targetCount, Allocator.TempJob);
            NativeArray<int> out_triangleBfr = new NativeArray<int>(triCount, Allocator.TempJob);
            NativeArray<Vector4> out_uv0Bfr = new NativeArray<Vector4>(targetCount, Allocator.TempJob);
            NativeArray<Vector4> out_uv1Bfr = new NativeArray<Vector4>(targetCount, Allocator.TempJob);
            NativeArray<Vector4> out_uv2Bfr = new NativeArray<Vector4>(targetCount, Allocator.TempJob);
            NativeArray<Vector4> out_uv3Bfr = new NativeArray<Vector4>(targetCount, Allocator.TempJob);
            NativeArray<Color> out_colorBfr = new NativeArray<Color>(targetCount, Allocator.TempJob);


            GemFurMeshJob gemFurMeshJob = new GemFurMeshJob
            {
                verticeBfr = verticeBfr,
                normalBfr = normalBfr,
                tangentBfr = tangentBfr,
                triangleBfr = triangleBfr,
                uv0Bfr = uv0Bfr,
                uv1Bfr = uv1Bfr,
                uv2Bfr = uv2Bfr,
                uv3Bfr = uv3Bfr,
                out_verticeBfr = out_verticeBfr,
                out_normalBfr = out_normalBfr,
                out_tangentBfr = out_tangentBfr,
                out_triangleBfr = out_triangleBfr,
                out_uv0Bfr = out_uv0Bfr,
                out_uv1Bfr = out_uv1Bfr,
                out_uv2Bfr = out_uv2Bfr,
                out_uv3Bfr = out_uv3Bfr,
                out_colorBfr = out_colorBfr,
                threshodCurveValue = threshodCurveValueBfr,
                origVertexCount = (uint)srcMesh.vertexCount,
                origTriangleCount = (uint)srcMesh.triangles.Length,
                furLayerNum = (uint)furLayerNum,
                height = height,
                tilingPerMesh = tiltingUV1,
                isfur = isfur,
                triangleCull = triangleCull,
            };
            int jobCount = Mathf.Max(targetCount, triCount);
            gemFurMeshJob.Schedule(jobCount, 64).Complete();

            if (triangleCull)
            {
                var indices = new NativeList<int>(Allocator.Persistent);
                NativeList<Color> colors = new NativeList<Color>(targetCount, Allocator.TempJob);
                colors.CopyFrom(out_colorBfr);
                NativeList<int> triangles = new NativeList<int>(triCount, Allocator.TempJob);
                triangles.CopyFrom(out_triangleBfr);
                triangleCull triangleCull = new triangleCull
                {
                    out_colorBfr = colors,
                    out_triangleBfr = triangles
                };

                triangleCull.ScheduleAppend(indices, (triCount / 3), 64).Complete();


                out_triangleBfr.CopyFrom(triangles.ToArray());
                out_colorBfr.CopyFrom(colors.ToArray());

                indices.Dispose();
                colors.Dispose();
                triangles.Dispose();
            }


            uvList0.Clear(); uvList0 = null;
            uvList1.Clear(); uvList1 = null;
            uvList2.Clear(); uvList2 = null;
            uvList3.Clear(); uvList3 = null;


            Vector3[] v3Buff = new Vector3[targetCount];
            Vector4[] v4Buff = new Vector4[targetCount];
            Color[] colBuff = new Color[targetCount];
            int[] intBuff = new int[triCount];

            out_verticeBfr.CopyTo(v3Buff);
            furMesh.vertices = v3Buff;

            out_normalBfr.CopyTo(v3Buff);
            furMesh.normals = v3Buff;

            out_tangentBfr.CopyTo(v4Buff);
            furMesh.tangents = v4Buff;

            out_triangleBfr.CopyTo(intBuff);

            if (triangleCull)
            {
                var l = intBuff.ToList();
                l.RemoveAll(x => x == -1);
                intBuff = l.ToArray();
                l = null;
            }

            furMesh.triangles = intBuff;

            out_colorBfr.CopyTo(colBuff);
            furMesh.colors = new Color[targetCount];
            furMesh.SetColors(colBuff);
            if (slice > 0)
            {
                srcMesh.SetColors(colBuff.ToList().GetRange(0, srcMesh.vertexCount));
            }
            furMesh.uv = new Vector2[targetCount];
            furMesh.uv3 = new Vector2[targetCount];
            furMesh.uv4 = new Vector2[targetCount];

            out_uv0Bfr.CopyTo(v4Buff);
            furMesh.SetUVs(0, v4Buff);

            out_uv1Bfr.CopyTo(v4Buff);
            furMesh.SetUVs(1, v4Buff);

            out_uv2Bfr.CopyTo(v4Buff);
            furMesh.SetUVs(2, v4Buff);

            out_uv3Bfr.CopyTo(v4Buff);
            furMesh.SetUVs(3, v4Buff);

            furMesh.Optimize();


            verticeBfr.Dispose();
            normalBfr.Dispose();
            tangentBfr.Dispose();
            triangleBfr.Dispose();
            uv0Bfr.Dispose();
            uv1Bfr.Dispose();
            uv2Bfr.Dispose();
            uv3Bfr.Dispose();
            threshodCurveValueBfr.Dispose();
            out_verticeBfr.Dispose();
            out_normalBfr.Dispose();
            out_tangentBfr.Dispose();
            out_triangleBfr.Dispose();
            out_uv0Bfr.Dispose();
            out_uv1Bfr.Dispose();
            out_uv2Bfr.Dispose();
            out_uv3Bfr.Dispose();
            out_colorBfr.Dispose();



            v3Buff = null;
            v4Buff = null;
            colBuff = null;
            intBuff = null;

            #endregion
        }
        /*
        if (useThread == FurMeshGroup.CoreType.GPU && !isMobileOrNotSupportComputeShader)
        {
            #region GPU Fur
            ComputeBuffer verticeBfr = new ComputeBuffer(srcMesh.vertexCount, System.Runtime.InteropServices.Marshal.SizeOf(Vector3.zero));
            ComputeBuffer normalBfr = new ComputeBuffer(srcMesh.vertexCount, System.Runtime.InteropServices.Marshal.SizeOf(Vector3.zero));
            ComputeBuffer tangentBfr = new ComputeBuffer(srcMesh.vertexCount, System.Runtime.InteropServices.Marshal.SizeOf(Vector4.zero));
            ComputeBuffer triangleBfr = new ComputeBuffer(srcMesh.triangles.Length, System.Runtime.InteropServices.Marshal.SizeOf(1));
            ComputeBuffer uv0Bfr = new ComputeBuffer(srcMesh.vertexCount, System.Runtime.InteropServices.Marshal.SizeOf(Vector4.zero));
            ComputeBuffer uv1Bfr = new ComputeBuffer(srcMesh.vertexCount, System.Runtime.InteropServices.Marshal.SizeOf(Vector4.zero));
            ComputeBuffer uv2Bfr = new ComputeBuffer(srcMesh.vertexCount, System.Runtime.InteropServices.Marshal.SizeOf(Vector4.zero));
            ComputeBuffer uv3Bfr = new ComputeBuffer(srcMesh.vertexCount, System.Runtime.InteropServices.Marshal.SizeOf(Vector4.zero));
            ComputeBuffer colorBfr = new ComputeBuffer(srcMesh.vertexCount, System.Runtime.InteropServices.Marshal.SizeOf(Color.clear));

            ComputeBuffer out_verticeBfr = new ComputeBuffer(targetCount, System.Runtime.InteropServices.Marshal.SizeOf(Vector3.zero));
            ComputeBuffer out_normalBfr = new ComputeBuffer(targetCount, System.Runtime.InteropServices.Marshal.SizeOf(Vector3.zero));
            ComputeBuffer out_tangentBfr = new ComputeBuffer(targetCount, System.Runtime.InteropServices.Marshal.SizeOf(Vector4.zero));
            ComputeBuffer out_triangleBfr = new ComputeBuffer(triCount, System.Runtime.InteropServices.Marshal.SizeOf(1));
            ComputeBuffer out_uv0Bfr = new ComputeBuffer(targetCount, System.Runtime.InteropServices.Marshal.SizeOf(Vector4.zero));
            ComputeBuffer out_uv1Bfr = new ComputeBuffer(targetCount, System.Runtime.InteropServices.Marshal.SizeOf(Vector4.zero));
            ComputeBuffer out_uv2Bfr = new ComputeBuffer(targetCount, System.Runtime.InteropServices.Marshal.SizeOf(Vector4.zero));
            ComputeBuffer out_uv3Bfr = new ComputeBuffer(targetCount, System.Runtime.InteropServices.Marshal.SizeOf(Vector4.zero));
            ComputeBuffer out_colorBfr = new ComputeBuffer(targetCount, System.Runtime.InteropServices.Marshal.SizeOf(Color.clear));

            ComputeBuffer[] bfrs = new ComputeBuffer[] { verticeBfr, normalBfr , tangentBfr, triangleBfr , uv0Bfr , uv1Bfr , uv2Bfr, uv3Bfr, colorBfr ,
            out_verticeBfr, out_normalBfr , out_tangentBfr , out_uv0Bfr , out_uv1Bfr , out_uv2Bfr, out_uv3Bfr, out_colorBfr};


            if (!threshodCurveMap || threshodCurveMap.width != furLayerNum)
            {
                if (threshodCurveMap)
                {
                    if (Application.isPlaying)
                    {
                        Destroy(threshodCurveMap);
                    }
                    else
                    {
                        DestroyImmediate(threshodCurveMap);
                    }
                }
                threshodCurveMap = new Texture2D(furLayerNum, 1, TextureFormat.RGBAHalf, false, true);
            }

            for (int i = 0; i < furLayerNum; i++)
            {
                float currentValue = map(i, 0, furLayerNum - 1, 0, height) + 1.0f;
                float normalizeCurveValue = (currentValue - 1) / height;
                float curvature = threshodCurve.Evaluate(normalizeCurveValue);
                if (slice <= 1)
                {
                    currentValue = 1.0f;
                }
                Color prop = new Color(currentValue, curvature, currentValue, furLayerNum);
                threshodCurveMap.SetPixel(i, 0, prop);
            }

            threshodCurveMap.Apply();

            int gemFurMeshKernel = furCompute.FindKernel("GemFurMesh");
            furCompute.SetBool(nameof(triangleCull), triangleCull);
            if (triangleCull)
            {
                float4 isfur = new float4(ren.sharedMaterial.GetFloat("_IsFur0"), ren.sharedMaterial.GetFloat("_IsFur1"), ren.sharedMaterial.GetFloat("_IsFur2"), ren.sharedMaterial.GetFloat("_IsFur3"));
                furCompute.SetVector(nameof(isfur), isfur);
            }

            furCompute.SetTexture(gemFurMeshKernel, nameof(threshodCurveMap), threshodCurveMap);

            furCompute.GetKernelThreadGroupSizes(gemFurMeshKernel, out uint x, out uint y, out uint z);
            verticeBfr.SetData(srcMesh.vertices);
            normalBfr.SetData(srcMesh.normals);
            tangentBfr.SetData(srcMesh.tangents);
            triangleBfr.SetData(srcMesh.triangles);
            List<Vector4> uvListTemp = new List<Vector4>();
            srcMesh.GetUVs(0, uvListTemp); uv0Bfr.SetData(uvListTemp);
            //srcMesh.GetUVs(1, uvListTemp); uv1Bfr.SetData(uvListTemp);
            srcMesh.GetUVs(2, uvListTemp); uv2Bfr.SetData(uvListTemp);
            srcMesh.GetUVs(3, uvListTemp); uv3Bfr.SetData(uvListTemp);
            colorBfr.SetData(srcMesh.colors);

            furCompute.SetInt("origVertexCount", srcMesh.vertexCount);
            furCompute.SetInt("origTriangleCount", srcMesh.triangles.Length);
            furCompute.SetInt("furLayerNum", furLayerNum);
            furCompute.SetFloat("height", height);
            furCompute.SetVector("tilingPerMesh", new float4(tiltingUV1, 1.0f, 1.0f));
            //ConstBuffer
            furCompute.SetBuffer(gemFurMeshKernel, nameof(verticeBfr), verticeBfr);
            furCompute.SetBuffer(gemFurMeshKernel, nameof(normalBfr), normalBfr);
            furCompute.SetBuffer(gemFurMeshKernel, nameof(tangentBfr), tangentBfr);
            furCompute.SetBuffer(gemFurMeshKernel, nameof(triangleBfr), triangleBfr);

            furCompute.SetBuffer(gemFurMeshKernel, nameof(uv0Bfr), uv0Bfr);
            furCompute.SetBuffer(gemFurMeshKernel, nameof(uv1Bfr), uv1Bfr);
            furCompute.SetBuffer(gemFurMeshKernel, nameof(uv2Bfr), uv2Bfr);
            furCompute.SetBuffer(gemFurMeshKernel, nameof(uv3Bfr), uv3Bfr);
            furCompute.SetBuffer(gemFurMeshKernel, nameof(colorBfr), colorBfr);

            //ResultBuffer
            furCompute.SetBuffer(gemFurMeshKernel, nameof(out_verticeBfr), out_verticeBfr);
            furCompute.SetBuffer(gemFurMeshKernel, nameof(out_normalBfr), out_normalBfr);
            furCompute.SetBuffer(gemFurMeshKernel, nameof(out_tangentBfr), out_tangentBfr);
            furCompute.SetBuffer(gemFurMeshKernel, nameof(out_triangleBfr), out_triangleBfr);
            furCompute.SetBuffer(gemFurMeshKernel, nameof(out_uv0Bfr), out_uv0Bfr);
            furCompute.SetBuffer(gemFurMeshKernel, nameof(out_uv1Bfr), out_uv1Bfr);
            furCompute.SetBuffer(gemFurMeshKernel, nameof(out_uv2Bfr), out_uv2Bfr);
            furCompute.SetBuffer(gemFurMeshKernel, nameof(out_uv3Bfr), out_uv3Bfr);
            furCompute.SetBuffer(gemFurMeshKernel, nameof(out_colorBfr), out_colorBfr);

            int dispatchCount = Mathf.Max(targetCount, triCount);
            furCompute.Dispatch(gemFurMeshKernel, Mathf.CeilToInt(dispatchCount / (float)x), 1, 1);

            if (triangleCull)
            {
                int triangleCullKernel = furCompute.FindKernel("TriangleCulling");
                furCompute.GetKernelThreadGroupSizes(triangleCullKernel, out x, out y, out z);
                furCompute.SetBuffer(triangleCullKernel, nameof(out_colorBfr), out_colorBfr);
                furCompute.SetBuffer(triangleCullKernel, nameof(out_triangleBfr), out_triangleBfr);
                furCompute.Dispatch(triangleCullKernel, Mathf.CeilToInt((triCount / 3) / (float)x), 1, 1);
            }

            Vector3[] v3Buff = new Vector3[targetCount];
            Vector4[] v4Buff = new Vector4[targetCount];
            Color[] colBuff = new Color[targetCount];
            int[] intBuff = new int[triCount];

            out_verticeBfr.GetData(v3Buff);
            furMesh.vertices = v3Buff;

            out_normalBfr.GetData(v3Buff);
            furMesh.normals = v3Buff;

            out_tangentBfr.GetData(v4Buff);
            furMesh.tangents = v4Buff;

            out_triangleBfr.GetData(intBuff);

            if (triangleCull)
            {
                var l = intBuff.ToList();
                l.RemoveAll(x => x == -1);
                intBuff = l.ToArray();
                l = null;
            }

            furMesh.triangles = intBuff;

            out_colorBfr.GetData(colBuff);
            furMesh.colors = new Color[targetCount];
            furMesh.SetColors(colBuff);
            if (slice > 0)
            {
                srcMesh.SetColors(colBuff.ToList().GetRange(0, srcMesh.vertexCount));
            }
            furMesh.uv = new Vector2[targetCount];
            furMesh.uv3 = new Vector2[targetCount];
            furMesh.uv4 = new Vector2[targetCount];

            out_uv0Bfr.GetData(v4Buff);
            furMesh.SetUVs(0, v4Buff);

            out_uv2Bfr.GetData(v4Buff);
            furMesh.SetUVs(2, v4Buff);

            out_uv3Bfr.GetData(v4Buff);
            furMesh.SetUVs(3, v4Buff);

            furMesh.Optimize();


            foreach (var bfr in bfrs)
            {
                bfr.Release(); bfr.Dispose();
            }

            bfrs = null;
            v3Buff = null;
            v4Buff = null;
            colBuff = null;
            intBuff = null;
            #endregion
        }
        */

        furMesh.name = srcMesh.name + "_Fur";
        if (smr)
        {
            furMesh.bindposes = bindPoses;

            BoneWeight[] newboneweights = new BoneWeight[boneWeights.Length * furLayerNum];
            for (int i = 0; i < furLayerNum; i++)
            {
                for (int k = 0; k < boneWeights.Length; k++)
                {
                    newboneweights[i * boneWeights.Length + k] = boneWeights[k];
                }
            }

            furMesh.boneWeights = newboneweights;
            furMesh.RecalculateBounds();
        }

        if (smr)
        {
            smr.bones = bones;
            smr.rootBone = rootBone;
        }
    }

    /// <summary>
    /// Clear fur mesh for skinmesh
    /// </summary>
    /// <param name="r"></param>
    private void ClearFurMesh_Skinmesh(SkinnedMeshRenderer r)
	{
		if (r.sharedMesh != srcMesh && srcMesh)
		{
			r.sharedMesh.Clear();
			r.sharedMesh = srcMesh;
			r.bones = bones;
			r.rootBone = rootBone;
		}
	}

	public Mesh GetFurMesh()
    {
		return furMesh;
    }
}
#if UNITY_EDITOR
[CustomEditor(typeof(FurMeshForPolyBrush))]
public class FurMeshForPolyBrush_Editor : Editor
{
    public static FurMeshForPolyBrush_Editor selectedGUI;
    FurMeshForPolyBrush data;

    SerializedProperty hasRootFurMeshProp;
    SerializedProperty useThread, height, slice, threshodCurve, tiltingUV1, triangleCull, bakedPaintMap;

    private void OnEnable()
    {
        data = target as FurMeshForPolyBrush;
        var editorType = typeof(FurMeshForPolyBrush_Editor);
        string[] propNames = new string[] { nameof(data.rootFurMeshGroup), nameof(data.useThread), nameof(data.height), nameof(data.slice), nameof(data.threshodCurve), nameof(data.tiltingUV1), nameof(data.triangleCull), nameof(data.bakedPaintMap) };

        var fields = editorType.GetFields(BindingFlags.Instance | BindingFlags.NonPublic);
        var spFields = fields.ToList().FindAll(f => f.FieldType == typeof(SerializedProperty));

        spFields.RemoveAll(f => f.Name == "m_EnabledProperty");

        for (int i = 0; i < propNames.Length; i++)
        {
            spFields[i].SetValue(this, serializedObject.FindProperty(propNames[i]));
        }

        selectedGUI = this;
    }
    public override void OnInspectorGUI()
    {
        if (data.furMesh)
        {
            GUILayout.Label(string.Format("Vertex: {0:#,00}; Triangle: {1:#,00};", data.furMesh.vertexCount, data.furMesh.triangles.Length / 3), EditorStyles.boldLabel);
            GUILayout.Space(10);
        }

        bool hasRootFurMesh = data.rootFurMeshGroup;

        if (hasRootFurMesh)
        {
            EditorGUI.BeginDisabledGroup(hasRootFurMesh);
            EditorGUILayout.PropertyField(hasRootFurMeshProp);
            EditorGUI.EndDisabledGroup();
            EditorGUILayout.HelpBox("Some attributes cannot modify because it's controlled by FurMeshGroup", MessageType.Info);

        }
        EditorGUI.BeginDisabledGroup(hasRootFurMesh);
        EditorGUILayout.PropertyField(useThread);
        EditorGUILayout.PropertyField(height);
        EditorGUILayout.PropertyField(slice);
        EditorGUILayout.PropertyField(threshodCurve);
        EditorGUI.EndDisabledGroup();
        EditorGUILayout.PropertyField(tiltingUV1);
        EditorGUI.BeginDisabledGroup(hasRootFurMesh);
        EditorGUILayout.PropertyField(triangleCull);
        EditorGUI.EndDisabledGroup();

        GUILayout.Space(10);
        EditorGUILayout.PropertyField(bakedPaintMap);

        serializedObject.ApplyModifiedProperties();

        GUILayout.Space(10);
        if(GUILayout.Button("Export Painted Map"))
        {
            ExportPaintChanel();
        }
    }

    void ExportPaintChanel()
    {
        Transform transformInstance = ((GameObject)PrefabUtility.InstantiatePrefab(AssetDatabase.LoadAssetAtPath<GameObject>(AssetDatabase.GUIDToAssetPath("6c011b846e8638d45b35325ce5f78d52")))).transform;
        Material materialTemplate1 = AssetDatabase.LoadAssetAtPath<Material>(AssetDatabase.GUIDToAssetPath("78630c60aac73da439ca06eb52d0a4ee"));
        Material materialTemplate2 = AssetDatabase.LoadAssetAtPath<Material>(AssetDatabase.GUIDToAssetPath("0ee54f6ff907d5c4094e698cc4ef1cf7"));

        var currentRenderer = data.GetComponent<MeshRenderer>();

        var currentBuffer = TextureExtension.CreateRenderTexture(data.gameObject.name, math.float2(2048), RenderTextureFormat.ARGBHalf, Color.clear, false);
        var cameraInstance = transformInstance.GetComponent<Camera>();
        //currentRenderer.SetPropertyBlock(currentBlock);
        cameraInstance.targetTexture = currentBuffer;
        var aabb = currentRenderer.bounds;

        transformInstance.position = aabb.center;
        float maxSize = math.max(aabb.size.z, math.max(aabb.size.x, aabb.size.y));
        cameraInstance.orthographicSize = maxSize * 0.5f;
        cameraInstance.nearClipPlane = -maxSize * 0.5f;
        cameraInstance.farClipPlane = +maxSize * 0.5f;


        currentRenderer.sharedMaterials = new Material[] { currentRenderer.sharedMaterial, materialTemplate1 };
        cameraInstance.Render();
        Texture2D color1 = new Texture2D(currentBuffer.width, currentBuffer.height, TextureFormat.RGBAHalf, false, true);
        currentBuffer.CopyToTex2D(color1);
        byte[] dataColor1 = color1.EncodeToEXR(Texture2D.EXRFlags.CompressPIZ);
        string path1 = Path.GetDirectoryName(AssetDatabase.GetAssetPath(currentRenderer.sharedMaterial)) + "/" + data.srcMesh.name + "_" + "Baked_Paint_123" + ".exr";
        System.IO.File.WriteAllBytes(Application.dataPath.Replace("/Assets", "/" + path1), dataColor1);


        currentRenderer.sharedMaterials = new Material[] { currentRenderer.sharedMaterial, materialTemplate2 };
        cameraInstance.Render();
        Texture2D color2 = new Texture2D(currentBuffer.width, currentBuffer.height, TextureFormat.RGBAHalf, false, true);
        currentBuffer.CopyToTex2D(color2);
        byte[] dataColor2 = color2.EncodeToEXR(Texture2D.EXRFlags.CompressPIZ);
        string path2 = Path.GetDirectoryName(AssetDatabase.GetAssetPath(currentRenderer.sharedMaterial)) + "/" + data.srcMesh.name + "_" + "Baked_Paint_b4" + ".exr";
        System.IO.File.WriteAllBytes(Application.dataPath.Replace("/Assets", "/" + path2), dataColor2);



        currentRenderer.sharedMaterials = new Material[] { currentRenderer.sharedMaterial };

        dataColor1 = dataColor2 = null;
        DestroyImmediate(color1); DestroyImmediate(color2);
        color1 = color2 = null;


        cameraInstance.targetTexture = null;
        DestroyImmediate(currentBuffer);
        currentBuffer = null;
        DestroyImmediate(transformInstance.gameObject);

        AssetDatabase.Refresh();
        color1 = AssetDatabase.LoadAssetAtPath<Texture2D>(path1);
        EditorGUIUtility.PingObject(color1);
    }
}
#endif

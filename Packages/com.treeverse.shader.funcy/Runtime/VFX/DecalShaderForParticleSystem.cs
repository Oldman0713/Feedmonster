using System.Collections;
using System.Collections.Generic;
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif
[ExecuteAlways]
[RequireComponent(typeof(ParticleSystem))]
public class DecalShaderForParticleSystem : MonoBehaviour
{
    ParticleSystem ps;
    ParticleSystemRenderer ren;
    MaterialPropertyBlock block;

    private void OnEnable()
    {
        ps = GetComponent<ParticleSystem>();
        ren = GetComponent<ParticleSystemRenderer>();
        block = new MaterialPropertyBlock();
        block.Clear();
        ren.GetPropertyBlock(block);
        List<ParticleSystemVertexStream> streams = new List<ParticleSystemVertexStream>();
        streams.AddRange(new ParticleSystemVertexStream[] {
         ParticleSystemVertexStream.Position,
         ParticleSystemVertexStream.Color,
         ParticleSystemVertexStream.UV,
         ParticleSystemVertexStream.UV2,
         ParticleSystemVertexStream.Custom1XYZW,
         ParticleSystemVertexStream.Custom2XYZW,
         ParticleSystemVertexStream.Center,
         ParticleSystemVertexStream.VertexID,
         ParticleSystemVertexStream.Rotation3D,
         ParticleSystemVertexStream.MeshIndex,
         ParticleSystemVertexStream.SizeXYZ,
        });
        ren.SetActiveVertexStreams(streams);
    }

    void Update()
    {
        block.SetMatrix("_w2o", ren.worldToLocalMatrix);
        ren.SetPropertyBlock(block);
    }

    private void OnDisable()
    {
        ren.SetPropertyBlock(null);
        block.Clear();
        block = null;
    }
}
#if UNITY_EDITOR
[CustomEditor(typeof(DecalShaderForParticleSystem))]
public class DecalShaderForParticleSystem_Editor : Editor
{
    DecalShaderForParticleSystem data;
    private void OnEnable()
    {
        data = target as DecalShaderForParticleSystem;
    }

    public override void OnInspectorGUI()
    {
        
    }
    private void OnDisable()
    {
        
    }
}
#endif

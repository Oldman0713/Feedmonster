﻿using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;


public class Blit : ScriptableRendererFeature
{
    public class BlitPass : ScriptableRenderPass
    {

        public Material blitMaterial = null;
        
        private BlitSettings settings;

        private RenderTargetIdentifier source { get; set; }
        private RenderTargetIdentifier destination { get; set; }

        RenderTargetHandle m_TemporaryColorTexture;
        RenderTargetHandle m_DestinationTexture;
        string m_ProfilerTag;

#if !UNITY_2020_2_OR_NEWER // v8
        private ScriptableRenderer renderer;
#endif

        public BlitPass(RenderPassEvent renderPassEvent, BlitSettings settings, string tag)
        {
            this.renderPassEvent = renderPassEvent;
            this.settings = settings;
            blitMaterial = settings.blitMaterial;
            m_ProfilerTag = tag;
            m_TemporaryColorTexture.Init("_TemporaryColorTexture");
            if (settings.dstType == Target.Texture)
            {
                m_DestinationTexture.Init(settings.dstTextureId);
            }
        }

        public void Setup(ScriptableRenderer renderer)
        {
#if UNITY_2020_2_OR_NEWER // v10+
            if (settings.requireDepthNormals)
                ConfigureInput(ScriptableRenderPassInput.Normal);
#else // v8
            this.renderer = renderer;
#endif
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmd = CommandBufferPool.Get(m_ProfilerTag);
            RenderTextureDescriptor opaqueDesc = renderingData.cameraData.cameraTargetDescriptor;
            opaqueDesc.depthBufferBits = 0;

            // Set Source / Destination
#if UNITY_2020_2_OR_NEWER // v10+
            var renderer = renderingData.cameraData.renderer;
#else // v8
            // For older versions, cameraData.renderer is internal so can't be accessed. Will pass it through from AddRenderPasses instead
            var renderer = this.renderer;
#endif

            // note : Seems this has to be done in here rather than in AddRenderPasses to work correctly in 2021.2+
            if (settings.srcType == Target.CameraColor)
            {
                source = renderer.cameraColorTarget;
            }
            else if (settings.srcType == Target.Texture)
            {
                source = new RenderTargetIdentifier(settings.srcTextureId);
            }


            if (settings.dstType == Target.CameraColor)
            {
                destination = renderer.cameraColorTarget;
            }
            else if (settings.dstType == Target.Texture)
            {
                destination = new RenderTargetIdentifier(settings.dstTextureId);
            }


            if (settings.setInverseViewMatrix)
            {
                Shader.SetGlobalMatrix("_InverseView", renderingData.cameraData.camera.cameraToWorldMatrix);
            }

            if (settings.dstType == Target.Texture)
            {
                if (settings.overrideGraphicsFormat)
                {
                    opaqueDesc.graphicsFormat = settings.graphicsFormat;
                }
                opaqueDesc.width /= settings.downSample;
                opaqueDesc.height /= settings.downSample;
                cmd.GetTemporaryRT(m_DestinationTexture.id, opaqueDesc, settings.filterMode);
            }

            //Debug.Log($"src = {source},     dst = {destination} ");
            // Can't read and write to same color target, use a TemporaryRT
            if (source == destination || (settings.srcType == settings.dstType && settings.srcType == Target.CameraColor))
            {
                opaqueDesc.colorFormat = RenderTextureFormat.ARGBHalf;
                cmd.GetTemporaryRT(m_TemporaryColorTexture.id, opaqueDesc, settings.filterMode);
                Blit(cmd, source, m_TemporaryColorTexture.Identifier(), blitMaterial, settings.blitMaterialPassIndex);
                Blit(cmd, m_TemporaryColorTexture.Identifier(), destination);
            }
            else
            {
                Blit(cmd, source, destination, blitMaterial, settings.blitMaterialPassIndex);
            }

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        public override void FrameCleanup(CommandBuffer cmd)
        {
            if (settings.dstType == Target.Texture)
            {
                cmd.ReleaseTemporaryRT(m_DestinationTexture.id);
            }
            if (source == destination || (settings.srcType == settings.dstType && settings.srcType == Target.CameraColor))
            {
                cmd.ReleaseTemporaryRT(m_TemporaryColorTexture.id);
            }
        }
    }

    [System.Serializable]
    public class BlitSettings
    {
        public RenderPassEvent Event = RenderPassEvent.AfterRenderingOpaques;

        public Material blitMaterial = null;
        public int blitMaterialPassIndex = 0;
        public bool setInverseViewMatrix = false;
        public bool requireDepthNormals = false;

        public Target srcType = Target.CameraColor;
        public string srcTextureId = "_CameraColorTexture";

        public Target dstType = Target.CameraColor;
        public string dstTextureId = "_BlitPassTexture";

        public bool overrideGraphicsFormat = false;
        public UnityEngine.Experimental.Rendering.GraphicsFormat graphicsFormat;

        public FilterMode filterMode = FilterMode.Bilinear;

        [Range(1, 16)]
        public int downSample = 1;
    }



    public BlitSettings settings = new BlitSettings();
    public BlitPass? blitPass;

    public override void Create()
    {
        var passIndex = settings.blitMaterial != null ? settings.blitMaterial.passCount - 1 : 1;
        settings.blitMaterialPassIndex = Mathf.Clamp(settings.blitMaterialPassIndex, -1, passIndex);
        blitPass = new BlitPass(settings.Event, settings, name);

#if !UNITY_2021_2_OR_NEWER
        if (settings.Event == RenderPassEvent.AfterRenderingPostProcessing)
        {
            Debug.LogWarning("Note that the \"After Rendering Post Processing\"'s Color target doesn't seem to work? (or might work, but doesn't contain the post processing) :( -- Use \"After Rendering\" instead!");
        }
#endif

        if (settings.graphicsFormat == UnityEngine.Experimental.Rendering.GraphicsFormat.None)
        {
            settings.graphicsFormat = SystemInfo.GetGraphicsFormat(UnityEngine.Experimental.Rendering.DefaultFormat.HDR);
        }
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {

        if (settings.blitMaterial == null)
        {
            Debug.LogWarningFormat("Missing Blit Material. {0} blit pass will not execute. Check for missing reference in the assigned renderer.", GetType().Name);
            return;
        }

#if !UNITY_2021_2_OR_NEWER
        // AfterRenderingPostProcessing event is fixed in 2021.2+ so this workaround is no longer required

        if (settings.Event == RenderPassEvent.AfterRenderingPostProcessing)
        {
        }
        else if (settings.Event == RenderPassEvent.AfterRendering && renderingData.postProcessingEnabled)
        {
            // If event is AfterRendering, and src/dst is using CameraColor, switch to _AfterPostProcessTexture instead.
            if (settings.srcType == Target.CameraColor)
            {
                settings.srcType = Target.TextureID;
                settings.srcTextureId = "_AfterPostProcessTexture";
            }
            if (settings.dstType == Target.CameraColor)
            {
                settings.dstType = Target.TextureID;
                settings.dstTextureId = "_AfterPostProcessTexture";
            }
        }
        else
        {
            // If src/dst is using _AfterPostProcessTexture, switch back to CameraColor
            if (settings.srcType == Target.TextureID && settings.srcTextureId == "_AfterPostProcessTexture")
            {
                settings.srcType = Target.CameraColor;
                settings.srcTextureId = "";
            }
            if (settings.dstType == Target.TextureID && settings.dstTextureId == "_AfterPostProcessTexture")
            {
                settings.dstType = Target.CameraColor;
                settings.dstTextureId = "";
            }
        }
#endif

        blitPass.Setup(renderer);
        renderer.EnqueuePass(blitPass);
    }
}




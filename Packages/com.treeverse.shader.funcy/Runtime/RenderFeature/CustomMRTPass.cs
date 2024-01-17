using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Scripting.APIUpdating;

public class CustomMRTPass : ScriptableRendererFeature
{
    public Settings settings = new Settings();

    [System.Serializable]
    public class Settings : PassRenderSettings
    {
        public List<string> MRTNames = new List<string>();
        public bool clear = false;
        public Color clearColor = Color.clear;
        public bool clearDepth = false;
    }

    Pass? pass;
    public class Pass : ScriptableRenderPass
    {
        Settings settings;
        RenderObjectType renderObjectType;
        FilteringSettings m_FilteringSettings;
        string m_ProfilerTag;
        ProfilingSampler m_ProfilingSampler;
        List<ShaderTagId> m_ShaderTagIdList = new List<ShaderTagId>();
        RenderStateBlock m_RenderStateBlock;

        RenderTargetHandle customColor;
        RenderTargetHandle[] m_MRTs;
        RenderTargetIdentifier[] _mrt;

        public Pass(string name, Settings settings)
        {
            this.settings = settings;

            base.profilingSampler = new ProfilingSampler(nameof(Pass));

            m_ProfilerTag = name;
            m_ProfilingSampler = new ProfilingSampler(name);

            this.renderPassEvent = settings.Event;
            this.renderObjectType = settings.filterSettings.RenderObjectType;

            m_FilteringSettings = new FilteringSettings(settings.renderQueueRange, settings.filterSettings.LayerMask);

            foreach (var passName in settings.filterSettings.PassNames)
            {
                m_ShaderTagIdList.Add(new ShaderTagId(passName));
            }

            m_RenderStateBlock = new RenderStateBlock(RenderStateMask.Nothing);

            if (settings.dstType == Target.Texture)
            {
                customColor.Init(settings.dstName);
            }

            _mrt = new RenderTargetIdentifier[1 + settings.MRTNames.Count];
            m_MRTs = new RenderTargetHandle[settings.MRTNames.Count];
            for (int i = 0; i < settings.MRTNames.Count; i++)
            {
                m_MRTs[i].Init(settings.MRTNames[i]);
            }
        }

        RenderTextureDescriptor desc;
        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            desc = new RenderTextureDescriptor(cameraTextureDescriptor.width / settings.downSample, cameraTextureDescriptor.height / settings.downSample, settings.dstFormat, 0);
            if (settings.dstType == Target.Texture)
            {
                cmd.GetTemporaryRT(customColor.id, desc, settings.filterMode);
            }

            for (int i = 0; i < settings.MRTNames.Count; i++)
            {
                cmd.GetTemporaryRT(m_MRTs[i].id, desc);
                _mrt[i + 1] = m_MRTs[i].Identifier();
            }

        }

        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            if (desc.width <= 0 || desc.height <= 0) return;
            if (settings.dstType == Target.Texture)
            {
                _mrt[0] = customColor.Identifier();
            }
            else
            {
                _mrt[0] = renderingData.cameraData.renderer.cameraColorTarget;
            }

            for (int i = 0; i < settings.MRTNames.Count; i++)
            {
                cmd.GetTemporaryRT(m_MRTs[i].id, desc);
                _mrt[i + 1] = m_MRTs[i].Identifier();
            }

            ConfigureTarget(_mrt, renderingData.cameraData.renderer.cameraDepthTarget);
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            if (settings.sceneViewOnly)
            {
                if (!renderingData.cameraData.isSceneViewCamera)
                {
                    return;
                }
            }

            SortingCriteria sortingCriteria = (renderObjectType == RenderObjectType.Transparent)
                ? SortingCriteria.CommonTransparent
                : renderingData.cameraData.defaultOpaqueSortFlags;

            DrawingSettings drawingSettings = CreateDrawingSettings(m_ShaderTagIdList, ref renderingData, sortingCriteria);

            ref CameraData cameraData = ref renderingData.cameraData;
            Camera camera = cameraData.camera;

            // NOTE: Do NOT mix ProfilingScope with named CommandBuffers i.e. CommandBufferPool.Get("name").
            // Currently there's an issue which results in mismatched markers.
            CommandBuffer cmd = CommandBufferPool.Get();

            using (new ProfilingScope(cmd, m_ProfilingSampler))
            {
                if (RenderSettings.skybox && settings.clear)
                {
                    cmd.ClearRenderTarget(settings.clearDepth, true, settings.clearColor);
                }
                // Ensure we flush our command-buffer before we render...
                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();

                // Render the objects...
                context.DrawRenderers(renderingData.cullResults, ref drawingSettings, ref m_FilteringSettings, ref m_RenderStateBlock);
            }
            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }


        public override void FrameCleanup(CommandBuffer cmd)
        {
            if (settings.dstType == Target.Texture)
            {
                cmd.ReleaseTemporaryRT(customColor.id);
            }
            for (int i = 0; i < settings.MRTNames.Count; i++)
            {
                cmd.ReleaseTemporaryRT(m_MRTs[i].id);
            }
        }
    }
    public override void Create()
    {
        FilterSettings filter = settings.filterSettings;

        // Render Objects pass doesn't support events before rendering prepasses.
        // The camera is not setup before this point and all rendering is monoscopic.
        // Events before BeforeRenderingPrepasses should be used for input texture passes (shadow map, LUT, etc) that doesn't depend on the camera.
        // These events are filtering in the UI, but we still should prevent users from changing it from code or
        // by changing the serialized data.
        if (settings.Event < RenderPassEvent.BeforeRenderingPrePasses)
        {
            settings.Event = RenderPassEvent.BeforeRenderingPrePasses;
        }

        switch (settings.filterSettings.RenderObjectType)
        {
            case RenderObjectType.Transparent:
                settings.renderQueueRange = RenderQueueRange.transparent;
                break;
            case RenderObjectType.Opaque:
                settings.renderQueueRange = RenderQueueRange.opaque;
                break;
            default:
                settings.renderQueueRange = RenderQueueRange.all;
                break;
        }
        settings.renderQueueRange.lowerBound = settings.limitQueueRange.x;
        settings.renderQueueRange.upperBound = settings.limitQueueRange.y;

        pass = new Pass(name, settings);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (settings.sceneViewOnly)
        {
            if (!renderingData.cameraData.isSceneViewCamera)
            {
                return;
            }
        }
        if (settings.gameViewOnly)
        {
            if (renderingData.cameraData.isSceneViewCamera)
            {
                return;
            }
        }
        renderer.EnqueuePass(pass);
    }

}



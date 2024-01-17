using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
public enum RenderObjectType
{
    Opaque,
    Transparent,
    All
}

public enum Target
{
    CameraColor,
    Texture
}

[System.Serializable]
public class PassRenderSettings
{
    public RenderPassEvent Event = RenderPassEvent.AfterRenderingOpaques;
    public FilterSettings filterSettings = new FilterSettings();
    public FilterMode filterMode = FilterMode.Point;
    public Vector2Int limitQueueRange = new Vector2Int(2000, 3000);

    public Target dstType = Target.CameraColor;
    public string dstName = "_CustomPassBuffer";
    public RenderTextureFormat dstFormat = RenderTextureFormat.ARGBHalf;
    public bool writeDefaultDepth = true;
    [Range(1, 16)] public int downSample = 1;    
    
    //No Drawing Properties
    public RenderQueueRange renderQueueRange;
    public bool sceneViewOnly = false;
    public bool gameViewOnly = false;
}

[System.Serializable]
public class FilterSettings
{
    // TODO: expose opaque, transparent, all ranges as drop down
    public RenderObjectType RenderObjectType;
    public LayerMask LayerMask = -1;
    public string[] PassNames = new string[0];

    public FilterSettings()
    {
        RenderObjectType = RenderObjectType.Opaque;
        LayerMask = 0;
    }
}

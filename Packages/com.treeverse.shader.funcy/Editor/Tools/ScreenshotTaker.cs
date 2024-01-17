//C# Example
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using Unity.Mathematics;
using System.Reflection;

[ExecuteInEditMode]
public class Screenshot : EditorWindow
{
	int resWidth = 1920; 
	int resHeight = 1080;

	public Camera myCamera;
	int scale = 1;

	string path = "";
	bool showPreview = true;
	RenderTexture renderTexture;

    ComputeShader cs;

	// Add menu item named "My Window" to the Window menu
	[MenuItem("Tools/ScreenShot")]
	public static void ShowWindow()
	{
		//Show existing window instance. If one doesn't exist, make one.
		EditorWindow editorWindow = EditorWindow.GetWindow(typeof(Screenshot));
		editorWindow.autoRepaintOnSceneChange = true;
		editorWindow.Show();
        editorWindow.titleContent = new GUIContent("Screenshot");
	}

	float lastTime;
    Blit linearToSRGB;
    UniversalAdditionalCameraData cameraData;
    private void OnEnable()
    {
        cs = AssetDatabase.LoadAssetAtPath<ComputeShader>(AssetDatabase.GUIDToAssetPath("ae9bdf2b700018642802c79f4ebec86e"));
    }

    void OnGUI()
	{
		EditorGUILayout.LabelField ("Resolution", EditorStyles.boldLabel);
		resWidth = EditorGUILayout.IntField ("Width", resWidth);
		resHeight = EditorGUILayout.IntField ("Height", resHeight);

		EditorGUILayout.Space();

		scale = EditorGUILayout.IntSlider ("Scale", scale, 1, 15);

		EditorGUILayout.HelpBox("The default mode of screenshot is crop - so choose a proper width and height. The scale is a factor " +
			"to multiply or enlarge the renders without loosing quality.",MessageType.None);

		
		EditorGUILayout.Space();
		
		
		GUILayout.Label ("Save Path", EditorStyles.boldLabel);

		EditorGUILayout.BeginHorizontal();
		EditorGUILayout.TextField(path,GUILayout.ExpandWidth(false));
		if(GUILayout.Button("Browse",GUILayout.ExpandWidth(false)))
			path = EditorUtility.SaveFolderPanel("Path to Save Images",path, UnityEngine.Application.dataPath);

		EditorGUILayout.EndHorizontal();

		EditorGUILayout.HelpBox("Choose the folder in which to save the screenshots ",MessageType.None);
		EditorGUILayout.Space();



		//isTransparent = EditorGUILayout.Toggle(isTransparent,"Transparent Background");



		GUILayout.Label ("Select Camera", EditorStyles.boldLabel);


		myCamera = EditorGUILayout.ObjectField(myCamera, typeof(Camera), true,null) as Camera;

        
		if(myCamera == null)
		{
			myCamera = Camera.main;
		}
        else
        {
            cameraData = myCamera.GetComponent<UniversalAdditionalCameraData>();
        }


        //isTransparent = EditorGUILayout.Toggle("Transparent Background", isTransparent);


        EditorGUILayout.HelpBox("Choose the camera of which to capture the render. You can make the background transparent using the transparency option.",MessageType.None);

		EditorGUILayout.Space();
		EditorGUILayout.BeginVertical();
		EditorGUILayout.LabelField ("Default Options", EditorStyles.boldLabel);


		EditorGUILayout.EndVertical();

		EditorGUILayout.Space();
		EditorGUILayout.LabelField ("Screenshot will be taken at " + resWidth*scale + " x " + resHeight*scale + " px", EditorStyles.boldLabel);

		if(GUILayout.Button("Take Screenshot",GUILayout.MinHeight(60)))
		{
			if(path == "")
			{
				path = EditorUtility.SaveFolderPanel("Path to Save Images",path, UnityEngine.Application.dataPath);
				Debug.Log("Path Set");
				TakeHiResShot();
			}
			else
			{
				TakeHiResShot();
			}
		}

		EditorGUILayout.Space();
		EditorGUILayout.BeginHorizontal();

		if(GUILayout.Button("Open Last Screenshot",GUILayout.MaxWidth(160),GUILayout.MinHeight(40)))
		{
			if(lastScreenshot != "")
			{
                UnityEngine.Application.OpenURL("file://" + lastScreenshot);
				Debug.Log("Opening File " + lastScreenshot);
			}
		}

		if(GUILayout.Button("Open Folder",GUILayout.MaxWidth(100),GUILayout.MinHeight(40)))
		{

            UnityEngine.Application.OpenURL("file://" + path);
		}

		
		EditorGUILayout.EndHorizontal();


		if (takeHiResShot) 
		{
            //RenderPipelineManager.endCameraRendering += ScreenShotAction;
            var nullCTX = new ScriptableRenderContext();
            ScreenShotAction(nullCTX, myCamera);

            takeHiResShot = false;
		}

		EditorGUILayout.HelpBox("In case of any error, make sure you have Unity Pro as the plugin requires Unity Pro to work.",MessageType.Info);


	}

    void ScreenShotAction(ScriptableRenderContext ctx, Camera camera)
    {
        if (camera != myCamera) return;


        if (cameraData != null)
        {
            int index = (int)typeof(UniversalAdditionalCameraData).GetField("m_RendererIndex", BindingFlags.Instance | BindingFlags.NonPublic).GetValue(cameraData);

            UniversalRenderPipelineAsset pipelineAsset = QualitySettings.GetRenderPipelineAssetAt(QualitySettings.GetQualityLevel()) as UniversalRenderPipelineAsset;
            FieldInfo fieldInfo = pipelineAsset.GetType().GetField("m_RendererDataList", BindingFlags.Instance | BindingFlags.NonPublic);
            ScriptableRendererData[] rendererDatas = fieldInfo.GetValue(pipelineAsset) as UnityEngine.Rendering.Universal.ScriptableRendererData[];
            var rootRenderer = rendererDatas[index] as UniversalRendererData;
            linearToSRGB = rootRenderer.rendererFeatures.Find(x => x.GetType() == typeof(Blit) && x.name == "LinearToSRGB") as Blit;
        }


        int resWidthN = resWidth * scale;
        int resHeightN = resHeight * scale;
        string filename = ScreenShotName(resWidthN, resHeightN);

        if (linearToSRGB != null)
        {
            linearToSRGB.SetActive(true);
        }

        RenderTexture rt = TextureExtension.CreateRenderTexture(filename, new Vector2(resWidthN, resHeightN), RenderTextureFormat.ARGBHalf, Color.clear, true);
        RenderTexture alpha = null;

        if (myCamera.clearFlags == CameraClearFlags.SolidColor)
        {
            alpha = TextureExtension.CreateRenderTexture(filename, new Vector2(resWidthN, resHeightN), RenderTextureFormat.ARGBHalf, Color.clear, true);
            bool isPostEnabled = cameraData.renderPostProcessing;
            myCamera.targetTexture = rt;
            myCamera.Render();
            myCamera.targetTexture = alpha;
            cameraData.renderPostProcessing = false;
            myCamera.Render();
            cameraData.renderPostProcessing = isPostEnabled;

            int kernel = cs.FindKernel("CSMain");
            cs.GetKernelThreadGroupSizes(kernel, out uint x, out uint y, out uint z);
            cs.SetTexture(kernel, "Result", rt);
            cs.SetTexture(kernel, "Alpha", alpha);
            cs.Dispatch(kernel, Mathf.CeilToInt(rt.width / (float)x), Mathf.CeilToInt(rt.height / (float)y), 1);
        }
        else
        {
            myCamera.targetTexture = rt;
            myCamera.Render();
        }
        myCamera.targetTexture = null;

        if (linearToSRGB != null)
        {
            linearToSRGB.SetActive(false);
        }

        TextureFormat tFormat = TextureFormat.RGBAHalf;
        Texture2D screenShot = new Texture2D(resWidthN, resHeightN, tFormat, false);

        rt.CopyToTex2D(screenShot);
        //screenShot.ReadPixels(new Rect(0, 0, resWidthN, resHeightN), 0, 0);

        byte[] bytes = screenShot.EncodeToPNG();


        System.IO.File.WriteAllBytes(filename, bytes);
        Debug.Log(string.Format("Took screenshot to: {0}", filename));
        UnityEngine.Application.OpenURL(filename);
        rt.Release();
        rt = null;
        if (alpha != null)
        {
            alpha.Release();
            alpha = null;
        }
        //RenderPipelineManager.endCameraRendering -= ScreenShotAction;
    }



    private bool takeHiResShot = false;
	public string lastScreenshot = "";
	
		
	public string ScreenShotName(int width, int height) {

		string strPath="";

		strPath = string.Format("{0}/screen_{1}x{2}_{3}.png", 
		                     path, 
		                     width, height, 
		                               System.DateTime.Now.ToString("yyyy-MM-dd_HH-mm-ss"));
		lastScreenshot = strPath;
	
		return strPath;
	}

    public void TakeHiResShot() {
		Debug.Log("Taking Screenshot");
		takeHiResShot = true;
	}

}


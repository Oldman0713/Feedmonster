using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;
using System.IO;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEditor.Build;
using UnityEditor.Build.Reporting;
using System.Threading.Tasks;
using Unity.Mathematics;

[InitializeOnLoad]
public class LightMapCutoutResslover : Editor
{
    static Camera cameraInstance = null;
    static Transform transformInstance = null;

    static List<Shader> includingShader = new List<Shader>();

    static List<MeshRenderer> cutoutTargets = new List<MeshRenderer>();
    static List<Material[]> cutoutSharedMaterials = new List<Material[]>();
    static List<RenderTexture> cutoutBuffers = new List<RenderTexture>();



    const string HeightBlendShader_GUID = "aa3dfb6a01bf1004fa04aa54c122190a";
    const string LitShader_GUID = "44bc3b5d5bcc1684588feaa7f0e75c31";

    static LightMapCutoutResslover()
    {
        EditorApplication.delayCall += () => 
        {
            return;
            GameObject cameraTemplate = AssetDatabase.LoadAssetAtPath<GameObject>(AssetDatabase.GUIDToAssetPath("8788354720fed244ebf8cea1a98729be"));

            //------------Add include shader--------
            string[] guids = new string[] { HeightBlendShader_GUID, LitShader_GUID };
            includingShader.Clear();
            foreach(var guid in guids)
            {
                Shader currentShader = AssetDatabase.LoadAssetAtPath<Shader>(AssetDatabase.GUIDToAssetPath(guid));
                includingShader.Add(currentShader);
            }
            //------------Add include shader---------

            System.Action CleanCameraInstance = () => {

                foreach (var instance in PrefabUtility.FindAllInstancesOfPrefab(cameraTemplate))
                {
                    DestroyImmediate(instance);
                }
            };

            System.Action UpdateCurrentRendererTargets = () => {
                cutoutTargets = FindObjectsOfType<MeshRenderer>(false).Where(x => x.sharedMaterials.ToList().Find(m => m != null && includingShader.IndexOf(m.shader) >= 0) != null).ToList();
            };

            CleanCameraInstance();
            EditorSceneManager.sceneOpened += (scene, mode) => {
                CleanCameraInstance();
                UpdateCurrentRendererTargets();
            };
            
            System.Action UpdateCutoutBuffer = () => {
                var so = PrefabUtility.FindAllInstancesOfPrefab(cameraTemplate);
                if (so.Length < 1)
                {
                    GameObject go = PrefabUtility.InstantiatePrefab(cameraTemplate) as GameObject;
                    go.hideFlags = HideFlags.HideAndDontSave;

                }

                if (so.Length < 1) return;

                cameraInstance = so[0].GetComponent<Camera>();
                transformInstance = so[0].transform;
                cameraInstance.enabled = false;
            };

            UpdateCutoutBuffer();
            Selection.selectionChanged += UpdateCutoutBuffer;
            EditorApplication.hierarchyChanged += UpdateCutoutBuffer;

            UpdateCurrentRendererTargets();
            EditorApplication.hierarchyChanged += UpdateCurrentRendererTargets;

            List<Material> materialtoDestory = null;
            Lightmapping.bakeStarted += () => {
                return;
                UpdateCutoutBuffer();
                cameraInstance.enabled = true;
                //Debug.Log(Lightmapping.isRunning);
                foreach (var cb in cutoutBuffers)
                {
                    DestroyImmediate(cb);
                }
                cutoutBuffers.Clear();

                foreach (var t in cutoutTargets)
                {
                    RenderTexture cbuffer = new RenderTexture(cameraInstance.targetTexture);
                    cutoutBuffers.Add(cbuffer);
                }

                MaterialPropertyBlock currentBlock = new MaterialPropertyBlock();
                currentBlock.Clear();
                cutoutSharedMaterials.Clear();
                materialtoDestory = new List<Material>();
                for (int i = 0; i < cutoutTargets.Count; i++)
                {
                    

                    var currentRenderer = cutoutTargets[i];
                    var currentBuffer = cutoutBuffers[i];
                    Debug.Log(currentRenderer.name);
                    currentBlock.SetFloat("_LightCutoutResslover_Solo", 1.0f);
                    currentRenderer.SetPropertyBlock(currentBlock);

                    var aabb = currentRenderer.bounds;

                    transformInstance.position = aabb.center;
                    float maxSize = math.max(aabb.size.z, math.max(aabb.size.x, aabb.size.y));
                    cameraInstance.orthographicSize = maxSize * 0.5f;
                    cameraInstance.nearClipPlane = -maxSize * 0.5f;
                    cameraInstance.farClipPlane = +maxSize * 0.5f;
                    cameraInstance.Render();
                    Graphics.Blit(cameraInstance.targetTexture, currentBuffer);
                    currentRenderer.SetPropertyBlock(null);

                    var ren = cutoutTargets[i];
                    var cutoutMaterials = ren.sharedMaterials.ToList().Where(m => includingShader.IndexOf(m.shader) >= 0).ToList();
                    cutoutSharedMaterials.Add(cutoutMaterials.ToArray());
                    Material[] overwrireMaterials = new Material[ren.sharedMaterials.Length];
                    for (int j = 0; j < overwrireMaterials.Length; j++) 
                    {
                        overwrireMaterials[j] = ren.sharedMaterials[j];
                    }
                    /*
                    Material bakingMaterial = Instantiate(ren.sharedMaterial);
                    bakingMaterial.name = "Baking Don't touch!!";
                    bakingMaterial.SetOverrideTag("RenderType", "TransparentCutout");
                    ren.sharedMaterials[0] = bakingMaterial;
                    bakingMaterial.SetTexture("_MainTex", cutoutBuffers[i]);
                    */
                    
                    foreach(var cutoutMaterial in cutoutMaterials)
                    {
                        int matIndex = ren.sharedMaterials.ToList().IndexOf(cutoutMaterial);
                        Material bakingMaterial = Instantiate(cutoutMaterial);
                        bakingMaterial.name = "Baking Don't touch!!";
                        bakingMaterial.SetOverrideTag("RenderType", "TransparentCutout");
                        overwrireMaterials[matIndex] = bakingMaterial;
                        bakingMaterial.SetTexture("_MainTex", cutoutBuffers[i]);
                        materialtoDestory.Add(bakingMaterial);
                    }

                    if(ren.sharedMaterial.shader == includingShader[0])
                    {
                        ren.sharedMaterials = overwrireMaterials;
                    }
                    else
                    {
                        foreach(var m in ren.sharedMaterials)
                        {
                            m.SetOverrideTag("RenderType", "TransparentCutout");
                            m.SetTexture("_MainTex", m.GetTexture("_BaseMap"));
                        }
                    }
                }
            };
            
            Lightmapping.bakeCompleted += () => {
                return;
                for (int i = 0; i < cutoutTargets.Count; i++)
                {
                    var ren = cutoutTargets[i];
                    ren.sharedMaterials = cutoutSharedMaterials[i];
                }
                if (materialtoDestory != null)
                {
                    foreach (var m in materialtoDestory)
                    {
                        DestroyImmediate(m);
                    }
                    materialtoDestory.Clear();
                }
                foreach (var cb in cutoutBuffers)
                {
                    DestroyImmediate(cb);
                }
                cutoutBuffers.Clear();

            };

            EditorApplication.update += () => { EditorUtility.SetDirty(cameraTemplate); };
            
        };
    }


}


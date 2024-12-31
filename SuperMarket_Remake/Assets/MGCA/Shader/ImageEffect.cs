using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
public class ImageEffect : MonoBehaviour
{
    private Material mat;
    private Camera cam;
    [Range(0f, 1f)] public float aoStrength = 0f;
    [Range(4, 64)] public int SampleKernelCount = 64;
    private List<Vector4> SampleKernelList = new List<Vector4>();
    [Range(0.0001f, 10f)] public float SampleKernelRadius = 0.01f;
    [Range(0.0001f, 1f)] public float rangeStrength = 0.001f;
    public float depthBiasValue = 0.001f;
    public Texture Noise;

    [Range(0, 2)] public int DownSample = 0;
    [Range(1, 4)] public float BlurRadius = 2;
    public float bilaterFilterStrength = 0.2f;
    public bool OnlyShowAO = false;

    public enum SSAOPassName
    {
        GenerateAO = 0,
        BilateralFilter = 1,
        Composite = 2,
    }
    
    
    private void Awake()
    {
        var shader = Shader.Find("ImageEffect/SSAO");

        mat = new Material(shader);
    }

    private void Start()
    {
        cam = this.GetComponent<Camera>();
        cam.depthTextureMode = cam.depthTextureMode | DepthTextureMode.DepthNormals;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        GenerateAOSampleKernel();
        int rtH = source.height >> DownSample;
        int rtW = source.width >> DownSample;

        RenderTexture aoRT = RenderTexture.GetTemporary(rtW, rtH, 0);
        mat.SetVectorArray("_SampleKernelArray", SampleKernelList.ToArray());
        mat.SetFloat("_RangeStrength",rangeStrength);
        mat.SetFloat("_AOStrength", aoStrength);
        mat.SetFloat("_SampleKernelCount", SampleKernelCount);
        mat.SetFloat("_SampleKernelRadius",SampleKernelRadius);
        mat.SetFloat("_DepthBiasValue",depthBiasValue);
        mat.SetTexture("_NoiseTex",Noise);
        Graphics.Blit(source, aoRT, mat,(int)SSAOPassName.GenerateAO);
        
        RenderTexture blurRT = RenderTexture.GetTemporary(rtW, rtH, 0);
        mat.SetFloat("_BilaterFilterFactor", 1.0f - bilaterFilterStrength);
        mat.SetVector("_BlurRadius",new Vector4(BlurRadius,0,0,0));
        Graphics.Blit(aoRT, blurRT, mat, (int)SSAOPassName.BilateralFilter);
        
        mat.SetVector("_BlurRadius",new Vector4(0,BlurRadius,0,0));

        if (OnlyShowAO)
        {
            Graphics.Blit(blurRT, destination, mat, (int)SSAOPassName.BilateralFilter);
        }
        else
        {
            Graphics.Blit(blurRT,aoRT,mat,(int)SSAOPassName.BilateralFilter);
            mat.SetTexture("_AOTex",aoRT);
            Graphics.Blit(source,destination, mat, (int)SSAOPassName.Composite);
        }
        
        RenderTexture.ReleaseTemporary(aoRT);
        RenderTexture.ReleaseTemporary(blurRT);
        
    }

    private void GenerateAOSampleKernel()
    {
        if (SampleKernelCount == SampleKernelList.Count)
            return;
        SampleKernelList.Clear();
        for(int i = 0; i < SampleKernelCount; i++)
        {
            var vec = new Vector4(Random.Range(-1.0f, 1.0f), Random.Range(-1.0f, 1.0f), Random.Range(0f, 1.0f), 1.0f);
            vec.Normalize();
            var scale = (float)i/SampleKernelCount;

            scale = Mathf.Lerp(0.01f, 1.0f, scale * scale);
            vec *= scale;
            SampleKernelList.Add(vec);
        }
    }
}

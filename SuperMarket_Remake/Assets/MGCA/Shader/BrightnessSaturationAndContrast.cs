using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SocialPlatforms;
using UnityEngine.UI;
public class BrightnessSaturationAndContrast : postprocess {
    
    public Shader ColorTintShader;
    public Camera mainCamera;
    private Material ColorTintMat;
    [Tooltip("ColorTint")]
    public Color color = new Color (1f, 1f, 1f, 1f);

    [Range(0f, 1f), Tooltip("ColorTintintensity")]
    public float blend = 0.5f;
    
    [Range(1,16)]
    public int Downsample = (int)1f;
    
    public Vector3 _boundsMin = new Vector3(1,1,1);

    public Vector3 _boundsMax = new Vector3(-1, -1, -1);
    
    public float _rayStep = 0.5f;
    
    public float _step = 0.1f;
    
    public Texture _VolumeTex;

    public Texture _WeatherMap;

    public Texture _BlueNoise;

    public Vector4 _BlueNoiseCoords = new Vector4(1f, 1f, 1f, 1f);
    
    public Vector3 _offset = new Vector3(0,0,0);
    
    public Vector3 _uvwScale = new Vector3(1,1,1);
    
    public float _lightAbsorptionTowardSun = 0.5f;
    
    public Color _colA = new Color(1f, 1f, 1f, 1f);
    
    public float _colorOffset1 = 1f;
    
    public Color _colB =new Color(1f, 1f, 1f, 1f) ;
    
    public float _colorOffset2 = 1f;
    
    public float _darknessThershold = 1f;
    
    public Vector4 _phaseParams = new Vector4(1f, 1f, 1f,1f) ;
    
    public float _shapeTiling = 0.5f ;
    
    public float _detailTiling = 0.5f ;
    
    public Vector4 _xzSpeed = new Vector4(1f, 1f,1f,1f);
    
    public Texture _noiseTex ;
    
    public Texture _noiseDetail3D ;
    
    public Vector4 _shapeNoiseWeights = new Vector4(1f, 1f, 1f, 1f) ;
    
    public float _densityOffset = 0.5f;
    
    public float _densityMultiplier = 0.5f;
    
    public float _detailWeights = 0.5f ;
    
    public float _detailNoiseWeight =  0.5f ;
    
    public Texture _maskNoise ;
    
    public float _heightWeights = 0.5f;
    
    public float _rayOffsetStrength = 0.5f;
    public Material material{
        get {
            ColorTintMat = CheckShaderAndCreateMaterial(ColorTintShader, ColorTintMat);
            return ColorTintMat;
        }
    }
    

    void OnRenderImage(RenderTexture src, RenderTexture dest) {
        if(material != null){
            ColorTintMat.SetColor("_Color",color);
            ColorTintMat.SetFloat("_BlendMultiply",blend);
            ColorTintMat.SetVector("_boundsMin",_boundsMin);
            ColorTintMat.SetVector("_boundsMax",_boundsMax);
            ColorTintMat.SetFloat("_rayStep",_rayStep);
            ColorTintMat.SetFloat("_step",_step);
            ColorTintMat.SetVector("_offset",_offset);
            ColorTintMat.SetVector("_uvwScale",_uvwScale);
            ColorTintMat.SetTexture("_VolumeTex",_VolumeTex);
            ColorTintMat.SetTexture("_BlueNoise",_BlueNoise);
            ColorTintMat.SetFloat("_lightAbsorptionTowardSun",_lightAbsorptionTowardSun);
            ColorTintMat.SetVector("_colA",_colA);
            ColorTintMat.SetVector("_colB",_colB);
            ColorTintMat.SetFloat("_colorOffset1",_colorOffset1);
            ColorTintMat.SetFloat("_colorOffset2",_colorOffset2);
            ColorTintMat.SetFloat("_darknessThershold",_darknessThershold);
            ColorTintMat.SetVector("_phaseParams",_phaseParams);
            ColorTintMat.SetTexture("_WeatherMap",_WeatherMap);
            ColorTintMat.SetFloat("_shapeTiling",_shapeTiling);
            ColorTintMat.SetVector("_xzSpeed",_xzSpeed);
            ColorTintMat.SetTexture("_noiseTex",_noiseTex);
            ColorTintMat.SetVector("_shapeNoiseWeights", _shapeNoiseWeights);
            ColorTintMat.SetFloat("_densityOffset",_densityOffset);
            ColorTintMat.SetFloat("_densityMultiplier",_densityMultiplier);
            ColorTintMat.SetFloat("_detailTiling",_detailTiling);
            ColorTintMat.SetTexture("_noiseDetail3D",_noiseDetail3D);
            ColorTintMat.SetFloat("_detailWeights",_detailWeights);
            ColorTintMat.SetFloat("_detailNoiseWeight",_detailNoiseWeight);
            ColorTintMat.SetTexture("_maskNoise",_maskNoise);
            ColorTintMat.SetFloat("_heightWeights",_heightWeights);
            ColorTintMat.SetVector("_BlueNoiseCoords",_BlueNoiseCoords);
            ColorTintMat.SetFloat("_rayOffsetStrength",_rayOffsetStrength);
            Matrix4x4 projectionMatrix = GL.GetGPUProjectionMatrix(mainCamera.projectionMatrix, false);
            ColorTintMat.SetMatrix(Shader.PropertyToID("_InverseProjectionMatrix"), projectionMatrix.inverse);
            ColorTintMat.SetMatrix(Shader.PropertyToID("_InverseViewMatrix"),mainCamera.cameraToWorldMatrix);

            int width = Screen.width / Downsample;
            int height = Screen.height / Downsample;
            RenderTexture RT2 = RenderTexture.GetTemporary(width, height, 0);
            Graphics.Blit (src, dest, ColorTintMat, 0);
            // ColorTintMat.SetTexture("_DownsampleColor",RT2);
            // Graphics.Blit (src, dest, ColorTintMat, 2);
            // RenderTexture.ReleaseTemporary(RT2);
        }
        else{
            Graphics.Blit(src,dest);
            Debug.LogError("Shader is missing!");
        }
    }
}


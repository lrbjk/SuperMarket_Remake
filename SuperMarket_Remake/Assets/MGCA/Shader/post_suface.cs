using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
public class post_suface : MonoBehaviour
{
    public Material material;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        RenderTexture RT1 = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
        Graphics.Blit(source, RT1,material,0);
        Graphics.Blit(RT1, destination,material,1);
    }
}

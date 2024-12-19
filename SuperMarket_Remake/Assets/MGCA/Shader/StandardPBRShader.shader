Shader "Custom/StandardPBRShader"
{
    Properties
    {
        _MainTex("BC",2D) = "white"{}
        _Normal("N",2D) = "white"{}
        _PBR("PBR",2D) = "black"{}
        _AO("AO",2D) = "white"{}
        _Alpha("A",2D) = "white"{}
        _height("Height",2D) = "black"{}
        _Emission("E",2D) = "black"{}
        _Roughness("R",2D) = "black"{}
        _Color("Color",Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        CULL Off
 
        CGPROGRAM
        #include "UnityCG.cginc"
        
        #pragma surface surf Standard vertex :myvert fullforwardshadows
        
        #pragma target 3.0
 
        sampler2D _MainTex;
        sampler2D _Normal;
        sampler2D _PBR;
        sampler2D _AO;
        sampler2D _Alpha;
        sampler2D _height;
        sampler2D _Emission;
        sampler2D _Roughness;

        half4 _Color;
 
        struct Input
        {
            float2 uv_MainTex;
            float2 uv_Normal;
            float2 uv_PBR;
            float2 uv_AO;
            float2 uv_Alpha;
            float2 uv_height;
            float2 uv_Emission;
        };
        
        void myvert(inout appdata_full v,Input IN)
        {
            v.vertex.xyz += tex2Dlod(_height,float4(IN.uv_height,0,0));
        }
 
        // The Surface Shader function
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            half4 albedo = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            float4 PBR = tex2D(_PBR,IN.uv_PBR);
            o.Albedo = albedo.rgb ;
            o.Metallic = PBR.b;
            o.Smoothness = max(PBR.g * PBR.b + tex2D(_Roughness,IN.uv_PBR)-0.2,0);
            o.Occlusion = PBR.r + tex2D(_AO,IN.uv_AO);
            o.Normal = UnpackNormal(tex2D(_Normal,IN.uv_Normal));
            o.Alpha = tex2D(_Alpha,IN.uv_Alpha).r;
            o.Emission = tex2D(_Emission,IN.uv_Emission);
        }
        
        ENDCG
    }
    FallBack "Diffuse"
}
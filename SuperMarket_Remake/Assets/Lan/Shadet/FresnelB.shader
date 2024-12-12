Shader "Custom/FresnelB"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _FresnelPow ("菲涅尔强度",float) = 1
        _FresnelColor("菲涅尔颜色",COLOR) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normalDir : TEXCOORD1;
                float4 worldPos : TEXCOORD2;
            };
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _FresnelPow;
            fixed4 _FresnelColor;
            fixed4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : COLOR
            {
                i.normalDir = normalize(i.normalDir);
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                float dotValue = pow(1 - saturate(dot(i.normalDir,viewDir)),_FresnelPow);
                fixed4 resultColor = _FresnelColor;
                resultColor.rgb *= dotValue;
                resultColor = resultColor * _Color;
                return resultColor;
            }
            ENDCG
        }
    }
}


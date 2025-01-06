Shader "Custom/GuanggaoPai"
{
    Properties{
        _MainTex("Main",2D) = "White"{}
        _Color("Color",Color) = (1,1,1,1)
        _VerticalBillboarding("Vertical Restraints",Range(0,1)) = 1
        _OutLineWidth("_OutLineWidth",Float) = 0.002
    }

    SubShader{
        Tags {"Queue" = "Overlay" "IgnoreProjector" = "True" "RenderType" = "Transparent" "DisableBatching" = "True"}
        pass{
            Tags { "LightMode" = "ForwardBase"}

            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _VerticalBillboarding;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.uv = v.texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
                float3 center = float3(0,0,0);
                float3 viewer = mul(unity_WorldToObject,float4(_WorldSpaceCameraPos,1));

                float3 normalDir = viewer - center;
                normalDir.y = normalDir.y  * _VerticalBillboarding;
                normalDir = normalize(normalDir);

                float3 upDir = abs(normalDir.y) > 0.999? float3(0,0,1) : float3(0,1,0);
                float3 rightDir = normalize(cross(upDir,normalDir));
                upDir  = normalize(cross(normalDir,rightDir));

                float3 centerOffs = v.vertex.xyz - center;
                float3 localPos = center + rightDir * centerOffs.x + upDir * centerOffs.y + normalDir * centerOffs.z;

                o.pos = UnityObjectToClipPos(float4(localPos,1));

                return o;

            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 c = tex2D(_MainTex,i.uv);
                c.rgb *= _Color.rgb;

                return c;
            }
            ENDCG
        }

        Pass
        {
            Name"Edge"
            ZTest Always
            Blend One One
            CULL Front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _VerticalBillboarding;
            float _OutLineWidth; 

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.uv = v.texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
                float3 center = float3(0,0,0);
                float3 viewer = mul(unity_WorldToObject,float4(_WorldSpaceCameraPos,1));

                float3 normalDir = viewer - center;
                normalDir.y = normalDir.y  * _VerticalBillboarding;
                normalDir = normalize(normalDir);

                float3 upDir = abs(normalDir.y) > 0.999? float3(0,0,1) : float3(0,1,0);
                float3 rightDir = normalize(cross(upDir,normalDir));
                upDir  = normalize(cross(normalDir,rightDir));

                float3 centerOffs = v.vertex.xyz - center;
                float3 localPos = center + rightDir * centerOffs.x + upDir * centerOffs.y + normalDir * centerOffs.z;

                o.pos = UnityObjectToClipPos(float4(localPos,1));
                o.pos.xyz += _OutLineWidth * normalDir;

                return o;

            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 c = tex2D(_MainTex,i.uv);
                return c;
            }

            
            ENDCG
        }

    }
    Fallback "Transparent/VertexLit"
}
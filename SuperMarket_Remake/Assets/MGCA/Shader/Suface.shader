// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader"suface"
{
    Properties
    {
        _MainTex("Main",2D) = "white"{}
        _OutlineWidth("OutlineWidth",Float) = 1
    }
    
    SubShader
    {
        
        
        Pass
        {
//            Tags {"LightMode" = "For"}
            
            CGPROGRAM
            #pragma target 4.0
            #pragma fragment frag
            #pragma vertex vert

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _OutlineWidth;
            

            struct v2f
            {
                float4 pos : SV_POSITION;
   

                //center 4
                float4 posCS : TEXCOORD0;
                float3 posWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
                float2 uv[9] : TEXCOORD3;

                
            };

            
            v2f vert(appdata_full v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.posWS = mul(unity_ObjectToWorld,v.vertex);
                o.posCS = UnityObjectToClipPos(v.vertex);
                o.normalWS = normalize(UnityObjectToWorldNormal(v.normal));
                o.uv[4] = v.texcoord;

                o.uv[0] = o.uv[4] + float2(-_OutlineWidth,_OutlineWidth);
                o.uv[1] = o.uv[4] + float2(0.0f,_OutlineWidth);
                o.uv[2] = o.uv[4] + float2(_OutlineWidth,_OutlineWidth);
                o.uv[3] = o.uv[4] + float2(-_OutlineWidth,0.0f);
                o.uv[5] = o.uv[4] + float2(_OutlineWidth,0.0f);
                o.uv[6] = o.uv[4] + float2(-_OutlineWidth,-_OutlineWidth);
                o.uv[7] = o.uv[4] + float2(0.0f,_OutlineWidth);
                o.uv[8] = o.uv[4] + float2(_OutlineWidth,_OutlineWidth);
                
                
                return o;
            }

            half luminace(half3 color)
            {
                 return 0.299*color.r + 0.587*color.g + 0.114*color.b;
            }

            half SobelSample(float2 uv[9])
            {
                float2 G;
                const half gx[9] = {-1,0,1,-2,0,2,-1,0,1};
                const half gy[9] = {-1,-2,-1,0,0,0,1,2,1};
                
                for(int i = 0; i < 9 ; i++)
                {
                    half texColor = luminace(tex2D(_MainTex,uv[i]));
                    G.x += texColor * gx[i];
                    G.y += texColor * gy[i];
                }
                return  abs(G.x) + abs(G.y);
            }

            fixed4 frag(v2f IN) : SV_Target
            {
                half3 lightDir = normalize(UnityWorldSpaceLightDir(IN.posWS));
                half3 lightColor = unity_LightColor0.rgb;
                float2 posSS = IN.posCS.xy / IN.posCS.w;

                half3 albedo = tex2D(_MainTex,IN.uv[4]);
                return float4((1-SobelSample(IN.uv)) * albedo,1);
                
                
            }



            
            ENDCG
        }
    }
    Fallback "Standard"
}
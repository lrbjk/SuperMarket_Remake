// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader"suface"
{
    Properties
    {
        _MainTex("Main",2D) = "white"{}
        _OutlineWidth("OutlineWidth",Float) = 1
        _hsv("hsv",Vector)=(1,1,1,1)
        _MasekDark("_MasekDark",Float)=0.2
        _MasekLight("_MasekLight",Float)=0.9
    }
    
    SubShader
    {
        
        Pass
        {
            
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

        Pass
        {
            Name "ERCIYUAN"
            
            CGPROGRAM
            #include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;

            float3 _hsv;

            half _MasekDark;
            half _MasekLight;

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };
            

            float3 RGBToHSV(float3 rgb)
            {
            
                rgb = clamp(rgb, 0.0, 1.0);
 
                float minVal = min(min(rgb.x, rgb.y), rgb.z);
                float maxVal = max(max(rgb.x, rgb.y), rgb.z);
                float delta = maxVal - minVal;
 
                float h, s, v;
 
                v = maxVal;
 
                if (maxVal != 0.0)
                s = delta / maxVal;
                else
                {
                    s = 0.0;
        
                    h = -1.0;
                    return float3(h, s, v);
                }
 
                if (rgb.x == maxVal)
                    h = (rgb.y - rgb.z) / delta;
                else if (rgb.y == maxVal)
                    h = 2.0 + (rgb.z - rgb.x) / delta; 
                else
                    h = 4.0 + (rgb.x - rgb.y) / delta; 
 
                h = h / 6.0; 
                if (h < 0)
                h += 1.0; 
 
                return float3(h, s, v);
            }

            float3 HSVToRGB(float3 hsv)
            {
                hsv = clamp(hsv, 0.0, 1.0); 
 
                float h = hsv.x * 6.0; 
                float s = hsv.y;      
                float v = hsv.z;     
 
                float i = floor(h); 
                float f = h - i;   
                float p = v * (1.0 - s); 
                float q = v * (1.0 - s * f); 
                float t = v * (1.0 - s * (1.0 - f));
 
                float3 rgb;
     
                if (i == 0) { rgb = float3(v, t, p); }
                else if (i == 1) { rgb = float3(q, v, p); }
                else if (i == 2) { rgb = float3(p, v, t); }
                else if (i == 3) { rgb = float3(p, q, v); }
                else if (i == 4) { rgb = float3(t, p, v); }
                else { rgb = float3(v, p, q); }
 
                return rgb;
            }

            half3 colorGrade(half c,half3 abledo)
            {
                if(c < _MasekDark)
                {
                    return 0.8 * abledo;
                }else if(c < _MasekLight)
                {
                    // return lerp(_MasekDark * abledo,_MasekLight*abledo,c/(_MasekLight-_MasekDark));
                    return abledo;
                }else
                {
                    return 1.2 * abledo;
                }
            }

            v2f vert(appdata_base v)
            {
                v2f o;
                o.uv = v.texcoord;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                float3 base = tex2D(_MainTex,i.uv);
                // base = RGBToHSV(base);
                //
                // float cutOUt = clamp(base.z-_hsv.z * base.z,0,1);
                // base = float3(clamp(base.x-_hsv.x * base.x,0,1),clamp(base.y-_hsv.y * base.y,0,1),clamp(base.z-_hsv.z * base.z,0,1));
                //
                //
                //
                // base = HSVToRGB(base);

                half4 finalColor;
                finalColor.w =1;
                finalColor.rgb = colorGrade(Luminance(base),base);

                
                
                return finalColor;
            }
            
            
            ENDCG
        }
    }
    Fallback "Standard"
}
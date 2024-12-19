// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/SkyBox"
{
    Properties
    {
        _MainTex("_MainTex",CUBE)="CUBE"{}
        _SunColor("SunColor",Color)=(1,1,1,1)
        _SunRadius("_SunRadius",Float) = 1
        _MoonColor("_MoonColor",Color)=(1,1,1,1)
        _MoonRadius("_MoonRadius",Float) = 1
        _MoonOffset("_MoonOffset",Float) = 1
        _DayBottomColor("_DayBottomColor",Color) = (0,0,0,0)
        _DayTopColor("_DayTopColor",Color) = (1,1,1,1)
        _NightBottomColor("_DayBottomColor",Color) = (0,0,0,0)
        _NightTopColor("_DayTopColor",Color) = (1,1,1,1)
        _Stars("_Stars",2D)="black"{}
        _StarsSpeed("_StarsSpeed",Float) = 1
        _StarsCutOff("_StarsCutOff",Range(0,1)) = 0.5
        _Cloud("_Cloud",2D) = "white"{}
        _CloudSpeed("_CloudSpeed",Float) = 1
        _CloudCutOff("_CloudCutOff",Float) = 0.5
        _DistortTex("_DistortTex",2D) = "white"{}
        _DistortionSpeed("_DistortionSpeed",Float) = 1
        _DistortScale("_DistortScale",Float) = 1
        _CloudNoise("_CloudNoise",2D) = "white"{}
        _CloudNoiseScale("_CloudNoiseScale",Float) = 1
        _Fuzziness("_Fuzziness",Float) = 0.5
        _FuzzinessSec("_FuzzinessSec",Float) = 0.5
        _cloudUp("_cloudUp",Color)=(1,1,1,1)
        _cloudDown("_cloudDown",Color)=(0,0,0,0)
        _HorizonIntensity("_HorizonIntensity",Float) = 1
        _HorizonHeight("_HorizonHeight",Float) = 1
        _HorzonColorDay("_HorzonColorDay",Color) = (1,1,1,1)
        _HorzonColorNight("_HorzonColorNight",Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200
        
        Pass
        {
            CGPROGRAM
            #include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag


            samplerCUBE _MainTex;
            float4 _MainTex_HDR;
            sampler2D _Stars;
            sampler2D _Cloud;
            sampler2D _DistortTex;
            sampler2D _CloudNoise;

            half4 _DayBottomColor;
            half4 _DayTopColor;
            half4 _NightBottomColor;
            half4 _NightTopColor;
            half4 _cloudUp;
            half4 _cloudDown;
            half4 _HorzonColorDay;
            half4 _HorzonColorNight;
            half4 _SunColor;
            half4 _MoonColor;

            float _SunRadius;
            float _MoonRadius;
            float _MoonOffset;
            float _StarsSpeed;
            float _StarsCutOff;
            float _CloudSpeed;
            float _CloudCutOff;
            float _Fuzziness;
            float _DistortionSpeed;
            float _DistortScale;
            float _CloudNoiseScale;
            float _FuzzinessSec;
            float _HorizonIntensity;
            float _HorizonHeight;

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 posWS : TEXCOORD1;
                
            };

            v2f vert(appdata_full v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.posWS = mul(unity_ObjectToWorld,v.vertex);
                
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                float4 col = texCUBE(_MainTex,i.uv.xyz);
                half3 col_hdr = DecodeHDR(col,_MainTex_HDR);
                
                float sun = distance(i.uv.xyz,_WorldSpaceLightPos0);
                float sunDisc  = smoothstep(_SunRadius,0,sun);

                sunDisc = saturate(sunDisc * 30);

                float moon = distance(i.uv.xyz,-_WorldSpaceLightPos0);
                float moonDisc = smoothstep(_MoonRadius,0,moon);
                moonDisc = saturate(moonDisc * 50);

                float crescentMoon = distance(float3(i.uv.xy,i.uv.z + _MoonOffset),-_WorldSpaceLightPos0);
                float cresentMoonDisc = smoothstep(_MoonRadius,0,crescentMoon);
                cresentMoonDisc = saturate(cresentMoonDisc * 50);

                moonDisc = saturate(moonDisc - cresentMoonDisc);

                float3 gradientDay = lerp(_DayBottomColor,_DayTopColor,saturate(i.uv.y));
                float3 gradientNight = lerp(_NightBottomColor,_NightTopColor,saturate(i.uv.y));
                float3 skyGradients = lerp(gradientNight,gradientDay,saturate(_WorldSpaceLightPos0.y));

                float2 skyuv = i.posWS.xz / clamp(i.posWS.y,0,10000);
                float3 stars = tex2D(_Stars,skyuv + float2(_StarsSpeed,_StarsSpeed * 0.2) * _Time.x);
                stars = step(_StarsCutOff,stars);
                
                float cloud = tex2D(_Cloud,skyuv + float2(_CloudSpeed,_CloudSpeed * 0.2) * _Time.x).r;
                float distort = tex2D(_DistortTex,(skyuv + (_Time.x * _DistortionSpeed)) * _DistortScale).r;
                float noise = tex2D(_CloudNoise,((skyuv + distort)-(_Time.x * _CloudSpeed)) * _CloudNoiseScale);
                float finalNoise = saturate(noise) * 3 * saturate(i.posWS.y);

                cloud = saturate(smoothstep(_CloudCutOff * cloud, _CloudCutOff * cloud + _Fuzziness,finalNoise));
                float cloudSec = saturate(smoothstep(_CloudCutOff * cloud,_CloudCutOff * cloud + _FuzzinessSec,finalNoise));

                cloudSec *= smoothstep(300,1000,i.posWS.y);
                cloud *= smoothstep(300,1000,i.posWS.y);

                stars = step(_StarsCutOff,stars) * saturate(-_WorldSpaceLightPos0.y);
                stars *= (1-cloud);

                float3 horizon = abs(i.uv.y * _HorizonIntensity) - (_HorizonHeight);
                horizon = saturate((1-horizon)) * (_HorzonColorNight * saturate(-_WorldSpaceLightPos0.y) + _HorzonColorDay * saturate(_WorldSpaceLightPos0.y));
                
                float4 finalColor;
                finalColor.w = 1;
                finalColor.xyz = sunDisc * _SunColor + moonDisc * _MoonColor + stars + cloud * _cloudUp + cloudSec * _cloudDown + horizon + skyGradients * col_hdr;
                return finalColor;
                
            }

            
            ENDCG
        }
    }
    FallBack "Diffuse"
}

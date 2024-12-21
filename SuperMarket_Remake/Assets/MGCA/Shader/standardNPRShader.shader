Shader "Custom/standardNPRRender"
{
    Properties
    {
        _MainTex("BC",2D) = "white"{}
        _PBR("PBR",2D) = "black"{}
        _AO("AO",2D) = "white"{}
        _Alpha("A",2D) = "white"{}
        _Emission("E",2D) = "black"{}
        _Roughness("R",2D) = "black"{}
        _Color("Color",Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CULL Off
            Tags{"LightMode"="ForwardBase"}
            
            CGPROGRAM
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            
            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            sampler2D _MainTex;
            sampler2D _PBR;
            sampler2D _AO;
            sampler2D _Alpha;
            sampler2D _Emission;
            sampler2D _Roughness;

            half3 _Color;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 posWS : TEXCOORD1;
                float3 normal : TEXCOORD2;
                SHADOW_COORDS(3)
            };

            v2f vert(appdata_full v)
            {
                v2f o;
                o.uv = v.texcoord;
                o.pos = UnityObjectToClipPos(v.vertex);
                float3 normalWS = normalize(UnityObjectToWorldNormal(v.normal));
                o.posWS = mul(unity_ObjectToWorld,v.vertex); 
                o.normal = normalWS;
                TRANSFER_SHADOW(o);
                return o;
            }

            //替换fresnelTerm
            float PHBeckmann(float NdotH, float m)
            {
                float alpha = acos(NdotH);
                float ta = tan(alpha);
                float val = 1 / (m*m*pow(NdotH,4.0))*exp(-(ta*ta)/m*m);
            
                return 0.5 * pow(val,0.1);
            }

            float fresnelReflectance(float3 H,float3 V,float F0)
            {
                float base = 1.0 - dot(H,V);
                float exponential = pow(base,5.0);
            
                return exponential + F0 * (1.0 - exponential);
            }

            half4 frag(v2f i,fixed facing : VFACE) : SV_Target
            {
                
                float3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.posWS));
                float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.posWS));
                worldLightDir.y = worldLightDir.y>0?worldLightDir.y:-worldLightDir.y;
                float lightIntensity = lerp(1.2,0.8,(worldLightDir.y+1)*0.5); 
                float3 halfDir = normalize(worldViewDir + worldLightDir);
                float NdotL = saturate(dot(i.normal,halfDir));

                
                
                half3 albedo = tex2D(_MainTex,i.uv).rgb * _Color;
                half3 OSM = tex2D(_PBR,i.uv).rgb;
                half roughness =1-( tex2D(_Roughness,i.uv).r + OSM.g);
                half Metal = max(OSM.b,0.01);
                half AO = tex2D(_AO,i.uv) * OSM.r;
                half3 Emission = tex2D(_Emission,i.uv);
                
                UNITY_LIGHT_ATTENUATION(atten,i,i.posWS);
                
                half3 Diffuse = _LightColor0.rgb * pow((dot(i.normal,worldLightDir) * 0.5 + 0.5),roughness) * albedo ;
                

                half fresnel = saturate(1 - dot(worldViewDir,i.normal));
                fresnel = smoothstep(0.6,0.7,fresnel);
                float PH = pow(2.0 * PHBeckmann(NdotL,1-Metal),10.0);
                float F = fresnelReflectance(halfDir,worldViewDir,0.028);
                float frSpec = max(PH * F/dot(halfDir,halfDir),0);
                float result = saturate(NdotL) * frSpec;//BRDF * dot(N,L) * rho_s
                float3 finalSpecular = saturate(result * atten)*  _LightColor0 * albedo ;

                atten = facing>0?(atten + 0.5):1; 
                
                
                half4 finalColor;
                finalColor.rgb = saturate(Diffuse + finalSpecular);
                finalColor.rgb = finalColor * lightIntensity + Emission ;
                finalColor.rgb *=  atten;
                finalColor.w =1;
                
                return finalColor.xyzx;
            }

            
            ENDCG
        }

        Pass
        {
            Tags{"LightMode"="ForwardAdd"}
            
            Blend One One
            
            CGPROGRAM
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd

            sampler2D _MainTex;
            sampler2D _PBR;
            sampler2D _AO;
            sampler2D _Alpha;
            sampler2D _height;
            sampler2D _Emission;
            sampler2D _Roughness;

            half3 _Color;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 posWS : TEXCOORD1;
                float3 normal : TEXCOORD2;
                SHADOW_COORDS(3)
            };

            v2f vert(appdata_full v)
            {
                v2f o;
                o.uv = v.texcoord;
                o.pos = UnityObjectToClipPos(v.vertex);
                float3 normalWS = normalize(UnityObjectToWorldNormal(v.normal));
                o.posWS = mul(unity_ObjectToWorld,v.vertex); 
                o.normal = normalWS;
                TRANSFER_SHADOW(o);
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                #ifdef USING_DIRECTIONAL_LIGHT
                    float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                #else
                    float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.posWS);
                #endif
                #ifdef USING_DIRECTIONAL_LIGHT
                    half atten = 1.0;
                #else
                    #if defined(POINT)
                        float3 lightCoord = mul(unity_WorldToLight,float4(i.posWS,1)).xyz;
                        fixed atten = tex2D(_LightTexture0,dot(lightCoord,lightCoord).rr).UNITY_ATTEN_CHANNEL;
                     #elif defined(SPOT)
                        float4 lightCoord = mul(unity_WorldToLight,float4(posWS,1));
                        fixed atten=(lightCoord.z>0)*tex2D(_LightTexture0,lightCoord.xy/lightCoord.w+0.5).w*tex2D(_LightTextureB0,dot(lightCoord,lightCoord).rr).UNITY_ATTEN_CHANNEL;
                    #endif
                #endif

                
                float3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.posWS));
                float3 halfDir = normalize(worldViewDir + worldLightDir);
                
                half3 albedo = tex2D(_MainTex,i.uv).rgb * _Color;
                half3 OSM = tex2D(_PBR,i.uv).rgb;
                half roughness = tex2D(_Roughness,i.uv).r + OSM.g;
                half M = OSM.b;
                half AO = tex2D(_AO,i.uv) * OSM.r;
                half3 Emission = tex2D(_Emission,i.uv);
                
                
                half3 Diffuse = _LightColor0.rgb * max(0,dot(i.normal,worldLightDir)) * OSM.g * 4;

                half fresnel = saturate(dot(worldViewDir,i.normal));
                fresnel = smoothstep(0.5,0.8,fresnel) * roughness * 0.5;
                half3 Specular = _LightColor0.rgb * pow(max(0,dot(i.normal,halfDir)) , OSM.b) * fresnel;

                
                
                
                half4 finalColor;
                finalColor.rgb = saturate(Diffuse) * albedo + Emission  ;
                finalColor.rgb *=  AO * atten * 10;
                finalColor.w =1;

                return 0;
                
            }
            
            
            ENDCG
            
            
            
            
            
        }
    }
    FallBack "Diffuse"
}

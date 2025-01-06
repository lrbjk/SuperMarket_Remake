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
            float4 _MainTex_ST;
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
                TRANSFORM_TEX(o.uv,_MainTex);
                o.pos = UnityObjectToClipPos(v.vertex);
                float3 normalWS = normalize(UnityObjectToWorldNormal(v.normal));
                o.posWS = mul(unity_ObjectToWorld,v.vertex); 
                o.normal = normalWS;
                TRANSFER_SHADOW(o);
                return o;
            }



            half4 frag(v2f i,fixed facing : VFACE) : SV_Target
            {
                
                float3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.posWS));
                float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.posWS));
                float3 halfDir = normalize(worldViewDir + worldLightDir);
                float NdotL = dot(i.normal,worldLightDir);
                UNITY_LIGHT_ATTENUATION(atten,i,i.posWS);
                atten = lerp(0.2,saturate(atten + 0.8),clamp(worldLightDir.y,0,1));

                //--------------------------------------------------------
                

                half3 albedo = tex2D(_MainTex,i.uv);
                half3 Diffuse = _LightColor0 * 1 * (NdotL * 0.5 + 0.5);
                half3 Specular = _LightColor0 * 1 * max(0,dot(i.normal,halfDir));

                half4 finalColor;
                finalColor.rgb = clamp(Diffuse + Specular,0.2,1);
                finalColor.rgb *= atten * albedo;
                
                return finalColor;
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
            float4 _MainTex_ST;
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
                TRANSFORM_TEX(o.uv,_MainTex);
                o.pos = UnityObjectToClipPos(v.vertex);
                float3 normalWS = normalize(UnityObjectToWorldNormal(v.normal));
                o.posWS = mul(unity_ObjectToWorld,v.vertex); 
                o.normal = normalWS;
                TRANSFER_SHADOW(o);
                return o;
            }

            half4 frag(v2f i,fixed facing : VFACE) : SV_Target
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
                float NdotL = dot(i.normal,worldLightDir);

                //--------------------------------------------------------
                

                half3 albedo = tex2D(_MainTex,i.uv);
                half3 Diffuse = _LightColor0 * 1 * (NdotL * 0.5 + 0.5);
                half3 Specular = _LightColor0 * 1 * max(0,dot(i.normal,halfDir));

                half4 finalColor;
                finalColor.rgb = clamp(Diffuse + Specular,0.2,1);
                finalColor.rgb *= atten * albedo;
                
                return finalColor;
                
            }
            
            
            ENDCG
            
            
            
            
            
        }
    }
    FallBack "Diffuse"
}

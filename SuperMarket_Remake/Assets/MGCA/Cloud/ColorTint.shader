// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader"Hidden/Postprocessing/ColorTint"
{
    SubShader
    {
        Cull Off
        ZWrite Off
        ZTest Always
      
        
        CGINCLUDE
            #include "UnityCG.cginc"
            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            sampler2D _WeatherMap;
            sampler2D _maskNoise;
            sampler2D _DownsampleColor;
            sampler2D _BlueNoise;
            
            sampler3D _VolumeTex;
            sampler3D _noiseTex;
            sampler3D _noiseDetail3D;
            
        
            float4 _Color;
            float4 _phaseParams;
            float4 _shapeNoiseWeights;
            float4 _xzSpeed;
            float4 _CameraDepthTexture_TexelSize;
            float4 _BlueNoiseCoords;
            float4x4 _InverseProjectionMatrix;
            float4x4 _InverseViewMatrix;
            float3 _boundsMin;
            float3 _boundsMax;
            float3 _offset;
            float3 _uvwScale;
            half3 _colA;
            half3 _colB;
            
            float _rayStep;
            float _step;
            float _shapeTiling;
            float _detailTiling;
            float _BlendMultiply;
            float _mipLevel;
            float _RenderViewportScaleFactor;
            float _lightAbsorptionTowardSun;
            float _colorOffset1;
            float _colorOffset2;
            float _darknessThershold;
            float _densityOffset;
            float _densityMultiplier;
            float _detailWeights;
            float _detailNoiseWeight;
            float _heightWeights;
            float _rayOffsetStrength;


            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 posSS : TEXCOORD1;
                float3 posWS : TEXCOORD2;
            };

            float remap(float original_value,float original_min,float original_max,float new_min,float new_max)
            {
                return new_min + (original_value - original_min) / (original_max - original_min) * (new_max - new_min);
            }
            
            float4 GetWorldSpacePosition(float depth,float2 uv)
            {
                //屏幕——view
                float4 view_vector = mul(_InverseProjectionMatrix,float4(2.0 * uv - 1.0, depth,1.0));
                view_vector.xyz /= view_vector.w;
                //view——世界
                float4x4 I_matViewinv = _InverseViewMatrix;
                float4 world_vector = mul(I_matViewinv,float4(view_vector.xyz,1));
                return world_vector;
            }
            

            float2 rayBoxDst(float3 boundsMin,float3 boundsMax,float3 rayOrigin,float3 invRaydir)
            {
                float3 t0 = (boundsMin - rayOrigin) * invRaydir;
                float3 t1 = (boundsMax - rayOrigin) * invRaydir;

                float3 tMin = min(t0,t1);
                float3 tMax = max(t0,t1);

                //进
                float dstA = max(max(tMin.x,tMin.y),tMin.z);
                //出
                float dstB = min(min(tMax.x,tMax.y),tMax.z);

                float dstToBox = max(0,dstA);
                float dstinsideBox = max(0,dstB-dstToBox);

                return float2(dstToBox,dstinsideBox);
            }

            float sampleDensity(float3 rayPos)
            {
                float3 center = (_boundsMax + _boundsMin) * 0.5;
                float3 length = _boundsMax - _boundsMin;
                float speedShape = _Time.y * _xzSpeed.x;
                float speedDetail = _Time.y * _xzSpeed.y;
                float3 uvwShape = rayPos * _shapeTiling + float3(speedShape,speedShape * 0.2,0);
                float3 uvwDetail = rayPos * _detailTiling + float3(speedDetail, speedDetail * 0.2,0);
                
                
                
                float2 uv = (length.xz * 0.5f + (rayPos.xz - center.xz) ) /max(length.x,length.z);
                float4 weatherMap = tex2Dlod(_WeatherMap,float4(uv + float2(speedShape * 0.4,0),0,0));
                float4 maskNoise = tex2Dlod(_maskNoise,float4(uv + float2(speedShape * 0.5,0),0,0));
                
                float4 shapeNoise = tex3Dlod(_noiseTex,float4(uvwShape + (maskNoise.r * _xzSpeed.z * 0.1),0));
                float4 detailNoise = tex3Dlod(_noiseDetail3D,float4(uvwDetail + (shapeNoise.r * _xzSpeed.w * 0.1),0));
                float4 normalizedShapeWeights = _shapeNoiseWeights / dot(_shapeNoiseWeights,1);

                const float cotainerEdgeFadeDst = 100;
                float dstFromEdgeX = min(cotainerEdgeFadeDst,min(rayPos.x - _boundsMin.x,_boundsMax.x - rayPos.x));
                float dstFromEdgeZ = min(cotainerEdgeFadeDst,min(rayPos.z - _boundsMin.z,_boundsMax.z - rayPos.z));
                float edgeWeight = min(dstFromEdgeZ,dstFromEdgeX)/cotainerEdgeFadeDst;
                
                float gMin = remap(weatherMap.x,0,1,0.1,0.6);
                float gMax = remap(weatherMap.x, 0, 1, gMin, 0.9);
                float heightPercent = (rayPos.y - _boundsMin.y)/length.y;
                float heightGradient = saturate(remap(heightPercent, 0.0, gMin, 0, 1)) * saturate(remap(heightPercent, 1, gMax, 0, 1));
                float heightGradient2 = saturate(remap(heightPercent, 0.0, weatherMap.r, 1, 0)) * saturate(remap(heightPercent, 0.0, gMin, 0, 1));
                heightGradient = saturate(lerp(heightGradient, heightGradient2,_heightWeights));
                
                heightGradient *= edgeWeight;
                
                float shapeFBM = dot(shapeNoise,normalizedShapeWeights) * heightGradient;
                float baseShapeDensity = shapeFBM + _densityOffset * 0.01;

                if(baseShapeDensity >0)
                {
                    float detailFBM = pow(detailNoise.r,_detailWeights);
                    float oneMinusShape = 1- baseShapeDensity;
                    float detailErodeWeight = oneMinusShape * oneMinusShape * oneMinusShape;
                    float cloudDensity = baseShapeDensity - detailFBM * detailErodeWeight * _detailNoiseWeight;
                    return saturate(cloudDensity * _densityMultiplier);
                }
                
                return 0;
            }

            float3 lightmarch(float3 position)
            {
                float3 dirToLight = _WorldSpaceLightPos0.xyz;
                float dstInsideBox = rayBoxDst(_boundsMin,_boundsMax,position,1/dirToLight).y;
                float stepSize = dstInsideBox / 8;
                float totalDensity = 0;

                for(int step = 0; step < 8; step ++)
                {
                    position += dirToLight * stepSize;
                    totalDensity += max(0,sampleDensity(position) * stepSize);
                }

                float transmittance = exp(-totalDensity * _lightAbsorptionTowardSun);
                float3 cloudColor = lerp(_colA,unity_LightColor0,saturate(transmittance * _colorOffset1));
                cloudColor = lerp(_colB,cloudColor,saturate(pow(transmittance * _colorOffset2,3)));
                return _darknessThershold + transmittance * (1-_darknessThershold) * cloudColor;
            }



            
            

            v2f vert_cloud(appdata_base v)
            {
                v2f o;
                o.pos = float4(v.vertex.xy,0,1) ;
                o.pos.y *= _ProjectionParams.x;
                o.uv = (v.vertex + 1) * 0.5f;
                o.posSS = ComputeScreenPos(o.pos);
                o.posWS = mul(unity_ObjectToWorld,float4(v.vertex.xyz,1.0));
                return o;
            }
            
            float4 frag_cloud(v2f i) : SV_Target
            {
                half4 color = tex2D(_MainTex,i.uv);
                color = lerp(color,color * _Color,_BlendMultiply);
                
                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,TransformStereoScreenSpaceTex(i.uv,1.0));
                float4 worldPos = GetWorldSpacePosition(depth,i.uv);
                float3 rayPos = _WorldSpaceCameraPos;
                float3 worldViewDir = normalize(worldPos.xyz - rayPos.xyz );

                float depthEyeLinear = length(worldPos.xyz - _WorldSpaceCameraPos);
                float2 ratToContainerInfo = rayBoxDst(_boundsMin,_boundsMax,rayPos,(1/worldViewDir));

                float dstToBox = ratToContainerInfo.x;
                float dstInsideBox = ratToContainerInfo.y;

                float dstLimit = min(depthEyeLinear - dstToBox,dstInsideBox);

                float blueNoise = tex2D(_BlueNoise,i.uv * _BlueNoiseCoords.xy + _BlueNoiseCoords.zw).r;
                
                
                float sumDensity = 1;
                float dstTravelled = blueNoise.r * _rayOffsetStrength;
                float3 lightEnergy = 0;
                float stepSize = exp(_step) * _rayStep;
                float3 enteryPoint = rayPos + worldViewDir * dstToBox;
                [unroll(512)]for(int j = 0;j<128;j++)
                {
                    if(dstTravelled < dstLimit)
                    {
                        rayPos = enteryPoint + (worldViewDir * dstTravelled * _rayStep);
                        float density = sampleDensity(rayPos);
                        if(density > 0)
                        {
                            float3 lightTransmittance = lightmarch(rayPos);
                            lightEnergy += density * stepSize * sumDensity * lightTransmittance ;
                            sumDensity *= exp(-density * stepSize);
                            if(sumDensity < 0.01) break;
                            
                        }
                    }
                    dstTravelled += stepSize;
                }
                float4 CloudColor = float4(lightEnergy,sumDensity);
                color.rgb *= CloudColor.a;
                color.rgb += CloudColor.rgb;
                return color ;
            }

            float DownsampleDepth(v2f i) : SV_Target
            {
                float2 texelSize = 0.5 * _CameraDepthTexture_TexelSize.xy;
                float2 taps[4] = { 	float2(i.uv + float2(-1,-1) * texelSize),
                                    float2(i.uv + float2(-1,1) * texelSize),
                                    float2(i.uv + float2(1,-1) * texelSize),
                                    float2(i.uv + float2(1,1) * texelSize)};

                float depth1 = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, taps[0]);
                float depth2 = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, taps[1]);
                float depth3 = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, taps[2]);
                float depth4 = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, taps[3]);

                float result = min(depth1, min(depth2, min(depth3, depth4)));

                return result;
            }
            float4 FragCombine(v2f i) : SV_Target
            {
                float4 color = tex2D(_MainTex, i.uv);
                float4 cloudColor = tex2D(_DownsampleColor, i.uv);

                color.rgb *= cloudColor.a;
                color.rgb += cloudColor.rgb;
                return i.uv.xyxy;
            }
            
        
        ENDCG
        

        Pass
        {
            CGPROGRAM
            #pragma vertex vert_cloud 
            #pragma fragment frag_cloud
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_cloud 
            #pragma fragment DownsampleDepth
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_cloud 
            #pragma fragment FragCombine
            ENDCG
        }
    }
}
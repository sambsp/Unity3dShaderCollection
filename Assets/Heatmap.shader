// 核心原理：
// 应用给到在UV区间[0, 1]内的采样点的强度信息。信息表达如下结构
// struct
// {
//    float2 uv;
//    float intensity;
// }
// 除采样点外，其他像素的信息都根据在[0, 1]空间跟采样点的距离差值，再相加而成。
// 这样就在[0, 1]空间得到所有的像素强度。然后根据配置的色彩信息，插值得到最后需要表达的色彩信息。

Shader "URP/Transparent/Heatmap"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color1("Color1", Color) = (0, 0, 0, 1)
        _Color2("Color2", Color) = (0.3, 0, 1, 1)
        _Color3("Color3", Color) = (0.7, 0.5, 1, 1)
        _Color4("Color4", Color) = (0.3, 0.1, 0.2, 1)
        _Color5("Color5", Color) = (1, 0, 0, 1)
        _Radius("Radius", Range(0, 0.248)) = 0.1
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        Cull back
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            // property
            sampler2D _MainTex;
            float4 _Color1;
            float4 _Color2;
            float4 _Color3;
            float4 _Color4;
            float4 _Color5;
            float _Radius;

            //
            fixed PointCount;
            float PointArray[8 * 8];
            float PointIntensity[8];

            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f input) : SV_Target
            {
                float intensity = 0;
                // 根据距离应用给到的采样点的长度，计算插值强度。应用给到多个采样点，则相加插值强度。
                for (int i = 0; i < PointCount; ++i) {
                    float2 targetUV = float2(PointArray[i * 2], PointArray[i * 2 +1]);
                    float targetIntensity = PointIntensity[i];
                    
                    float len = distance(input.uv, targetUV);
                    float inten;

                    if (len > _Radius) {
                        inten = 0;
                    }
                    else {
                        inten = 1 - len / _Radius;
                    }

                    intensity += inten;
                }

                intensity = clamp(0, 1, intensity);

                float4 col;

                // 支持4段色彩（5个应用可编辑的色彩点形成），每段权重平均。
                // 根据强度计算应该落在那个区间，最后的插值色彩应该是多少。
                if (intensity >= 0 && intensity < 0.25) {
                    intensity -= 0;
                    intensity /= 0.25;
                    col = lerp(_Color1, _Color2, intensity);
                }
                else if(intensity >= 0.25 && intensity < 0.5) {
                    intensity -= 0.25;
                    intensity /= 0.25;
                    col = lerp(_Color2, _Color3, intensity);
                }
                else if(intensity >= 0.5 && intensity > 0.75) {
                    intensity -= 0.5;
                    intensity /= 0.25;
                    col = lerp(_Color3, _Color4, intensity);
                }
                else if (intensity >= 0.75) {
                    intensity -= 0.75;
                    intensity /= 0.25;
                }

                return col;
            }
            ENDCG
        }
    }
}

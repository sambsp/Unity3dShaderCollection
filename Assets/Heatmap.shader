// ����ԭ��
// Ӧ�ø�����UV����[0, 1]�ڵĲ������ǿ����Ϣ����Ϣ������½ṹ
// struct
// {
//    float2 uv;
//    float intensity;
// }
// ���������⣬�������ص���Ϣ��������[0, 1]�ռ��������ľ����ֵ������Ӷ��ɡ�
// ��������[0, 1]�ռ�õ����е�����ǿ�ȡ�Ȼ��������õ�ɫ����Ϣ����ֵ�õ������Ҫ����ɫ����Ϣ��

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
                // ���ݾ���Ӧ�ø����Ĳ�����ĳ��ȣ������ֵǿ�ȡ�Ӧ�ø�����������㣬����Ӳ�ֵǿ�ȡ�
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

                // ֧��4��ɫ�ʣ�5��Ӧ�ÿɱ༭��ɫ�ʵ��γɣ���ÿ��Ȩ��ƽ����
                // ����ǿ�ȼ���Ӧ�������Ǹ����䣬���Ĳ�ֵɫ��Ӧ���Ƕ��١�
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

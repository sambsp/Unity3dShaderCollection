Shader "Unlit/EdgeDetect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _EdgeSize("Edge Size", Range(1, 10)) = 1
        _EdgeColor("Edge Color", Color) = (1, 0, 0, 1)
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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;
            float4 _EdgeColor;
            float _EdgeSize;

            fixed luminance(fixed4 color)
            {
                return 0.299 * color.r + 0.587 * color.g + 0.114 * color.b;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Index
                // 0, 1, 2
                // 3, 4, 5
                // 6, 7, 8

                // Gx
                // 1, 0, -1
                // 2, 0, -2
                // 1, 0, -1

                // Gy
                // 1,   2,  1
                // 0,   0,  0
                // -1, -2, -1

                float2 targetUV;
                float gray;
                float4 color;
                float gradient;

                // 0
                targetUV = i.uv.xy + _MainTex_TexelSize * float2(-1, -1);
                color = tex2D(_MainTex, targetUV);
                gray = luminance(color);  // luminance of a corner
                float x = gray * 1;       // Gx
                float y = gray * 1;       // Gy

                // 1
                targetUV = i.uv.xy + _MainTex_TexelSize * float2(0, -1);
                color = tex2D(_MainTex, targetUV);
                gray = luminance(color);
                x += gray * 0;
                y += gray * 2;

                // 2
                targetUV = i.uv.xy + _MainTex_TexelSize * float2(1, -1);
                color = tex2D(_MainTex, targetUV);
                gray = luminance(color);
                x += gray * -1;
                y += gray * 1;

                // 3
                targetUV = i.uv.xy + _MainTex_TexelSize * float2(-1, 0);
                color = tex2D(_MainTex, targetUV);
                gray = luminance(color);
                x += gray * 2;
                y += gray * 0;

                // 4
                targetUV = i.uv.xy + _MainTex_TexelSize * float2(0, 0);
                color = tex2D(_MainTex, targetUV);
                gray = luminance(color);
                x += gray * 0;
                y += gray * 0;

                // 5
                targetUV = i.uv.xy + _MainTex_TexelSize * float2(1, 0);
                color = tex2D(_MainTex, targetUV);
                gray = luminance(color);
                x += gray * -2;
                y += gray * 0;

                // 6
                targetUV = i.uv.xy + _MainTex_TexelSize * float2(-1, 1);
                color = tex2D(_MainTex, targetUV);
                gray = luminance(color);
                x += gray * 1;
                y += gray * -1;

                // 7
                targetUV = i.uv.xy + _MainTex_TexelSize * float2(0, 1);
                color = tex2D(_MainTex, targetUV);
                gray = luminance(color);
                x += gray * 0;
                y += gray * -2;

                // 8
                targetUV = i.uv.xy + _MainTex_TexelSize * float2(1, 1);
                color = tex2D(_MainTex, targetUV);
                gray = luminance(color);
                x += gray * -1;
                y += gray * -1;

                // now we get the gradient
                gradient = 1 - abs(x) - abs(y);

                // lerp to get the color
                return fixed4(gradient, gradient, gradient, 1);
            }
            ENDCG
        }
    }
}

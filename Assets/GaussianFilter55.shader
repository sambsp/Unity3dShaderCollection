Shader "Unlit/GaussianFilter55"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NeighbourDistance("Neighbour", Range(1, 10)) = 1
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

            float _NeighbourDistance;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // 0,  1,  2,  3,  4
                // 5,  6,  7,  8,  9
                // 10, 11, 12, 13, 14
                // 15, 16, 17, 18, 19
                // 20, 21, 22, 23, 24

                // kernal
                // 1,  4,  6,  4,  1
                // 4,  16, 24, 16, 4
                // 6,  24, 36, 24, 6
                // 4,  16, 24, 16, 4
                // 1,  4,  6,  4,  1

                // 12
                fixed4 color = tex2D(_MainTex, i.uv) * 36;
                
                // 0
            float2 targetUV = i.uv.xy + _MainTex_TexelSize.xy * float2(-2, -2) * _NeighbourDistance;
                color += tex2D(_MainTex, targetUV) * 1;

                // 1
                targetUV = i.uv.xy + _MainTex_TexelSize.xy * float2(-1, -2) * _NeighbourDistance;
                color += tex2D(_MainTex, targetUV) * 4;

                // 2
                targetUV = i.uv.xy + _MainTex_TexelSize.xy * float2(0, -2) * _NeighbourDistance;
                color += tex2D(_MainTex, targetUV) * 6;

                // 3
                targetUV = i.uv.xy + _MainTex_TexelSize.xy * float2(1, -2) * _NeighbourDistance;
                color += tex2D(_MainTex, targetUV) * 4;

                // 4
                targetUV = i.uv.xy + _MainTex_TexelSize.xy * float2(2, -2) * _NeighbourDistance;
                color += tex2D(_MainTex, targetUV) * 1;

                // 5
                targetUV = i.uv.xy + _MainTex_TexelSize.xy * float2(-2, -1) * _NeighbourDistance;
                color += tex2D(_MainTex, targetUV) * 4;

                // 6
                targetUV = i.uv.xy + _MainTex_TexelSize.xy * float2(-1, -1) * _NeighbourDistance;
                color += tex2D(_MainTex, targetUV) * 16;

                // 7
                targetUV = i.uv.xy + _MainTex_TexelSize.xy * float2(0, -1) * _NeighbourDistance;
                color += tex2D(_MainTex, targetUV) * 24;

                // 8
                targetUV = i.uv.xy + _MainTex_TexelSize.xy * float2(1, -1) * _NeighbourDistance;
                color += tex2D(_MainTex, targetUV) * 16;

                // 9
                targetUV = i.uv.xy + _MainTex_TexelSize.xy * float2(2, -1) * _NeighbourDistance;
                color += tex2D(_MainTex, targetUV) * 4;

                // 10
                targetUV = i.uv.xy + _MainTex_TexelSize.xy * float2(-2, 0) * _NeighbourDistance;
                color += tex2D(_MainTex, targetUV) * 6;

                // 11
                targetUV = i.uv.xy + _MainTex_TexelSize.xy * float2(-1, 0) * _NeighbourDistance;
                color += tex2D(_MainTex, targetUV) * 24;

                // 13
                targetUV = i.uv.xy + _MainTex_TexelSize.xy * float2(1, 0) * _NeighbourDistance;
                color += tex2D(_MainTex, targetUV) * 24;

                // 14
                targetUV = i.uv.xy + _MainTex_TexelSize.xy * float2(2, 0) * _NeighbourDistance;
                color += tex2D(_MainTex, targetUV) * 6;

                // 15
                targetUV = i.uv.xy + _MainTex_TexelSize.xy * float2(-2, 1) * _NeighbourDistance;
                color += tex2D(_MainTex, targetUV) * 4;

                // 16
                targetUV = i.uv.xy + _MainTex_TexelSize.xy * float2(-1, 1) * _NeighbourDistance;
                color += tex2D(_MainTex, targetUV) * 16;

                // 17
                targetUV = i.uv.xy + _MainTex_TexelSize.xy * float2(0, 1) * _NeighbourDistance;
                color += tex2D(_MainTex, targetUV) * 24;

                // 18
                targetUV = i.uv.xy + _MainTex_TexelSize.xy * float2(1, 1) * _NeighbourDistance;
                color += tex2D(_MainTex, targetUV) * 16; 

                // 19
                targetUV = i.uv.xy + _MainTex_TexelSize.xy * float2(2, 1) * _NeighbourDistance;
                color += tex2D(_MainTex, targetUV) * 4;

                // 20
                targetUV = i.uv.xy + _MainTex_TexelSize.xy * float2(-2, 2) * _NeighbourDistance;
                color += tex2D(_MainTex, targetUV) * 1;

                // 21
                targetUV = i.uv.xy + _MainTex_TexelSize.xy * float2(-1, 2) * _NeighbourDistance;
                color += tex2D(_MainTex, targetUV) * 4;

                // 22
                targetUV = i.uv.xy + _MainTex_TexelSize.xy * float2(0, 2) * _NeighbourDistance;
                color += tex2D(_MainTex, targetUV) * 6;

                // 23
                targetUV = i.uv.xy + _MainTex_TexelSize.xy * float2(1, 2) * _NeighbourDistance;
                color += tex2D(_MainTex, targetUV) * 4;

                // 24
                targetUV = i.uv.xy + _MainTex_TexelSize.xy * float2(2, 2) * _NeighbourDistance;
                color += tex2D(_MainTex, targetUV) * 1;

                return color / 256;
            }
            ENDCG
        }
    }
}

Shader "Unlit/GaussianFilter33"
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

            fixed4 frag (v2f i) : SV_Target
            {
                //0, 1, 2
                //3, 4, 5
                //6, 7, 8

                // 4
                fixed4 color = tex2D(_MainTex, i.uv);

                // 0
                float2 targetUV = i.uv.xy + _MainTex_TexelSize.xy * float2(-1, -1) * _NeighbourDistance;
                color += tex2D(_MainTex, targetUV);

                // 1
                targetUV = i.uv.xy + _MainTex_TexelSize.xy * float2(0, -1) * _NeighbourDistance;
                color += tex2D(_MainTex, targetUV);

                // 2
                targetUV = i.uv.xy + _MainTex_TexelSize.xy * float2(1, -1) * _NeighbourDistance;
                color += tex2D(_MainTex, targetUV);

                // 3
                targetUV = i.uv.xy + _MainTex_TexelSize.xy * float2(-1, 0) * _NeighbourDistance;
                color += tex2D(_MainTex, targetUV);

                // 5
                targetUV = i.uv.xy + _MainTex_TexelSize.xy * float2(1, 0) * _NeighbourDistance;
                color += tex2D(_MainTex, targetUV);

                // 6
                targetUV = i.uv.xy + _MainTex_TexelSize.xy * float2(-1, 1) * _NeighbourDistance;
                color += tex2D(_MainTex, targetUV);

                // 7
                targetUV = i.uv.xy + _MainTex_TexelSize.xy * float2(0, 1) * _NeighbourDistance;
                color += tex2D(_MainTex, targetUV);

                // 8
                targetUV = i.uv.xy + _MainTex_TexelSize.xy * float2(1, 1) * _NeighbourDistance;
                color += tex2D(_MainTex, targetUV);
                
                return color / 9;
            }
            ENDCG
        }
    }
}

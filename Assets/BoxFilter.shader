Shader "Unlit/BoxFilter"
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
            #pragma enable_d3d11_debug_symbols

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct VertexOutput
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 uv1: TEXCOORD1;
                float4 uv2: TEXCOORD2;
                float4 uv3: TEXCOORD3;
                float4 uv4: TEXCOORD4;
            };

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;

            float _NeighbourDistance;

            VertexOutput vert (appdata_img v)
            {
                VertexOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);

                // self
                o.uv = v.texcoord.xy;

                // x direction, left and right
                o.uv1.xy = v.texcoord.xy + _MainTex_TexelSize.xy * float2(1, 0) * _NeighbourDistance;
                o.uv1.zw = v.texcoord.xy + _MainTex_TexelSize.xy * float2(-1, 0) * _NeighbourDistance;

                // y direction, up and down
                o.uv2.xy = v.texcoord.xy + _MainTex_TexelSize.xy * float2(0, 1) * _NeighbourDistance;
                o.uv2.zw = v.texcoord.xy + _MainTex_TexelSize.xy * float2(0, -1) * _NeighbourDistance;

                // down, left and right
                o.uv3.xy = v.texcoord.xy + _MainTex_TexelSize.xy * float2(1, 1) * _NeighbourDistance;
                o.uv3.zw = v.texcoord.xy + _MainTex_TexelSize.xy * float2(-1, 1) * _NeighbourDistance;

                // top, left and right
                o.uv4.xy = v.texcoord.xy + _MainTex_TexelSize.xy * float2(1, -1) * _NeighbourDistance;
                o.uv4.zw = v.texcoord.xy + _MainTex_TexelSize.xy * float2(-1, -1) * _NeighbourDistance;

                return o;
            }

            fixed4 frag(VertexOutput i) : SV_Target
            {
                fixed4 color = fixed4(0, 0, 0, 0);
            
                color += tex2D(_MainTex, i.uv.xy);
                color += tex2D(_MainTex, i.uv1.xy);
                color += tex2D(_MainTex, i.uv1.zw);
                color += tex2D(_MainTex, i.uv2.xy);
                color += tex2D(_MainTex, i.uv2.zw);
                color += tex2D(_MainTex, i.uv3.xy);
                color += tex2D(_MainTex, i.uv3.zw);
                color += tex2D(_MainTex, i.uv4.xy);
                color += tex2D(_MainTex, i.uv4.zw);
                return color/9;
            }
            ENDCG
        }
    }
}

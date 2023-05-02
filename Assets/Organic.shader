Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
    }
        SubShader
    {
        Tags { "RenderType" = "Opaque" }
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

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            // Get 2D rotation matrix given angle (radians).

            // c, -s, s, c = clockwise.
            // c, s, -s, c = counterclockwise.
            float2x2 Get2DRotationMatrix(float angle)
            {
                float c = cos(angle);
                float s = sin(angle);

                return float2x2(c, -s, s, c);
            }

            float GetAnimatedOrganicFractal(float scale, float scaleMultStep, float rotationStep, int iterations, float2 uv, float uvAnimationSpeed, float rippleStrength, float rippleMaxFrequency, float rippleSpeed, float brightness)
            {
                // Remap to [-1.0, 1.0].
                uv = float2(uv - 0.5) * 2.0;

                float2 n, q;
                float invertedRadialGradient = pow(length(uv), 2.0);

                float output = 0.0;
                float2x2 rotationMatrix = Get2DRotationMatrix(rotationStep);

                float t = _Time.y;
                float uvTime = t * uvAnimationSpeed;

                // Ripples can be pre-calculated and passed from outside.
                // They don't need to be here in this function.
                float ripples = sin((t * rippleSpeed) - (invertedRadialGradient * rippleMaxFrequency)) * rippleStrength;

                for (int i = 0; i < iterations; i++)
                {
                    uv = mul(rotationMatrix, uv);
                    n = mul(rotationMatrix, n);

                    float2 animatedUV = (uv * scale) + uvTime;

                    q = animatedUV + i + n + ripples;
                    output += dot(cos(q) / scale, float2(1.0, 1.0) * brightness);

                    n -= sin(q);

                    scale *= scaleMultStep;
                }

                return output;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float fractal = GetAnimatedOrganicFractal(6,   // scale
                                                          1.2, // scaleMultStep 
                                                          5,   // rotationStep 
                                                          16,  // iterations
                                                          i.uv,// uv 
                                                          3.5, // uvAnimationSpeed
                                                          0.9, // rippleStrength
                                                          1.4, // rippleMaxFrequency
                                                          5,   // rippleSpeed
                                                          2    // brightness
                                                         );
                return fixed4(fractal, fractal, fractal, 1);
            }
            ENDCG
        }
    }
}

Shader "Unlit/Pulse"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}

        _scale("Scale", float) = 6.0

        _scaleStep("ScaleMultStep", float) = 1.2

        _rotationStep("rotationStep", float) = 5

        _iterations("Iterations", float) = 16

        _uvAnimationSpeed("AnimationSpeed", float) = 3.5

        _rippleStrenght("RippleStrenght", float) = 0.9

        _rippleMaxFrequency("MaxFrequency", float) = 1.4

        _rippleSpeed("RippleSpeed", float) = 5

        _brightness("Brightness",float) = 2
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
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            float _scale;

            float _scaleStep;

            float _rotationStep;

            float _iterations;

            float _uvAnimationSpeed;

            float _rippleStrenght;

            float _rippleMaxFrequency;

            float _rippleSpeed;

            float _brightness;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            // Get 2D rotation matrix given rotation in degrees.

        
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float2x2 Get2DRotationMatrix(float angle)
            {
                return float2x2(cos(angle), sin(angle), -sin(angle), cos(angle));
            }

            // Output this function directly (default values only for reference).
        
            float GetAnimatedOrganicFractal(

                float scale , float scaleMultStep ,

                float rotationStep , int layers,
                float2 uv , float uvAnimationSpeed ,

                float rippleStrength , float rippleMaxFrequency , float rippleSpeed ,

                float brightness )
            {
                // Remap to [-1.0, 1.0].

                uv = float2(uv - 0.5) * 2.0;

                float2 n;
                float invertedRadialGradient = pow(length(uv), 2.0);

                float output = 0.0;
                float2x2 rotationMatrix = Get2DRotationMatrix(rotationStep);

                float t = _Time.y;
                float uvTime = t * uvAnimationSpeed;

                // Ripples can be pre-calculated and passed from outside.
                // They don't need to be here in this function.

                float ripples = sin((t * rippleSpeed) - (invertedRadialGradient * rippleMaxFrequency)) * rippleStrength;

                float2 q;

                for (int i = 0; i < layers; i++)
                {
                    uv = mul(rotationMatrix, uv);
                    n = mul(rotationMatrix, n);

                    float2 animatedUV = (uv * scale) + uvTime;

                    q = animatedUV + ripples + i + n;
                    output += dot(cos(q) / scale, float2(1.0, 1.0) * brightness);

                    n -= sin(q);

                    scale *= scaleMultStep;
                }

                return output;
            }
        

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);

                // _uvAnimationSpeed = 0 will let organic stay on the position

                return GetAnimatedOrganicFractal(_scale, _scaleStep, _rotationStep, _iterations, 
                    i.uv, _uvAnimationSpeed, _rippleStrenght, _rippleMaxFrequency, _rippleSpeed, 
                    _brightness);
            }
            ENDCG
        }
    }
}
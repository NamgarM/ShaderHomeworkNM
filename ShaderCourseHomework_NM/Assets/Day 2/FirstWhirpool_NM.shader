Shader "Unlit/FirstWhirpool_NM"
{
    Properties
    {
        // Texture
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseTex("Noise Texture", 2D) = "white" {}
        _GalaxyTex("Galaxy Texture", 2D) = "white" {}
        // Waves 
        _TwistAngle("Twist Angle", Range(-10,10)) = 4
        _WavesAmount("Waves Amount", Range(-10,10)) = 3
        _WavesSpeed("Waves Speed", Range(-5, 5)) = 2
        // Other
        _NoiseFading("Noise Fading", Range(-0.01, 0.01)) = 0.001
        _EdgeRoundness("Edge Roundness", Range(-1,1)) = 0.5
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

            sampler2D _MainTex;
            sampler2D _NoiseTex;
            sampler2D _GalaxyTex;

            float4 _MainTex_ST;
            float _TwistAngle;
            float _WavesAmount;
            float _WavesSpeed;
            float _NoiseFading;
            float _EdgeRoundness;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                // Correct mapping of galaxy tex (from Minions Art)
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //
                // Move the whole "graph" in the center to make it polar coordinate system
                i.uv -= float2(0.5, 0.5);
                i.uv *= 2.0;
                float2 uv = i.uv;

                // Making spiral  
                float dist = length(uv);
                float angle = atan2(uv.y, uv.x);
                float spiral = sin(dist * _TwistAngle + angle* _WavesAmount - _Time.y * _WavesSpeed);

                // Fading noise effect 
                float noiseTex = tex2D(_NoiseTex, i.uv).x;
                float offset = noiseTex *_Time.x * _NoiseFading; // fading
                spiral -= float2(offset, offset);
                
                // Galaxy Texture
                float2 galaxyTex = tex2D(_GalaxyTex, i.uv);
                float galaxyX = galaxyTex.x * -0.004 * _Time.x;
                float galaxyY = galaxyTex.y * -0.004 * _Time.y;
                spiral -=float2(galaxyX, galaxyY);

                // Cicrle form
                float edgeNoiseTex = tex2D(_NoiseTex, float2(spiral, spiral)).x;
                float edgeNoise = edgeNoiseTex * _EdgeRoundness;
                float edgeStart = 0.1;
                float edgeEnd = 0.8;
                float fadingEdges = 1.0 - smoothstep(edgeStart, edgeEnd + edgeNoise, length(i.uv));

                // End result
                float4 col = tex2D(_MainTex, spiral) * fadingEdges;
                return col;
            }
            ENDCG
        }
    }
}

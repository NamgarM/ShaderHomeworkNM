Shader "Unlit/HypnosisShader_NM"
{
    Properties
    {
        // Texture
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseTex("Noise Texture", 2D) = "white" {}
        _GalaxyTex("Galaxy Texture", 2D) = "white" {}
        _StarsTex("Stars Texture", 2D) = "white"{}
        _StarsColor("Stars Color", Color) = (1,1,1,1)
        _StarOffset("Stars Offset", float) = (0.5, 0, 0)
        _GalaxyColor("Galaxy Color", Color) = (1,1,1,1)
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
        Tags { "RenderType"="Transparent" "Queue" = "Transparent"}
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _NoiseTex;
            sampler2D _GalaxyTex;
            sampler2D _StarsTex;

            float4 _MainTex_ST;
            float _TwistAngle;
            float _WavesAmount;
            float _WavesSpeed;
            float _NoiseFading;
            float _EdgeRoundness;

            // Stars
            float4 _StarsColor;
            float4 _GalaxyColor;
            float4 _StarOffset;

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

                // Mapping
                float2 viewDirection : TEXCOORD1;
                float normDirection : TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o;
                // For mapping of galaxy tex
                o.viewDirection = normalize(WorldSpaceViewDir(v.vertex));
                o.normDirection = v.normal.y;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //
                // Move the whole "graph" in the center to make it polar coordinate system
                float2 vDir = i.viewDirection;
                i.uv -= float2(0.5, 0.5);
                i.uv *= 2.0;
                float2 uv = i.viewDirection;

                // Making spiral  
                float dist = length(uv);
                float angle = atan2(uv.y, uv.x);
                float spiral = sin(dist * _TwistAngle + angle* _WavesAmount - _Time.y * _WavesSpeed);

                // Fading noise effect 
                float2 noiseTex = tex2D(_NoiseTex, i.viewDirection).x;
                float offset = noiseTex *_Time.x * _NoiseFading; // fading
                spiral -= float2(offset, offset);

                // Stars
                float2 starsUv = float2(i.viewDirection.x, i.viewDirection.y+_StarOffset.x);
                fixed4 starColor = tex2D(_StarsTex, starsUv+float2(0.5, 0));
                starColor.w = 0.2;

                // Cicrle form
                float edgeNoiseTex = tex2D(_NoiseTex, float2(spiral, spiral)).x;
                float edgeNoise = edgeNoiseTex * _EdgeRoundness;
                float edgeStart = 0.5;
                float edgeEnd = 0.9;
                float fadingEdges = 1.0 - smoothstep(edgeStart, edgeEnd + edgeNoise, length(i.uv));
                
                // Galaxy
                float4 col = tex2D(_GalaxyTex, spiral) * _GalaxyColor;

                // End result
                float4 result = (col + starColor)*fadingEdges;
                return result;
            }
            ENDCG
        }
    }
}

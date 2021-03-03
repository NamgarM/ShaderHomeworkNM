Shader "Homework for Shader Course/Twisting_NM"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _WavesDist("Distance between waves", Range(-10,10)) = 4
        _WavesAmount("Waves Amount", Range(-10,10)) = 3
        _WavesSpeed("Waves Speed", Range(-5, 5)) = 2
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
            float _WavesDist;
            float _WavesAmount;
            float _WavesSpeed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // fixed4 col = tex2D(_MainTex, i.uv);
                // Move the whole "graph" in the center to make it polar coordinate system
                i.uv -= float2(0.5, 0.5);
                float2 uv = i.uv;
                // Make it polar
                float2 polar = i.uv;
                float angle = atan2(uv.y, uv.x);
                polar = float2(length(polar), (angle / 0.6366)); // PI/2
                float time = saturate(sin(_Time.y));
                // Go from uv-coordinates to polar coordinates (it will give an effect of moving in circle)
                
                polar = lerp(i.uv, polar, time);
                float offset = _Time.x * 0.0005; // _FadingSpeed
                //uv += float2(offset, offset);
                fixed4 col = tex2D(_MainTex, polar);
                return col;//float4(uv, 0, 1); // colors on object */
            }
            ENDCG
        }
    }
}

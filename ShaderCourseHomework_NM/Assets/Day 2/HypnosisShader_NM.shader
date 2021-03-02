Shader "Unlit/HypnosisShader_NM"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseTex("Noise Texture", 2D) = "white" {}
        _Blend("Blend", Range(0,1)) = 0.5

        _TwistAngle("Twist Angle", Range(-10,10)) = 4
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

            sampler2D _MainTex;
            sampler2D _NoiseTex;
            float4 _MainTex_ST;
            float _TwistAngle;
            float _WavesAmount;
            float _WavesSpeed;

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

            v2f vert (appdata v)
            {
                v2f o;
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
                
                // Fading effect
                float fadingSpeed = 0.1;
                float offset = _Time.x * fadingSpeed;
                spiral += float2(offset, offset);

                // Noise
                float noise = tex2D(_NoiseTex, i.uv).x;

                // End result
                float4 col = tex2D(_MainTex, spiral) ;
                return col;
            }
            ENDCG
        }
    }
}

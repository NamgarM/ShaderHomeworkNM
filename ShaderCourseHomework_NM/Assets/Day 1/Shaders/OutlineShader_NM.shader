Shader "Unlit/OutlineShader_NM"
{
    Properties
    {
        // Texture
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseTex ("Texture", 2D) = "white" {}
        // Size
        _OutlineWidth ("Outline Width", Range(0, 0.1)) = 0.01
        _SpeedX ("Speed X", Range(-10, 10)) = 0.5
        _SpeedY ("Speed Y", Range(-10, 10)) = 0.5
        _NoiseTexSize ("Noise Size", Range (0, 1)) = 0.01
        _OffsetZ ("Offset Z", Range(0, 0.1)) = 0.0001
        // Colors
        _OutlineColor("Outline Color", Color) = (0,0,0,0)
        _Color("Tint", Color) = (0,0,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            Tags
            {
                //"RenderType" = "Opaque"
                "LightMode" = "UniversalForward"//"ForwardBase"
                "PassFlags" = "OnlyDirectional"
            }

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
        // Second pass
        Pass
        {
            Cull Front
            //ZTest Always // for showing in front of the wall

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 viewDirection : TEXCOORD1;
                float3 normalDirection : TEXCOORD2;
            };
            sampler2D _NoiseTex;
            sampler2D _MainTex;
            float4 _OutlineColor;
            half _OutlineWidth;
            fixed4 _Color;

            float _SpeedX;
            float _SpeedY;
            float _NoiseTexSize;
            float _OffsetZ;
            //fixed4 _OutlineWidth;

            v2f vert (appdata v)
            {
                // Displacing vertices for making outline visible
                v.vertex.xyz += v.normal * _OutlineWidth;
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.vertex.z += -0.01;
                o.normalDirection = normalize(mul(float4(v.normal, 0), unity_WorldToObject).xyz); // normal direction
		        o.viewDirection = normalize(WorldSpaceViewDir(v.vertex)); // view direction
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Scrolling
                float scrollX = _Time.x * _SpeedX;
                float scrollY = _Time.y * _SpeedY;
                float2 uv = float2(i.vertex.x * _NoiseTexSize - scrollX, i.vertex.y * _NoiseTexSize - scrollY);
                // Texturing 
                float4 noiseColor = tex2D(_NoiseTex, uv);
                // Rim
                float4 rim = pow(saturate(dot(i.viewDirection, i.normalDirection)), 0.01); 
                rim -= noiseColor;
                // Delete it and make flame
                float4 texturedRim = saturate(rim.a * 1);
                float4 result = (_Color * texturedRim);

                return result*_OutlineColor;
            }
            ENDCG
        }
    }
}

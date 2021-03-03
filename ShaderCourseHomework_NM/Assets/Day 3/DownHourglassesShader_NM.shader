Shader "Unlit/DownHourglassesShader_NM"
{
    Properties
    {
        _TopColor("Top Color", Color) = (0,0,0,0)
        _LiquidColor("Liquid Color", Color) = (0,0,0,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "DisableBatching" = "True "}
        ZWrite On
        Cull Off
        AlphaToMask On
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float4 _TopColor;
            //float4 _MiddleColor;
            float4 _LiquidColor;
            float _LiquidAmount;
            //float _MidColAmount;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float liquidOffset : TEXCOORD1;
            };


            v2f vert (appdata v)
            {
                v2f o;
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex.xyz);
                o.liquidOffset = worldPos.y - _LiquidAmount;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i, fixed facing : VFACE) : SV_Target
            {
                fixed4 base = step(i.liquidOffset, 0.0); 
                fixed4 color = base * _LiquidColor;
                fixed renderBase = color; 
                fixed4 renderTop = _TopColor * (base); 
                return facing > 0 ? color : renderTop;
            }
            ENDCG
        }
    }
}

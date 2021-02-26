Shader "Day1/MultipassOutline_NM"
{
    Properties
    {
        _OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
        _OutlineThickness ("Outline Thickness", Range(0,0.1)) = 0.03
        _OutlineWidth ("Outline Width", Range(0, 0.1)) = 0.09 // Добавляем 

        _Color("Tint", Color) = (0, 0, 0, 1)
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry"}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 position : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.position = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                col *= _Color;
                return col;
            } 
            ENDCG
        }
        Pass
{	
    // Скрываем полигоны, повернутые к камере
    Cull Front

    CGPROGRAM
    #pragma vertex vert
    #pragma fragment frag

    #include "UnityCG.cginc"

    struct appdata
    {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
    };

    struct v2f
    {
        float4 vertex : SV_POSITION;
    };

    // Объявляем переменные
    half _OutlineWidth;
    static const half4 OUTLINE_COLOR = half4(0,0,0,0);

    v2f vert (appdata v)
    {
        // Смещаем вершины по направлению нормали на заданное расстояние
        v.vertex.xyz += v.normal * _OutlineWidth;
				
        v2f o;
        o.vertex = UnityObjectToClipPos(v.vertex);
				
        return o;
    }

    fixed4 frag () : SV_Target
    {
        // Все пиксели контура имеют один и тот же цвет
        return OUTLINE_COLOR;
    }
    ENDCG
}
    }

    FallBack "Standard"
}

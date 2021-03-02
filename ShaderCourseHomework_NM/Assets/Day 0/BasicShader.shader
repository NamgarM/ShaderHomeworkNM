Shader "Unlit/BasicShader"
{
    Properties
    {
        _Color ("Tint", Color) = (0, 0, 0, 1)
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue" = "Geometry"}

        Pass
        {
            CGPROGRAM
            //include useful shader functions
            #include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag

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

            //the vertex shader function
            v2f vert(appdata v){
            //vertex stage stuff
                v2f o;
                //convert the vertex positions from object space to clip space so they can be rendered correctly
                o.position = UnityObjectToClipPos(v.vertex);
                //apply the texture transforms to the UV coordinates and pass them to the v2f struct
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            //the fragment shader function
            fixed4 frag(v2f i) : SV_TARGET{
                //fragment stage code
                //read the texture color at the uv coordinate
                fixed4 col = tex2D(_MainTex, i.uv);
                //multiply the texture color and tint color
                col *= _Color;
                //return the final color to be drawn on screen
                return col;
            }

            ENDCG
        }
    }
    Fallback "VertexLit"
}

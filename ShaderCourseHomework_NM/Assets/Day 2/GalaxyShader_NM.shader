Shader "Unlit/GalaxyShader_NM"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _StarsTex("Stars Texture", 2D) = "white"{}
        _StarsColor("Stars Color", Color) = (1,1,1,1)
        _StarOffset("Stars Offset", float) = (0.5, 0, 0)
        _GalaxyColor("Galaxy Color", Color) = (1,1,1,1)
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
                float2 viewDirection : TEXCOORD1;
                float normDirection : TEXCOORD2;
            };

            sampler2D _MainTex;
            sampler2D _StarsTex;
            float4 _MainTex_ST;
            // Stars
            float4 _StarsColor;
            float4 _GalaxyColor;
            float4 _StarOffset;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // View direction
                o.viewDirection = normalize(WorldSpaceViewDir(v.vertex));
                // Normals direction
                o.normDirection = v.normal.y;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //float2 dir = i.viewDirection + i.normDirection;
                //fixed4
                float2 dir = float2(i.viewDirection.x, i.viewDirection.y+i.normDirection);
                // Galaxy
                float2 galaxyUv = float2(i.viewDirection.x, i.viewDirection.y+i.normDirection+1);
                fixed4 galaxyCol = tex2D(_MainTex, galaxyUv) * _GalaxyColor;
                // Stars
                float2 starsUv = float2(i.viewDirection.x, i.viewDirection.y+_StarOffset.x);
                fixed4 starCol = tex2D(_StarsTex, starsUv) * _StarsColor;
                // sample the texture
                fixed4 col = galaxyCol + starCol;
                return col;
            }
            ENDCG
        }
    }
}

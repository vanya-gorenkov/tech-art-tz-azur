Shader "_Project/Fog"
{
    Properties
    {
        [PerRendererData]_MainTex ("Sprite Texture", 2D) = "white" {}
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _Speed ("Speed", Float) = 0.5
        _Scale ("Noise Scale", Float) = 1.0
        _Rotation ("Noise Rotation (Radians)", Float) = 0.0
        _Density ("Density", Float) = 1
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "RenderType"="Transparent"
            "CanUseSpriteAtlas"="True"
        }

        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off
        Lighting Off
        ZWrite Off
        ZTest LEqual

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _NoiseTex;

            float _Speed;
            float _Scale;
            float _Rotation;
            float _Density;

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                float4 color    : COLOR;
                float2 uv       : TEXCOORD0;
                float2 noiseUV  : TEXCOORD1;
            };

            v2f vert (appdata_t v)
            {
                v2f o;

                float4 world = mul(unity_ObjectToWorld, v.vertex);

                float s = sin(_Rotation);
                float c = cos(_Rotation);

                float2 uv = world.xy * _Scale;

                float2 rotated = float2(
                    uv.x * c - uv.y * s,
                    uv.x * s + uv.y * c
                );

                o.noiseUV = rotated;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv     = v.texcoord;
                o.color  = v.color;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float t = _Time.y * _Speed;

                float2 uv = i.noiseUV;
                uv.y += t;

                float n1 = tex2D(_NoiseTex, uv).r;
                float n2 = tex2D(_NoiseTex, uv * 1.5 + t * 0.3).r;

                float density = n1 * n2 * _Density;

                float mask = tex2D(_MainTex, i.uv).a;

                float fadeIn  = smoothstep(0.0, 0.2, i.uv.y);
                float fadeOut = 1.0 - smoothstep(0.6, 1.0, i.uv.y);
                float fade = fadeIn * fadeOut;

                float alpha = density * fade * mask * i.color.a;

                return float4(i.color.rgb, alpha);
            }
            ENDCG
        }
    }
}
Shader "_Project/Puddle-NoGrab"
{
    Properties
    {
        _MainTex ("Mask", 2D) = "white" {}
        _CausticsTex ("Caustics", 2D) = "white" {}

        _Speed ("Speed", Float) = 0.25
        _CausticsScale ("Caustics Scale", Float) = 1.0

        _Dir ("Direction", Float) = 0

        _Spec ("Spec Strength", Range(0,2)) = 0.8
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "RenderType"="Transparent"
            "CanUseSpriteAtlas"="True"
        }

        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off
        Lighting Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _CausticsTex;

            float _Speed;
            float _CausticsScale;
            float _Dir;
            float _Spec;

            struct appdata
            {
                float4 vertex : POSITION;
                float4 color  : COLOR;
                float2 uv     : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos   : SV_POSITION;
                float4 color : COLOR;
                float2 uv    : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.color = v.color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float t = _Time.y * _Speed;

                float s = sin(_Dir);
                float c = cos(_Dir);
                float2 dir = float2(c, s);

                float2 cuv = i.uv * _CausticsScale + dir * t;

                float caustics = tex2D(_CausticsTex, cuv).r;

                float mask = tex2D(_MainTex, i.uv).a;

                float wave = sin(i.uv.x * 8.0 + t * 1.8);
                wave = wave * 0.5 + 0.5;

                float spec = caustics * wave;

                spec = spec * spec;

                float3 col = i.color.rgb;

                col += spec * _Spec;
                col += caustics * 0.06;

                col *= 1.0 - mask * 0.15;

                float alpha = mask * i.color.a;

                return float4(col, alpha);
            }
            ENDCG
        }
    }
}
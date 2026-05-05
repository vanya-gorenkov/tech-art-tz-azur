Shader "_Project/Puddle-NoGrab"
{
    Properties
    {
        _MainTex ("Mask", 2D) = "white" {}
        _CausticsTex ("Caustics", 2D) = "white" {}

        _Speed ("Speed", Range(0,2)) = 0.3
        _Dir ("Direction", Range(0,6.2831)) = 0

        _CausticsScale ("Caustics Scale", Range(0.1,5)) = 1.0

        _Intensity ("Intensity", Range(0,2)) = 1.0
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "RenderType"="Transparent"
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

            half _Speed;
            half _Dir;
            half _CausticsScale;
            half _Intensity;

            struct appdata
            {
                float4 vertex : POSITION;
                half4 color   : COLOR;
                half2 uv      : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos   : SV_POSITION;
                half4 color  : COLOR;
                half2 uv     : TEXCOORD0;
                half2 dir    : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.color = v.color;

                half s = sin(_Dir);
                half c = cos(_Dir);
                o.dir = half2(c, s);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half t = _Time.y * _Speed;

                half2 cuv = i.uv * _CausticsScale + i.dir * t;

                half caustics = tex2D(_CausticsTex, cuv).r;
                half mask = tex2D(_MainTex, i.uv).a;

                half wave = frac(i.uv.x * 6.0h + t * 1.2h);
                wave = wave * (1.0h - wave) * 2.0h;

                half energy = caustics * _Intensity;

                half base = energy * 0.5h;
                half spec = energy * wave;

                half3 col = i.color.rgb;

                col += base;
                col += spec;

                col *= (1.0h - mask * 0.12h);

                half alpha = mask * i.color.a;

                return half4(col, alpha);
            }
            ENDCG
        }
    }
}
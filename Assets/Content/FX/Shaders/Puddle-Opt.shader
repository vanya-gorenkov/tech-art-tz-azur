Shader "_Project/Puddle-Opt"
{
    Properties
    {
        _MainTex ("Mask", 2D) = "white" {}
        _NoiseTex ("Noise", 2D) = "gray" {}

        _Color ("Water Color", Color) = (0.2,0.3,0.35,0.6)

        _Speed ("Speed", Float) = 0.3
        _SpecIntensity ("Spec", Range(0,2)) = 0.7
        _SpecPower ("Spec Power", Range(1,30)) = 15
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

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _NoiseTex;

            float4 _Color;
            float _Speed;
            float _SpecIntensity;
            float _SpecPower;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float t = _Time.y * _Speed;

                float2 n = (
                    tex2D(_NoiseTex, i.uv + float2(t, t*0.5)).rg +
                    tex2D(_NoiseTex, i.uv - float2(t*0.7, t)).rg
                ) * 0.5;

                float mask = tex2D(_MainTex, i.uv).a;

                float3 col = _Color.rgb;

                float spec = abs(n.r - 0.5) * 2;
                spec = spec * spec;
                col += spec * _SpecIntensity;

                col *= lerp(1.0, 0.85, mask);

                return float4(col, mask * _Color.a);
            }
            ENDCG
        }
    }
}
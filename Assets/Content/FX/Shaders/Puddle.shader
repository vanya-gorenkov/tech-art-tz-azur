Shader "_Project/Puddle"
{
    Properties
    {
        _MainTex ("Mask", 2D) = "white" {}
        _NoiseTex ("Noise", 2D) = "gray" {}

        _Strength ("Distortion", Range(0,0.1)) = 0.03
        _Speed ("Speed", Float) = 0.3

        _Tint ("Tint", Color) = (0.8,0.9,1,0.3)

        _SpecIntensity ("Spec Intensity", Range(0,2)) = 0.7
        _SpecPower ("Spec Power", Range(1,50)) = 25
    }

    SubShader
    {
        Tags { "Queue"="Transparent" }

        GrabPass { "_GrabTexture" }

        Pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _NoiseTex;
            sampler2D _GrabTexture;

            half _Strength, _Speed;
            fixed4 _Tint;

            half _SpecIntensity, _SpecPower;

            struct appdata
            {
                float4 vertex : POSITION;
                half2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                half2 uv : TEXCOORD0;
                float4 grabUV : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.grabUV = ComputeGrabScreenPos(o.pos);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half t = _Time.y * _Speed;

                half2 n1 = tex2D(_NoiseTex, i.uv + half2(t, t * 0.5)).rg;
                half2 n2 = tex2D(_NoiseTex, i.uv - half2(t * 0.7, t)).rg;

                half2 n = (n1 + n2) * 0.5;

                half2 distortion = (n * 2.0h - 1.0h) * _Strength;

                half2 screenUV = i.grabUV.xy / i.grabUV.w + distortion;

                fixed4 col = tex2D(_GrabTexture, screenUV);

                half a = tex2D(_MainTex, i.uv).a;

                half edge = saturate(a * 2.0h);
                col.rgb *= lerp(0.85h, 1.0h, edge);

                col.rgb = lerp(col.rgb, col.rgb * _Tint.rgb, _Tint.a);

                half specBase = abs(n.r - 0.5h) * 2.0h;

                half spec = specBase * specBase;
                spec *= spec;
                spec = lerp(spec, pow(specBase, _SpecPower), step(4.0h, _SpecPower));

                col.rgb += spec * _SpecIntensity;

                col.a = a;
                return col;
            }
            ENDCG
        }
    }
}
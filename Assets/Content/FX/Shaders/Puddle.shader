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

        _FresnelPower ("Fresnel Power", Range(1,8)) = 4
        _EdgeIntensity ("Edge Intensity", Range(0,2)) = 1.0
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
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _NoiseTex;
            sampler2D _GrabTexture;

            float _Strength, _Speed;
            float4 _Tint;

            float _SpecIntensity, _SpecPower;
            float _FresnelPower, _EdgeIntensity;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
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
                float t = _Time.y * _Speed;

                float2 n = (
                    tex2D(_NoiseTex, i.uv + float2(t, t * 0.5)).rg +
                    tex2D(_NoiseTex, i.uv - float2(t * 0.7, t)).rg
                ) * 0.5;

                float2 screenUV = i.grabUV.xy / i.grabUV.w + (n * 2 - 1) * _Strength;

                float4 col = tex2D(_GrabTexture, screenUV);

                float a = tex2D(_MainTex, i.uv).a;

                col.rgb *= lerp(1.0, 0.85, smoothstep(0.0, 0.5, a));
                col.rgb = lerp(col.rgb, col.rgb * _Tint.rgb, _Tint.a);

                float spec = pow(abs(n.r - 0.5) * 2, _SpecPower);
                col.rgb += spec * _SpecIntensity;

                col.rgb += pow(1.0 - a, _FresnelPower) * _EdgeIntensity;

                col.a = a;
                return col;
            }
            ENDCG
        }
    }
}
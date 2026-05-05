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
            #pragma target 2.0

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _NoiseTex;

            half _Speed;
            half _Scale;
            half _Rotation;
            half _Density;

            half2 GetRotation()
            {
                return half2(sin(_Rotation), cos(_Rotation));
            }

            struct appdata_t
            {
                float4 vertex   : POSITION;
                fixed4 color    : COLOR;
                half2 texcoord  : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                half2 uv        : TEXCOORD0;
                half2 noiseUV   : TEXCOORD1;
            };

            v2f vert (appdata_t v)
            {
                v2f o;

                float4 world = mul(unity_ObjectToWorld, v.vertex);

                half2 sc = GetRotation();

                half2 uv = world.xy * _Scale;

                o.noiseUV = half2(
                    uv.x * sc.y - uv.y * sc.x,
                    uv.x * sc.x + uv.y * sc.y
                );

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv     = v.texcoord;
                o.color  = v.color;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half t = _Time.y * _Speed;

                half2 uv = i.noiseUV;
                uv.y += t;

                half n1 = tex2D(_NoiseTex, uv).r;
                half n2 = tex2D(_NoiseTex, uv * 1.5 + t * 0.3).r;

                half density = n1 * n2 * _Density;

                half mask = tex2D(_MainTex, i.uv).a;

                half fade = smoothstep(0.0, 0.2, i.uv.y) *
                            (1.0 - smoothstep(0.6, 1.0, i.uv.y));

                half alpha = density * fade * mask * i.color.a;

                return fixed4(i.color.rgb, alpha);
            }
            ENDCG
        }
    }
}
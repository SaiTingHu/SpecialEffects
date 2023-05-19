//扁平
Shader "HT.SpecialEffects/Mesh/Flatten"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        [KeywordEnum(X, Y, Z)] _Axis("扁平轴", Float) = 0
        _FlattenValue("扁平值", float) = 0.0
        _FlattenValueMin("扁平值下限", float) = 0.0
        _FlattenColor("扁平断面颜色", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma vertex vert
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        #include "MeshEffectsLib.cginc"

        #pragma multi_compile _AXIS_X _AXIS_Y _AXIS_Z

        struct Input
        {
            float2 uv_MainTex;
            fixed t;
        };

        fixed4 _Color;
        sampler2D _MainTex;
        half _Glossiness;
        half _Metallic;
        float _FlattenValue;
        float _FlattenValueMin;
        fixed4 _FlattenColor;

        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        void vert(inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            float value = max(_FlattenValueMin, _FlattenValue);
#if _AXIS_X
            o.t = step(value, v.vertex.x);
            v.vertex.x = If(o.t, value, v.vertex.x);
#endif

#if _AXIS_Y
            o.t = step(value, v.vertex.y);
            v.vertex.y = If(o.t, value, v.vertex.y);
#endif
           
#if _AXIS_Z
            o.t = step(value, v.vertex.z);
            v.vertex.z = If(o.t, value, v.vertex.z);
#endif
        }

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = If(IN.t, _FlattenColor.rgb, c.rgb);
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = If(IN.t, _FlattenColor.a, c.a);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
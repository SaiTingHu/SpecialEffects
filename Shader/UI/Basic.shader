Shader "HTSpecialEffects/UI/Basic"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		_Color("Tint", Color) = (1,1,1,1)
		_ColorMask("Color Mask", Float) = 15
		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip("Use Alpha Clip", Float) = 0
		_ToneIntensity("亮度", Range(0,5)) = 1
		_Saturation("饱和度",Range(0,5)) = 1
		_Contrast("对比度",Range(0,5)) = 1
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
			"PreviewType" = "Plane"
			"CanUseSpriteAtlas" = "True"
		}

		Cull Off
		Lighting Off
		ZWrite Off
		ZTest[unity_GUIZTestMode]
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask[_ColorMask]

		Pass
		{
			Name "Default"

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0

			#include "UnityCG.cginc"
			#include "UnityUI.cginc"

			#pragma multi_compile_local _ UNITY_UI_CLIP_RECT
			#pragma multi_compile_local _ UNITY_UI_ALPHACLIP

			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color : COLOR;
				float2 texcoord  : TEXCOORD0;
				float4 worldPosition : TEXCOORD1;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _MainTex;
			fixed4 _Color;
			half _ToneIntensity;
			half _Saturation;
			half _Contrast;
			fixed4 _TextureSampleAdd;
			fixed4 _MainTex_ST;
			float4 _ClipRect;

			v2f vert(appdata_t v)
			{
				v2f OUT;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				OUT.worldPosition = v.vertex;
				OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);
				OUT.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				OUT.color = v.color * _Color;
				return OUT;
			}

			fixed4 frag(v2f IN) : SV_Target
			{
				half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;
				
				//应用亮度
				fixed3 finalColor = color * _ToneIntensity;

				//应用灰度
				fixed gray = dot(fixed3(0.2154, 0.7154, 0.0721), finalColor);
				fixed3 grayColor = fixed3(gray, gray, gray);
				finalColor = lerp(grayColor, finalColor, _Saturation);

				//应用对比度
				fixed3 contColor = fixed3(0.5, 0.5, 0.5);
				finalColor = lerp(contColor, finalColor, _Contrast);

				#ifdef UNITY_UI_CLIP_RECT
				color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
				#endif

				#ifdef UNITY_UI_ALPHACLIP
				clip(color.a - 0.001);
				#endif
				
				return fixed4(finalColor, color.a);
			}
			ENDCG
		}
	}
}
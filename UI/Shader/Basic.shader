Shader "HTSpecialEffects/UI/Basic"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip("使用透明度裁剪", Float) = 0
		_Brightness("亮度", Range(0,5)) = 1
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

		Pass
		{
			Name "Default"

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0

			#include "UnityCG.cginc"
			#include "UnityUI.cginc"
			#include "UIEffectsLib.cginc"

			#pragma multi_compile_local _ UNITY_UI_ALPHACLIP

			sampler2D _MainTex;
			half _Brightness;
			half _Saturation;
			half _Contrast;
			fixed4 _TextureSampleAdd;
			float4 _ClipRect;

			fixed4 frag(FragData IN) : SV_Target
			{
				half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;
				color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
				
				//应用亮度
				half3 finalColor = ApplyBrightness(color.rgb, _Brightness);

				//应用饱和度
				finalColor = ApplySaturation(finalColor, _Saturation);

				//应用对比度
				finalColor = ApplyContrast(finalColor, _Contrast);

				#ifdef UNITY_UI_ALPHACLIP
				clip(color.a - 0.001);
				#endif
				
				return half4(finalColor, color.a);
			}
			ENDCG
		}
	}
}
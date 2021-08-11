//泛光
Shader "HT.SpecialEffects/UI/Bloom"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip("使用透明度裁剪", Float) = 0
		_BloomTex("泛光纹理", 2D) = "white" {}
		_BloomColor("泛光颜色", Color) = (1,1,1)
		_ThresholdValue("泛光阀值", Range(0, 1)) = 0.5
		_Intensity("泛光强度", Range(0, 1)) = 0.5
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
			fixed4 _TextureSampleAdd;
			sampler2D _BloomTex;
			fixed3 _BloomColor;
			fixed _ThresholdValue;
			fixed _Intensity;

			fixed4 frag(FragData IN) : SV_Target
			{
				half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;

				half value = (tex2D(_BloomTex, IN.texcoord) + _TextureSampleAdd).a;

				color = ApplyBloom(color, value, _ThresholdValue, _Intensity, _BloomColor);
				
				#ifdef UNITY_UI_ALPHACLIP
				clip(color.a - 0.001);
				#endif
				
				return color;
			}
			ENDCG
		}
	}
}
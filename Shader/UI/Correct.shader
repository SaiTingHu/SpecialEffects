//色彩修正
Shader "HT.SpecialEffects/UI/Correct"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip("使用透明度裁剪", Float) = 0
		_TargetHue("目标颜色", Range(0, 1)) = 0
		_CorrectHue("修正颜色", Range(0, 1)) = 0
		_DifferenceHue("最大色差", Range(0, 1)) = 0.1
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
			float _TargetHue;
			float _CorrectHue;
			float _DifferenceHue;

			fixed4 frag(FragData IN) : SV_Target
			{				
				half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;

				//应用颜色修正
				color.rgb = ApplyCorrect(color.rgb, _TargetHue, _CorrectHue, _DifferenceHue);

				#ifdef UNITY_UI_ALPHACLIP
				clip(color.a - 0.001);
				#endif
				
				return color;
			}
			ENDCG
		}
	}

	CustomEditor "HT.Effects.CorrectShaderGUI"
}
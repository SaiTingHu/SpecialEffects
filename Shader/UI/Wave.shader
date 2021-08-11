//波浪
Shader "HT.SpecialEffects/UI/Wave"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip("使用透明度裁剪", Float) = 0
		_NoiseTex("噪声纹理", 2D) = "white" {}
		[Toggle] _MoveX("横向波动", Float) = 1
		[Toggle] _MoveY("纵向波动", Float) = 0
		_Intensity("强度", Range(0, 1)) = 0.2
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
			sampler2D _NoiseTex;
			fixed _MoveX;
			fixed _MoveY;
			fixed _Intensity;

			fixed4 frag(FragData IN) : SV_Target
			{
				float2 wave = float2(_Time.y * _MoveX, _Time.y * _MoveY);
				half4 color = (ApplyWave(_MainTex, _NoiseTex, IN.texcoord, wave, _Intensity) + _TextureSampleAdd) * IN.color;
				
				#ifdef UNITY_UI_ALPHACLIP
				clip(color.a - 0.001);
				#endif
				
				return color;
			}
			ENDCG
		}
	}
}
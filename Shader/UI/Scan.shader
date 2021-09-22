//扫描
Shader "HT.SpecialEffects/UI/Scan"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip("使用透明度裁剪", Float) = 0
		_NoiseTex("噪声纹理", 2D) = "white" {}
		_ScanPos("扫描光线位置", Range(0,2)) = 0
		_ScanWidth("扫描光线宽度",Range(0,1)) = 1
		_ScanColor("扫描光线颜色", Color) = (1,1,1,1)
		_ScanIntensity("扫描光线强度", Range(0, 10)) = 5
		_ScanDensity("扫描光线密度", Range(2, 20)) = 5
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
			fixed _ScanPos;
			fixed _ScanWidth;
			fixed4 _ScanColor;
			half _ScanIntensity;
			half _ScanDensity;

			fixed4 frag(FragData IN) : SV_Target
			{
				half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;
				
				color = ApplyScan(color, IN.texcoord, _ScanPos, _ScanWidth, _ScanColor, _ScanIntensity, _ScanDensity, _NoiseTex);

				#ifdef UNITY_UI_ALPHACLIP
				clip(color.a - 0.001);
				#endif
				
				return color;
			}
			ENDCG
		}
	}
}
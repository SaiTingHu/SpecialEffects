//像素化
Shader "HT.SpecialEffects/UI/Pixel"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip("使用透明度裁剪", Float) = 0
		_PixelSize("像素大小", Range(0, 1)) = 0
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
			float4 _MainTex_TexelSize;
			fixed _PixelSize;
			
			fixed4 frag(FragData IN) : SV_Target
			{
				//根据纹理的宽（_MainTex_TexelSize.z）生成缩放系数，应用像素化
				IN.texcoord = ApplyPixel(IN.texcoord, _PixelSize, _MainTex_TexelSize.z);

				half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;
				
				#ifdef UNITY_UI_ALPHACLIP
				clip(color.a - 0.001);
				#endif
				
				return color;
			}
			ENDCG
		}
	}
}
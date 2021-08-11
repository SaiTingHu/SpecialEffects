//边框流动
Shader "HT.SpecialEffects/UI/BorderFlow"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip("使用透明度裁剪", Float) = 0
		_FlowPos("流光位置", Range(0, 1)) = 0
		_FlowColor("流光颜色", Color) = (1,1,1)
		_FlowWidth("流光区域宽度", Range(0, 1)) = 0.3
		_FlowThickness("流光区域厚度", Range(0, 1)) = 0.03
		_FlowBrightness("流光亮度", Range(0, 1)) = 1
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
			float4 _MainTex_TexelSize;
			fixed4 _TextureSampleAdd;
			half _FlowPos;
			fixed3 _FlowColor;
			half _FlowWidth;
			half _FlowThickness;
			half _FlowBrightness;

			fixed4 frag(FragData IN) : SV_Target
			{
				half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;

				//应用边框流动特效
				color = ApplyBorderFlow(color, IN.texcoord, _FlowPos, _FlowWidth, _FlowThickness, _FlowBrightness, _FlowColor, _MainTex_TexelSize.zw);

				#ifdef UNITY_UI_ALPHACLIP
				clip(color.a - 0.001);
				#endif
				
				return color;
			}
			ENDCG
		}
	}
}
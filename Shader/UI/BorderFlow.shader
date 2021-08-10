Shader "HTSpecialEffects/UI/BorderFlow"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip("使用透明度裁剪", Float) = 0
		_FlowTex("流光纹理", 2D) = "white" {}
		_FlowPos("流光位置", Range(0, 1)) = 0
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
			float4 _ClipRect;
			sampler2D _FlowTex;
			half _FlowPos;

			fixed4 frag(FragData IN) : SV_Target
			{
				half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;
				color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);

				half radius = 0.1;
				half thick = 0.1;

				//下方
				half ratio = clamp(0, 0.5, _FlowPos) / 0.5;
				half realPos = lerp(radius * -1, 1 + radius, ratio);
				fixed left = 1 - step(IN.texcoord.x, realPos - radius);
				fixed right = 1 - step(realPos + radius, IN.texcoord.x);
				fixed up = 1 - step(thick, IN.texcoord.y);
				color.rgb *= ((5 * left*right*up) + 1);

				//右方
				ratio = clamp(0, 0.5, _FlowPos - 0.5) / 0.5;
				realPos = lerp(0, 1 + radius, ratio);
				left = 1 - step(IN.texcoord.y, realPos - radius);
				right = 1 - step(realPos + radius, IN.texcoord.y);
				up = 1 - step(IN.texcoord.x, 1 - thick);
				color.rgb *= ((5 * left*right*up) + 1);

				//上方

				#ifdef UNITY_UI_ALPHACLIP
				clip(color.a - 0.001);
				#endif
				
				return color;
			}
			ENDCG
		}
	}
}
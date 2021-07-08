Shader "HTSpecialEffects/UI/Dissolve"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip("使用透明度裁剪", Float) = 0
		_DissolveTex("溶解纹理", 2D) = "white" {}
		_DissolveColor("溶解颜色", Color) = (1,1,1)
		[KeywordEnum(Blend, Overlay)] _Mode("溶解模式", Float) = 0
		_Degree("溶解程度", Range(0, 1)) = 0
		_Width("溶解区域宽度", Range(0, 1)) = 1
		_Softness("溶解区域柔和度", Range(0, 1)) = 1
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
			#pragma shader_feature _MODE_BLEND _MODE_OVERLAY
			
			sampler2D _MainTex;
			fixed4 _TextureSampleAdd;
			float4 _ClipRect;
			sampler2D _DissolveTex;
			fixed3 _DissolveColor;
			fixed _Degree;
			fixed _Width;
			fixed _Softness;
			
			fixed4 frag(FragData IN) : SV_Target
			{
				half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;
				color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);

				//应用溶解特效
				color = ApplyDissolve(color, _DissolveColor, tex2D(_DissolveTex, IN.texcoord).a, _Degree, _Width, _Softness);

				#ifdef UNITY_UI_ALPHACLIP
				clip(color.a - 0.001);
				#endif
				
				return color;
			}
			ENDCG
		}
	}
}
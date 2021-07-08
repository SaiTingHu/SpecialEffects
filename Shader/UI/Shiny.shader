Shader "HTSpecialEffects/UI/Shiny"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip("使用透明度裁剪", Float) = 0
		[Toggle] _ShinyX("横向移动", Float) = 1
		[Toggle] _ShinyY("纵向移动", Float) = 0
		_Position("位置", Range(0, 1)) = 0.5
		_Rotation("旋转", Range(-180, 180)) = 0
		_Width("宽度", Range(0.01, 1)) = 0.25
		_Softness("柔和度", Range(0.01, 1)) = 1
		_Brightness("亮度", Range(0, 1)) = 1
		_Gloss("光泽度", Range(0, 1)) = 1
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
			fixed _ShinyX;
			fixed _ShinyY;
			fixed _Position;
			half _Rotation;
			fixed _Width;
			fixed _Softness;
			fixed _Brightness;
			fixed _Gloss;
			
			fixed4 frag(FragData IN) : SV_Target
			{
				half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;
				color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);

				//计算uv偏移值（映射到区间[-2, 2]）
				fixed offset = _Position * 4 - 2;
				//uv偏移
				float2 uv = float2(IN.texcoord.x - offset * _ShinyX, IN.texcoord.y - offset * _ShinyY);
				//uv旋转
				uv = RotatePoint2(uv, float2(0.5, 0.5), radians(_Rotation));
				//应用闪亮特效
				color = ApplyShiny(color, uv, _Width, _Softness, _Brightness, _Gloss);

				#ifdef UNITY_UI_ALPHACLIP
				clip(color.a - 0.001);
				#endif
				
				return color;
			}
			ENDCG
		}
	}
}
//线框
Shader "HT.SpecialEffects/UI/Wireframe"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip("使用透明度裁剪", Float) = 0
		[Toggle] _ShowOriginal("显示原图", Float) = 0
		_WireframeColor ("线框颜色", Color) = (0, 0, 0, 1)
		_BackgroundColor ("背景颜色", Color) = (1, 1, 1, 1)
		_Range("线框范围", Range(0, 1)) = 0.5
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
			#pragma vertex vertWF
			#pragma fragment fragWF
			#pragma target 2.0

			#include "UnityCG.cginc"
			#include "UnityUI.cginc"
			#include "UIEffectsLib.cginc"

			#pragma multi_compile_local _ UNITY_UI_ALPHACLIP
			
			uniform float4 _MainTex_TexelSize;
			sampler2D _MainTex;
			fixed _ShowOriginal;
			fixed4 _WireframeColor;
			fixed4 _BackgroundColor;
			fixed _Range;

			struct FragDataWF
			{
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				float2 texcoord[9] : TEXCOORD0;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			half Sobel(FragDataWF IN)
			{
				const half Sx[9] = {-1,  0,  1,
									-2,  0,  2,
									-1,  0,  1};
				const half Sy[9] = {1,  2,  1,
									0,  0,  0,
								   -1, -2, -1};

				half gx = 0;
				half gy = 0;
				for(int i = 0; i < 9; i++)
				{
					half4 color = tex2D(_MainTex, IN.texcoord[i]);
					half l = Luminance(color);
					gx += l * Sx[i];
					gy += l * Sy[i];
				}
				half g = abs(gx) + abs(gy);
				return g;
			}

			FragDataWF vertWF(VertData IN)
			{
				FragDataWF OUT;
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				OUT.vertex = UnityObjectToClipPos(IN.vertex);
				OUT.color = IN.color;
				OUT.texcoord[0] = IN.texcoord + _MainTex_TexelSize.xy * float2(-1, -1);
				OUT.texcoord[1] = IN.texcoord + _MainTex_TexelSize.xy * float2(0, -1);
				OUT.texcoord[2] = IN.texcoord + _MainTex_TexelSize.xy * float2(1, -1);
				OUT.texcoord[3] = IN.texcoord + _MainTex_TexelSize.xy * float2(-1, 0);
				OUT.texcoord[4] = IN.texcoord + _MainTex_TexelSize.xy * float2(0, 0);
				OUT.texcoord[5] = IN.texcoord + _MainTex_TexelSize.xy * float2(1, 0);
				OUT.texcoord[6] = IN.texcoord + _MainTex_TexelSize.xy * float2(-1, 1);
				OUT.texcoord[7] = IN.texcoord + _MainTex_TexelSize.xy * float2(0, 1);
				OUT.texcoord[8] = IN.texcoord + _MainTex_TexelSize.xy * float2(1, 1);
				return OUT;
			}

			fixed4 fragWF(FragDataWF IN) : SV_Target
			{
				half g = Sobel(IN);

				fixed4 original = tex2D(_MainTex, IN.texcoord[4]);
				fixed4 wireframe = lerp(If(_ShowOriginal, original, _BackgroundColor), _WireframeColor, g);
				fixed4 color = If(step(_Range, IN.texcoord[4].x), original, wireframe);

				#ifdef UNITY_UI_ALPHACLIP
				clip(color.a - 0.001);
				#endif
				
				return color;
			}
			ENDCG
		}
	}
}
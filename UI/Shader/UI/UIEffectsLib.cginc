#ifndef UI_EFFECTS_LIB
#define UI_EFFECTS_LIB

//����һ����ɫ������
half GetBrightness(fixed3 color)
{
	return 0.299f * color.r + 0.587f * color.g + 0.114f * color.b;
}

//����ά����point2������Բ��center��˳ʱ����תradian����
float2 RotatePoint2(float2 point2, float2 center, half radian)
{
	half radius = distance(point2, center);
	half angle = atan((point2.y - center.y) / (point2.x - center.x)) - radian;
	point2.x = cos(angle) * radius + center.x;
	point2.y = sin(angle) * radius + center.y;
	return point2;
}

//Ϊһ����ɫӦ������
half3 ApplyBrightness(half3 color, half brightness)
{
	return color * brightness;
}

//Ϊһ����ɫӦ�ñ��Ͷ�
half3 ApplySaturation(half3 color, half saturation)
{
	half gray = dot(half3(0.2154, 0.7154, 0.0721), color);
	half3 grayColor = half3(gray, gray, gray);
	return lerp(grayColor, color, saturation);
}

//Ϊһ����ɫӦ�öԱȶ�
half3 ApplyContrast(half3 color, half contrast)
{
	half3 contColor = half3(0.5, 0.5, 0.5);
	return lerp(contColor, color, contrast);
}

//Ϊһ��UVֵӦ�����ػ�����
float2 ApplyPixel(float2 uv, half pixelSize, float2 texelSize)
{
	//�˴�ȷ������ϵ��ʼ�մ��ڵ���2����Ϊ���С��2����������0�˻�Ӱ�����ļ��㣩
	half2 factor = max(2, (1 - pixelSize * 0.95) * texelSize);
	//��uvֵ��������ϵ����Ȼ��ȡ�����ٳ�������ϵ�����Դﵽ��������ϸ�������Ч��
	return round(uv * factor) / factor;
}

//��һ����ɫ����
half4 ApplyCoolColor(half4 color, half intensity)
{
	color.r *= (1 - intensity);
	color.b *= (1 + intensity);
	return color;
}

//��һ����ɫ��ů
half4 ApplyWarmColor(half4 color, half intensity)
{
	color.r *= (1 + intensity);
	color.b *= (1 - intensity);
	return color;
}

//Ϊһ����ɫӦ�÷���Ч����������ɫ�ﵽָ�����ȷ�ֵʱ��
half4 ApplyBloom(half4 color, fixed threshold, half3 bloomColor, fixed intensity)
{
	color.rgb += saturate(GetBrightness(color.rgb) - threshold) * bloomColor * intensity;
	return color;
}

//Ϊһ��uv����Ӧ��ģ��Ч��
half4 ApplyBlur(sampler2D mainTex, float2 pixelSize, float2 uv, int intensity)
{
	float4 color = float4(0.0, 0.0, 0.0, 0.0);
	int count = 0;
	for (int i = -intensity; i <= intensity; i++)
	{
		for (int j = -intensity; j <= intensity; j++)
		{
			color += tex2D(mainTex, float2(uv.x + i * pixelSize.x, uv.y + j * pixelSize.y));
			count += 1;
		}
	}
	return color / count;
}

//Ϊһ��uv����Ӧ��������Ч�����������������Խ������Խ��
half4 ApplyShiny(half4 color, float2 uv, fixed width, fixed softness, fixed brightness, fixed gloss)
{
	//�Ƚ������uv����[0,0.5,1]��תΪ����[1,0,1]������widthϵ����������
	//Ȼ��ͨ��1��ȥ���䣬��value����Ϊ����[0,1,0]
	half value = 1 - saturate(abs((uv.x * 2 - 1) / (width * 2)));
	//ͨ��smoothstep������[0,1,0]ƽ����������һ��ǿ�ȵõ�����ǿ��power
	half power = smoothstep(0, softness * 2, value) * 0.5;
	//ͨ������Ȳ�ֵ�õ�������ɫshinyColor
	half3 shinyColor = lerp(fixed3(1, 1, 1), color.rgb * 20, gloss);
	//��ԭ��ɫ�����ϵ���������ɫ
	color.rgb += color.a * power * brightness * shinyColor;
	return color;
}

//Ϊһ����ɫӦ���ܽ�Ч��
half4 ApplyDissolve(half4 color, fixed3 dissolveColor, float alpha, fixed degree, fixed width, fixed softness)
{
	//���ſ��ϵ��
	width *= 0.1;
	//ֻҪ�ܽ�̶�degreeС��0.01���򽫿��width����Ͷ�softness��Ϊ0����ֹ�ܽ�̶�Ϊ0ʱ��Ȼ���ܽ�Ч��
	fixed value = step(0.01, degree);
	width *= value;
	softness *= value;
	//����gap���ܽ�̶����ܽ�͸���ȵĲ�ֵ
	//gapС��widthʱ������δ�ܽ�Ĳ���
	//gap����widthʱ�������Ѿ��ܽ�Ĳ���
	float gap = degree - alpha;
	//abs(gap)С��widthʱ���������ܽⷶΧ�У�width��Ϊ�ܽⷶΧ����saturate���ش���0������Ϊͼ�����ܽ�ɫ
	//abs(gap)���ڵ���widthʱ���������ܽⷶΧ�У�width��Ϊ�ܽⷶΧ����saturate����0����Ϊͼ�����ܽ�ɫ
#if _MODE_BLEND
	color.rgb += dissolveColor * saturate((width - abs(gap)) * 20 / softness);
#endif
	//abs(gap)С��widthʱ���������ܽⷶΧ�У�width��Ϊ�ܽⷶΧ����saturate���ش���0������Ϊͼ�񸲸��ܽ�ɫ
	//abs(gap)���ڵ���widthʱ���������ܽⷶΧ�У�width��Ϊ�ܽⷶΧ����saturate����0����Ϊͼ�񸲸��ܽ�ɫ
#if _MODE_OVERLAY
	color.rgb = lerp(color.rgb, dissolveColor, saturate((width - abs(gap)) * 20 / softness));
#endif
	//��δ�ܽ�Ĳ��֣�saturate���ش���0������͸���ȵ���
	//�Ѿ��ܽ�Ĳ��֣�saturate����0��͸����Ϊ0
	color.a *= saturate((width - gap) * 20 / softness);
	//���ܽ�̶�Ϊ1ʱ��͸����Ϊ0
	color.a *= (1 - step(1, degree));
	return color;
}

//���㴦���������ݣ���׼��
struct VertData
{
	float4 vertex   : POSITION;
	fixed4 color    : COLOR;
	float2 texcoord : TEXCOORD0;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

//ƬԪ�����������ݣ���׼��
struct FragData
{
	float4 vertex   : SV_POSITION;
	fixed4 color : COLOR;
	float2 texcoord  : TEXCOORD0;
	float4 worldPosition : TEXCOORD1;
	UNITY_VERTEX_OUTPUT_STEREO
};

//���㴦��������׼��
FragData vert(VertData IN)
{
	FragData OUT;
	UNITY_SETUP_INSTANCE_ID(IN);
	UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
	OUT.worldPosition = IN.vertex;
	OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);
	OUT.texcoord = IN.texcoord;
	OUT.color = IN.color;
	return OUT;
}

#endif
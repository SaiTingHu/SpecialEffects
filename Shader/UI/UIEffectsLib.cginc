#ifndef UI_EFFECTS_LIB
#define UI_EFFECTS_LIB

//������� condition == 1������ trueValue����� condition == 0������ falseValue
half If(fixed condition, half trueValue, half falseValue)
{
	return trueValue * condition + falseValue * (1 - condition);
}

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

//��һ�����Ƿ���ָ������������
fixed IsInRect(half4 rect, half2 point2)
{
	half width = rect.z * 0.5;
	half height = rect.w * 0.5;
	fixed left = step(rect.x - width, point2.x);
	fixed right = step(point2.x, rect.x + width);
	fixed up = step(rect.y - height, point2.y);
	fixed down = step(point2.y, rect.y + height);
	return left * right * up * down;
}

//��һ�����Ƿ���ָ��Բ��������
fixed IsInCircle(half2 center, half radius, half2 point2)
{
	half dis = distance(point2, center);
	return step(dis, radius);
}

//Ϊһ����ɫӦ������
half3 ApplyBrightness(half3 color, fixed brightness)
{
	return color * brightness;
}

//Ϊһ����ɫӦ�ñ��Ͷ�
half3 ApplySaturation(half3 color, fixed saturation)
{
	half gray = dot(half3(0.2154, 0.7154, 0.0721), color);
	half3 grayColor = half3(gray, gray, gray);
	return lerp(grayColor, color, saturation);
}

//Ϊһ����ɫӦ�öԱȶ�
half3 ApplyContrast(half3 color, fixed contrast)
{
	half3 contColor = half3(0.5, 0.5, 0.5);
	return lerp(contColor, color, contrast);
}

//Ϊһ��uvֵӦ�����ػ�����
float2 ApplyPixel(float2 uv, fixed pixelSize, float2 texelSize)
{
	//�˴�ȷ������ϵ��ʼ�մ��ڵ���2����Ϊ���С��2����������0�˻�Ӱ�����ļ��㣩
	half2 factor = max(2, (1 - pixelSize * 0.95) * texelSize);
	//��uvֵ��������ϵ����Ȼ��ȡ�����ٳ�������ϵ�����Դﵽ��������ϸ�������Ч��
	return round(uv * factor) / factor;
}

//��һ����ɫ����
half4 ApplyCoolColor(half4 color, fixed intensity)
{
	color.r *= (1 - intensity);
	color.b *= (1 + intensity);
	return color;
}

//��һ����ɫ��ů
half4 ApplyWarmColor(half4 color, fixed intensity)
{
	color.r *= (1 + intensity);
	color.b *= (1 - intensity);
	return color;
}

//Ϊһ����ɫӦ�÷���Ч��
half4 ApplyBloom(half4 color, half alpha, fixed threshold, fixed intensity, fixed3 bloomColor)
{
	color.rgb += bloomColor * saturate(1 - abs(threshold - alpha) * lerp(5, 1, intensity));
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
	//�Ƚ������uv����[0,0.5,1]��ӳ�䵽����[1,0,1]������widthϵ����������
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
half4 ApplyDissolve(half4 color, fixed3 dissolveColor, half alpha, fixed degree, fixed width, fixed softness)
{
	//���ſ��ϵ��
	width *= 0.1;
	//ֻҪ�ܽ�̶�degreeС��0.01���򽫿��width����Ͷ�softness��Ϊ0����ֹ�ܽ�̶�Ϊ0ʱ��Ȼ���ܽ�Ч��
	fixed value = step(0.01, degree);
	width *= value;
	softness *= value;
	//����gap���ܽ�̶����ܽ�͸���ȵĲ�ֵ��widthΪ�ܽⷶΧ��
	//gapС��widthʱ������δ�ܽ⡢�����ܽ���
	//gap����widthʱ�������Ѿ��ܽ�
	//abs(gap)С��widthʱ���������ܽ���
	//abs(gap)���ڵ���widthʱ���������ܽ���
	float gap = degree - alpha;
#if _MODE_BLEND
	//�������ܽ���ʱ��width - abs(gap) ����0����saturate���ش���0�����������ܽ�ɫ������saturate����0����������ɫ
	color.rgb += dissolveColor * saturate((width - abs(gap)) * 20 / softness);
#endif
#if _MODE_OVERLAY
	//�������ܽ���ʱ��width - abs(gap) ����0����saturate���ش���0�����������ܽ�ɫ������saturate����0����������ɫ
	color.rgb = lerp(color.rgb, dissolveColor, saturate((width - abs(gap)) * 20 / softness));
#endif
	//����δ�ܽ⡢�����ܽ���ʱ��width - gap ����0����saturate���ش���0������͸���ȵ��ӣ�����saturate����0��͸����Ϊ0
	color.a *= saturate((width - gap) * 20 / softness);
	//���ܽ�̶�Ϊ1ʱ��͸����Ϊ0
	color.a *= (1 - step(1, degree));
	return color;
}

//Ϊһ��uv����Ӧ�ñ߿�����
half4 ApplyBorderFlow(half4 color, float2 uv, half flowPos, half flowWidth, half flowThickness, half flowBrightness, fixed3 flowColor, float2 texelSize)
{
	//�������±߿�Ŀ���
	half width = flowWidth * 0.5;
	half height = flowThickness * 0.5;

	//�����ϱ߿�
	//���㵱ǰ����λ��
	half ratio = smoothstep(-width, 0.5, If(step(flowPos, 0.5), flowPos, flowPos - 1));
	//������ӳ�䵽ͼ���ϵ���ʵλ��
	half realPos = lerp(width * -1, 1 + width, ratio);
	//���㵱ǰ����ǿ��
	half brightness = IsInRect(half4(realPos, 1 - height, width * 2, height * 2), uv) * flowBrightness;
	//����������ƽ����ʹ��Խ���������Ҳ࣬����ǿ��Խ�ӽ�1��Խ����������࣬����ǿ��Խ�ӽ�0��
	brightness *= smoothstep(0, width * 2, uv.x - realPos + width);
	//��������ɫ���ӵ�����ɫ
	color.rgb += color.a * brightness * flowColor;

	//�����±߿�ԭ��ͬ�ϱ߿�
	realPos = lerp(width * -1, 1 + width, 1 - ratio);
	brightness = IsInRect(half4(realPos, height, width * 2, height * 2), uv) * flowBrightness;
	brightness *= smoothstep(0, width * 2, realPos - uv.x + width);
	color.rgb += color.a * brightness * flowColor;

	//�������ұ߿�Ŀ��ߣ���֤��ͼ��Ŀ��߲���ʱ������Ŀ���ֵ����һ�£�
	width = width * texelSize.x / texelSize.y;
	height = height * texelSize.y / texelSize.x;

	//������߿�ԭ��ͬ�ϱ߿�
	ratio = smoothstep(0.5 - width, 1, flowPos);
	realPos = lerp(width * -1, 1 + width, ratio);
	brightness = IsInRect(half4(height, realPos, height * 2, width * 2), uv) * flowBrightness;
	brightness *= smoothstep(0, width * 2, uv.y - realPos + width);
	color.rgb += color.a * brightness * flowColor;

	//�����ұ߿�ԭ��ͬ�ϱ߿�
	realPos = lerp(width * -1, 1 + width, 1 - ratio);
	brightness = IsInRect(half4(1 - height, realPos, height * 2, width * 2), uv) * flowBrightness;
	brightness *= smoothstep(0, width * 2, realPos - uv.y + width);
	color.rgb += color.a * brightness * flowColor;

	return color;
}

//Ϊһ��uv����Ӧ�÷����ο�
half4 ApplyCubePierced(half4 color, float2 uv, half4 piercedRect, fixed alpha)
{
	fixed value = IsInRect(piercedRect, uv);
	color.a = alpha * value + color.a * (1 - value);
	return color;
}

//Ϊһ��uv����Ӧ��Բ���ο�
half4 ApplyCirclePierced(half4 color, float2 uv, half2 center, half radius, fixed alpha)
{
	fixed value = IsInCircle(center, radius, uv);
	color.a = alpha * value + color.a * (1 - value);
	return color;
}

//Ϊһ��uv����Ӧ�ò���Ч��
half4 ApplyWave(sampler2D mainTex, sampler2D noiseTex, float2 uv, float2 wave, fixed intensity)
{
	half4 noise = tex2D(noiseTex, uv + wave);
	half4 color = tex2D(mainTex, uv + noise.a * intensity);
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
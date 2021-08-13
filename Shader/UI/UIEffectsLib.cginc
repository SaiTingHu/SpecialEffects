#ifndef UI_EFFECTS_LIB
#define UI_EFFECTS_LIB

//如果条件 condition == 1，返回 trueValue，如果 condition == 0，返回 falseValue
half If(fixed condition, half trueValue, half falseValue)
{
	return trueValue * condition + falseValue * (1 - condition);
}

//计算一个颜色的亮度
half GetBrightness(fixed3 color)
{
	return 0.299f * color.r + 0.587f * color.g + 0.114f * color.b;
}

//将二维顶点point2，沿着圆心center，顺时针旋转radian弧度
float2 RotatePoint2(float2 point2, float2 center, half radian)
{
	half radius = distance(point2, center);
	half angle = atan((point2.y - center.y) / (point2.x - center.x)) - radian;
	point2.x = cos(angle) * radius + center.x;
	point2.y = sin(angle) * radius + center.y;
	return point2;
}

//求一个点是否在指定方形区域内
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

//求一个点是否在指定圆形区域内
fixed IsInCircle(half2 center, half radius, half2 point2)
{
	half dis = distance(point2, center);
	return step(dis, radius);
}

//为一个颜色应用亮度
half3 ApplyBrightness(half3 color, fixed brightness)
{
	return color * brightness;
}

//为一个颜色应用饱和度
half3 ApplySaturation(half3 color, fixed saturation)
{
	half gray = dot(half3(0.2154, 0.7154, 0.0721), color);
	half3 grayColor = half3(gray, gray, gray);
	return lerp(grayColor, color, saturation);
}

//为一个颜色应用对比度
half3 ApplyContrast(half3 color, fixed contrast)
{
	half3 contColor = half3(0.5, 0.5, 0.5);
	return lerp(contColor, color, contrast);
}

//为一个uv值应用像素化缩放
float2 ApplyPixel(float2 uv, fixed pixelSize, float2 texelSize)
{
	//此处确保缩放系数始终大于等于2（因为如果小于2，甚至等于0了会影响后面的计算）
	half2 factor = max(2, (1 - pixelSize * 0.95) * texelSize);
	//将uv值乘以缩放系数，然后取整，再除以缩放系数，以达到丢弃部分细节纹理的效果
	return round(uv * factor) / factor;
}

//让一个颜色更冷
half4 ApplyCoolColor(half4 color, fixed intensity)
{
	color.r *= (1 - intensity);
	color.b *= (1 + intensity);
	return color;
}

//让一个颜色更暖
half4 ApplyWarmColor(half4 color, fixed intensity)
{
	color.r *= (1 + intensity);
	color.b *= (1 - intensity);
	return color;
}

//为一个颜色应用泛光效果
half4 ApplyBloom(half4 color, half alpha, fixed threshold, fixed intensity, fixed3 bloomColor)
{
	color.rgb += bloomColor * saturate(1 - abs(threshold - alpha) * lerp(5, 1, intensity));
	return color;
}

//为一个uv区域应用模糊效果
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

//为一个uv区域应用闪亮特效，区域的中心最亮，越往两边越暗
half4 ApplyShiny(half4 color, float2 uv, fixed width, fixed softness, fixed brightness, fixed gloss)
{
	//先将输入的uv区间[0,0.5,1]，映射到区间[1,0,1]，再以width系数缩放区间
	//然后通过1减去区间，将value倒置为区间[0,1,0]
	half value = 1 - saturate(abs((uv.x * 2 - 1) / (width * 2)));
	//通过smoothstep将区间[0,1,0]平滑，并降低一倍强度得到闪光强度power
	half power = smoothstep(0, softness * 2, value) * 0.5;
	//通过光泽度插值得到闪光颜色shinyColor
	half3 shinyColor = lerp(fixed3(1, 1, 1), color.rgb * 20, gloss);
	//在原颜色基础上叠加闪光颜色
	color.rgb += color.a * power * brightness * shinyColor;
	return color;
}

//为一个颜色应用溶解效果
half4 ApplyDissolve(half4 color, fixed3 dissolveColor, half alpha, fixed degree, fixed width, fixed softness)
{
	//缩放宽度系数
	width *= 0.1;
	//只要溶解程度degree小于0.01，则将宽度width和柔和度softness设为0，防止溶解程度为0时依然有溶解效果
	fixed value = step(0.01, degree);
	width *= value;
	softness *= value;
	//计算gap，溶解程度与溶解透明度的差值（width为溶解范围）
	//gap小于width时，代表还未溶解、处于溶解中
	//gap大于width时，代表已经溶解
	//abs(gap)小于width时，代表处于溶解中
	//abs(gap)大于等于width时，代表不在溶解中
	float gap = degree - alpha;
#if _MODE_BLEND
	//当处于溶解中时（width - abs(gap) 大于0），saturate返回大于0的数，附加溶解色，否则saturate返回0，不附加颜色
	color.rgb += dissolveColor * saturate((width - abs(gap)) * 20 / softness);
#endif
#if _MODE_OVERLAY
	//当处于溶解中时（width - abs(gap) 大于0），saturate返回大于0的数，覆盖溶解色，否则saturate返回0，不覆盖颜色
	color.rgb = lerp(color.rgb, dissolveColor, saturate((width - abs(gap)) * 20 / softness));
#endif
	//当还未溶解、处于溶解中时（width - gap 大于0），saturate返回大于0的数，透明度叠加，否则saturate返回0，透明度为0
	color.a *= saturate((width - gap) * 20 / softness);
	//当溶解程度为1时，透明度为0
	color.a *= (1 - step(1, degree));
	return color;
}

//为一个uv区域应用边框流动
half4 ApplyBorderFlow(half4 color, float2 uv, half flowPos, half flowWidth, half flowThickness, half flowBrightness, fixed3 flowColor, float2 texelSize)
{
	//计算上下边框的宽、高
	half width = flowWidth * 0.5;
	half height = flowThickness * 0.5;

	//绘制上边框
	//计算当前流光位置
	half ratio = smoothstep(-width, 0.5, If(step(flowPos, 0.5), flowPos, flowPos - 1));
	//将流光映射到图像上的真实位置
	half realPos = lerp(width * -1, 1 + width, ratio);
	//计算当前流光强度
	half brightness = IsInRect(half4(realPos, 1 - height, width * 2, height * 2), uv) * flowBrightness;
	//将流光区域平滑（使得越靠近区域右侧，流光强度越接近1，越靠近区域左侧，流光强度越接近0）
	brightness *= smoothstep(0, width * 2, uv.x - realPos + width);
	//将流光颜色叠加到主颜色
	color.rgb += color.a * brightness * flowColor;

	//绘制下边框（原理同上边框）
	realPos = lerp(width * -1, 1 + width, 1 - ratio);
	brightness = IsInRect(half4(realPos, height, width * 2, height * 2), uv) * flowBrightness;
	brightness *= smoothstep(0, width * 2, realPos - uv.x + width);
	color.rgb += color.a * brightness * flowColor;

	//计算左右边框的宽、高（保证在图像的宽、高不等时，流光的宽、高值保持一致）
	width = width * texelSize.x / texelSize.y;
	height = height * texelSize.y / texelSize.x;

	//绘制左边框（原理同上边框）
	ratio = smoothstep(0.5 - width, 1, flowPos);
	realPos = lerp(width * -1, 1 + width, ratio);
	brightness = IsInRect(half4(height, realPos, height * 2, width * 2), uv) * flowBrightness;
	brightness *= smoothstep(0, width * 2, uv.y - realPos + width);
	color.rgb += color.a * brightness * flowColor;

	//绘制右边框（原理同上边框）
	realPos = lerp(width * -1, 1 + width, 1 - ratio);
	brightness = IsInRect(half4(1 - height, realPos, height * 2, width * 2), uv) * flowBrightness;
	brightness *= smoothstep(0, width * 2, realPos - uv.y + width);
	color.rgb += color.a * brightness * flowColor;

	return color;
}

//为一个uv区域应用方格镂空
half4 ApplyCubePierced(half4 color, float2 uv, half4 piercedRect, fixed alpha)
{
	fixed value = IsInRect(piercedRect, uv);
	color.a = alpha * value + color.a * (1 - value);
	return color;
}

//为一个uv区域应用圆形镂空
half4 ApplyCirclePierced(half4 color, float2 uv, half2 center, half radius, fixed alpha)
{
	fixed value = IsInCircle(center, radius, uv);
	color.a = alpha * value + color.a * (1 - value);
	return color;
}

//为一个uv区域应用波浪效果
half4 ApplyWave(sampler2D mainTex, sampler2D noiseTex, float2 uv, float2 wave, fixed intensity)
{
	half4 noise = tex2D(noiseTex, uv + wave);
	half4 color = tex2D(mainTex, uv + noise.a * intensity);
	return color;
}

//顶点处理输入数据（标准）
struct VertData
{
	float4 vertex   : POSITION;
	fixed4 color    : COLOR;
	float2 texcoord : TEXCOORD0;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

//片元处理输入数据（标准）
struct FragData
{
	float4 vertex   : SV_POSITION;
	fixed4 color : COLOR;
	float2 texcoord  : TEXCOORD0;
	float4 worldPosition : TEXCOORD1;
	UNITY_VERTEX_OUTPUT_STEREO
};

//顶点处理方法（标准）
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
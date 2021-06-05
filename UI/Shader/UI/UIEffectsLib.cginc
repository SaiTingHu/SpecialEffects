#ifndef UI_EFFECTS_LIB
#define UI_EFFECTS_LIB

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

//为一个颜色应用亮度
half3 ApplyBrightness(half3 color, half brightness)
{
	return color * brightness;
}

//为一个颜色应用饱和度
half3 ApplySaturation(half3 color, half saturation)
{
	half gray = dot(half3(0.2154, 0.7154, 0.0721), color);
	half3 grayColor = half3(gray, gray, gray);
	return lerp(grayColor, color, saturation);
}

//为一个颜色应用对比度
half3 ApplyContrast(half3 color, half contrast)
{
	half3 contColor = half3(0.5, 0.5, 0.5);
	return lerp(contColor, color, contrast);
}

//为一个UV值应用像素化缩放
float2 ApplyPixel(float2 uv, half pixelSize, float2 texelSize)
{
	//此处确保缩放系数始终大于等于2（因为如果小于2，甚至等于0了会影响后面的计算）
	half2 factor = max(2, (1 - pixelSize * 0.95) * texelSize);
	//将uv值乘以缩放系数，然后取整，再除以缩放系数，以达到丢弃部分细节纹理的效果
	return round(uv * factor) / factor;
}

//让一个颜色更冷
half4 ApplyCoolColor(half4 color, half intensity)
{
	color.r *= (1 - intensity);
	color.b *= (1 + intensity);
	return color;
}

//让一个颜色更暖
half4 ApplyWarmColor(half4 color, half intensity)
{
	color.r *= (1 + intensity);
	color.b *= (1 - intensity);
	return color;
}

//为一个颜色应用泛光效果（当该颜色达到指定亮度阀值时）
half4 ApplyBloom(half4 color, fixed threshold, half3 bloomColor, fixed intensity)
{
	color.rgb += saturate(GetBrightness(color.rgb) - threshold) * bloomColor * intensity;
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
	//先将输入的uv区间[0,0.5,1]，转为区间[1,0,1]，再以width系数缩放区间
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
half4 ApplyDissolve(half4 color, fixed3 dissolveColor, float alpha, fixed degree, fixed width, fixed softness)
{
	//缩放宽度系数
	width *= 0.1;
	//只要溶解程度degree小于0.01，则将宽度width和柔和度softness设为0，防止溶解程度为0时依然有溶解效果
	fixed value = step(0.01, degree);
	width *= value;
	softness *= value;
	//计算gap，溶解程度与溶解透明度的差值
	//gap小于width时，代表还未溶解的部分
	//gap大于width时，代表已经溶解的部分
	float gap = degree - alpha;
	//abs(gap)小于width时，代表处在溶解范围中（width即为溶解范围），saturate返回大于0的数，为图像混合溶解色
	//abs(gap)大于等于width时，代表不在溶解范围中（width即为溶解范围），saturate返回0，不为图像混合溶解色
#if _MODE_BLEND
	color.rgb += dissolveColor * saturate((width - abs(gap)) * 20 / softness);
#endif
	//abs(gap)小于width时，代表处在溶解范围中（width即为溶解范围），saturate返回大于0的数，为图像覆盖溶解色
	//abs(gap)大于等于width时，代表不在溶解范围中（width即为溶解范围），saturate返回0，不为图像覆盖溶解色
#if _MODE_OVERLAY
	color.rgb = lerp(color.rgb, dissolveColor, saturate((width - abs(gap)) * 20 / softness));
#endif
	//还未溶解的部分，saturate返回大于0的数，透明度叠加
	//已经溶解的部分，saturate返回0，透明度为0
	color.a *= saturate((width - gap) * 20 / softness);
	//当溶解程度为1时，透明度为0
	color.a *= (1 - step(1, degree));
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
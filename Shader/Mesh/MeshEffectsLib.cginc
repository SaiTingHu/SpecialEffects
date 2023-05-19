#ifndef MESH_EFFECTS_LIB
#define MESH_EFFECTS_LIB

//������� condition == 1������ trueValue����� condition == 0������ falseValue
half If(fixed condition, half trueValue, half falseValue)
{
	return trueValue * condition + falseValue * (1 - condition);
}

//������� condition == 1������ trueValue����� condition == 0������ falseValue
half2 If(fixed condition, half2 trueValue, half2 falseValue)
{
	return trueValue * condition + falseValue * (1 - condition);
}

//������� condition == 1������ trueValue����� condition == 0������ falseValue
half3 If(fixed condition, half3 trueValue, half3 falseValue)
{
	return trueValue * condition + falseValue * (1 - condition);
}

//������� condition == 1������ trueValue����� condition == 0������ falseValue
half4 If(fixed condition, half4 trueValue, half4 falseValue)
{
	return trueValue * condition + falseValue * (1 - condition);
}

//������� condition == 1������ trueValue����� condition == 0������ falseValue
float If(fixed condition, float trueValue, float falseValue)
{
	return trueValue * condition + falseValue * (1 - condition);
}

//������� condition == 1������ trueValue����� condition == 0������ falseValue
float2 If(fixed condition, float2 trueValue, float2 falseValue)
{
	return trueValue * condition + falseValue * (1 - condition);
}

//������� condition == 1������ trueValue����� condition == 0������ falseValue
float3 If(fixed condition, float3 trueValue, float3 falseValue)
{
	return trueValue * condition + falseValue * (1 - condition);
}

//������� condition == 1������ trueValue����� condition == 0������ falseValue
float4 If(fixed condition, float4 trueValue, float4 falseValue)
{
	return trueValue * condition + falseValue * (1 - condition);
}
#endif
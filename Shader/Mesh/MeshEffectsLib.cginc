#ifndef MESH_EFFECTS_LIB
#define MESH_EFFECTS_LIB

//如果条件 condition == 1，返回 trueValue，如果 condition == 0，返回 falseValue
half If(fixed condition, half trueValue, half falseValue)
{
	return trueValue * condition + falseValue * (1 - condition);
}

//如果条件 condition == 1，返回 trueValue，如果 condition == 0，返回 falseValue
half2 If(fixed condition, half2 trueValue, half2 falseValue)
{
	return trueValue * condition + falseValue * (1 - condition);
}

//如果条件 condition == 1，返回 trueValue，如果 condition == 0，返回 falseValue
half3 If(fixed condition, half3 trueValue, half3 falseValue)
{
	return trueValue * condition + falseValue * (1 - condition);
}

//如果条件 condition == 1，返回 trueValue，如果 condition == 0，返回 falseValue
half4 If(fixed condition, half4 trueValue, half4 falseValue)
{
	return trueValue * condition + falseValue * (1 - condition);
}

//如果条件 condition == 1，返回 trueValue，如果 condition == 0，返回 falseValue
float If(fixed condition, float trueValue, float falseValue)
{
	return trueValue * condition + falseValue * (1 - condition);
}

//如果条件 condition == 1，返回 trueValue，如果 condition == 0，返回 falseValue
float2 If(fixed condition, float2 trueValue, float2 falseValue)
{
	return trueValue * condition + falseValue * (1 - condition);
}

//如果条件 condition == 1，返回 trueValue，如果 condition == 0，返回 falseValue
float3 If(fixed condition, float3 trueValue, float3 falseValue)
{
	return trueValue * condition + falseValue * (1 - condition);
}

//如果条件 condition == 1，返回 trueValue，如果 condition == 0，返回 falseValue
float4 If(fixed condition, float4 trueValue, float4 falseValue)
{
	return trueValue * condition + falseValue * (1 - condition);
}
#endif
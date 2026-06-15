#if !defined PACKING_FILE_INCLUDED
#define PACKING_FILE_INCLUDED

// Structs
struct vec6 {
    vec3 a;
    vec3 b;
};

// the packing / unpacking assumes normalized floats
float pack2x16(float a, float b) {
    a = clamp(a, 0.0, 0.99);
    b = clamp(b, 0.0, 0.99);
	uint low = uint(a * 65535.0);
	uint high = uint(b * 65535.0);
	return (low | (high << 16)) / 4294967295.0;
}

vec3 pack2x16(vec3 a, vec3 b) {
    a = clamp(a, 0.0, 0.99);
    b = clamp(b, 0.0, 0.99);
	uvec3 low = uvec3(a * 65535.0);
	uvec3 high = uvec3(b * 65535.0);
	return (low | (high << 16)) / 4294967295.0;
}

vec2 unpack2x16(float val) {
	uint temp = uint(val * 4294967295.0);
	return vec2(float(temp & 65535u), (temp >> 16u)) / 65535.0;
}

vec6 unpack2x16(vec3 val) {
	uvec3 temp = uvec3(val * 4294967295.0);
	return vec6(vec3(temp & 65535u) / 65535.0, (temp >> 16u) / 65535.0);
}

struct vec8 {
    vec4 a;
    vec4 b;
};

vec4 pack2x16(vec4 a, vec4 b) {
    a = clamp(a, 0.0, 0.99);
    b = clamp(b, 0.0, 0.99);
    uvec4 low = uvec4(a * 65535.0);
    uvec4 high = uvec4(b * 65535.0);
    return (low | (high << 16)) / 4294967295.0;
}

vec8 unpack2x16(vec4 val) {
    uvec4 temp = uvec4(val * 4294967295.0);
    return vec8(vec4(temp & 65535u) / 65535.0, (temp >> 16u) / 65535.0);
}

#endif

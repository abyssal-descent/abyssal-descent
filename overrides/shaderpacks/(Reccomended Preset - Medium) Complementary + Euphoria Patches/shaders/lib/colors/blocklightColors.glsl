#include "/lib/shaderSettings/materials.glsl"
#define BASE_BLOCKLIGHT (vec3(0.1775, 0.104, 0.077) * vec3(XLIGHT_R, XLIGHT_G, XLIGHT_B))

#define SOUL_VALLEY_COLOR vec3(0.05, 0.22, 0.25)

#ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
    vec3 blocklightCol = mix(BASE_BLOCKLIGHT, SOUL_VALLEY_COLOR, inSoulValley);
#else
    vec3 blocklightCol = BASE_BLOCKLIGHT;
#endif

#if COLORED_LIGHTING_INTERNAL > 0
	#include "/lib/colors/blocklightColorsACT.glsl"
#endif

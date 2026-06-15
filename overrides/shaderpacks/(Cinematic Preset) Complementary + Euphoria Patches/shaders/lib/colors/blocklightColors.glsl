#include "/lib/shaderSettings/materials.glsl"
#ifdef SPOOKY
    #define BASE_BLOCKLIGHT vec3(0.2, 0.1098, 0.0431)
#else
    #define BASE_BLOCKLIGHT vec3(0.1775, 0.108, 0.0775)
#endif

#define MODIFIED_BASE (BASE_BLOCKLIGHT * vec3(XLIGHT_R, XLIGHT_G, XLIGHT_B))

#define SOUL_VALLEY_COLOR vec3(0.05, 0.22, 0.25)

#ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
    vec3 blocklightCol = mix(MODIFIED_BASE, SOUL_VALLEY_COLOR, inSoulValley);
#else
    vec3 blocklightCol = MODIFIED_BASE;
#endif

#if COLORED_LIGHTING_INTERNAL > 0
	#include "/lib/colors/blocklightColorsACL.glsl"
#endif
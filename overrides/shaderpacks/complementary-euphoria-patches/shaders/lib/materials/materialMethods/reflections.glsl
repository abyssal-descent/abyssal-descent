#ifdef OVERWORLD
    #include "/lib/atmospherics/sky.glsl"
    #include "/lib/shaderSettings/stars.glsl"
    #ifdef OVERWORLD_BEAMS
        #include "/lib/atmospherics/overworldBeams.glsl"
    #endif
    #ifdef END_PORTAL_BEAM_INTERNAL
        #include "/lib/atmospherics/endPortalBeam.glsl"
    #endif
#endif
#define ROUGHNESS_MULTIPLIER 1.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.5 3.0 3.5 4.0 4.5 5.0 5.5 6.0 6.5 7.0 7.5 8.0 8.5 9.0 9.5 10.0]
#ifdef END
    #include "/lib/shaderSettings/endBeams.glsl"
    #ifdef DEFERRED1
        #include "/lib/atmospherics/enderBeams.glsl"
    #endif
    #if END_CRYSTAL_VORTEX_INTERNAL > 0 || DRAGON_DEATH_EFFECT_INTERNAL > 0
        #include "/lib/atmospherics/endCrystalVortex.glsl"
    #endif
#endif

#if defined ATM_COLOR_MULTS || defined SPOOKY
    #include "/lib/colors/colorMultipliers.glsl"
#endif
#ifdef MOON_PHASE_INF_ATMOSPHERE
    #include "/lib/colors/moonPhaseInfluence.glsl"
#endif

vec3 nvec3(vec4 pos) {
    return pos.xyz/pos.w;
}

vec3 refPos = vec3(0.0);

#if defined GBUFFERS_WATER && defined PIXELATED_WATER_REFLECTIONS
vec4 GetReflection(vec3 normalM, vec3 viewPos, vec3 nViewPos, vec3 playerPos, float lViewPos, float z0,
                   sampler2D depthtex, float dither, float skyLightFactor, float fresnel,
                   float smoothness, vec3 geoNormal, vec3 color, vec3 shadowMult, float highlightMult, vec2 texelOffset) {
    #define PIXELATED_WATER_REFLECTIONS_MODE
#else
vec4 GetReflection(vec3 normalM, vec3 viewPos, vec3 nViewPos, vec3 playerPos, float lViewPos, float z0,
                   sampler2D depthtex, float dither, float skyLightFactor, float fresnel,
                   float smoothness, vec3 geoNormal, vec3 color, vec3 shadowMult, float highlightMult) {
#endif
#include "/lib/materials/materialMethods/reflectionImpl.glsl"
}
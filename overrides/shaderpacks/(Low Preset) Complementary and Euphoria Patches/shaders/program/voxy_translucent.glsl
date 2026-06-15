/////////////////////////////////////
// Complementary Shaders by EminGT //
/////////////////////////////////////

#define VOXY_PATCH
#define texture2DLod textureLod
#define texture2D texture

mat4 gbufferModelView = vxModelView;
mat4 gbufferModelViewInverse = vxModelViewInv;
mat4 gbufferPreviousModelView = vxModelViewPrev;
mat4 gbufferProjection = vxProj;
mat4 gbufferProjectionInverse = vxProjInv;
mat4 gbufferPreviousProjection = vxProjPrev;

//Common//
#include "/lib/common.glsl"
#include "/lib/shaderSettings/water.glsl"
#include "/lib/shaderSettings/shockwave.glsl"
#include "/lib/shaderSettings/emissionMult.glsl"

//////////Fragment Shader//////////Fragment Shader//////////Fragment Shader//////////
#ifdef FRAGMENT_SHADER

//Pipeline//
layout(location = 0) out vec4 gbufferData0;
layout(location = 1) out vec4 gbufferData6;
#ifdef SS_BLOCKLIGHT
    layout(location = 2) out vec4 gbufferData9;
#endif

//Common Variables//
vec3 sunVec = GetSunVector();
vec3 upVec = normalize(gbufferModelView[1].xyz);
vec3 eastVec = normalize(gbufferModelView[0].xyz);
vec3 northVec = normalize(gbufferModelView[2].xyz);

float SdotU = dot(sunVec, upVec);
float sunFactor = SdotU < 0.0 ? clamp(SdotU + 0.375, 0.0, 0.75) / 0.75 : clamp(SdotU + 0.03125, 0.0, 0.0625) / 0.0625;
float sunVisibility = clamp(SdotU + 0.0625, 0.0, 0.125) / 0.125;
float sunVisibility2 = sunVisibility * sunVisibility;
float shadowTimeVar1 = abs(sunVisibility - 0.5) * 2.0;
float shadowTimeVar2 = shadowTimeVar1 * shadowTimeVar1;
float shadowTime = shadowTimeVar2 * shadowTimeVar2;
int blockLightEmission = 0;

int mat;
float NdotU;
float NdotUmax0;
vec2 lmCoord;
vec2 lmCoordM;
vec3 normal;
vec3 viewVector;
vec4 glColor;
mat3 tbnMatrix;

#ifdef OVERWORLD
    vec3 lightVec = sunVec * ((timeAngle < 0.5325 || timeAngle > 0.9675) ? 1.0 : -1.0);
#else
    vec3 lightVec = sunVec;
#endif

//Common Functions//

//Includes//
#include "/lib/util/spaceConversion.glsl"
#include "/lib/util/dither.glsl"
#include "/lib/lighting/mainLighting.glsl"
#include "/lib/atmospherics/fog/mainFog.glsl"
#include "/lib/materials/materialMethods/translucentTweaks.glsl"

#ifdef OVERWORLD
    #include "/lib/atmospherics/sky.glsl"
#endif

#if WATER_REFLECT_QUALITY >= 0
    #if defined SKY_EFFECT_REFLECTION && defined OVERWORLD
        #if AURORA_STYLE > 0
            #include "/lib/atmospherics/auroraBorealis.glsl"
        #endif

        #if NIGHT_NEBULAE == 1
            #include "/lib/atmospherics/nightNebula.glsl"
        #else
            #include "/lib/atmospherics/stars.glsl"
        #endif

        #ifdef VL_CLOUDS_ACTIVE
            #include "/lib/atmospherics/clouds/mainClouds.glsl"
        #endif
    #endif

    #include "/lib/materials/materialMethods/reflections.glsl"
#endif

#ifdef ATM_COLOR_MULTS
    #include "/lib/colors/colorMultipliers.glsl"
#endif

#ifdef TAA
    #include "/lib/antialiasing/jitter.glsl"
#endif

#ifdef SNOWY_WORLD
    #include "/lib/materials/materialMethods/snowyWorld.glsl"
#endif

#ifdef SS_BLOCKLIGHT
    #include "/lib/lighting/coloredBlocklight.glsl"
#endif

#if PIXEL_WATER > 0
    #include "/lib/materials/materialMethods/waterProcedureTexture.glsl"
#endif

//Program//
void voxy_emitFragment(VoxyFragmentParameters parameters) {
    // Prepare
        mat = int(parameters.customId);
        lmCoord = clamp((parameters.lightMap - 0.03125) * 1.06667, vec2(0.0), vec2(0.9333, 1.0));
        lmCoordM = lmCoord;
        normal = upVec;
        switch (uint(parameters.face) >> 1u) {
            case 0u:
            normal = vxModelView[1].xyz;
            break;
            case 1u:
            normal = vxModelView[2].xyz;
            break;
            case 2u:
            normal = vxModelView[0].xyz;
            break;
        }
        if ((parameters.face & 1) == 0) {
            normal = -normal;
        }
        NdotU = dot(normal, upVec);
        NdotUmax0 = max(NdotU, 0.0);
        glColor = parameters.tinting;
    //
    vec4 colorP = parameters.sampledColour;
    vec4 color = parameters.sampledColour * vec4(glColor.rgb, 1.0);

    vec3 screenPos = vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z);
    #ifdef TAA
        vec3 viewPos = ScreenToView(vec3(TAAJitter(screenPos.xy, -0.5), screenPos.z));
    #else
        vec3 viewPos = ScreenToView(screenPos);
    #endif
    float lViewPos = length(viewPos);
    vec3 nViewPos = normalize(viewPos);
    vec3 playerPos = mat3(vxModelViewInv) * viewPos + vxModelViewInv[3].xyz;
    vec3 worldPos = playerPos + cameraPosition;

    vec3 tangent = vxModelView[0].xyz;
    vec3 binormal = vxModelView[2].xyz;
    tbnMatrix = mat3(tangent.x, binormal.x, normal.x,
                     tangent.y, binormal.y, normal.y,
                     tangent.z, binormal.z, normal.z);
    viewVector = vec3(playerPos.x, playerPos.z, 0);

    float dither = Bayer64(gl_FragCoord.xy);
    #ifdef TAA
        dither = fract(dither + goldenRatio * mod(float(frameCounter), 3600.0));
    #endif

    #ifdef ATM_COLOR_MULTS
        atmColorMult = GetAtmColorMult();
        sqrtAtmColorMult = sqrt(atmColorMult);
    #endif

    float materialMask = 0.0;
    float VdotU = dot(nViewPos, upVec);
    float VdotS = dot(nViewPos, sunVec);
    float VdotN = dot(nViewPos, normal);

    // Materials
    vec4 translucentMult = vec4(1.0);
    bool noSmoothLighting = false, noDirectionalShading = false, translucentMultCalculated = false, noGeneratedNormals = false;
    int subsurfaceMode = 0;
    float smoothnessG = 0.0, highlightMult = 1.0, reflectMult = 0.0, emission = 0.0;
    vec3 geoNormal = normal, normalM = normal, shadowMult = vec3(1.0);
    vec3 worldGeoNormal = normalize(mat3(vxModelViewInv) * normal);
    float fresnel = clamp(1.0 + dot(normalM, nViewPos), 0.0, 1.0);
    float fresnelM = pow3(fresnel);

    float overlayNoiseIntensity = 1.0, snowNoiseIntensity = 1.0, sandNoiseIntensity = 1.0, mossNoiseIntensity = 1.0, overlayNoiseTransparentOverwrite = 0.0, overlayNoiseAlpha = 1.0, overlayNoiseFresnelMult = 1.0, IPBRMult = 1.0, purkinjeOverwrite = 0.0, enderDragonDead = 1.0, SSBLAlpha = 1.0;
    bool isFoliage = false;
    vec3 dhColor = vec3(1.0);

    #include "/lib/materials/materialHandling/translucentMaterials.glsl"

    bool isLightSource = false;
    if (lmCoord.x > 0.99) { // Mod support for light level 15 light sources
        if (mat == 0) {
            emission = DoAutomaticEmission(noSmoothLighting, noDirectionalShading, color.rgb, lmCoord.x, blockLightEmission, 0.0);
        }
        isLightSource = true;
        overlayNoiseIntensity = 0.0;
    }

    #if MONOTONE_WORLD > 0
        #if MONOTONE_WORLD == 1
            color.rgb = vec3(1.0);
        #elif MONOTONE_WORLD == 2
            color.rgb = vec3(0.0);
        #else
            color.rgb = vec3(0.5);
        #endif
    #endif

    #ifdef SS_BLOCKLIGHT
        blocklightCol = ApplyMultiColoredBlocklight(blocklightCol, screenPos, playerPos, lmCoord.x);
    #endif

    emission *= EMISSION_MULTIPLIER;

    DoLighting(color, shadowMult, playerPos, viewPos, lViewPos, geoNormal, normalM, dither,
               worldGeoNormal, lmCoordM, noSmoothLighting, noDirectionalShading, false,
               false, subsurfaceMode, smoothnessG, highlightMult, emission, purkinjeOverwrite, isLightSource,
               enderDragonDead);

    #ifdef SS_BLOCKLIGHT
        vec3 normalizedColor = normalize(color.rgb);
        vec3 maskedLightAlbedo =
            (mat == 30012 || mat == 30016 || (mat >= 31000 && mat < 32000) || mat == 32004) // Slime, Honey, Glass, Ice
            ? normalizedColor : vec3(0.0);
        vec3 lightAlbedo = mix(maskedLightAlbedo, normalizedColor * min1(emission), color.a);
    #endif

    // Reflections
    float skyLightFactor = GetSkyLightFactor(lmCoordM, shadowMult);
    #if WATER_REFLECT_QUALITY >= 0
        #ifdef LIGHT_COLOR_MULTS
            highlightColor *= lightColorMult;
        #endif
        #ifdef MOON_PHASE_INF_REFLECTION
            highlightColor *= pow2(moonPhaseInfluence);
        #endif

        fresnelM = (fresnelM * 0.85 + 0.15) * reflectMult;

        vec4 reflection = GetReflection(normalM, viewPos.xyz, nViewPos, playerPos, lViewPos, -1.0,
                                        vxDepthTexOpaque, dither, skyLightFactor, fresnel,
                                        smoothnessG, geoNormal, color.rgb, shadowMult, highlightMult, enderDragonDead, vec2(0.0));
        color.rgb = mix(color.rgb, reflection.rgb, fresnelM);
    #else
        fresnelM = 0.0;
        vec4 reflection = vec4(0.0);
    #endif

    float entitySSBLMask = 1.0;
    #ifdef ENTITIES_ARE_LIGHT
        entitySSBLMask = 0.0;
    #endif

    ////

    // Writing to: 0,6,9 (defined in voxy.json)
    gbufferData0 = color;
    gbufferData6 = vec4(1.0, materialMask, 0.0, lmCoord.x + clamp01(purkinjeOverwrite) + clamp01(emission));
    #ifdef SS_BLOCKLIGHT
        gbufferData9 = vec4(lightAlbedo, entitySSBLMask);
    #endif
}

#endif

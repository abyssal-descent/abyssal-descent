//////////////////////////////////////////
// Complementary Shaders by EminGT      //
// With Euphoria Patches by SpacEagle17 //
//////////////////////////////////////////
#extension GL_ARB_derivative_control : enable
#ifdef GL_ARB_derivative_control
    #define USE_FINE_DERIVATIVES
#endif

//Common//
#include "/lib/common.glsl"
#include "/lib/shaderSettings/materials.glsl"
#include "/lib/shaderSettings/shockwave.glsl"
#include "/lib/shaderSettings/interactiveFoliage.glsl"
#include "/lib/shaderSettings/emissionMult.glsl"
#include "/lib/shaderSettings/emissionMult.glsl"
#include "/lib/shaderSettings/wavingBlocks.glsl"
//#define NIGHT_DESATURATION

#if defined MIRROR_DIMENSION || defined WORLD_CURVATURE
    #include "/lib/misc/distortWorld.glsl"
#endif

#ifdef GBUFFERS_VOXELS
    #include "/photonics/photonics.glsl"
#endif

//////////Fragment Shader//////////Fragment Shader//////////Fragment Shader//////////
#ifdef FRAGMENT_SHADER

flat in int mat;
flat in int blockLightEmission;

in vec2 texCoord;
#ifdef GBUFFERS_COLORWHEEL
    vec2 lmCoord;
#else
    in vec2 lmCoord;
#endif
in vec2 signMidCoordPos;
flat in vec2 absMidCoordPos;
flat in vec2 midCoord;
in vec3 blockUV;
in vec3 atMidBlock;
// #if SEASONS == 1 || SEASONS == 4 || defined MOSS_NOISE_INTERNAL || defined SAND_NOISE_INTERNAL
//     flat in ivec2 pixelTexSize;
// #endif

flat in vec3 upVec, sunVec, northVec, eastVec;
in vec3 normal;
in vec3 vertexPos;

#ifdef GBUFFERS_VOXELS
    in vec3 blockNormal;
#endif

in vec4 glColorRaw;

#if RAIN_PUDDLES >= 1 || defined GENERATED_NORMALS || defined CUSTOM_PBR
    flat in vec3 binormal, tangent;
#endif

#ifdef POM
    in vec3 viewVector;

    in vec4 vTexCoordAM;
#endif

#if ANISOTROPIC_FILTER > 0
    in vec4 spriteBounds;
#endif

#ifdef IRIS_FEATURE_FADE_VARIABLE
    flat in float chunkFade;
#endif

//Pipeline Constants//
#if END_CRYSTAL_VORTEX_INTERNAL > 0 || DRAGON_DEATH_EFFECT_INTERNAL > 0
    const float voxelDistance = 64.0;
#elif COLORED_LIGHTING_INTERNAL > 0
    #if WORLD_SPACE_REFLECTIONS_INTERNAL == -1
        const float voxelDistance = 32.0;
    #else
        const float voxelDistance = 64.0;
    #endif
#endif

//Common Variables//
float NdotU = dot(normal, upVec);
float geoNdotU = NdotU;
float NdotUmax0 = max(NdotU, 0.0);
float SdotU = dot(sunVec, upVec);
float sunFactor = SdotU < 0.0 ? clamp(SdotU + 0.375, 0.0, 0.75) / 0.75 : clamp(SdotU + 0.03125, 0.0, 0.0625) / 0.0625;
float sunVisibility = clamp(SdotU + 0.0625, 0.0, 0.125) / 0.125;
float sunVisibility2 = sunVisibility * sunVisibility;
float shadowTimeVar1 = abs(sunVisibility - 0.5) * 2.0;
float shadowTimeVar2 = shadowTimeVar1 * shadowTimeVar1;
float shadowTime = shadowTimeVar2 * shadowTimeVar2;
float skyLightCheck = 0.0;

vec4 glColor = glColorRaw;

#ifdef OVERWORLD
    vec3 lightVec = sunVec * ((timeAngle < 0.5325 || timeAngle > 0.9675) ? 1.0 : -1.0);
#else
    vec3 lightVec = sunVec;
#endif

#if RAIN_PUDDLES >= 1 || defined GENERATED_NORMALS || defined CUSTOM_PBR
    mat3 tbnMatrix = mat3(
        tangent.x, binormal.x, normal.x,
        tangent.y, binormal.y, normal.y,
        tangent.z, binormal.z, normal.z
    );
#endif

//Common Functions//
void DoFoliageColorTweaks(inout vec3 color, inout vec3 shadowMult, inout float snowMinNdotU, vec3 viewPos, vec3 nViewPos, float lViewPos, float dither) {
    float factor = max(80.0 - lViewPos, 0.0);
    shadowMult *= 1.0 + 0.004 * noonFactor * factor;

    #if defined IPBR && !defined IPBR_COMPAT_MODE
        color.rgb *= 0.97 - 0.2 * signMidCoordPos.x;
    #endif

    //#define FOLIAGE_ALT_SUBSURFACE

    #ifdef FOLIAGE_ALT_SUBSURFACE
        float edgeSize = 0.12;
        float edgeEffectFactor = 0.75;

        vec2 texCoordM = texCoord;
             texCoordM.y -= edgeSize * dither * absMidCoordPos.y;
             texCoordM.y = max(texCoordM.y, midCoord.y - absMidCoordPos.y);
        vec4 colorSample = texture2DLod(tex, texCoordM, 0);

        if (colorSample.a < 0.5) {
            float edgeFactor = dot(nViewPos, lightVec);
            shadowMult *= 1.0 + edgeEffectFactor * (1.0 + edgeFactor);
        }

        shadowMult *= 1.03 + 0.2333 * edgeEffectFactor * (dot(normal, lightVec) - 1.0);
    #endif

    #ifdef SNOWY_WORLD
        if (glColor.g - glColor.b > 0.01)
            snowMinNdotU = min(pow2(pow2(max0(color.g * 2.0 - color.r - color.b))) * 5.0, 0.1);
        else
            snowMinNdotU = min(pow2(pow2(max0(color.g * 2.0 - color.r - color.b))) * 3.0, 0.1) * 0.25;

        #ifdef DISTANT_HORIZONS
            // DH chunks don't have foliage. The border looks too noticeable without this tweak
            snowMinNdotU = mix(snowMinNdotU, 0.09, smoothstep(far * 0.5, far, lViewPos));
        #endif
    #endif
}

void DoBrightBlockTweaks(vec3 color, float minLight, inout vec3 shadowMult, inout float highlightMult) {
    float factor = mix(minLight * 0.5 + 0.5, 1.0, pow2(pow2(color.r)));
    shadowMult = vec3(factor);
    highlightMult /= factor;
}

void DoOceanBlockTweaks(inout float smoothnessD) {
    smoothnessD *= max0(lmCoord.y - 0.95) * 20.0;
}

//Includes//
#include "/lib/util/spaceConversion.glsl"
#include "/lib/lighting/mainLighting.glsl"
#include "/lib/util/dither.glsl"

#ifdef TAA
    #include "/lib/antialiasing/jitter.glsl"
#endif

#if defined GENERATED_NORMALS || defined COATED_TEXTURES || ANISOTROPIC_FILTER > 0 || defined DISTANT_LIGHT_BOKEH
    #include "/lib/util/miplevel.glsl"
#endif

#ifdef GENERATED_NORMALS
    #include "/lib/materials/materialMethods/generatedNormals.glsl"
#endif

#ifdef COATED_TEXTURES
    #include "/lib/materials/materialMethods/coatedTextures.glsl"
#endif

#if IPBR_EMISSIVE_MODE != 1
    #include "/lib/materials/materialMethods/customEmission.glsl"
#endif

#ifdef CUSTOM_PBR
    #include "/lib/materials/materialHandling/customMaterials.glsl"
#endif

#ifdef COLOR_CODED_PROGRAMS
    #include "/lib/misc/colorCodedPrograms.glsl"
#endif

#if ANISOTROPIC_FILTER > 0
    #include "/lib/materials/materialMethods/anisotropicFiltering.glsl"
#endif

#ifdef PUDDLE_VOXELIZATION
    #include "/lib/voxelization/puddleVoxelization.glsl"
#endif

#ifdef ACT_GROUND_LEAVES_FIX
    #include "/lib/voxelization/leavesVoxelization.glsl"
#endif

#ifdef SNOWY_WORLD
    #include "/lib/materials/materialMethods/snowyWorld.glsl"
#endif

#ifdef DISTANT_LIGHT_BOKEH
    #include "/lib/misc/distantLightBokeh.glsl"
#endif

#if RAIN_PUDDLES >= 1 && BLOCK_REFLECT_QUALITY == 1 && defined OVERWORLD
    #ifdef ATM_COLOR_MULTS
        #include "/lib/colors/colorMultipliers.glsl"
    #endif
    #ifdef MOON_PHASE_INF_ATMOSPHERE
        #include "/lib/colors/moonPhaseInfluence.glsl"
    #endif

    #include "/lib/atmospherics/sky.glsl"
#endif

#ifdef SS_BLOCKLIGHT
    #include "/lib/lighting/coloredBlocklight.glsl"
#endif

#if defined ATM_COLOR_MULTS
    #include "/lib/colors/colorMultipliers.glsl"
#endif

#if SEASONS > 0 || defined MOSS_NOISE_INTERNAL || defined SAND_NOISE_INTERNAL
    #include "/lib/materials/overlayNoise.glsl"
#endif

#if PIXEL_WATER > 0
    #include "/lib/materials/materialMethods/waterProcedureTexture.glsl"
#endif

#if SHOCKWAVE > 0
    #include "/lib/misc/shockwave.glsl"
#endif

//Program//
void main() {
    skyLightCheck = pow2(1.0 - min1(lmCoord.y * 2.9 * sunVisibility));

    vec3 screenPos = vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z);
    #ifdef TAA
        vec3 viewPos = ScreenToView(vec3(TAAJitter(screenPos.xy, -0.5), screenPos.z));
    #else
        vec3 viewPos = ScreenToView(screenPos);
    #endif
    float lViewPos = length(viewPos);
    vec3 nViewPos = normalize(viewPos);
    vec3 playerPos = vertexPos;
    vec3 worldPos = playerPos + cameraPosition;

    vec3 normalM = normal, geoNormal = normal, shadowMult = vec3(1.0), normal_PH = normal;

    #ifdef GBUFFERS_VOXELS
        #undef GENERATED_NORMALS
        #undef COATED_TEXTURES
        // Photonics raytracing
        RayJob ray = RayJob(vec3(0), vec3(0), vec3(0), vec3(0), vec3(0), false);
        ray.origin = worldPos - world_offset - 0.001f * blockNormal;
        ray.direction = playerPos - gbufferModelViewInverse[3].xyz;
        ray_constraint = ivec3(ray.origin);
        trace_ray(ray);

        if (!ray.result_hit) discard;
        if (ray.result_normal == vec3(0.0f)) ray.result_normal = blockNormal;

        playerPos = ray.result_position + world_offset - cameraPosition;
        viewPos = (gbufferModelView * vec4(playerPos, 1.0f)).xyz;
        vec4 ndc4 = gbufferProjection * vec4(viewPos, 1.0f);
        screenPos = ndc4.xyz / ndc4.w * 0.5f + 0.5f;
        gl_FragDepth = screenPos.z;

        lViewPos = length(viewPos);
        nViewPos = normalize(viewPos);

        normal_PH = normalize(gl_NormalMatrix * ray.result_normal);
        normalM = normal_PH;
        vec4 color = vec4(ray.result_color, 1.0f);
    #else
        #if SHOCKWAVE > 0
            vec4 color = doShockwave(playerPos + relativeEyePosition, texCoord);
        #else
            #if ANISOTROPIC_FILTER == 0
                vec4 color = texture2D(tex, texCoord);
            #else
                vec4 color = textureAF(tex, texCoord);
            #endif
        #endif
    #endif

    float smoothnessD = 0.0, materialMask = 0.0;

    #if !defined POM || !defined POM_ALLOW_CUTOUT
        if (color.a <= 0.00001) discard; // 6WIR4HT23
    #endif

    vec3 colorP = color.rgb;

    #ifdef GBUFFERS_COLORWHEEL
        float ao;
        vec4 overlayColor;

        clrwl_computeFragment(color, color, lmCoord, ao, overlayColor);
        color.rgb = mix(color.rgb, overlayColor.rgb, overlayColor.a);
        lmCoord = clamp((lmCoord - 1.0 / 32.0) * 32.0 / 30.0, 0.0, 1.0);
    #else
        color.rgb *= glColor.rgb;
    #endif

    float dither = Bayer64(gl_FragCoord.xy);
    #ifdef TAA
        dither = fract(dither + goldenRatio * mod(float(frameCounter), 3600.0));
    #endif

    int subsurfaceMode = 0;
    bool noSmoothLighting = false, noDirectionalShading = false, noVanillaAO = false, centerShadowBias = false, noGeneratedNormals = false, doTileRandomisation = true;
    float smoothnessG = 0.0, highlightMult = 1.0, emission = 0.0, noiseFactor = 1.0, snowFactor = 1.0, snowMinNdotU = 0.0, noPuddles = 0.0;
    vec2 lmCoordM = lmCoord;
    #ifdef PHOTONICS_LIGHTING
        vec3 oldAlbedo = vec3(0.0);
    #endif
    vec3 worldGeoNormal = normalize(ViewToPlayer(geoNormal * 10000.0));

    bool isFoliage = false;
    float overlayNoiseIntensity = 1.0, snowNoiseIntensity = 1.0, sandNoiseIntensity = 1.0, mossNoiseIntensity = 1.0, overlayNoiseTransparentOverwrite = 0.0, overlayNoiseEmission = 1.0, IPBRMult = 1.0, lavaNoiseIntensity = LAVA_NOISE_INTENSITY, enderDragonDead = 1.0, purkinjeOverwrite = 0.0;
    vec3 dhColor = vec3(1.0);

    bool isLightSource = false;
    if (lmCoord.x > 0.99 || blockLightEmission > 0) { // Mod support for light level 15 (and all light levels with iris 1.7) light sources
        if (mat == 0) {
            emission = DoAutomaticEmission(noSmoothLighting, noDirectionalShading, color.rgb, lmCoord.x, blockLightEmission, 0.0);
        }
        isLightSource = true;
        overlayNoiseIntensity = 0.0;
    }

    #ifndef GBUFFERS_COLORWHEEL
    if (length(abs(worldGeoNormal.xz) - vec2(sqrt(0.5))) < 0.01) { // Auto SSS on unknown cross model blocks (modded)
        if (mat == 0) {
            subsurfaceMode = 1;
            noSmoothLighting = true, noDirectionalShading = true;
        }
        isFoliage = true;
        sandNoiseIntensity = 0.3, mossNoiseIntensity = 0.0;
    }
    #endif

    #include "/lib/materials/materialHandling/terrainMaterials.glsl"

    #ifdef SNOWY_WORLD
        DoSnowyWorld(color, smoothnessG, highlightMult, smoothnessD, emission,
                     playerPos, lmCoord, snowFactor, snowMinNdotU, NdotU, subsurfaceMode);
    #endif

    #if defined NETHER && defined BIOME_COLORED_NETHER_PORTALS && !defined IPBR
        if (mat == 10476 || mat == 10588 || mat == 10592) { // Crying Obsidian, Respawn Anchor lit and unlit
            float luminance = GetLuminance(color.rgb);
            emission = sqrt(luminance * luminance) * 10.0;
            color.a *= luminance;
        }
    #endif

    #if SEASONS > 0
        #include "/lib/materials/seasons.glsl"
    #endif
    #if defined MOSS_NOISE_INTERNAL || defined SAND_NOISE_INTERNAL
        #include "/lib/materials/overlayNoiseApply.glsl"
    #endif

    #if defined COATED_TEXTURES && defined IPBR
        CoatTextures(color.rgb, noiseFactor, playerPos, doTileRandomisation); // Has to be after seasons and overlay noise to work properly with them in IPBR mode
    #endif

    #if MONOTONE_WORLD > 0
        #if MONOTONE_WORLD == 1
            color.rgb = vec3(1.0);
        #elif MONOTONE_WORLD == 2
            color.rgb = vec3(0.0);
        #else
            color.rgb = vec3(0.5);
        #endif
    #endif

    #if RAIN_PUDDLES >= 1 && defined OVERWORLD
        float puddleLightFactor = max0(lmCoord.y * 32.0 - 31.0) * clamp((1.0 - 1.15 * lmCoord.x) * 10.0, 0.0, 1.0);
        float puddleNormalFactor = pow2(max0(NdotUmax0 - 0.5) * 2.0);
        float puddleMixer = puddleLightFactor * inRainy * puddleNormalFactor;
        #if RAIN_PUDDLES < 3
            float wetnessM = wetnessDynamic;
        #else
            float wetnessM = 1.0;
        #endif
        #ifdef PUDDLE_VOXELIZATION
            vec3 voxelPos = SceneToPuddleVoxel(playerPos);
            vec3 voxel_sample_pos = clamp01(voxelPos / vec3(puddle_voxelVolumeSize));
            if (CheckInsidePuddleVoxelVolume(voxelPos)) {
                noPuddles += texture2D(puddle_sampler, voxel_sample_pos.xz).r;
            }
        #endif
        if (pow2(pow2(wetnessM)) * puddleMixer - noPuddles > 0.00001) {
            vec2 worldPosXZ = playerPos.xz + cameraPosition.xz;
            vec2 puddleWind = vec2(frameTimeCounter) * 0.03;
            #if WATER_STYLE == 1
                vec2 puddlePosNormal = floor(worldPosXZ * 16.0) * 0.0625;
            #else
                vec2 puddlePosNormal = worldPosXZ;
            #endif

            puddlePosNormal *= 0.1;
            vec2 pNormalCoord1 = puddlePosNormal + vec2(puddleWind.x, puddleWind.y);
            vec2 pNormalCoord2 = puddlePosNormal + vec2(puddleWind.x * -1.5, puddleWind.y * -1.0);
            vec3 pNormalNoise1 = texture2DLod(noisetex, pNormalCoord1, 0.0).rgb;
            vec3 pNormalNoise2 = texture2DLod(noisetex, pNormalCoord2, 0.0).rgb;
            float pNormalMult = 0.03;

            vec3 puddleNormal = vec3((pNormalNoise1.xy + pNormalNoise2.xy - vec2(1.0)) * pNormalMult, 1.0);
            puddleNormal = clamp(normalize(puddleNormal * tbnMatrix), vec3(-1.0), vec3(1.0));
            puddleNormal = normalize(mix(geoNormal, puddleNormal, rainFactor));

            #if RAIN_PUDDLES == 1 || RAIN_PUDDLES == 3
                vec2 puddlePosForm = puddlePosNormal * 0.05;
                float pFormNoise  = texture2DLod(noisetex, puddlePosForm, 0.0).b        * 3.0;
                      pFormNoise += texture2DLod(noisetex, puddlePosForm * 0.5, 0.0).b  * 5.0;
                      pFormNoise += texture2DLod(noisetex, puddlePosForm * 0.25, 0.0).b * 8.0;
                      pFormNoise *= sqrt1(wetnessM) * 0.5625 + 0.4375;
                      pFormNoise  = clamp(pFormNoise - 7.0, 0.0, 1.0);
            #else
                float pFormNoise = wetnessM;
            #endif
            puddleMixer *= pFormNoise;

            float puddleSmoothnessG = 0.7 - rainFactor * 0.3;
            float puddleHighlight = (1.5 - subsurfaceMode * 0.6 * invNoonFactor);
            smoothnessG = mix(smoothnessG, puddleSmoothnessG, puddleMixer);
            highlightMult = mix(highlightMult, puddleHighlight, puddleMixer);
            smoothnessD = mix(smoothnessD, 1.0, sqrt1(puddleMixer));
            normalM = normalize(mix(normalM, puddleNormal, sqrt1(puddleMixer) * 0.98));
        } else puddleMixer = 0.0;
    #endif

    #if SHOW_LIGHT_LEVEL > 0
        #include "/lib/misc/showLightLevels.glsl"
    #endif

    #ifdef DH_BLENDING
        float fog = max(length(playerPos.xz), abs(playerPos.y)) / far;
        fog = pow2(pow2(pow2(pow2(fog))));
        fog = exp(-3.0 * fog);

        float newDither = fract(dither * 50.0); // Using normal dither here doesnt work well with TAA
        if (newDither > fog) discard;

        fog *= fog;
        emission *= fog;
    #endif

    #ifdef SS_BLOCKLIGHT
        float lmCoordXModified = lmCoord.x;
        #ifdef IRIS_FEATURE_BLOCK_EMISSION_ATTRIBUTE
            lmCoordXModified = lmCoord.x == 1.0 && blockLightEmission < 0.5 ? 0.0 : lmCoord.x;
        #endif
        blocklightCol = ApplyMultiColoredBlocklight(blocklightCol, screenPos, playerPos, lmCoordXModified);
    #endif

    emission *= EMISSION_MULTIPLIER;

    #ifdef PHOTONICS_LIGHTING
        oldAlbedo = color.rgb;
    #endif

    DoLighting(color, shadowMult, playerPos, viewPos, lViewPos, geoNormal, normalM, dither,
               worldGeoNormal, lmCoordM, noSmoothLighting, noDirectionalShading, noVanillaAO,
               centerShadowBias, subsurfaceMode, smoothnessG, highlightMult, emission, purkinjeOverwrite, isLightSource,
               enderDragonDead);

    #ifdef SS_BLOCKLIGHT
        vec3 lightAlbedo = normalize(color.rgb) * min1(emission);

        #ifdef COLORED_CANDLE_LIGHT
            if (mat >= 10900 && mat <= 10922) { // Candles:Lit
                lightAlbedo = normalize(color.rgb) * lmCoord.x;
            }
        #endif
    #endif

    #ifdef IPBR
        color.rgb += maRecolor;
    #endif

    #if RAIN_PUDDLES >= 1 && BLOCK_REFLECT_QUALITY == 1 && defined OVERWORLD
        // Adding low quality sky reflection to puddles if Block Reflection Quality is Low
        if (puddleMixer > 0.00001) {
            vec3 nViewPosR = normalize(reflect(nViewPos, normalM));
            float RVdotU = dot(nViewPosR, upVec);
            float RVdotS = dot(nViewPosR, sunVec);

            vec3 sky = GetLowQualitySky(RVdotU, RVdotS, dither, true, false);
            #ifdef ATM_COLOR_MULTS
                atmColorMult = GetAtmColorMult();
                sky *= atmColorMult;
            #endif
            #ifdef MOON_PHASE_INF_ATMOSPHERE
                sky *= moonPhaseInfluence;
            #endif

            float fresnel = clamp(1.0 + dot(normalM, nViewPos), 0.0, 1.0);

            sky *= 0.5 + 0.5 * GetLuminance(shadowMult);
            fresnel *= 0.5;

            color.rgb = mix(color.rgb, sky, fresnel * puddleMixer);
        }
   #endif

    float skyLightFactor = GetSkyLightFactor(lmCoordM, shadowMult);

    #ifdef COLOR_CODED_PROGRAMS
        ColorCodeProgram(color, mat);
    #endif

    #ifdef IRIS_FEATURE_FADE_VARIABLE
        skyLightFactor *= 0.5;
        if (chunkFade < 1.0) skyLightFactor = 1.0 - chunkFade * 0.5;
    #endif

    #ifdef PHOTONICS_LIGHTING
        vec4 phAlbedoOut = vec4(oldAlbedo, 1.0);
        vec3 playerPosDelta = vec3(0.0);
        #ifdef DO_PIXELATION_EFFECTS
            // Compute snap delta here where dFdx/dFdy are valid (same triangle in 2x2 quad)
            // Store world-space delta so post-passes can apply it without any derivatives
            vec2 pixelationOffset = ComputeTexelOffset(tex, texCoord);
            playerPosDelta = TexelSnap(playerPos, pixelationOffset) - playerPos;
        #endif
    #endif

    /* DRAWBUFFERS:06 */
    gl_FragData[0] = color;
    gl_FragData[1] = vec4(smoothnessD, materialMask, skyLightFactor, lmCoord.x + clamp01(purkinjeOverwrite) + clamp01(emission));

    #if BLOCK_REFLECT_QUALITY >= 2 && RP_MODE != 0
        /* DRAWBUFFERS:064 */
        gl_FragData[2] = vec4(mat3(gbufferModelViewInverse) * normalM, 1.0);

        #ifdef SS_BLOCKLIGHT
            /* DRAWBUFFERS:0649 */
            gl_FragData[3] = vec4(lightAlbedo, 0.0);
        #endif

        #ifdef PHOTONICS_LIGHTING
            /* RENDERTARGETS:0,6,4,10,11,20 */
            gl_FragData[3] = phAlbedoOut;
            gl_FragData[4] = vec4(playerPosDelta, 1.0);
            gl_FragData[5] = vec4(normalize((gbufferModelViewInverse * vec4(normal_PH, 0.0f)).xyz), 1.0);
        #endif
    #elif defined SS_BLOCKLIGHT
        /* DRAWBUFFERS:069 */
        gl_FragData[2] = vec4(lightAlbedo, 0.0);
    #elif defined PHOTONICS_LIGHTING
        /* RENDERTARGETS:0,6,4,10,11,20 */
        gl_FragData[2] = vec4(mat3(gbufferModelViewInverse) * normalM, 1.0);
        gl_FragData[3] = phAlbedoOut;
        gl_FragData[4] = vec4(playerPosDelta, 1.0);
        gl_FragData[5] = vec4(normalize((gbufferModelViewInverse * vec4(normal_PH, 0.0f)).xyz), 1.0);
    #endif

}

#endif

//////////Vertex Shader//////////Vertex Shader//////////Vertex Shader//////////
#ifdef VERTEX_SHADER

flat out int mat;
flat out int blockLightEmission;

out vec2 texCoord;
#ifdef GBUFFERS_COLORWHEEL
    vec2 lmCoord;
#else
    out vec2 lmCoord;
#endif

out vec2 signMidCoordPos;
flat out vec2 absMidCoordPos;
flat out vec2 midCoord;
out vec3 blockUV;
out vec3 atMidBlock;
// #if SEASONS == 1 || SEASONS == 4 || defined MOSS_NOISE_INTERNAL || defined SAND_NOISE_INTERNAL
//     flat out ivec2 pixelTexSize;
// #endif

flat out vec3 upVec, sunVec, northVec, eastVec;
out vec3 normal;
out vec3 vertexPos;

#ifdef GBUFFERS_VOXELS
    out vec3 blockNormal;
#endif

out vec4 glColorRaw;

#if RAIN_PUDDLES >= 1 || defined GENERATED_NORMALS || defined CUSTOM_PBR
    flat out vec3 binormal, tangent;
#endif

#ifdef POM
    out vec3 viewVector;

    out vec4 vTexCoordAM;
#endif

#if ANISOTROPIC_FILTER > 0
    out vec4 spriteBounds;
#endif

#ifdef IRIS_FEATURE_FADE_VARIABLE
    flat out float chunkFade;
#endif

//Attributes//
attribute vec4 mc_Entity;
attribute vec4 mc_midTexCoord;
attribute vec4 at_midBlock;

#if RAIN_PUDDLES >= 1 || defined GENERATED_NORMALS || defined CUSTOM_PBR
    attribute vec4 at_tangent;
#endif

//Common Variables//
vec4 glColor = vec4(1.0);

//Common Functions//

//Includes//
#ifdef TAA
    #include "/lib/antialiasing/jitter.glsl"
#endif

#if defined WAVING_ANYTHING_TERRAIN || defined INTERACTIVE_FOLIAGE || defined WAVE_EVERYTHING
    #include "/lib/materials/materialMethods/wavingBlocks.glsl"
#endif

float infnorm(vec3 x) {return max(max(abs(x.x), abs(x.y)), abs(x.z));} // Thanks to gri for general non axis aligned normal detection
float isCross(vec3 x) {return length(abs(normalize(x).xz) - vec2(sqrt(0.5)));}

//Program//
void main() {
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    #ifdef ATLAS_ROTATION
        texCoord += texCoord * float(hash33(mod(cameraPosition * 0.1, vec3(100.0))));
    #endif
    lmCoord  = GetLightMapCoordinates();
    blockUV = 0.5 - at_midBlock.xyz / 64.0;
    atMidBlock = at_midBlock.xyz;

    glColorRaw = gl_Color;
    if (glColorRaw.a < 0.1) glColorRaw.a = 1.0;
    glColor = glColorRaw;

    normal = normalize(gl_NormalMatrix * gl_Normal);
    upVec = normalize(gbufferModelView[1].xyz);
    eastVec = normalize(gbufferModelView[0].xyz);
    northVec = normalize(gbufferModelView[2].xyz);
    sunVec = GetSunVector();

    #ifdef GBUFFERS_VOXELS
        blockNormal = gl_Normal;
    #endif

    midCoord = (gl_TextureMatrix[0] * mc_midTexCoord).st;
    vec2 texMinMidCoord = texCoord - midCoord;
    signMidCoordPos = sign(texMinMidCoord);
    absMidCoordPos  = abs(texMinMidCoord);

    // #if SEASONS == 1 || SEASONS == 4 || defined MOSS_NOISE_INTERNAL || defined SAND_NOISE_INTERNAL
    //     pixelTexSize = ivec2(absMidCoordPos * 2.0 * atlasSize);
    // #endif

    mat = int(mc_Entity.x + 0.5);

    #if !(defined GBUFFERS_COLORWHEEL || defined GBUFFERS_VOXELS)
        if ((mat == 10132 || mat == 10133)){ // Improve Patrix Resource pack extra grass block model
            if (isCross(gl_Normal) < 0.5) mat = 10005; // First detect cross models
            else if (infnorm(gl_Normal) < 0.99) mat = 10031; // Then detect extruding faces, but ONLY if it's not already detected as cross
        }
    #endif

    #if ANISOTROPIC_FILTER > 0
        if (mc_Entity.y > 0.5 && dot(normal, upVec) < 0.999) absMidCoordPos = vec2(0.0); // Fix257062
    #endif

    vec4 position = gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;
    vertexPos = position.xyz;

    #ifdef GBUFFERS_VOXELS
        mat = 2;
        // mat = get_block_id(floor(rt_camera_position + vertexPos));
    #endif

    blockLightEmission = 0;
    #ifdef IRIS_FEATURE_BLOCK_EMISSION_ATTRIBUTE
        blockLightEmission = clamp(int(at_midBlock.w + 0.5), 0, 15);
    #endif

    #if defined MIRROR_DIMENSION || defined WORLD_CURVATURE || defined WAVING_ANYTHING_TERRAIN || defined WAVE_EVERYTHING || defined INTERACTIVE_FOLIAGE
        #ifdef MIRROR_DIMENSION
            doMirrorDimension(position);
        #endif
        #ifdef WORLD_CURVATURE
            position.y += doWorldCurvature(position.xz);
        #endif
        #ifdef WAVING_ANYTHING_TERRAIN
            DoWave(position.xyz, mat);
        #endif
        #ifdef INTERACTIVE_FOLIAGE
            if (mat == 10003 || mat == 10005 || mat == 10015 || mat == 10021 || mat == 10029 || mat == 10023 || mat == 10629 || mat == 10632 || mat == 10025 || mat == 10027 || mat == 10923 || mat == 10972) {
                vec3 playerPosM = position.xyz + relativeEyePosition;
                DoInteractiveWave(playerPosM, mat);
                position.xyz = playerPosM - relativeEyePosition;
            }
        #endif

        #ifdef WAVE_EVERYTHING
            DoWaveEverything(position.xyz);
        #endif

    #endif
    gl_Position = gl_ProjectionMatrix * gbufferModelView * position;

    #ifdef FLICKERING_FIX
        if (mat == 10257) gl_Position.z -= 0.00001; // Iron Bars
    #endif

    #ifdef TAA
        gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
    #endif

    #if RAIN_PUDDLES >= 1 || defined GENERATED_NORMALS || defined CUSTOM_PBR
        vec3 rawBinormal = gl_NormalMatrix * cross(at_tangent.xyz, gl_Normal.xyz) * at_tangent.w;
        binormal = rawBinormal * inversesqrt(max(dot(rawBinormal, rawBinormal), 1e-8));
        vec3 rawTangent = gl_NormalMatrix * at_tangent.xyz;
        tangent = rawTangent * inversesqrt(max(dot(rawTangent, rawTangent), 1e-8));
    #endif

    #ifdef POM
        mat3 tbnMatrix = mat3(
            tangent.x, binormal.x, normal.x,
            tangent.y, binormal.y, normal.y,
            tangent.z, binormal.z, normal.z
        );

        viewVector = tbnMatrix * (gl_ModelViewMatrix * gl_Vertex).xyz;

        vTexCoordAM.zw  = abs(texMinMidCoord) * 2;
        vTexCoordAM.xy  = min(texCoord, midCoord - texMinMidCoord);
    #endif

    #if ANISOTROPIC_FILTER > 0
        vec2 spriteRadius = abs(texCoord - mc_midTexCoord.xy);
        vec2 bottomLeft = mc_midTexCoord.xy - spriteRadius;
        vec2 topRight = mc_midTexCoord.xy + spriteRadius;
        spriteBounds = vec4(bottomLeft, topRight);
    #endif

    #ifdef IRIS_FEATURE_FADE_VARIABLE
        chunkFade = mc_chunkFade;
    #endif
}

#endif

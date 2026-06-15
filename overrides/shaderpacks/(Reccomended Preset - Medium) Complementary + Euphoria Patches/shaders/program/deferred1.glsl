//////////////////////////////////////////
// Complementary Shaders by EminGT      //
// With Euphoria Patches by SpacEagle17 //
//////////////////////////////////////////

//Common//
#include "/lib/common.glsl"
#include "/lib/shaderSettings/enderStars.glsl"
#include "/lib/shaderSettings/deferred1.glsl"

//////////Fragment Shader//////////Fragment Shader//////////Fragment Shader//////////
#ifdef FRAGMENT_SHADER

noperspective in vec2 texCoord;

flat in vec3 upVec, sunVec, eastVec;

#if defined LIGHTSHAFTS_ACTIVE && (LIGHTSHAFT_BEHAVIOUR == 1 && SHADOW_QUALITY >= 1 || defined END)
    flat in float vlFactor;
#endif

//Pipeline Constants//
const bool colortex0MipmapEnabled = true;

//Common Variables//
float SdotU = dot(sunVec, upVec);
float sunFactor = SdotU < 0.0 ? clamp(SdotU + 0.375, 0.0, 0.75) / 0.75 : clamp(SdotU + 0.03125, 0.0, 0.0625) / 0.0625;
float sunVisibility = clamp(SdotU + 0.0625, 0.0, 0.125) / 0.125;
float sunVisibility2 = sunVisibility * sunVisibility;
float shadowTimeVar1 = abs(sunVisibility - 0.5) * 2.0;
float shadowTimeVar2 = shadowTimeVar1 * shadowTimeVar1;
float shadowTime = shadowTimeVar2 * shadowTimeVar2;
float farMinusNear = far - near;

vec2 view = vec2(viewWidth, viewHeight);

#ifdef OVERWORLD
    vec3 lightVec = sunVec * ((timeAngle < 0.5325 || timeAngle > 0.9675) ? 1.0 : -1.0);
#else
    vec3 lightVec = sunVec;
#endif

#if defined LIGHTSHAFTS_ACTIVE && (LIGHTSHAFT_BEHAVIOUR == 1 && SHADOW_QUALITY >= 1 || defined END)
#else
    float vlFactor = 0.0;
#endif

#ifdef IRIS_FEATURE_FADE_VARIABLE
    float chunkFade = 1.0;
#endif

//Common Functions//
float GetLinearDepth(float depth) {
    return (2.0 * near) / (far + near - depth * farMinusNear);
}

float GetLinearDepth(float depth, float far, float near) {
    return (2.0 * near) / (far + near - depth * (far - near));
}

float CalculateLinearDepth(float depth_sample, float near_plane, float far_plane) {
    return (2.0 * near_plane) / (far_plane + near_plane - depth_sample * (far_plane - near_plane));
}

#ifdef PHOTONICS_LIGHTING
    vec3 compressLightSoftKnee(vec3 lightValue, float kneeStart, float maxExtra) {
        vec3 safeLight = max0(lightValue);
        float lightLum = GetLuminance(safeLight);

        if (lightLum <= kneeStart) return safeLight;

        float lumExcess = lightLum - kneeStart;
        float compressedLum = kneeStart + lumExcess / (1.0 + lumExcess / maxExtra);
        float lumScale = compressedLum / max(lightLum, 1e-5);
        return safeLight * lumScale;
    }
#endif

#if SSAO_QUALI > 0
    // Original offset distribution function
    vec2 OffsetDist(float x, int s) {
        float n = fract(x * 1.414) * 3.1415;
        return pow2(vec2(cos(n), sin(n)) * x / s);
    }

    // Improved offset distribution function for DH SSAO
    vec2 OffsetDistImproved(float x_norm, int s) {
        float n = fract(x_norm * 1.41421356237f) * 6.28318530718f;
        float radius_mult = x_norm;
        return vec2(cos(n), sin(n)) * radius_mult;
    }

    // Original SSAO function for regular geometry
    float GetAmbientOcclusion(sampler2D depthtex, float z0, float linearZ0, float dither, float farM, float nearM, float aoWorldRange, vec3 playerPos) {
        if (z0 < 0.56) return 1.0;
        float ao = 0.0;

        #if SSAO_QUALI == 2
            int samples = 4;
            float scm = 0.4;
        #elif SSAO_QUALI == 3
            int samples = 12;
            float scm = 0.6;
        #endif

        #define SSAO_I_FACTOR 0.004

        float sampleDepth = 0.0, angle = 0.0, dist = 0.0;
        float fovScale = gbufferProjection[1][1];
        float distScale = max((farM - nearM) * linearZ0 + near, 3.0);
        vec2 scale = vec2(scm / aspectRatio, scm) * fovScale / distScale;

        for (int i = 1; i <= samples; i++) {
            vec2 offset = OffsetDist(i + dither, samples) * scale;
            if (i % 2 == 0) offset.y = -offset.y;

            vec2 coord1 = texCoord + offset;
            vec2 coord2 = texCoord - offset;

            sampleDepth = GetLinearDepth(texture2D(depthtex, coord1).r, farM, nearM);
            float aosample = aoWorldRange * (linearZ0 - sampleDepth) * 2.0;
            angle = clamp(0.5 - aosample, 0.0, 1.0);
            dist = clamp(0.5 * aosample - 1.0, 0.0, 1.0);

            sampleDepth = GetLinearDepth(texture2D(depthtex, coord2).r, farM, nearM);
            aosample = aoWorldRange * (linearZ0 - sampleDepth) * 2.0;
            angle += clamp(0.5 - aosample, 0.0, 1.0);
            dist += clamp(0.5 * aosample - 1.0, 0.0, 1.0);

            ao += clamp(angle + dist, 0.0, 1.0);
        }
        ao /= samples;

        #define SSAO_IM SSAO_I * SSAO_I_FACTOR

        #ifdef RAIN_ATMOSPHERE
            vec3 lightningPos = getLightningPos(playerPos, lightningBoltPosition.xyz, false);
            vec2 lightningAdd = lightningFlashEffect(lightningPos, vec3(0), 550.0, 0, 0) * isLightningActive() * 0.5;
            ao += lightningAdd.y;
        #endif

        return pow(ao, SSAO_IM);
    }

    #ifdef DISTANT_HORIZONS
        #include "/lib/misc/dhSSAO.glsl"
    #endif

#endif

#if defined DISTANT_HORIZONS || defined VOXY
    float GetLinearDepth(float depth, mat4 invProjMatrix) {
        depth = depth * 2.0 - 1.0;
        vec2 zw = depth * invProjMatrix[2].zw + invProjMatrix[3].zw;
        return -zw.x / zw.y;
    }

    float GetLODShadows(vec3 viewPos, vec3 nViewPos, sampler2D depthtex, mat4 projection, mat4 projectionInverse, float dither) {
        #if defined OVERWORLD || defined END
            float shadow = 1.0;
            vec3 tracePos = viewPos.xyz;
            vec3 traceStep = normalize(lightVec) * 2.5;

            #ifdef TAA
                tracePos += traceStep * (fract(dither + frameCounter * 0.618) + 0.2);
            #else
                tracePos += traceStep * (dither + 0.2);
            #endif

            float traceZ = 0.0;
            float zDelta = 0.0;

            #ifdef VOXY
                vec3 texture6 = texelFetch(colortex6, texelCoord, 0).rgb;
                int materialMaskInt = int(texture6.g * 255.1);

                if (materialMaskInt != 253) // Reduced Edge TAA (Leaves)
                    tracePos -= nViewPos * 1.5; // Tweak to imitate shadow bias
            #endif

            for (int i = 0; i < 32; i++) {
                vec4 pos = projection * vec4(tracePos.xyz, 1.0);
                pos = pos / pos.w * 0.5 + 0.5;

                if (pos.x < 0.0 || pos.x > 1.0 || pos.y < 0.0 || pos.y > 1.0) break;

                #ifdef VOXY
                    traceZ = texture2D(depthtex0, pos.xy).r;

                    if (traceZ < 1.0) {
                        zDelta = -tracePos.z - GetLinearDepth(traceZ, gbufferProjectionInverse);
                    } else
                #endif
                {
                    traceZ = texture2D(depthtex, pos.xy).r;
                    zDelta = -tracePos.z - GetLinearDepth(traceZ, projectionInverse);
                }

                shadow *= 1.0 - smoothstep(0.0, 0.01, zDelta) * smoothstep(5.0, 4.0, zDelta);
                tracePos += traceStep;
            }

            return shadow;
        #else
            return 1.0;
        #endif
    }
#endif

//Includes//
#include "/lib/util/spaceConversion.glsl"
#include "/lib/util/dither.glsl"
#include "/lib/atmospherics/fog/mainFog.glsl"
#include "/lib/colors/skyColors.glsl"
#include "/lib/colors/lightAndAmbientColors.glsl"
#include "/lib/atmospherics/fog/endCenterFog.glsl"

#ifdef PHOTONICS_LIGHTING
    #include "/lib/shaderSettings/photonics.glsl"
    #include "/photonics/ph_samplers.glsl"
    #include "/lib/shaderSettings/mainLighting.glsl"
#endif

#if AURORA_STYLE > 0
    #include "/lib/atmospherics/auroraBorealis.glsl"
#endif

#if NETHER_NOISE == 1 && defined NETHER
    #include "/lib/atmospherics/netherNoise.glsl"
#endif

#ifdef BEDROCK_NOISE
    #include "/lib/atmospherics/stars.glsl"
#endif

#if NIGHT_NEBULAE == 1
    #include "/lib/atmospherics/nightNebula.glsl"
#endif

#ifdef VL_CLOUDS_ACTIVE
    #include "/lib/atmospherics/clouds/mainClouds.glsl"
#endif

#if defined END && defined END_STARS
    #include "/lib/atmospherics/enderStars.glsl"
#endif

#if defined WORLD_OUTLINE || RETRO_LOOK == 1 || RETRO_LOOK == 2
    #include "/lib/misc/worldOutline.glsl"
#endif

#ifdef DARK_OUTLINE
    #include "/lib/misc/darkOutline.glsl"
#endif

#ifdef ATM_COLOR_MULTS
    #include "/lib/colors/colorMultipliers.glsl"
#endif

#ifdef MOON_PHASE_INF_ATMOSPHERE
    #include "/lib/colors/moonPhaseInfluence.glsl"
#endif

#ifdef DISTANT_LIGHT_BOKEH
    #include "/lib/misc/distantLightBokeh.glsl"
#endif

#ifdef BEDROCK_NOISE
    #include "/lib/atmospherics/bedrockNoise.glsl"
#endif

#if defined END && EP_END_FLASH > 0 && MC_VERSION >= 12109 && defined IS_IRIS
    #include "/lib/atmospherics/endFlash.glsl"
#endif

#ifdef BLOCKLIGHT_CAUSTICS
    #include "/lib/lighting/blocklightCaustics.glsl"
#endif

//Program//
void main() {
    vec4 albedoTextureSample = texelFetch(colortex0, texelCoord, 0);
    vec4 color = vec4(albedoTextureSample.rgb, 1.0);
    float pixelVisibilityFactor = albedoTextureSample.a;
    float z0 = texelFetch(depthtex0, texelCoord, 0).r;

    vec4 screenPos = vec4(texCoord, z0, 1.0);
    vec4 viewPos = gbufferProjectionInverse * (screenPos * 2.0 - 1.0);
    viewPos /= viewPos.w;
    float lViewPos = length(viewPos.xyz);
    vec3 nViewPos = normalize(viewPos.xyz);
    vec3 playerPos = ViewToPlayer(viewPos.xyz);

    #ifdef PHOTONICS_LIGHTING
        float photonicsLightMask = 0;
    {
        if (z0 < 0.99999) {
            float phRtCoverage = getPhotonicsFade(playerPos);

            if (phRtCoverage > 0.0001) {
                vec3 photonicsAlbedo = clamp01(texelFetch(colortex10, texelCoord, 0).rgb);

                #if PHOTONICS_MAX_LIGHTS == 0 && !defined PHOTONICS_COMBINED_GI
                    vec3 directCurved = vec3(0.0);
                    vec3 directGlow = vec3(0.0);
                #else
                    vec3 directLight = sample_photonics_direct(texCoord);
                    vec3 handheldLight = vec3(0.0);
                    #if HELD_LIGHTING_MODE >= 1
                        handheldLight = sample_photonics_handheld(texCoord);
                    #endif

                    vec3 totalDirect = directLight + handheldLight;
                    vec3 directBase = max0(totalDirect * 1.34);
                    vec3 directCurved = pow(directBase, vec3(0.78));

                    float lightingMultiplier = 1.5;
                    directCurved *= lightingMultiplier * XLIGHT_I;

                    float directLuminance = GetLuminance(directBase);
                    // Remove tiny luminance floor so mask can fully fade to zero at light edges.
                    const float luminanceFloor = 0.0028;
                    const float luminanceSoftness = 0.0058;
                    directLuminance = max0(directLuminance - luminanceFloor);
                    directLuminance *= smoothstep(0.0, luminanceSoftness, directLuminance);

                    float curveMask = smoothstep(0.001, 0.025, directLuminance);
                    directCurved = mix(totalDirect, directCurved * 1.55, 0.75 * curveMask);

                    #ifdef BLOCKLIGHT_CAUSTICS
                        #if defined DO_PIXELATION_EFFECTS && defined PIXELATED_SHADOWS
                            playerPos += texelFetch(colortex11, texelCoord, 0).rgb;
                        #endif
                        vec3 worldPos = playerPos + cameraPosition;
                        vec3 worldGeoNormal = texelFetch(colortex20, texelCoord, 0).rgb;

                        directCurved *= GetBlocklightCaustics(worldGeoNormal, worldPos);
                    #endif

                    vec3 directGlow = compressLightSoftKnee(max0(directCurved), 0.85, 0.25);
                #endif

                vec3 indirectLighting = texelFetch(colortex9, ivec2(texelCoord * PHOTONICS_RENDER_SCALE), 0).rgb * 0.23;
                float indirectLuminance = GetLuminance(indirectLighting);
                indirectLighting = pow(indirectLighting, vec3(1.16));
                indirectLighting *= 1.8 * PHOTONICS_INDIRECT_INTENSITY * 0.1 * mix(1.2, indirectLuminance * 0.33, min1(indirectLuminance * 1.1));
                indirectLighting = min1(indirectLighting);

                vec3 photonicsLightingRaw = max0(directCurved + indirectLighting);
                vec3 photonicsLighting = compressLightSoftKnee(photonicsLightingRaw, 0.80, 0.8);

                photonicsLightMask = GetLuminance(clamp01(photonicsLightingRaw));

                color.rgb += photonicsLighting * photonicsAlbedo * phRtCoverage;
                color.rgb += 0.12 * directGlow * phRtCoverage;
            }
        }
    }
    #endif

    float dither = texture2DLod(noisetex, texCoord * vec2(viewWidth, viewHeight) / 128.0, 0.0).b;
    #ifdef TAA
        dither = fract(dither + goldenRatio * mod(float(frameCounter), 3600.0));
    #endif

    #ifdef ATM_COLOR_MULTS
        atmColorMult = GetAtmColorMult();
        sqrtAtmColorMult = sqrt(atmColorMult);
    #endif

    #if defined VOXY && SHADOW_QUALITY > -1
        float lodShadow = 0.0;
    #endif

    float VdotU = dot(nViewPos, upVec);
    float VdotS = dot(nViewPos, sunVec);
    float skyFade = 0.0;
    vec3 waterRefColor = vec3(0.0);
    vec3 auroraBorealis = vec3(0.0);
    vec3 nightNebula = vec3(0.0);
    vec3 netherNoise = vec3(0.0);
    vec3 bedrockNoise = vec3(0.0);

    vec3 normalM = vec3(0);
    float fresnelM = 0.0;
    float linearZ0_DH;

    vec4 texture6 = texelFetch(colortex6, texelCoord, 0).rgba;

    if (z0 < 1.0) {
        #ifdef DISTANT_LIGHT_BOKEH
            int dlbo = 1;
            vec3 dlbColor = color.rgb;
            dlbColor += texelFetch(colortex0, texelCoord + ivec2( 0, dlbo), 0).rgb;
            dlbColor += texelFetch(colortex0, texelCoord + ivec2( 0,-dlbo), 0).rgb;
            dlbColor += texelFetch(colortex0, texelCoord + ivec2( dlbo, 0), 0).rgb;
            dlbColor += texelFetch(colortex0, texelCoord + ivec2(-dlbo, 0), 0).rgb;
            dlbColor = max(color.rgb, dlbColor * 0.2);
            float dlbMix = GetDistantLightBokehMix(lViewPos);
            color.rgb = mix(color.rgb, dlbColor, dlbMix);
        #endif

        #if SSAO_QUALI > 0 || defined WORLD_OUTLINE || RETRO_LOOK == 1 || RETRO_LOOK == 2
            float linearZ0 = GetLinearDepth(z0);
        #endif

        #if SSAO_QUALI > 0
            float ssao = GetAmbientOcclusion(depthtex0, z0, linearZ0, dither, far, near, far - near, playerPos);
        #else
            float ssao = 1.0;
        #endif

        bool entityOrParticle = z0 < 0.56;
        int materialMaskInt = int(texture6.g * 255.1);
        float intenseFresnel = 0.0;
        float smoothnessD = texture6.r;
        vec3 reflectColor = vec3(1.0);

        #include "/lib/materials/materialHandling/deferredMaterials.glsl"

        #ifdef PBR_REFLECTIONS
            vec3 texture4 = texelFetch(colortex4, texelCoord, 0).rgb;
            normalM = mat3(gbufferModelView) * texture4;
            float fresnel = clamp(1.0 + dot(normalM, nViewPos), 0.0, 1.0);
        #else
            float fresnel = 0.0;
        #endif

        #if defined WORLD_OUTLINE || RETRO_LOOK == 1 || RETRO_LOOK == 2
            #if !defined WORLD_OUTLINE_ON_ENTITIES && RETRO_LOOK == 0
                if (!entityOrParticle)
            #endif
            DoWorldOutline(color.rgb, linearZ0, playerPos, fresnel, dither);
        #endif

        #ifdef DARK_OUTLINE
            DoDarkOutline(color.rgb, z0, pixelVisibilityFactor, playerPos, far);
        #endif

        color.rgb *= ssao;

        #ifdef PBR_REFLECTIONS
            #if WORLD_SPACE_REFLECTIONS_INTERNAL == -1 && !defined END
                // Way steeper fresnel falloff on SSR-only mode to hide SSR limitation and gain performance
                float fresnelFactor = (1.0 - smoothnessD) * 0.7;
                fresnelM = max(fresnel - fresnelFactor, 0.0) / (1.0 - fresnelFactor);
            #else
                fresnelM = fresnel * 0.7 + 0.3;
            #endif

            fresnelM = mix(pow2(fresnelM), fresnelM * 0.75 + 0.25, intenseFresnel);
            fresnelM = fresnelM * sqrt1(smoothnessD) - dither * 0.01;
        #endif

        #ifdef IRIS_FEATURE_FADE_VARIABLE
            chunkFade = texture6.b > 0.50001 ? (1.0 - texture6.b) * 2.0 : 1.0;
        #endif

        waterRefColor = color.rgb;
        DoFog(color, skyFade, lViewPos, playerPos, VdotU, VdotS, dither, false, 0.0);
    } else {
        #if defined DISTANT_HORIZONS || defined VOXY
            #ifdef DISTANT_HORIZONS
                float z0lod = texelFetch(dhDepthTex, texelCoord, 0).r;
            #elif defined VOXY
                float z0lod = texelFetch(vxDepthTexTrans, texelCoord, 0).r;
            #endif
            if (z0lod < 1.0) { // Lod Chunks
                vec4 screenPosLod = vec4(texCoord, z0lod, 1.0);
                #ifdef DISTANT_HORIZONS
                    vec4 viewPosLod = dhProjectionInverse * (screenPosLod * 2.0 - 1.0);
                    viewPosLod /= viewPosLod.w;

                    #if SHADOW_QUALITY > -1
                        color.rgb *= 0.5 + 0.5 * GetLODShadows(viewPosLod.xyz, nViewPos, dhDepthTex, dhProjection, dhProjectionInverse, dither);
                    #endif
                    #if SSAO_QUALI > 0 && defined DISTANT_HORIZONS_SSAO
                        linearZ0_DH = CalculateLinearDepth(z0lod, dhNearPlane, dhFarPlane);
                        float ssao_dh = DoAmbientOcclusionDH(z0lod, linearZ0_DH, dhDepthTex, dither, texture6.a);
                        color.rgb *= ssao_dh;
                    #endif
                #elif defined VOXY
                    vec4 viewPosLod = vxProjInv * (screenPosLod * 2.0 - 1.0);
                    viewPosLod /= viewPosLod.w;

                    #if SHADOW_QUALITY > -1
                        lodShadow = GetLODShadows(viewPosLod.xyz, nViewPos, vxDepthTexTrans, vxProj, vxProjInv, dither);
                        lodShadow += OSIEBCA; // For being able to check if a calculation has been done;
                    #endif

                    #if SSAO_QUALI > 0
                        float farLod = 16*20, nearLod = 16;
                        float aoWorldRange = (farLod - nearLod);
                        float ssao = GetAmbientOcclusion(vxDepthTexTrans, z0lod, GetLinearDepth(z0lod, farLod, nearLod), dither, farLod, nearLod, aoWorldRange, playerPos);
                        color.rgb *= pow2(pow2(ssao));
                    #endif
                #endif

                lViewPos = length(viewPosLod.xyz);
                playerPos = ViewToPlayer(viewPosLod.xyz);
                waterRefColor = color.rgb;

                DoFog(color, skyFade, lViewPos, playerPos, VdotU, VdotS, dither, false, 0.0);
            } else
        #endif
        { // Sky
            skyFade = 1.0;

            #ifdef OVERWORLD
                #if AURORA_STYLE > 0
                    auroraBorealis = GetAuroraBorealis(viewPos.xyz, VdotU, dither);
                    color.rgb += auroraBorealis;
                #endif
                #if NIGHT_NEBULAE == 1
                    nightNebula += GetNightNebula(viewPos.xyz, VdotU, VdotS);
                    color.rgb += nightNebula;
                #endif
            #endif
            #ifdef NETHER
                color.rgb = netherColor * (1.0 - maxBlindnessDarkness);

                #ifdef ATM_COLOR_MULTS
                    color.rgb *= atmColorMult;
                #endif
            #endif
            #ifdef END
                color.rgb = endSkyColor;
                #ifdef END_STARS
                    vec3 starColor = GetEnderStars(viewPos.xyz, VdotU, 1.0, 0.0);

                    #define ADD_STAR_LAYER_END1 (STAR_LAYER_END == 1 || STAR_LAYER_END == 3)
                    #define ADD_STAR_LAYER_END2 (STAR_LAYER_END == 2 || STAR_LAYER_END == 3)

                    #if ADD_STAR_LAYER_END1
                        starColor = max(starColor, GetEnderStars(viewPos.xyz, VdotU, 0.66, 0.0));
                    #endif

                    #if ADD_STAR_LAYER_END2
                        starColor = max(starColor, GetEnderStars(viewPos.xyz, VdotU, 2.2, 0.33));
                    #endif

                    color.rgb += starColor;
                #endif

                #if MC_VERSION >= 12109 && defined IS_IRIS && EP_END_FLASH > 0
                    if (endFlashIntensityM > 0.0) {
                        color.rgb += DrawEndFlash(nViewPos, VdotU, dither);
                    }
                #endif

                color.rgb *= 1.0 - maxBlindnessDarkness;

                #ifdef ATM_COLOR_MULTS
                    color.rgb *= atmColorMult;
                #endif
            #endif
        }
    }

    #if defined NETHER && NETHER_NOISE == 1
        netherNoise = GetNetherNoise(viewPos.xyz, VdotU, dither);
        color.rgb += pow4(skyFade) * netherNoise;
    #endif
    #ifdef END
        #ifdef END_SMOKE
            vec3 wpos = normalize((gbufferModelViewInverse * vec4(viewPos.xyz * 1000.0, 1.0)).xyz);
            vec3 endSmoke = texture2DLod(noisetex, (wpos.xz / wpos.y) * 0.5 + frameTimeCounter * 0.004, 0.0).g * abs(VdotU) * endSkyColor * 1.5;
            color.rgb += pow4(skyFade) * endSmoke * (1.0 - maxBlindnessDarkness);
        #endif
    #endif

    float cloudLinearDepth = 1.0;
    vec4 clouds = vec4(0.0);

    #ifdef VL_CLOUDS_ACTIVE
        float cloudZCheck = 0.56;

        if (z0 > cloudZCheck) {
            clouds = GetClouds(cloudLinearDepth, skyFade, vec3(0.0), playerPos, viewPos.xyz,
                               lViewPos, VdotS, VdotU, dither, auroraBorealis, nightNebula, sunVec);

            color = mix(color, vec4(clouds.rgb, 0.0), clouds.a);
        }
    #endif

    #ifdef SKY_EFFECT_REFLECTION
        waterRefColor = mix(waterRefColor, clouds.rgb, clouds.a);
    #endif
    waterRefColor = sqrt(waterRefColor) * 0.5;

    #if defined LIGHTSHAFTS_ACTIVE && (LIGHTSHAFT_BEHAVIOUR == 1 && SHADOW_QUALITY >= 1 || defined END)
        if (viewWidth + viewHeight - gl_FragCoord.x - gl_FragCoord.y < 1.5)
            cloudLinearDepth = vlFactor;
    #endif

    #if defined OVERWORLD && defined ATMOSPHERIC_FOG && (defined SPECIAL_BIOME_WEATHER || RAIN_STYLE == 2)
        if (isEyeInWater == 0) {
            float altitudeFactorRaw = GetAtmFogAltitudeFactor(playerPos.y + cameraPosition.y);
            vec3 atmFogColor = GetAtmFogColor(altitudeFactorRaw, VdotS);
            #ifdef ATM_COLOR_MULTS
                atmFogColor *= atmColorMult;
            #endif

            #if RAIN_STYLE == 2
                float factor = 1.0;
            #else
                float factor = max(inSnowy, inDry);
            #endif

            color = mix(color, vec4(atmFogColor, 0.0), 0.5 * rainFactor * factor * sqrt1(skyFade));
        }
    #endif

    #if defined OVERWORLD || defined NETHER
        #ifdef BEDROCK_NOISE
            bedrockNoise = GetBedrockNoise(viewPos.xyz, VdotU, dither);
            color.rgb += pow4(skyFade) * bedrockNoise;
        #endif
    #endif
    #if defined END && END_CENTER_LIGHTING > 0 && MC_VERSION >= 10900
        float attentuation = doEndCenterFog(cameraPositionBest, normalize(playerPos), min(renderDistance, lViewPos), 0.5);
        vec3 pointLightFog = vec3(END_CENTER_LIGHTING_R, END_CENTER_LIGHTING_G + 0.05, END_CENTER_LIGHTING_B) * 0.25 * END_CENTER_LIGHTING * 0.1 * attentuation * (1.0 - vlFactor);
        color.rgb = sqrt(pow2(color.rgb) + vec3(pointLightFog));
    #endif

    // color.rgb = texelFetch(colortex9, ivec2(texelCoord * PHOTONICS_RENDER_SCALE), 0).rgb;
    // color.rgb = vec3(clamp01(smoothstep(0.01, 1.0, GetLuminance(sample_photonics_direct(texCoord))) * 1000000));

    /*DRAWBUFFERS:05*/
    gl_FragData[0] = vec4(color.rgb, 1.0);
    gl_FragData[1] = vec4(waterRefColor, cloudLinearDepth);

    // same check as #ifdef PBR_REFLECTIONS but for Optifine to understand:
    #if BLOCK_REFLECT_QUALITY >= 2 && RP_MODE >= 1
        /*DRAWBUFFERS:054*/
        gl_FragData[2] = vec4(mat3(gbufferModelViewInverse) * normalM, sqrt(fresnelM * color.a));

        #ifdef VOXY
            /* RENDERTARGETS: 0,5,4,19 */
            gl_FragData[3] = vec4(waterRefColor, cloudLinearDepth);

            #ifdef PHOTONICS_LIGHTING
                /* RENDERTARGETS: 0,5,4,19,20 */
                gl_FragData[4] = vec4(photonicsLightMask, 1.0, 1.0, 1.0);
            #endif

            #if SHADOW_QUALITY > -1
                #ifdef PHOTONICS_LIGHTING
                    /* RENDERTARGETS: 0,5,4,19,20,18 */
                    gl_FragData[5] = vec4(lodShadow, 1.0, 1.0, 1.0);
                #else
                    /* RENDERTARGETS: 0,5,4,19,18 */
                    gl_FragData[4] = vec4(lodShadow, 1.0, 1.0, 1.0);
                #endif
            #endif
        #elif defined PHOTONICS_LIGHTING
            /* RENDERTARGETS: 0,5,4,20 */
            gl_FragData[3] = vec4(photonicsLightMask, 1.0, 1.0, 1.0);
        #endif
    #elif defined VOXY
        /* RENDERTARGETS: 0,5,19 */
        gl_FragData[2] = vec4(waterRefColor, cloudLinearDepth);

        #ifdef PHOTONICS_LIGHTING
            /* RENDERTARGETS: 0,5,19,20 */
            gl_FragData[3] = vec4(photonicsLightMask, 1.0, 1.0, 1.0);
        #endif

        #if SHADOW_QUALITY > -1
            #ifdef PHOTONICS_LIGHTING
                /* RENDERTARGETS: 0,5,19,20,18 */
                gl_FragData[4] = vec4(lodShadow, 1.0, 1.0, 1.0);
            #else
                /* RENDERTARGETS: 0,5,19,18 */
                gl_FragData[3] = vec4(lodShadow, 1.0, 1.0, 1.0);
            #endif
        #endif
    #elif defined PHOTONICS_LIGHTING
        /* RENDERTARGETS: 0,5,20 */
        gl_FragData[2] = vec4(photonicsLightMask, 1.0, 1.0, 1.0);
    #endif
}

#endif

//////////Vertex Shader//////////Vertex Shader//////////Vertex Shader//////////
#ifdef VERTEX_SHADER

noperspective out vec2 texCoord;

#if END_CRYSTAL_VORTEX_INTERNAL / 2 == 1 || DRAGON_DEATH_EFFECT_INTERNAL > 0
    uniform isampler2D endcrystal_sampler;
#endif

flat out vec3 upVec, sunVec, eastVec;

#if defined LIGHTSHAFTS_ACTIVE && (LIGHTSHAFT_BEHAVIOUR == 1 && SHADOW_QUALITY >= 1 || defined END)
    flat out float vlFactor;
#endif

//Attributes//

//Common Variables//

//Common Functions//

//Includes//

//Program//
void main() {
    gl_Position = ftransform();
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

    upVec = normalize(gbufferModelView[1].xyz);
    sunVec = GetSunVector();
    eastVec = normalize(gbufferModelView[0].xyz);

    #if defined LIGHTSHAFTS_ACTIVE && (LIGHTSHAFT_BEHAVIOUR == 1 && SHADOW_QUALITY >= 1 || defined END)
        vlFactor = texelFetch(colortex5, ivec2(viewWidth-1, viewHeight-1), 0).a;

        #ifdef END
            if (frameCounter % int(0.06666 / frameTimeSmooth + 0.5) == 0) { // Change speed is not too different above 10 fps
                #if MC_VERSION >= 12106
                    bool isEnderDragonDead = !heavyFog;
                #else
                    vec2 absCamPosXZ = abs(cameraPosition.xz);
                    float maxCamPosXZ = max(absCamPosXZ.x, absCamPosXZ.y);
                    bool isEnderDragonDead = gl_Fog.start / far > 0.5 || maxCamPosXZ > 350.0;
                    #if END_CRYSTAL_VORTEX_INTERNAL / 2 == 1 || DRAGON_DEATH_EFFECT_INTERNAL > 0
                        isEnderDragonDead = texelFetch(endcrystal_sampler, ivec2(35, 5), 0).r == 0;
                    #endif
                #endif

                if (isEnderDragonDead) vlFactor = max(vlFactor - OSIEBCA*2, 0.0);
                else                   vlFactor = min(vlFactor + OSIEBCA*2, 1.0);
            }
        #endif
    #endif
}

#endif

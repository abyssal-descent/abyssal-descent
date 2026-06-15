#include "/lib/shaderSettings/cloudsAndLighting.glsl"
const float cloudStretchModified = max(0.25, float(CLOUD_STRETCH) * 1.9 - 0.9);
#if CLOUD_QUALITY_INTERNAL == 1 || !defined DEFERRED1
    const float cloudStretchRaw = 11.0 * cloudStretchModified;
#elif CLOUD_QUALITY_INTERNAL == 2
    const float cloudStretchRaw = 16.0 * cloudStretchModified;
#elif CLOUD_QUALITY_INTERNAL == 3
    const float cloudStretchRaw = 18.0 * cloudStretchModified;
#elif CLOUD_QUALITY_INTERNAL == 4
    const float cloudStretchRaw = 20.0 * cloudStretchModified;
#endif

#ifdef DOUBLE_UNBOUND_CLOUDS
    const float L2cloudStretch = cloudStretchRaw * CLOUD_UNBOUND_LAYER2_HEIGHT / CLOUD_STRETCH;

    #if CLOUD_UNBOUND_SIZE_MULT <= 100
        float cloudStretch = cloudStretchRaw;
    #else
        float cloudStretch = cloudStretchRaw / float(CLOUD_UNBOUND_SIZE_MULT_M);
    #endif

    float cloudTallness = cloudStretch * 2.0;
#else
    #if CLOUD_UNBOUND_SIZE_MULT <= 100
        const float cloudStretch = cloudStretchRaw;
    #else
        const float cloudStretch = cloudStretchRaw / float(CLOUD_UNBOUND_SIZE_MULT_M);
    #endif
    const float cloudTallness = cloudStretch * 2.0;
#endif

#if CLOUD_QUALITY_INTERNAL > 1
    const float cloudNarrowness = 0.00012;
#else
    const float cloudNarrowness = 0.00006;
#endif

#if PIXELATED_UNBOUND_CLOUDS > 0
const float pixelatedUnboundWindSpeedMult = 0.2;

vec3 PixelateUnboundCloudPos(vec3 tracePos, float pixelStep) {
    return (floor(tracePos / pixelStep) + 0.5) * pixelStep;
}

vec2 PixelateUnboundCloudPos(vec2 tracePos, float pixelStep) {
    return (floor(tracePos / pixelStep) + 0.5) * pixelStep;
}

float QuantizeCloudValue(float value, float levels) {
    return floor(value * levels + 0.5) / levels;
}

float GetVoxelCloudVariation(vec3 cloudTracePos, float pixelStep) {
    vec3 voxelCoord = floor(cloudTracePos / pixelStep + 0.5);
    return fract(sin(dot(voxelCoord, vec3(12.9898, 78.233, 37.719))) * 43758.5453);
}
#endif


float GetCloudNoise(vec3 tracePos, int cloudAltitude, float lTracePosXZ, float cloudPlayerPosY) {
    vec3 tracePosM = tracePos.xyz * cloudNarrowness;
    float wind = 0.0006;
    float noise = 0.0;
    float currentPersist = 1.0;
    float total = 0.0;

    #if CLOUD_SPEED_MULT == 100
        #define CLOUD_SPEED_MULT_M CLOUD_SPEED_MULT * 0.01
        wind *= syncedTime;
    #else
        #define CLOUD_SPEED_MULT_M CLOUD_SPEED_MULT * 0.01
        wind *= frameTimeCounter * CLOUD_SPEED_MULT_M;
    #endif

    #if CLOUD_UNBOUND_SIZE_MULT != 100
        tracePosM *= CLOUD_UNBOUND_SIZE_MULT_M;
        wind *= CLOUD_UNBOUND_SIZE_MULT_M;
    #endif

    #ifdef DOUBLE_UNBOUND_CLOUDS
        if (cloudAltitude != cloudAlt1i) {
            tracePosM *= CLOUD_UNBOUND_LAYER2_SIZE * 10.0 / CLOUD_UNBOUND_SIZE_MULT;
            wind *= CLOUD_UNBOUND_LAYER2_SIZE * 30.0 * CLOUD_LAYER2_SPEED_MULT / CLOUD_UNBOUND_SIZE_MULT;
        }
    #endif

    #if PIXELATED_UNBOUND_CLOUDS > 0
        float pixelStepM = PIXELATED_UNBOUND_CLOUDS * cloudNarrowness;

        #if CLOUD_UNBOUND_SIZE_MULT != 100
            pixelStepM *= CLOUD_UNBOUND_SIZE_MULT_M;
        #endif

        #ifdef DOUBLE_UNBOUND_CLOUDS
            if (cloudAltitude != cloudAlt1i) {
                pixelStepM *= CLOUD_UNBOUND_LAYER2_SIZE * 10.0 / CLOUD_UNBOUND_SIZE_MULT;
            }
        #endif
    #endif

    #if PIXELATED_UNBOUND_CLOUDS > 0
        int sampleCount = 5;
        float persistance = 0.43;
        float noiseMult = 0.92;
        wind *= pixelatedUnboundWindSpeedMult;
    #elif CLOUD_QUALITY_INTERNAL == 1
        int sampleCount = 2;
        float persistance = 0.6;
        float noiseMult = 0.95;
        wind *= 0.5;
    #elif CLOUD_QUALITY_INTERNAL == 2 || !defined DEFERRED1
        int sampleCount = 4;
        float persistance = 0.5;
        float noiseMult = 1.14;
    #elif CLOUD_QUALITY_INTERNAL == 3
        int sampleCount = 4;
        float persistance = 0.5;
        float noiseMult = 1.0;
    #elif CLOUD_QUALITY_INTERNAL == 4
        int sampleCount = 5;
        float persistance = 0.5;
        float noiseMult = 1.05;
    #endif

    #ifndef DEFERRED1
        noiseMult *= 1.2;
    #endif

    #if CLOUD_DIRECTION == 1
        tracePosM.xz = tracePosM.zx;
    #endif

    for (int i = 0; i < sampleCount; i++) {
        vec3 windOffset = vec3(0.0, 0.0, wind);
        #if PIXELATED_UNBOUND_CLOUDS > 0
            vec3 pos = PixelateUnboundCloudPos(tracePosM - windOffset, pixelStepM);
        #else
            vec3 pos = tracePosM - windOffset;
        #endif

        #if CLOUD_QUALITY_INTERNAL >= 2
            noise += Noise3D(pos) * currentPersist;
        #else
            noise += texture2DLod(noisetex, pos.xz, 0.0).b * currentPersist;
        #endif
        total += currentPersist;

        float octaveOffset = 3.0;
        tracePosM *= octaveOffset;
        #if PIXELATED_UNBOUND_CLOUDS > 0
            pixelStepM *= octaveOffset;
            wind *= octaveOffset; // normalize wind speed across octaves to prevent different speed voxel grids
        #else
            wind *= 0.5;
        #endif
        currentPersist *= persistance;
    }
    noise = pow2(noise / total);

    #define CLOUD_BASE_ADD 0.8
    //#define CLOUD_FAR_ADD -0.005
    #define CLOUD_ABOVE_ADD 0.1

    float nightCloudRemove = NIGHT_CLOUD_UNBOUND_REMOVE * (1.0 - sunVisibility) * -0.65 + 1.0; // mapped to 1 to 0.65 range

    float seasonCloudAdd = 0.0;
    #if SEASONS > 0
        float autumnOnlyForests = 1.0;
        #ifdef AUTUMN_CONDITION
            autumnOnlyForests = inForest;
        #endif
        float autumnWinterTime = autumnTime + winterTime;
        #if SNOW_CONDITION != 2
            autumnWinterTime *= mix(inSnowy + autumnOnlyForests, inSnowy, winterTime); // make only appear in cold biomes during winter
        #endif
        #if SNOW_CONDITION == 0
            autumnWinterTime *= mix(rainFactor + autumnOnlyForests, rainFactor, winterTime); // make only appear in rain during winter
        #endif
        seasonCloudAdd += mix(0.0, 0.35, autumnWinterTime);
        seasonCloudAdd += mix(0.0, -0.2, summerTime);
    #endif

    noiseMult *= CLOUD_BASE_ADD
                //+ CLOUD_FAR_ADD * sqrt(lTracePosXZ + 10.0) // more/less clouds far away
                + CLOUD_ABOVE_ADD * clamp01(-cloudPlayerPosY / cloudTallness) // more clouds when camera is above them
                + CLOUD_UNBOUND_RAIN_ADD * rainFactor + seasonCloudAdd; // more clouds during rain and seasons

    #ifdef DOUBLE_UNBOUND_CLOUDS
    if (cloudAltitude != cloudAlt1i)
        noise *= noiseMult * CLOUD_UNBOUND_LAYER2_AMOUNT * nightCloudRemove;
    else
    #endif
    noise *= noiseMult * CLOUD_UNBOUND_AMOUNT * nightCloudRemove;

    float threshold = clamp(abs(cloudAltitude - tracePos.y) / cloudStretch, 0.001, 0.999);
    threshold = pow2(pow2(pow2(threshold)));
    return noise - (threshold * 0.2 + 0.25);
}

vec4 GetVolumetricClouds(int cloudAltitude, float distanceThreshold, inout float cloudLinearDepth, float skyFade, float skyMult0, vec3 cameraPos, vec3 nPlayerPos, float lViewPosM, float VdotS, float VdotU, float dither, vec3 sunVec, vec3 viewPos) {
    vec4 volumetricClouds = vec4(0.0);

    #ifdef DOUBLE_UNBOUND_CLOUDS
    float L1cloudStretch = cloudStretch;

    if (cloudAltitude != cloudAlt1i) { // second layer
        cloudStretch = L2cloudStretch;
        cloudTallness = 2.0 * cloudStretch;
    }
    #endif

    float higherPlaneAltitude = cloudAltitude + cloudStretch;
    float lowerPlaneAltitude  = cloudAltitude - cloudStretch;

    float lowerPlaneDistance  = (lowerPlaneAltitude - cameraPos.y) / nPlayerPos.y;
    float higherPlaneDistance = (higherPlaneAltitude - cameraPos.y) / nPlayerPos.y;
    float minPlaneDistance = min(lowerPlaneDistance, higherPlaneDistance);
          minPlaneDistance = max(minPlaneDistance, 0.0);
    float maxPlaneDistance = max(lowerPlaneDistance, higherPlaneDistance);
    if (maxPlaneDistance < 0.0) return vec4(0.0);
    float planeDistanceDif = maxPlaneDistance - minPlaneDistance;

    float aboveClouds = clamp01((cameraPos.y - lowerPlaneAltitude) * 0.01);
    float skyFadeM = mix(skyFade, 1.0, mix(0.4 * max(aboveClouds, rainFactor2), 1.0, clamp01(CLOUD_TRANSPARENCY - 1.0)));
    float min1CloudTransparency = min1(CLOUD_TRANSPARENCY);

    #ifndef DEFERRED1
        float stepMult = 64.0;
    #elif PIXELATED_UNBOUND_CLOUDS > 0
        float stepMult = 3.0;
    #elif CLOUD_QUALITY_INTERNAL == 1
        float stepMult = 16.0;
    #elif CLOUD_QUALITY_INTERNAL == 2
        float stepMult = 32.0;
    #elif CLOUD_QUALITY_INTERNAL == 3
        float stepMult = 16.0;
    #elif CLOUD_QUALITY_INTERNAL == 4
        float stepMult = 24.0;
    #endif

    #if defined DOUBLE_UNBOUND_CLOUDS && (CLOUD_UNBOUND_LAYER2_SIZE > 10 || CLOUD_UNBOUND_SIZE_MULT > 100)
        if (cloudAltitude != cloudAlt1i) {
        #if CLOUD_UNBOUND_LAYER2_SIZE > 10
            stepMult = stepMult / sqrt(CLOUD_UNBOUND_LAYER2_SIZE * 0.1);
        #endif
        } else {
        #if CLOUD_UNBOUND_SIZE_MULT > 100
            stepMult = stepMult / sqrt(float(CLOUD_UNBOUND_SIZE_MULT_M));
        #endif
        }

    #else

    #if CLOUD_UNBOUND_SIZE_MULT > 100
        stepMult = stepMult / sqrt(float(CLOUD_UNBOUND_SIZE_MULT_M));
    #endif

    #endif

    int sampleCount = int(planeDistanceDif / stepMult + dither + 1);
    vec3 traceAdd = nPlayerPos * stepMult;
    vec3 tracePos = cameraPos + minPlaneDistance * nPlayerPos;
    tracePos += traceAdd * dither;
    tracePos.y -= traceAdd.y;

    float firstHitPos = 0.0;
    float VdotSM1 = max0(sunVisibility > 0.5 ? VdotS : - VdotS);
    float VdotSM1M = VdotSM1 * invRainFactor;
    float VdotSM2 = pow2(VdotSM1) * abs(sunVisibility - 0.5) * 2.0;
    float VdotSM3 = VdotSM2 * (2.5 + rainFactor) + 1.5 * rainFactor;
    float VdotSM4 = pow(VdotSM1M, 100.0) * sunVisibility;

    #ifdef FIX_AMD_REFLECTION_CRASH
        sampleCount = min(sampleCount, 30); //BFARC
    #endif

    #ifdef AURORA_INFLUENCE
        cloudLightColor = getAuroraAmbientColor(cloudLightColor, viewPos, 0.06, AURORA_CLOUD_INFLUENCE_INTENSITY, 0.75);
        cloudAmbientColor = getAuroraAmbientColor(cloudAmbientColor, viewPos, 0.03, AURORA_CLOUD_INFLUENCE_INTENSITY, 0.75);
    #endif

    for (int i = 0; i < sampleCount; i++) {
        tracePos += traceAdd;

        if (abs(tracePos.y - cloudAltitude) > cloudStretch) break;

        vec3 cloudPlayerPos = tracePos - cameraPos;
        float lTracePos = length(cloudPlayerPos);
        float lTracePosXZ = length(cloudPlayerPos.xz);
        float cloudMult = 1.0;
        if (lTracePosXZ > distanceThreshold) break;
        if (lTracePos > lViewPosM) {
            if (skyFade < 0.7) continue;
            else cloudMult = skyMult0;
        }

        #if PIXELATED_UNBOUND_CLOUDS > 0
            float cloudWind = 0.0006;
            #if CLOUD_SPEED_MULT == 100
                cloudWind *= syncedTime;
            #else
                cloudWind *= frameTimeCounter * (CLOUD_SPEED_MULT * 0.01);
            #endif

            float cloudTraceScale = cloudNarrowness;

            #if CLOUD_UNBOUND_SIZE_MULT != 100
                cloudWind *= CLOUD_UNBOUND_SIZE_MULT_M;
                cloudTraceScale *= CLOUD_UNBOUND_SIZE_MULT_M;
            #endif

            #ifdef DOUBLE_UNBOUND_CLOUDS
                if (cloudAltitude != cloudAlt1i) {
                    float cloudLayer2Scale = CLOUD_UNBOUND_LAYER2_SIZE * 10.0 / CLOUD_UNBOUND_SIZE_MULT;
                    cloudWind *= CLOUD_UNBOUND_LAYER2_SIZE * 30.0 * CLOUD_LAYER2_SPEED_MULT / CLOUD_UNBOUND_SIZE_MULT;
                    cloudTraceScale *= cloudLayer2Scale;
                }
            #endif

            vec3 cloudWindOffset = vec3(0.0, 0.0, (cloudWind / cloudTraceScale) * pixelatedUnboundWindSpeedMult);
            #if CLOUD_DIRECTION == 1
                cloudWindOffset.xz = cloudWindOffset.zx;
            #endif

            vec3 cloudTracePos = PixelateUnboundCloudPos(tracePos - cloudWindOffset, PIXELATED_UNBOUND_CLOUDS);
        #else
            vec3 cloudTracePos = tracePos;
        #endif

        float cloudNoise = GetCloudNoise(tracePos, cloudAltitude, lTracePosXZ, cloudPlayerPos.y);

        if (cloudNoise > 0.00001) {
            #if defined DOUBLE_UNBOUND_CLOUDS
            //Fixes overlapping clouds

            if (CLOUD_UNBOUND_LAYER2_HEIGHT > CLOUD_STRETCH){
                if (cloudAltitude == cloudAlt1i) {
                    if (abs(tracePos.y - cloudAlt2i) < L2cloudStretch)
                        continue;
                }
            } else {
                if (cloudAltitude != cloudAlt1i) {
                    if (abs(tracePos.y - cloudAlt1i) < L1cloudStretch)
                        continue;
                }
            }

            #endif

            #if defined CLOUD_CLOSED_AREA_CHECK && SHADOW_QUALITY > -1 && !defined VOXY_PATCH
                float shadowLength = shadowDistance * 0.9166667; //consistent08JJ622
                if (shadowLength < lTracePos)
                if (GetShadowOnCloud(tracePos, cameraPos, cloudAltitude, lowerPlaneAltitude, higherPlaneAltitude)) {
                    if (eyeBrightness.y != 240) continue;
                }
            #endif

            if (firstHitPos < 1.0) {
                firstHitPos = lTracePos;
                #if CLOUD_QUALITY_INTERNAL == 1 && defined DEFERRED1
                    tracePos.y += 4.0 * (texture2DLod(noisetex, tracePos.xz * cloudNarrowness * 16.0, 0.0).r - 0.5);
                #endif
            }

            float opacityFactor = min1(cloudNoise * 8.0);

            #if PIXELATED_UNBOUND_CLOUDS > 0
                opacityFactor = QuantizeCloudValue(opacityFactor, 4.0);
                float pixelStep = PIXELATED_UNBOUND_CLOUDS;
                float hitDepth = max0(lTracePos - firstHitPos);
                float depthFade = exp(-hitDepth / (pixelStep * 2.6));
                opacityFactor *= mix(0.62, 1.0, depthFade);
            #endif

            #if defined DOUBLE_UNBOUND_CLOUDS && CLOUD_UNBOUND_LAYER2_TRANSPARENCY != 20
                float cloudTransparency = cloudAltitude != cloudAlt1i ? opacityFactor * (CLOUD_UNBOUND_LAYER2_TRANSPARENCY * 0.05) : opacityFactor * min1CloudTransparency;
            #else
                float cloudTransparency = min1CloudTransparency;
            #endif

            opacityFactor *= cloudTransparency;


            float cloudSampleY = tracePos.y;
            #if PIXELATED_UNBOUND_CLOUDS > 0
                cloudSampleY = mix(cloudTracePos.y, tracePos.y, 0.66);
            #endif

            #ifdef INVERTED_CLOUD_SHADING
                float cloudShading = (higherPlaneAltitude - cloudSampleY) / cloudTallness;
            #else
                float cloudShading = 1.0 - (higherPlaneAltitude - cloudSampleY) / cloudTallness;
            #endif

            cloudShading *= 1.0 + 0.2 * VdotSM3 * (1.0 - opacityFactor) + VdotSM4;
            #if CLOUD_SHADING_AMOUNT != 10
                cloudShading = pow(max0(cloudShading), CLOUD_SHADING_AMOUNT * 0.1);
            #endif
            #if PIXELATED_UNBOUND_CLOUDS > 0
                cloudShading *= 0.9;
                float layer2ShadeFactor = 0.0;
                #ifdef DOUBLE_UNBOUND_CLOUDS
                    layer2ShadeFactor = float(cloudAltitude != cloudAlt1i);
                #endif

                float voxelVariation = GetVoxelCloudVariation(cloudTracePos, pixelStep);
                float voxelShade = mix(0.85, 1.2, voxelVariation);
                voxelShade = mix(voxelShade, voxelShade * mix(0.3, 0.55, layer2ShadeFactor) + mix(0.7, 0.45, layer2ShadeFactor), aboveClouds);
                float cloudHeight01 = clamp01((tracePos.y - lowerPlaneAltitude) / cloudTallness);
                #ifdef INVERTED_CLOUD_SHADING
                    float reverseHeight01 = cloudHeight01;
                #else
                    float reverseHeight01 = 1.0 - cloudHeight01;
                #endif
                float undersideLift = reverseHeight01 * mix(0.05, 0.10, sunVisibility) * mix(1.0, 1.8, layer2ShadeFactor);

                cloudShading *= voxelShade;
                cloudShading += undersideLift + reverseHeight01 * 0.13 * layer2ShadeFactor;
            #endif

            #ifdef AURORA_INFLUENCE
                cloudLightColor = getAuroraAmbientColor(cloudLightColor, viewPos, 0.1, AURORA_CLOUD_INFLUENCE_INTENSITY, 0.75);
            #endif

            #if CLOUD_SUN_MOON_SHADING > 0
                float visibilityFactor = 1.0;
                #if CLOUD_SUN_MOON_SHADING == 1
                    visibilityFactor = 1.0 - sunVisibility;
                #elif CLOUD_SUN_MOON_SHADING == 2
                    visibilityFactor = sunVisibility;
                #endif

                if (visibilityFactor > 0.0) {
                    vec3 worldLightVec = mat3(gbufferModelViewInverse) * sunVec;
                    float cloudLightRadius = 375.0;

                    float aboveFade = clamp01(1.0 - (cameraPos.y - cloudAltitude) / (cloudTallness * 3.0));
                    float radiusFactor = mix(cloudLightRadius * 8.0, cloudLightRadius, aboveFade);
                    float moonVisibility = abs(1.0 - moonPhase / 4.0);
                    float sunMult = mix(moonVisibility, 0.85, sunVisibility);

                    float sunPlaneIntersect = (cloudAltitude - cameraPos.y) / worldLightVec.y;
                    vec2 posVector = cameraPos.xz + worldLightVec.xz * sunPlaneIntersect - tracePos.xz;
                    float falloff = exp((1.0 - max0(1.0 - length(posVector) / radiusFactor)) * -6.0) * aboveFade * sunMult;

                    float sunShadingFactor = clamp01(falloff * mix(1.0, 2.0, aboveFade) * mix(1.0, (lTracePos - minPlaneDistance) / (maxPlaneDistance - minPlaneDistance), 0.75));

                    vec3 bloodMoonCloudColor = vec3(1.0);
                    #if BLOOD_MOON > 0
                        bloodMoonCloudColor = mix(bloodMoonCloudColor, vec3(0.302, 0.0078, 0.0078) * 5, getBloodMoon(sunVisibility));
                    #endif

                    #if PIXELATED_UNBOUND_CLOUDS > 0
                        visibilityFactor *= 0.2;
                    #endif

                    cloudLightColor += bloodMoonCloudColor * sunShadingFactor * 0.3 * visibilityFactor;
                    cloudShading += sunShadingFactor * 0.45 * visibilityFactor;
                }
            #endif

            #if BLOOD_MOON > 0
                vec3 hsvCloudLightColor = rgb2hsv(cloudLightColor);
                cloudLightColor = mix(cloudLightColor, hsv2rgb(vec3(0, max(0.66, hsvCloudLightColor.y), hsvCloudLightColor.z)), getBloodMoon(sunVisibility));
            #endif

            vec3 colorSample = cloudAmbientColor * (0.4 + 0.6 * cloudShading) + cloudLightColor * cloudShading;
            //vec3 colorSample = 2.5 * cloudLightColor * pow2(cloudShading); // <-- Used this to take the Unbound logo

            #ifdef RAIN_ATMOSPHERE
                // Lightning flashes around lightning bolt position
                vec3 lightningPos = getLightningPos(tracePos - cameraPos, lightningBoltPosition.xyz, false);
                vec2 lightningAdd = lightningFlashEffect(lightningPos, vec3(1.0), 550.0, 0.0, 0) * isLightningActive() * 10.0;
                colorSample += lightningAdd.y;

                // Thunderstorm cloud highlights (randomly appear in stormy weather)
                float highlightBoost = getThunderstormCloudHighlights(tracePos, cameraPos.xz, lTracePos, minPlaneDistance, maxPlaneDistance, 0.004);
                colorSample += highlightBoost;
            #endif

            float distanceRatio = (distanceThreshold - lTracePosXZ) / distanceThreshold;
            float cloudDistanceFactor = clamp(distanceRatio, 0.0, 0.8) * 1.25;
            float cloudFogFactor = pow2(pow1_5(clamp(distanceRatio, 0.0, 1.0))) * 0.69;
            cloudFogFactor = mix(1.0, cloudFogFactor, skyFadeM);

            bool isCustomSky;
            vec3 cloudSkyColor = GetSky(VdotU, VdotS, dither, isEyeInWater == 0, false, isCustomSky, false);
            #ifdef SAVE_SKYBOX_DATA
                if (isCustomSky) {
                    vec3 averageSkyColor = texelFetch(colortex14, texelCoord, 0).rgb;
                    cloudSkyColor = mix(cloudSkyColor, averageSkyColor, cloudFogFactor);
                }
            #endif
            #ifdef ATM_COLOR_MULTS
                cloudSkyColor *= sqrtAtmColorMult; // C72380KD - Reduced atmColorMult impact on some things
            #endif
            colorSample *= 1.0 - 0.2 * (1.0 - skyFadeM) * max(sunVisibility2, nightFactor);
            colorSample = mix(cloudSkyColor, colorSample, cloudFogFactor * 0.69);
            colorSample *= pow2(1.0 - maxBlindnessDarkness);

            volumetricClouds.rgb = mix(volumetricClouds.rgb, colorSample, 1.0 - min1(volumetricClouds.a));
            volumetricClouds.a += opacityFactor * pow(cloudDistanceFactor, 0.5 + 10.0 * pow(abs(VdotSM1M), 90.0)) * cloudMult;
            #if PIXELATED_UNBOUND_CLOUDS > 0
                volumetricClouds.a += mix(0.0, min(1.0 - pow5(distanceRatio * 0.99), 0.2), cloudTransparency);
            #endif

            if (volumetricClouds.a > 0.9) {
                volumetricClouds.a = 1.0;
                break;
            }
        }
    }

    #ifndef DOUBLE_UNBOUND_CLOUDS
    if (volumetricClouds.a > 0.5)
    #endif
    { cloudLinearDepth = sqrt(firstHitPos / renderDistance); }

    volumetricClouds.a *= 0.5 + 0.5 * skyFadeM;

    return volumetricClouds;
}

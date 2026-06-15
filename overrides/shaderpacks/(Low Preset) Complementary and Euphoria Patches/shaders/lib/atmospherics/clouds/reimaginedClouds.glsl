#include "/lib/shaderSettings/cloudsAndLighting.glsl"
#include "/lib/atmospherics/clouds/cloudCoord.glsl"

#ifdef DOUBLE_REIM_CLOUDS
    const float cloudStretch = CLOUD_STRETCH * 4.2;
    const float L2cloudStretch = cloudStretch * CLOUD_REIMAGINED_LAYER2_HEIGHT;
    const float cloudTallness = cloudStretch * 2.0;
#else
    const float cloudStretch = CLOUD_STRETCH * 4.2;
    const float cloudTallness = cloudStretch * 2.0;
#endif
const float cloudRoundness = CLOUD_ROUNDNESS;

bool GetCloudNoise(vec3 tracePos, inout vec3 tracePosM, int cloudAltitude, float cloudStretchParam) {
    tracePosM = ModifyTracePos(tracePos, cloudAltitude);
    vec2 coord = GetRoundedCloudCoord(tracePosM.xz, cloudRoundness);

    #ifdef DEFERRED1
        float noise = texture2D(colortex3, coord).b;
    #else
        float noise = texture2D(gaux4, coord).b;
    #endif

    float threshold = clamp(abs(cloudAltitude - tracePos.y) / cloudStretchParam, 0.001, 0.999);
    threshold = pow2(pow2(pow2(threshold)));
    return noise > threshold * 0.5 + 0.25;
}

float Get2DCloudSample(vec2 pos) {
    #ifdef DEFERRED1
        return texture2D(colortex3, GetRoundedCloudCoord(pos, cloudRoundness)).b;
    #else
        return texture2D(gaux4, GetRoundedCloudCoord(pos, cloudRoundness)).b;
    #endif
}

vec4 GetVolumetricClouds(int cloudAltitude, float distanceThreshold, inout float cloudLinearDepth, float skyFade, float skyMult0, vec3 cameraPos, vec3 nPlayerPos, float lViewPosM, float VdotS, float VdotU, float dither, vec3 sunVec, vec3 viewPos) {
    vec4 volumetricClouds = vec4(0.0);

    // Use local variables to avoid modifying globals
    float localCloudStretch = cloudStretch;
    float localCloudTallness = cloudTallness;

    #ifdef DOUBLE_REIM_CLOUDS
        if (cloudAltitude != cloudAlt1i) { // second layer
            localCloudStretch = L2cloudStretch;
            localCloudTallness = 2.0 * localCloudStretch;
        }
    #endif

    float higherPlaneAltitude = cloudAltitude + localCloudStretch;
    float lowerPlaneAltitude  = cloudAltitude - localCloudStretch;

    float lowerPlaneDistance  = (lowerPlaneAltitude - cameraPos.y) / nPlayerPos.y;
    float higherPlaneDistance = (higherPlaneAltitude - cameraPos.y) / nPlayerPos.y;
    float minPlaneDistance = min(lowerPlaneDistance, higherPlaneDistance);
          minPlaneDistance = max(minPlaneDistance, 0.0);
    float maxPlaneDistance = max(lowerPlaneDistance, higherPlaneDistance);
    if (maxPlaneDistance < 0.0) return vec4(0.0);
    float planeDistanceDif = maxPlaneDistance - minPlaneDistance;

    float aboveClouds = clamp01((cameraPos.y - lowerPlaneAltitude) * 0.05);
    float skyFadeM = mix(skyFade, 1.0, mix(0.4 * max(aboveClouds, rainFactor2), 1.0, clamp01(CLOUD_TRANSPARENCY - 1.0)));
    float min1CloudTransparency = min1(CLOUD_TRANSPARENCY);

    #if CLOUD_QUALITY_INTERNAL == 1 || !defined DEFERRED1
        int sampleCount = max(int(planeDistanceDif) / 16, 6);
    #elif CLOUD_QUALITY_INTERNAL == 2
        int sampleCount = max(int(planeDistanceDif) / 8, 12);
    #elif CLOUD_QUALITY_INTERNAL == 3 || CLOUD_QUALITY_INTERNAL == 4
        int sampleCount = max(int(planeDistanceDif), 12);
    #endif

    float stepMult = planeDistanceDif / sampleCount;
    vec3 traceAdd = nPlayerPos * stepMult;
    vec3 tracePos = cameraPos + minPlaneDistance * nPlayerPos;
    tracePos += traceAdd * dither;
    tracePos.y -= traceAdd.y;

    #ifdef FIX_AMD_REFLECTION_CRASH
        sampleCount = min(sampleCount, 30); //BFARC
    #endif

    #ifdef AURORA_INFLUENCE
        cloudAmbientColor = getAuroraAmbientColor(cloudAmbientColor, viewPos, 0.032, AURORA_CLOUD_INFLUENCE_INTENSITY, 0.75);
    #endif

    for (int i = 0; i < sampleCount; i++) {
        tracePos += traceAdd;

        vec3 cloudPlayerPos = tracePos - cameraPos;
        float lTracePos = length(cloudPlayerPos);
        float lTracePosXZ = length(cloudPlayerPos.xz);
        float cloudMult = 1.0;
        if (lTracePosXZ > distanceThreshold) break;
        if (lTracePos > lViewPosM) {
            if (skyFade < 0.7) continue;
            else cloudMult = skyMult0;
        }

        vec3 tracePosM;
        if (GetCloudNoise(tracePos, tracePosM, cloudAltitude, localCloudStretch)) {
            float lightMult = 1.0;

            #if SHADOW_QUALITY > -1 && !defined VOXY_PATCH
                float shadowLength = shadowDistance * 0.9166667; //consistent08JJ622
                if (shadowLength > lTracePos)
                if (GetShadowOnCloud(tracePos, cameraPos, cloudAltitude, lowerPlaneAltitude, higherPlaneAltitude)) {
                    #ifdef CLOUD_CLOSED_AREA_CHECK
                        if (eyeBrightness.y != 240) continue;
                        else
                    #endif
                    lightMult = 0.25;
                }
            #endif

            #ifdef INVERTED_CLOUD_SHADING
                float cloudShading = (higherPlaneAltitude - tracePos.y) / localCloudTallness;
            #else
                float cloudShading = 1.0 - (higherPlaneAltitude - tracePos.y) / localCloudTallness;
            #endif
            cloudShading = pow(max0(cloudShading), max0(CLOUD_SHADING_AMOUNT * 0.1 - 0.2));
            float VdotSM1 = max0(sunVisibility > 0.5 ? VdotS : - VdotS);

            #if CLOUD_QUALITY_INTERNAL >= 2
                #ifdef DEFERRED1
                    float cloudShadingM = 1.0 - pow2(cloudShading);
                #else
                    float cloudShadingM = 1.0 - cloudShading;
                #endif

                float gradientNoise = InterleavedGradientNoiseForClouds();

                vec3 cLightPos = tracePosM;
                #if REIMAGINED_CLOUDS_OUTLINE > 0
                    vec3 cLightPosAdd = nPlayerPos * REIMAGINED_CLOUDS_OUTLINE * localCloudTallness * 0.01;
                    float tempCloudOutlineThickness = 0.0;
                #else
                    vec3 cLightPosAdd = normalize(ViewToPlayer(lightVec * 1000000000.0)) * vec3(0.08) * shadowTime;
                    float tempCloudOutlineThickness = 1.0;
                #endif

                float light = 2.0;
                cLightPos += (tempCloudOutlineThickness + gradientNoise) * cLightPosAdd;
                    light -= Get2DCloudSample(cLightPos.xz) * cloudShadingM;
                cLightPos += gradientNoise * cLightPosAdd;
                    light -= Get2DCloudSample(cLightPos.xz) * cloudShadingM;

                float VdotSM2 = VdotSM1 * shadowTime * 0.25;
                      VdotSM2 += 0.5 * cloudShading + 0.08;
                cloudShading = VdotSM2 * light * lightMult;
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

                    float aboveFade = 1.0 - smoothstep(-20.0, 0.0, cameraPos.y - cloudAltitude);
                    float sunPlaneIntersect = (cloudAltitude - cameraPos.y) / worldLightVec.y;
                    vec2 posVector = cameraPos.xz + worldLightVec.xz * sunPlaneIntersect - tracePos.xz;

                    float moonVisibility = abs(1.0 - moonPhase / 4.0);
                    float sunMult = mix(moonVisibility, 0.75, sunVisibility);
                    float falloff = exp((1.0 - max0(1.0 - length(posVector) / cloudLightRadius)) * -6.0) * aboveFade * sunMult;

                    float sunCloudMult = clamp01(falloff * 2.5 * mix(1.0, (lTracePos - minPlaneDistance) / (maxPlaneDistance - minPlaneDistance), 0.6));

                    vec3 bloodMoonCloudColor = vec3(1.0);
                    #if BLOOD_MOON > 0
                        bloodMoonCloudColor = mix(bloodMoonCloudColor, vec3(0.302, 0.0078, 0.0078) * 5, getBloodMoon(sunVisibility));
                    #endif

                    cloudLightColor += bloodMoonCloudColor * sunCloudMult * 0.11 * visibilityFactor;
                    cloudShading += sunCloudMult * 1.5 * visibilityFactor;
                }
            #endif

            #if BLOOD_MOON > 0
                vec3 hsvCloudLightColor = rgb2hsv(cloudLightColor);
                cloudLightColor = mix(cloudLightColor, hsv2rgb(vec3(0, max(0.66, hsvCloudLightColor.y), hsvCloudLightColor.z)), getBloodMoon(sunVisibility));
            #endif

            #ifdef AURORA_INFLUENCE
                cloudLightColor = getAuroraAmbientColor(cloudLightColor, viewPos, 0.1, AURORA_CLOUD_INFLUENCE_INTENSITY, 0.75);
            #endif

            vec3 colorSample = cloudAmbientColor * 0.95 * (1.0 - 0.35 * cloudShading) + cloudLightColor * 0.9 * (0.1 + cloudShading);

            #ifdef RAIN_ATMOSPHERE
                // Lightning flashes around lightning bolt position
                vec3 lightningPos = getLightningPos(tracePos - cameraPos, lightningBoltPosition.xyz, false);
                vec2 lightningAdd = lightningFlashEffect(lightningPos, vec3(1.0), 450.0, 0.0, 0) * isLightningActive() * 10.0;
                colorSample += lightningAdd.y;

                // Thunderstorm cloud highlights (randomly appear in stormy weather)
                float highlightBoost = getThunderstormCloudHighlights(tracePos, cameraPos.xz, lTracePos, minPlaneDistance, maxPlaneDistance, 0.005);
                colorSample += highlightBoost;
            #endif

            float distanceRatio = (distanceThreshold - lTracePosXZ) / distanceThreshold;
            float cloudFogFactor = pow2(clamp(distanceRatio, 0.0, 1.0)) * 0.707;
            cloudFogFactor = mix(1.0, cloudFogFactor, skyFadeM);
            float nightCloudRemove = NIGHT_CLOUD_UNBOUND_REMOVE * (1.0 - sunVisibility) * -1 + 1.0; // mapped to 1 to 0 range

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

            #if defined DOUBLE_REIM_CLOUDS && CLOUD_REIMAGINED_LAYER2_TRANSPARENCY != 20
                if (cloudAltitude != cloudAlt1i) { // second layer uses custom transparency
                    cloudMult *= (CLOUD_REIMAGINED_LAYER2_TRANSPARENCY * 0.05) * nightCloudRemove;
                } else {
                    cloudMult *= min1CloudTransparency * nightCloudRemove;
                }
            #else
                cloudMult *= min1CloudTransparency * nightCloudRemove;
            #endif

            colorSample *= 1.0 - 0.2 * (1.0 - skyFadeM) * max(sunVisibility2, nightFactor);
            colorSample = mix(cloudSkyColor, colorSample, cloudFogFactor * 0.707);
            colorSample *= pow2(1.0 - maxBlindnessDarkness);

            float cloudDistanceFactor = clamp(distanceRatio, 0.0, 0.75);

            volumetricClouds.a = sqrt(cloudDistanceFactor * 1.33333) * cloudMult;
            volumetricClouds.rgb = colorSample;

            cloudLinearDepth = sqrt(lTracePos / renderDistance);
            break;
        }
    }

    volumetricClouds.a *= 0.5 + 0.5 * skyFadeM;

    return volumetricClouds;
}

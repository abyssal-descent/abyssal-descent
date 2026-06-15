#include "/lib/shaderSettings/clouds.glsl"
#if CLOUD_UNBOUND_SIZE_MULT != 100
    #define CLOUD_UNBOUND_SIZE_MULT_M CLOUD_UNBOUND_SIZE_MULT * 0.01
#endif

#include "/lib/colors/lightAndAmbientColors.glsl"
#include "/lib/colors/cloudColors.glsl"
#include "/lib/atmospherics/sky.glsl"

float InterleavedGradientNoiseForClouds() {
    float n = 52.9829189 * fract(0.06711056 * gl_FragCoord.x + 0.00583715 * gl_FragCoord.y);
    #ifdef TAA
        return fract(n + goldenRatio * mod(float(frameCounter), 3600.0));
    #else
        return fract(n);
    #endif
}

#if SHADOW_QUALITY > -1 && !defined VOXY_PATCH
    vec3 GetShadowOnCloudPosition(vec3 tracePos, vec3 cameraPos) {
        vec3 wpos = PlayerToShadow(tracePos - cameraPos);
        float distb = sqrt(wpos.x * wpos.x + wpos.y * wpos.y);
        float distortFactor = 1.0 - shadowMapBias + distb * shadowMapBias;
        vec3 shadowPosition = vec3(vec2(wpos.xy / distortFactor), wpos.z * 0.2);
        return shadowPosition * 0.5 + 0.5;
    }

    bool GetShadowOnCloud(vec3 tracePos, vec3 cameraPos, int cloudAltitude, float lowerPlaneAltitude, float higherPlaneAltitude) {
        const float cloudShadowOffset = 0.5;

        vec3 shadowPosition0 = GetShadowOnCloudPosition(tracePos, cameraPos);
        if (length(shadowPosition0.xy * 2.0 - 1.0) < 1.0) {
            float shadowsample0 = shadow2D(shadowtex0, shadowPosition0).z;

            if (shadowsample0 == 0.0) return true;
        }

        return false;
    }
#endif

#ifdef CLOUDS_REIMAGINED
    #include "/lib/atmospherics/clouds/reimaginedClouds.glsl"
#endif
#ifdef CLOUDS_UNBOUND
    #include "/lib/atmospherics/clouds/unboundClouds.glsl"
#endif

vec4 GetClouds(inout float cloudLinearDepth, float skyFade, vec3 cameraPosOffset, vec3 playerPos, vec3 viewPos,
               float lViewPos, float VdotS, float VdotU, float dither, vec3 auroraBorealis, vec3 nightNebula, vec3 sunVec) {
    vec4 clouds = vec4(0.0);

    vec3 nPlayerPos = normalize(playerPos);
    float lViewPosM = lViewPos < renderDistance * 1.5 ? lViewPos - 1.0 : 1000000000.0;
    float skyMult0 = pow2(skyFade * 3.333333 - 2.333333);

    #if IRIS_VERSION >= 10800
        #ifdef CLOUDS_REIMAGINED
            float modFactor = 1.0 / cloudNarrowness * 256.0;
        #else
            #if CLOUD_UNBOUND_SIZE_MULT == 100
                float modFactor = 1.0 / cloudNarrowness;
            #else
                float modFactor = 1.0 / (cloudNarrowness * CLOUD_UNBOUND_SIZE_MULT_M);
            #endif
        #endif

        int modFactorM = int(modFactor);

        vec2 cameraPositionBIM = cameraPositionInt.xz - modFactorM * (cameraPositionInt.xz / modFactorM);

        vec3 cameraPos = vec3(
            cameraPositionBIM.x + cameraPositionBestFract.x,
            cameraPosition.y,
            cameraPositionBIM.y + cameraPositionBestFract.z
        );

        #if defined CLOUDS_UNBOUND && defined DOUBLE_UNBOUND_CLOUDS
            float layer2ScaleFactor = CLOUD_UNBOUND_LAYER2_SIZE * 10.0 / CLOUD_UNBOUND_SIZE_MULT;
            #if CLOUD_UNBOUND_SIZE_MULT == 100
                float modFactor2 = 1.0 / (cloudNarrowness * layer2ScaleFactor);
            #else
                float modFactor2 = 1.0 / (cloudNarrowness * CLOUD_UNBOUND_SIZE_MULT_M * layer2ScaleFactor);
            #endif

            int modFactorM2 = int(modFactor2);

            vec2 cameraPositionBIM2 = cameraPositionInt.xz - modFactorM2 * (cameraPositionInt.xz / modFactorM2);

            vec3 cameraPos2 = vec3(
                cameraPositionBIM2.x + cameraPositionBestFract.x,
                cameraPosition.y,
                cameraPositionBIM2.y + cameraPositionBestFract.z
            );
        #endif
    #else
        vec3 cameraPos = cameraPosition;
        #if defined CLOUDS_UNBOUND && defined DOUBLE_UNBOUND_CLOUDS
            vec3 cameraPos2 = cameraPosition;
        #endif
    #endif
    cameraPos += cameraPosOffset;
    #if defined CLOUDS_UNBOUND && defined DOUBLE_UNBOUND_CLOUDS
        cameraPos2 += cameraPosOffset;
    #endif

    #ifdef CLOUDS_REIMAGINED
        float thresholdF = 4000.0;
    #else
        float thresholdF = 4000.0;
    #endif

    //float thresholdMix = pow2(clamp01(VdotU * 15.0));
    //thresholdF = mix(far, thresholdF, thresholdMix * 0.5 + 0.5);
    thresholdF *= CLOUD_RENDER_DISTANCE;

    #if RAINBOW_CLOUD != 0
        vec3 wpos = normalize((gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz);
        wpos /= (abs(wpos.y) + length(wpos.xz));

        vec3 rainbowColor = getRainbowColor(wpos.xz * rainbowCloudDistribution * 0.35, 0.05);
        cloudRainColor *= rainbowColor;
        cloudAmbientColor *= rainbowColor;
        cloudLightColor *= rainbowColor;
    #endif

    #ifdef CLOUDS_REIMAGINED
        cloudAmbientColor *= 1.0 - 0.25 * rainFactor;
    #endif

    vec3 cloudColorMult = vec3(1.0);
    #if CLOUD_R != 100 || CLOUD_G != 100 || CLOUD_B != 100
        cloudColorMult *= vec3(CLOUD_R, CLOUD_G, CLOUD_B) * 0.01;
    #endif
    cloudAmbientColor *= cloudColorMult;
    cloudLightColor *= cloudColorMult;

    #if defined CLOUDS_REIMAGINED && defined DOUBLE_REIM_CLOUDS
        int maxCloudAlt = max(cloudAlt1i, cloudAlt2i);
        int minCloudAlt = min(cloudAlt1i, cloudAlt2i);

        if (abs(cameraPos.y - minCloudAlt) < abs(cameraPos.y - maxCloudAlt)) {
            clouds = GetVolumetricClouds(minCloudAlt, thresholdF, cloudLinearDepth, skyFade, skyMult0,
                                            cameraPos, nPlayerPos, lViewPosM, VdotS, VdotU, dither, sunVec, viewPos);
            if (clouds.a == 0.0) {
            clouds = GetVolumetricClouds(maxCloudAlt, thresholdF, cloudLinearDepth, skyFade, skyMult0,
                                            cameraPos, nPlayerPos, lViewPosM, VdotS, VdotU, dither, sunVec, viewPos);
            }
        } else {
            clouds = GetVolumetricClouds(maxCloudAlt, thresholdF, cloudLinearDepth, skyFade, skyMult0,
                                            cameraPos, nPlayerPos, lViewPosM, VdotS, VdotU, dither, sunVec, viewPos);
            if (clouds.a == 0.0) {
            clouds = GetVolumetricClouds(minCloudAlt, thresholdF, cloudLinearDepth, skyFade, skyMult0,
                                            cameraPos, nPlayerPos, lViewPosM, VdotS, VdotU, dither, sunVec, viewPos);
            }
        }

    #elif defined CLOUDS_UNBOUND && defined DOUBLE_UNBOUND_CLOUDS
        float cloudLinearDepth1 = 1.0;
        float cloudLinearDepth2 = 1.0;
        //The order of calculating the clouds actually matters here
        vec4 clouds1 = GetVolumetricClouds(cloudAlt1i, thresholdF, cloudLinearDepth1, skyFade, skyMult0,
                                        cameraPos, nPlayerPos, lViewPosM, VdotS, VdotU, dither, sunVec, viewPos);
        vec4 clouds2 = GetVolumetricClouds(cloudAlt2i, thresholdF, cloudLinearDepth2, skyFade, skyMult0,
                                       cameraPos2, nPlayerPos, lViewPosM, VdotS, VdotU, dither, sunVec, viewPos);

        if (clouds1.a * clouds2.a < 1e-36)
            clouds = clouds1 * sign(max(0.0, clouds1.a - 1e-36)) + clouds2 * sign(max(0.0, clouds2.a - 1e-36));
        else {
            if (cloudLinearDepth1 < cloudLinearDepth2)
                clouds = vec4(mix(clouds2.rgb, clouds1.rgb, clouds1.w), mix(clouds2.w, 1.0, clouds1.w));
            else
                clouds = vec4(mix(clouds1.rgb, clouds2.rgb, clouds2.w), mix(clouds1.w, 1.0, clouds2.w));
        }

        cloudLinearDepth = min(clouds1.a > 0.5 ? cloudLinearDepth1 : 1.0, clouds2.a > 0.5 ? cloudLinearDepth2 : 1.0);
    #else
        clouds = GetVolumetricClouds(cloudAlt1i, thresholdF, cloudLinearDepth, skyFade, skyMult0,
                                        cameraPos, nPlayerPos, lViewPosM, VdotS, VdotU, dither, sunVec, viewPos) ;

    #endif

    #ifdef ATM_COLOR_MULTS
        clouds.rgb *= sqrtAtmColorMult; // C72380KD - Reduced atmColorMult impact on some things
    #endif
    #ifdef MOON_PHASE_INF_ATMOSPHERE
        clouds.rgb *= moonPhaseInfluence;
    #endif

    #if AURORA_STYLE > 0
        clouds.rgb += auroraBorealis * 0.1;
    #endif
    #if NIGHT_NEBULAE == 1
        clouds.rgb += nightNebula * 0.2;
    #endif

    return clouds;
}

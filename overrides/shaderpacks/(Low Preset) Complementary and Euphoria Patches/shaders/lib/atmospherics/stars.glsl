#if !defined STARS_FILE_INCLUDED
#define STARS_FILE_INCLUDED
#include "/lib/colors/skyColors.glsl"
#include "/lib/shaderSettings/stars.glsl"

#ifdef CELESTIAL_BOTH_HEMISPHERES
vec2 GetStarCoordBothHemispheres(vec3 viewPos, float sphereness) {
    vec3 wpos = normalize((gbufferModelViewInverse * vec4(viewPos * 1000.0, 1.0)).xyz);
    float ySign = sign(wpos.y);
    float yMagnitude = abs(wpos.y);

    vec3 adjustedWpos = vec3(wpos.x, yMagnitude, wpos.z);
    vec3 starCoord = adjustedWpos / (adjustedWpos.y + length(adjustedWpos.xz) * sphereness);

    if (ySign >= 0.0) {
        starCoord.x += 0.006 * syncedTime;  // Top hemisphere (original direction)
    } else {
        starCoord.x = starCoord.x - 0.006 * syncedTime + 0.37;  // Bottom hemisphere with offset
        starCoord.z += 0.21;
    }

    return starCoord.xz;
}
#endif

vec2 GetStarCoordUpperHemisphere(vec3 viewPos, float sphereness) {
    vec3 wpos = normalize((gbufferModelViewInverse * vec4(viewPos * 1000.0, 1.0)).xyz);
    vec3 starCoord = wpos / (wpos.y + length(wpos.xz) * sphereness);
    starCoord.x += 0.006 * syncedTime;

    return starCoord.xz;
}

vec2 GetStarCoord(vec3 viewPos, float sphereness) {
    #ifdef CELESTIAL_BOTH_HEMISPHERES
        return GetStarCoordBothHemispheres(viewPos, sphereness);
    #else
        return GetStarCoordUpperHemisphere(viewPos, sphereness);
    #endif
}

vec3 GetStars(vec2 starCoord, float VdotU, float VdotS, float sizeMult, float starAmount) {
    #if NIGHT_STAR_AMOUNT == 0 || (defined EUPHORIA_PATCHES_IS_SPYGLASS_ASTRONOMY_INSTALLED && defined GBUFFERS_SKYBASIC)
        return vec3(0.0, 0.0, 0.0);
    #endif
    float starsAroundSun = 1.0;
    #ifdef CELESTIAL_BOTH_HEMISPHERES
        float starBelowHorizonBrightness = 1.0;
        float horizonFactor = exp(-pow(VdotU / 0.1, 2.0));
        #ifdef SUN_MOON_HORIZON
            starsAroundSun = max0(sign(VdotU));
        #endif
    #else
        if (VdotU < 0.0) return vec3(0.0);
        float starBelowHorizonBrightness = min1(VdotU * 3.0);
        float horizonFactor = 0.0;
    #endif

    starCoord *= 0.2 / (STAR_SIZE * sizeMult);

    const float starFactor = 1024.0;

    vec2 fractPart = fract(starCoord * starFactor);

    starCoord = floor(starCoord * starFactor) / starFactor;

    float star = GetStarNoise(starCoord.xy) * GetStarNoise(starCoord.xy+0.1) * GetStarNoise(starCoord.xy+0.23);

    #if NIGHT_STAR_AMOUNT == 1
        star -= 0.82;
        star *= 2.0;
    #elif NIGHT_STAR_AMOUNT == 2
        star -= 0.7;
    #elif NIGHT_STAR_AMOUNT == 3
        star -= 0.62;
        star *= 0.75;
    #elif NIGHT_STAR_AMOUNT == 4
        star -= 0.52;
        star *= 0.55;
    #endif

    star = max0(star - starAmount * 0.1);
    star *= getStarEdgeFactor(fractPart, STAR_ROUNDNESS_OW / 10.0, STAR_SOFTNESS_OW);
    star *= star;

    star *= max0(1.0 - pow(abs(VdotS) * 1.002, 100.0) * starsAroundSun) * starBelowHorizonBrightness - horizonFactor * 0.5;
    #ifndef DAYLIGHT_STARS
        star *= pow2(pow2(invNoonFactor2)) * (1.0 - 0.5 * sunVisibility);
    #endif

    #ifdef CLEAR_SKY_WHEN_RAINING
        star *= min1(invRainFactorDynamic + 0.4);
    #else
        star *= invRainFactorDynamic;
    #endif

    vec3 starColor = GetStarColor(starCoord,
                                vec3(0.38, 0.4, 0.5),
                                  vec3(STAR_COLOR_1_OW_R, STAR_COLOR_1_OW_G, STAR_COLOR_1_OW_B),
                                  vec3(STAR_COLOR_2_OW_R, STAR_COLOR_2_OW_G, STAR_COLOR_2_OW_B),
                                  vec3(STAR_COLOR_3_OW_R, STAR_COLOR_3_OW_G, STAR_COLOR_3_OW_B),
                                  float(STAR_COLOR_VARIATION_OW));

    vec3 stars = 40.0 * star * starColor * starBrightness;

    #if TWINKLING_STARS > 0
        stars *= getTwinklingStars(starCoord, float(TWINKLING_STARS));
    #endif

    return stars;
}
#endif

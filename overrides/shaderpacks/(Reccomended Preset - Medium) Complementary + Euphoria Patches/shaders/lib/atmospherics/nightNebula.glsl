#include "/lib/atmospherics/stars.glsl"

// Nebula implementation by flytrap https://godotshaders.com/shader/2d-nebula-shader/
#include "/lib/shaderSettings/stars.glsl"
#include "/lib/shaderSettings/nightNebula.glsl"

#ifndef HQ_NIGHT_NEBULA
    const int OCTAVE = 5;
#else
    const int OCTAVE = 8;
#endif

const float timescale = 5.0;
const float zoomScale = NEBULA_ZOOM_LEVEL;

const vec4 CLOUD1_COL = vec4(NEBULA_R_1, NEBULA_G_1, NEBULA_B_1, 0.4);
const vec4 CLOUD2_COL = vec4(NEBULA_R_2, NEBULA_G_2, NEBULA_B_2, 0.2);
const vec4 CLOUD3_COL = vec4(NEBULA_R_3, NEBULA_G_3, NEBULA_B_3, 1.0);

float sinM(float x) {
    return sin(mod(x, 2.0 * pi));
}

float cosM(float x) {
    return cos(mod(x, 2.0 * pi));
}

float rand(vec2 inCoord){
    return fract(sinM(dot(inCoord, vec2(23.5, 44.0))) * 42350.45);
}

float perlin(vec2 inCoord){
    vec2 i = floor(inCoord);
    vec2 j = fract(inCoord);
    vec2 coord = smoothstep(0.0, 1.0, j);

    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));

    return mix(mix(a, b, coord.x), mix(c, d, coord.x), coord.y);
}

float fbmCloud(vec2 inCoord, float minimum){
    float value = 0.0;
    float scale = NEBULA_AMOUNT * 0.1 + 0.45;

    for (int i = 0; i < OCTAVE; i++){
        value += perlin(inCoord) * scale;
        inCoord *= 2.0;
        scale *= 0.5;
    }

    return smoothstep(0.0, 1.0, (smoothstep(minimum, 1.0, value) - minimum) / (1.0 - minimum));
}

float fbmCloud2(vec2 inCoord, float minimum){
    float value = 0.0;
    float scale = (NEBULA_AMOUNT + 0.1) * 0.25 + 0.35;

    for (int i = 0; i < OCTAVE; i++){
        value += perlin(inCoord) * scale;
        inCoord *= 2.0;
        scale *= 0.5;
    }

    return (smoothstep(minimum, 1.0, value) - minimum) / (1.0 - minimum);
}

vec2 warpCoords(vec2 coord, float warpAmount) {
    float angle = perlin(coord * 0.5) * 6.28318 * warpAmount;
    float strength = perlin(coord * 0.7 + 0.5) * warpAmount;
    vec2 offset = vec2(cos(angle), sin(angle)) * strength;
    return coord + offset;
}

vec3 GetNightNebula(vec3 viewPos, float VdotU, float VdotS) {
    float VdotUFactor = max0(VdotU);
    float starsAroundSun = 1.0;
    #ifdef CELESTIAL_BOTH_HEMISPHERES
        VdotUFactor = VdotU;
        #ifdef SUN_MOON_HORIZON
            starsAroundSun = max0(sign(VdotU));
        #endif
    #endif
    float originalVdotUFactor = VdotUFactor;
    float horizonPower = NEBULA_HORIZON_STRENGTH * 0.05 + 0.5;

    #if NEBULA_HORIZON_STRENGTH < 10
        VdotUFactor = pow(VdotUFactor, horizonPower);
    #endif

    float nebulaFactor = pow2(VdotUFactor * min1(nightFactor * 2.0));

    #if NEBULA_HORIZON_STRENGTH < 10
        float brightnessCompensation = 1.0 - (1.0 - horizonPower) * 0.5 * max0(originalVdotUFactor);
        nebulaFactor *= brightnessCompensation;
    #endif

    #ifdef CLEAR_SKY_WHEN_RAINING
        nebulaFactor *= min1(invRainFactorDynamic + 0.4);
    #else
        nebulaFactor *= invRainFactorDynamic;
    #endif

    nebulaFactor -= maxBlindnessDarkness;

    #if NEBULA_MOON_CONDITION == 1
        if (moonPhase != 4) return vec3(0.0);
    #elif NEBULA_MOON_CONDITION == 2
        if (moonPhase != 0) return vec3(0.0);
    #elif NEBULA_MOON_CONDITION == 3
        if (moonPhase == 0 || moonPhase == 4) return vec3(0.0);
    #elif NEBULA_MOON_CONDITION == 4
        nebulaFactor *= step(0.5, hash11(float(worldDay) + float(moonPhase) * 37.0));
    #elif NEBULA_MOON_CONDITION == 5
        nebulaFactor *= clamp01(max(moonPhase, 1) % 4);
    #endif

    if (nebulaFactor < 0.001) return vec3(0.0);

    vec2 UV = GetStarCoord(viewPos, 0.75);
    float TIME = syncedTime * 0.003 + 15.0;
    float timescaled = TIME * timescale;

    float sinTime = sinM(0.07 * timescaled);
    float cosTime06 = cosM(0.06 * timescaled);
    float cosTime07 = cosM(0.07 * timescaled);

    float tide = 0.05 * sinM(TIME);
    float tide2 = 0.06 * cosM(0.3 * TIME);

    vec4 nebulaTexture = vec4(vec3(0.0), 0.5 + 0.2 * sinM(0.23 * TIME + UV.x - UV.y));

    #if PIXELATED_NEBULA > 0
        float pixelFactor = PIXELATED_NEBULA * 2.0;
        vec2 baseUV = floor(UV * pixelFactor) / pixelFactor;
    #else
        vec2 baseUV = UV;
    #endif

    vec2 scaledUV = baseUV * zoomScale;
    vec2 cloudUV2 = vec2(scaledUV.x + 0.03 * timescaled * sinTime, scaledUV.y + 0.03 * timescaled * cosTime06);
    vec2 cloudUV3 = vec2(scaledUV.x + 0.027 * timescaled * sinTime, scaledUV.y + 0.025 * timescaled * cosTime06);
    vec2 cloudUV4 = vec2(scaledUV.x + 0.021 * timescaled * sinTime, scaledUV.y + 0.021 * timescaled * cosTime07);

    #if NEBULA_PATTERN_WARP > 0
        cloudUV2 = warpCoords(cloudUV2, NEBULA_PATTERN_WARP * 0.1);
        cloudUV3 = warpCoords(cloudUV3, NEBULA_PATTERN_WARP * 0.1);
        cloudUV4 = warpCoords(cloudUV4, NEBULA_PATTERN_WARP * 0.1);
    #endif

    nebulaTexture += fbmCloud2(cloudUV3, 0.24 + tide) * CLOUD1_COL;
    nebulaTexture += fbmCloud(cloudUV2 * 0.9, 0.33 - tide) * CLOUD2_COL;
    nebulaTexture = mix(nebulaTexture, CLOUD3_COL, fbmCloud(vec2(0.9 * cloudUV4.x, 0.9 * cloudUV4.y), 0.25 + tide2));

    nebulaFactor *= 1.0 - pow2(pow2(pow2(abs(VdotS)))) * starsAroundSun;
    nebulaTexture.a *= min1(pow2(pow2(nebulaTexture.a))) * nebulaFactor;

    float starFactor = 1024.0;
    UV /= STAR_SIZE * (0.75 + 0.25 * NEBULA_STAR_SIZE);
    vec2 starCoord = floor(UV * 0.25 * starFactor) / starFactor;
    vec2 fractPart = fract(UV * 0.25 * starFactor);

    float starAmount = (2.0 - NEBULA_STAR_AMOUNT) * 0.1;
    float starIntensity = GetStarNoise(starCoord) * GetStarNoise(starCoord + 0.1) - (starAmount + 0.5);
    starIntensity *= getStarEdgeFactor(fractPart, STAR_ROUNDNESS_OW / 10.0, STAR_SOFTNESS_OW);

    #if TWINKLING_STARS > 0
        starIntensity *= getTwinklingStars(starCoord * 4, float(TWINKLING_STARS));
    #endif

    float starGlow = pow2(clamp(starIntensity, 0.0, 0.3 + starAmount)) * starBrightness * NEBULA_STAR_BRIGHTNESS;

    #ifdef NEBULA_ONLY_STARS
        nebulaTexture.rgb = vec3(10.0 * starGlow);
    #else
        nebulaTexture.rgb *= 1.5 + 10.0 * starGlow;
    #endif

    #if NIGHT_NEBULA_I != 100
        #define NIGHT_NEBULA_IM NIGHT_NEBULA_I * 0.01
        nebulaTexture.a *= NIGHT_NEBULA_IM;
    #endif

    #if NEBULA_SATURATION != 10
        nebulaTexture.rgb = rgb2hsv(nebulaTexture.rgb);
        nebulaTexture.g *= NEBULA_SATURATION * 0.1;
        nebulaTexture.rgb = hsv2rgb(nebulaTexture.rgb);
    #endif

    #ifdef ATM_COLOR_MULTS
        nebulaTexture.rgb *= sqrtAtmColorMult; // C72380KD - Reduced atmColorMult impact on some things
    #endif

    return max(nebulaTexture.rgb * nebulaTexture.a, vec3(0.0));
}

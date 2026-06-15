#include "/lib/shaderSettings/enderStars.glsl"
vec3 GetEnderStars(vec3 viewPos, float VdotU, float sizeMult, float starAmount) {
    vec3 wpos = normalize((gbufferModelViewInverse * vec4(viewPos * 1000.0, 1.0)).xyz);
    vec3 starCoord = 0.65 * wpos / (abs(wpos.y) + length(wpos.xz));
    vec2 starCoord2 = starCoord.xz * 0.5 / (END_STAR_SIZE * sizeMult);
    starCoord2 += VdotU < 0.0 ? 100.0 : 0.0;

    #if END_STAR_HEMISPHERE != 0
        #if END_STAR_HEMISPHERE == 1
            if (VdotU < 0.0) return vec3(0.0);
        #else
            if (VdotU > 0.0) return vec3(0.0);
        #endif
        float starBelowHorizonBrightness = min(1.0, (abs(VdotU)) * 3.0);
    #else
        float starBelowHorizonBrightness = 1.0;
    #endif

    const float starFactor = 1024.0;
    vec2 fractPart = fract(starCoord2 * starFactor);
    starCoord2 = floor(starCoord2 * starFactor) / starFactor;

    float star = GetStarNoise(starCoord2.xy) * GetStarNoise(starCoord2.xy+0.1) * GetStarNoise(starCoord2.xy+0.23);

    #if END_STAR_AMOUNT == 0
        star = max0(star - 0.77);
    #elif END_STAR_AMOUNT == 2
        star = max0((star + 0.15) * 0.9 - 0.7);
    #elif END_STAR_AMOUNT == 3
        star = max0((star + 0.4) * 0.8 - 0.7);
    #elif END_STAR_AMOUNT == 4
        star = max0((star + 0.5) * 0.8 - 0.7);
    #else
        star = max0(star - 0.7);
    #endif

    star *= getStarEdgeFactor(fractPart, STAR_ROUNDNESS_END / 10.0, STAR_SOFTNESS_END);
    star = max0(star - starAmount * 0.1);
    star *= star;

    vec3 starColor = GetStarColor(starCoord2,
                                  endSkyColor,
                                  vec3(STAR_COLOR_1_END_R, STAR_COLOR_1_END_G, STAR_COLOR_1_END_B),
                                  vec3(STAR_COLOR_2_END_R, STAR_COLOR_2_END_G, STAR_COLOR_2_END_B),
                                  vec3(STAR_COLOR_3_END_R, STAR_COLOR_3_END_G, STAR_COLOR_3_END_B),
                                  float(STAR_COLOR_VARIATION_END));

    vec3 enderStars = star * starColor * 3000.0 * END_STAR_BRIGHTNESS * starBelowHorizonBrightness;

    float absVdotU = abs(VdotU);
    float VdotUM2 = pow2(1.0 - absVdotU);
    enderStars *= min(VdotUM2 + 0.015, 0.05) + 0.015;

    float VdotUM3 = smoothstep(0.0, 0.25, absVdotU);
    float endBeamHeight = END_BEAM_HEIGHT * 200.0;
    float beamFactor = END_BEAM_INTENSITY * max0(endBeamHeight - abs(END_BEAM_CENTER_ALT - cameraPosition.y)) / endBeamHeight;
    enderStars *= pow(VdotUM3, min1(beamFactor + 0.001) * min1(END_BEAM_HEIGHT));

    #if END_TWINKLING_STARS > 0
        enderStars *= getTwinklingStars(starCoord2, float(END_TWINKLING_STARS));
    #endif

    return enderStars * END_STAR_INTENSITY;
}

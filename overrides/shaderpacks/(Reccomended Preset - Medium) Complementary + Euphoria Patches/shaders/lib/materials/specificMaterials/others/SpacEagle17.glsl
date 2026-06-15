// SpacEagle17's custom skin indicator
#if defined GBUFFERS_ENTITIES || defined GBUFFERS_BLOCK
    #define TEXCOORD_FOR_SPACEAGLE17 texCoord
if (CheckForColor(texelFetch(tex, ivec2(0, 0), 0).rgb, vec3(233, 41, 209))) {
#else
    #define TEXCOORD_FOR_SPACEAGLE17 quadTexCoord
#endif
    vec3 hsv = rgb2hsv(colorP.rgb);
    float luminance = GetLuminance(colorP.rgb);
    if (TEXCOORD_FOR_SPACEAGLE17.y < 0.25) { // Head
        float blinkPhase = mod(frameTimeCounter, 7.0);
        float blink = 1.0 - smoothstep(0.08, 0.0, abs(blinkPhase - 0.04));
        if (hsv.g > 0.06) {  // Eyes
            emission = 7 * luminance * blink;
            color.rgb = mix(vec3(luminance), color.rgb, 0.85) * blink;
        }
    }
    #ifndef GBUFFERS_BLOCK
    else {
        if (TEXCOORD_FOR_SPACEAGLE17.x < 0.6 && hsv.g > 0.05) { // Legs
            if (hsv.r < 0.6) { // Portal
                float powVal = 1.0 + 3.0 * (cos(frameTimeCounter * 1.5) * 0.5 + 0.5);
                emission = 0.25 + pow4(luminance) * 4.0 * float(colorP.b > 0.8) + 3.0 * max(pow(hsv.g, powVal), 0.15);
            } else { // Lightning
                emission = 1.15 + (1.0 - hsv.g) * 1.2 * sin(frameTimeCounter * 2.5 + TEXCOORD_FOR_SPACEAGLE17.y * 6.2831);
            }
        }
    }
    #endif

    float emissionMask = 1.0 - step(0.001, emission);
    smoothnessD = (1.0 - pow2(colorP.g)) * 0.07 * emissionMask;
    smoothnessG = smoothnessD;
#if defined GBUFFERS_ENTITIES || defined GBUFFERS_BLOCK
}
#endif

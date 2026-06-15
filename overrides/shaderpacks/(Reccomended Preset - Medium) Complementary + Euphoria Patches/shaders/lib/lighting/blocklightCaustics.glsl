#ifdef DEFERRED1
    #define causticsTex colortex3
#else
    #define causticsTex gaux4
#endif

float GetBlocklightCaustics(vec3 worldGeoNormal, vec3 worldPos) {
    if (isEyeInWater == 1) {
        float causticTime = frameTimeCounter * 0.045;
        mat2 rot = rotate(causticTime * 35);

        vec3 absNormal = abs(worldGeoNormal);
        vec2 basePos = absNormal.y > max(absNormal.x, absNormal.z) ? worldPos.xz :
                    absNormal.x > absNormal.z ? worldPos.yz : worldPos.xy;

        basePos *= 1.35;

        // Opposing directional movement for the two layers
        vec2 causticWind1 = vec2(causticTime * 0.3, causticTime * 0.15);
        vec2 causticWind2 = vec2(-causticTime * 0.17, -causticTime * 0.22);

        vec2 cPos1 = basePos * 0.10 + causticWind1;
        vec2 cPos2 = basePos * 0.05 + causticWind2;

        float gradientNoise = fract(52.9829189 * fract(0.06711056 * gl_FragCoord.x + 0.00583715 * gl_FragCoord.y));
        #ifdef TAA
            gradientNoise = fract(gradientNoise + 0.618034 * mod(float(frameCounter), 3600.0));
        #endif

        float caustic = 0.0;
        int causticSamples = 4;

        for (int i = 0; i < causticSamples; i++) {
            vec2 offset1 = causticOffsetDist(gradientNoise + float(i), causticSamples);
            vec2 offset2 = causticOffsetDist(gradientNoise + float(i) + 0.5, causticSamples);

            offset1 = rot * offset1;
            offset2 = rot * offset2;

            vec4 sample1a = texture2D(causticsTex, cPos1 + offset1);
            vec4 sample1b = texture2D(causticsTex, cPos1 - offset1);
            vec4 sample2a = texture2D(causticsTex, cPos2 + offset2);
            vec4 sample2b = texture2D(causticsTex, cPos2 - offset2);

            float caustic1 = dot(sample1a.rg - sample1b.rg, vec2(6.0));
            float caustic2 = dot(sample2a.rg - sample2b.rg, vec2(6.0));

            caustic += caustic1 + caustic2;
        }

        caustic /= causticSamples;
        caustic = clamp(caustic, -0.15, 2.0) * 0.52 + 0.587;

        return caustic * WATER_CAUSTIC_STRENGTH;
    } else {
        return 1.0;
    }
}

#if defined GBUFFERS_TERRAIN || defined DH_TERRAIN || defined VOXY_PATCH
    float noise = -1.0 * LAVA_NOISE_AMOUNT;
    float lavaNoiseEmission = emission;
    float dhLavaSides = 0.0;
    #ifdef DH_TERRAIN
        dhLavaSides = 1.0 - clamp01(dot(worldGeoNormal, ViewToPlayer(upVec)));
    #endif
    if (mat == 10070
    #ifdef DH_TERRAIN
    || dhLavaSides > 0.5 // vertical lava columns
    #endif
    ) { // Flowing Lava
        lavaPos += wind.x * 0.75;
    }
    #if LAVA_VARIATION == 1 // Adaptive Noise
        lavaNoiseColor += min(pow2(pow2(lavaNoiseEmission * 0.50)), 0.2) * LAVA_TEMPERATURE * 0.65 + 0.1;
        #ifdef NETHER
            #ifdef DH_TERRAIN
            if ((worldPos.y > 30 && worldPos.y < 32.3 || (worldPos.y > 35 && worldPos.y < 37.3) && dhLavaSides < 0.5) && BLOCK_LAVA_STILL_DEFINE) { // lava lakes in the nether
            #else
            if ((worldPos.y > 30 && worldPos.y < 32.3 || (worldPos.y > 35 && worldPos.y < 37.3)) && BLOCK_LAVA_STILL_DEFINE) {
            #endif
                noise += texture2DLod(noisetex, lavaPos * 0.3 + wind * 0.1, 0.0).r;
                noise -= texture2DLod(noisetex, lavaPos * 10.1 + wind * 0.05, 0.0).g * 0.3;
                noise += texture2DLod(noisetex, lavaPos * 0.9 + wind * 0.04, 0.0).r * 0.5;
                noise *= texture2DLod(noisetex, lavaPos * 0.1 + wind * 0.02, 0.0).r * 0.5;
                lavaNoiseEmission *= 1.6;
                lavaNoiseColor *= smoothstep(0.00, 0.40, noise);
                lavaNoiseColor.r *= 1.2;
            } else {
                noise += texture2DLod(noisetex, lavaPos * 2.5 + wind * 0.01, 0.0).g;
                noise -= texture2DLod(noisetex, lavaPos * 10.1 + wind * 0.05, 0.0).g * 0.3;
                noise += texture2DLod(noisetex, lavaPos * 2.1, 0.0).g * 0.3;
                lavaNoiseColor *= smoothstep(0.0, 0.90, noise);
                lavaNoiseColor.r *= 1.25;
                lavaNoiseEmission *= 1.1;
            }
        #else
            if (worldPos.y > -56 && worldPos.y < -53.7 && BLOCK_LAVA_STILL_DEFINE) { // lava lakes in the Overworld, End not affected because no negative coords
                noise += texture2DLod(noisetex, lavaPos * 0.2 + wind * 0.1, 0.0).r;
                noise += texture2DLod(noisetex, lavaPos * 0.8 + wind * 0.04, 0.0).r * 0.5;
                noise *= texture2DLod(noisetex, lavaPos * 0.1 + wind * 0.02, 0.0).r * 0.5;
                lavaNoiseEmission *= 1.6;
                lavaNoiseColor *= smoothstep(0.00, 0.45, noise);
                lavaNoiseColor.r *= 1.2;
            } else {
                noise += texture2DLod(noisetex, lavaPos * 2.5 + wind * 0.01, 0.0).g;
                noise -= texture2DLod(noisetex, lavaPos * 10.1 + wind * 0.05, 0.0).g * 0.3;
                noise += texture2DLod(noisetex, lavaPos * 2.1, 0.0).g * 0.3;
                lavaNoiseColor *= smoothstep(0.0, 0.90, noise);
                lavaNoiseIntensity *= 0.5;
                lavaNoiseColor.r *= 1.25;
                lavaNoiseEmission *= 1.1;
            }
        #endif
    #elif LAVA_VARIATION == 2 // Blushing Hotness
        noise += texture2DLod(noisetex, lavaPos * 0.05 + wind * 0.1, 0.0).r;
        lavaNoiseColor -= vec3(0.03) * noise * 8.0;
        lavaNoiseColor += min(pow2(pow2(lavaNoiseEmission * 0.50)), 0.2) * LAVA_TEMPERATURE * 0.65 - 0.05;

    #elif LAVA_VARIATION == 3 // Molten Cheese
        lavaNoiseColor += vec3(min(pow2(pow2(pow2(smoothstep1(lavaNoiseEmission * 0.5)))), 0.25)) * LAVA_TEMPERATURE * 0.65 + 0.1;
        noise += texture2DLod(noisetex, lavaPos * 0.01 + wind * 0.01, 0.0).g;
        noise -= texture2DLod(noisetex, lavaPos * 2.0 + wind * 0.05, 0.0).g * 0.3;
        noise += texture2DLod(noisetex, lavaPos * 0.1, 0.0).g * 0.3;
        lavaNoiseColor *= smoothstep(0.00, 0.70, noise);
    #elif LAVA_VARIATION == 4 // Dark Islands
        lavaNoiseColor += vec3(min(pow2(pow2(pow2(smoothstep1(lavaNoiseEmission * 0.5)))), 0.25)) * LAVA_TEMPERATURE * 0.65 + 0.1;
        noise += texture2DLod(noisetex, lavaPos * 0.01 + wind * 0.01, 0.0).r;
        noise -= texture2DLod(noisetex, lavaPos * 1.1 + wind * 0.05, 0.0).r * 0.3;
        noise += texture2DLod(noisetex, lavaPos * 0.1, 0.0).r * 0.7;
        lavaNoiseColor *= smoothstep(0.00, 0.70, noise);
    #elif LAVA_VARIATION == 5 // Chaotic Flow
        lavaNoiseColor += min(pow2(pow2(lavaNoiseEmission * 0.50)), 0.2) * LAVA_TEMPERATURE * 0.65 + 0.1;
        noise += texture2DLod(noisetex, lavaPos * 1.0 + wind * 0.01, 0.0).g;
        noise -= texture2DLod(noisetex, lavaPos * 10.1 + wind * 0.05, 0.0).g * 0.3;
        noise += texture2DLod(noisetex, lavaPos * 2.1, 0.0).g * 0.3;
        lavaNoiseColor *= smoothstep(0.5, 0.70, noise);
        lavaNoiseColor.r *= 1.25;
        lavaNoiseEmission *= 1.1;
    #endif

    lavaNoiseColor = max(vec3(0.01), lavaNoiseColor); // prevent going too dark
    lavaNoiseColor = mix(color.rgb, lavaNoiseColor, lavaNoiseIntensity);
    emission = mix(emission, lavaNoiseEmission, lavaNoiseIntensity);
#endif

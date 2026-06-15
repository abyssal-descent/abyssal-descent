#define MOSS_NOISE_INTENSITY 1.0 //[0.5 0.75 1.0 1.25 1.5 2.0]
#define MOSS_NOISE_REMOVE_INTENSITY 1.00 //[0.00 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.60 1.70 1.80 1.90 2.00 2.25 2.50 2.75 3.00]
#define MOSS_TRANSPARENCY 0.85 // [0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 1.00]
#define MOSS_IN_CAVES 0 //[0 1 2] //lush caves, true, false
#define MOSS_SIDE_INTENSITY 10 //[0 1 2 3 4 5 6 7 8 9 10]
#define MOSS_NOISE_DISTANCE 1.0 //[0.5 1.0 1.5 2.0 2.5 3.0 3.5 4.0]
#define MOSS_SIZE 16 //[16 32 64 128]

#define SAND_CONDITION 0 //[0 1 2] 0 = dynamic 1 = only in hot biomes, 2 = everywhere
#define SAND_SIZE 16 //[16 32 64 128]
#define SAND_NOISE_INTENSITY 1.0 //[0.5 0.75 1.0 1.25 1.5 2.0]
#define SAND_NOISE_REMOVE_INTENSITY 1.00 //[0.00 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.60 1.70 1.80 1.90 2.00 2.25 2.50 2.75 3.00]
#define SAND_TRANSPARENCY 0.85 // [0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 1.00]
#define SAND_IN_CAVES true //[true false]
#define SAND_SIDE_INTENSITY 7 //[0 1 2 3 4 5 6 7 8 9 10]
#define SAND_NOISE_DISTANCE 1.0 //[0.5 1.0 1.5 2.0 2.5 3.0 3.5 4.0]

vec3 absPlayerPos = abs(playerPos);
float maxPlayerPosXZ = max(absPlayerPos.x, absPlayerPos.z);
#ifdef MOSS_NOISE_INTERNAL
    #if MOSS_IN_CAVES == 0
        float mossDecider = -clamp01(pow2(min1(maxPlayerPosXZ / (200 * MOSS_NOISE_DISTANCE)) * 2.0)) + 1.0; // The effect will only be around the player
    #else
        float mossDecider = 1.0;
    #endif
    if (mossDecider > 0.001){
        vec3 mossColor = mix(vec3(0.2745, 0.3412, 0.1412), vec3(0.451, 0.5804, 0.1255), float(hash33(floor(mod(worldPos, vec3(100.0)) * MOSS_SIZE + 0.03) * MOSS_SIZE)) * 0.15);
        #if MOSS_IN_CAVES < 2
            bool disableLight = true;
        #else
            bool disableLight = false;
        #endif

        #if MOSS_SIDE_INTENSITY == 0
            float mossSide = 0.0;
        #else
            float mossSide = MOSS_SIDE_INTENSITY * 0.1;
        #endif

        vec2 mossVec = getOverlayNoise(mossSide, disableLight, false, 0.1, MOSS_SIZE, worldPos, MOSS_TRANSPARENCY, MOSS_NOISE_REMOVE_INTENSITY * 1.5);

        float mossNoise = mossVec.y;
        float mossVariable = mossVec.x;

        #if MOSS_IN_CAVES == 0
            mossVariable *= inLushCave;
        #endif

        mossColor *= 1.1;
        mossColor += 0.13 * mossNoise * MOSS_NOISE_INTENSITY; // make the noise less noticeable & configurable with option

        #ifdef GBUFFERS_TERRAIN
            #if MOSS_IN_CAVES == 0
                emission *= mix(1.0, overlayNoiseEmission, inLushCave * overlayNoiseIntensity * mossNoiseIntensity);
                smoothnessG = mix(smoothnessG, 0.0, mossVariable * inLushCave * overlayNoiseIntensity * mossNoiseIntensity);
                #ifndef DH_TERRAIN
                smoothnessD = mix(smoothnessD, smoothnessG, mossVariable * inLushCave * overlayNoiseIntensity * mossNoiseIntensity);
                #endif
            #else
                emission *= mix(1.0, overlayNoiseEmission, overlayNoiseIntensity * mossNoiseIntensity);
                smoothnessG = mix(smoothnessG, 0.0, mossVariable * overlayNoiseIntensity * mossNoiseIntensity);
                #ifndef DH_TERRAIN
                smoothnessD = mix(smoothnessD, smoothnessG, mossVariable * overlayNoiseIntensity * mossNoiseIntensity);
                #endif
            #endif
        #endif

        #if MOSS_IN_CAVES == 0
            smoothnessG = mix(smoothnessG, max(smoothnessG, 0.3 * color.g * float(color.g > color.b * 1.5)), mossVariable * inLushCave * overlayNoiseIntensity * mossNoiseIntensity);
        #else
            smoothnessG = mix(smoothnessG, max(smoothnessG, 0.3 * color.g * float(color.g > color.b * 1.5)), mossVariable * overlayNoiseIntensity * mossNoiseIntensity);
        #endif

        #ifdef GBUFFERS_WATER
                #if MOSS_IN_CAVES == 0
                    overlayNoiseTransparentOverwrite = mix(overlayNoiseTransparentOverwrite, overlayNoiseAlpha, inLushCave);
                    fresnel = mix(fresnel, 0.01, mossVariable * overlayNoiseFresnelMult * inLushCave);
                #else
                    overlayNoiseTransparentOverwrite = overlayNoiseAlpha;
                    fresnel = mix(fresnel, 0.01, mossVariable * overlayNoiseFresnelMult);
                #endif
        #endif

        mossVariable *= mossDecider;

        color.rgb = mix(color.rgb, mossColor, mossVariable * overlayNoiseIntensity * mossNoiseIntensity * MOSS_TRANSPARENCY);
        color.a = mix(color.a, 1.0, clamp(overlayNoiseTransparentOverwrite * mossVariable * mossNoiseIntensity, 0.0, 1.0 * MOSS_TRANSPARENCY));
    }
#endif

#ifdef SAND_NOISE_INTERNAL
    #if SAND_CONDITION < 2
        float sandDecider = -clamp01(pow2(min1(maxPlayerPosXZ / (200 * SAND_NOISE_DISTANCE)) * 2.0)) + 1.0; // The effect will only be around the player
    #else
        float sandDecider = 1.0;
    #endif
    if (sandDecider > 0.001){
        #if SAND_CONDITION == 0
            float desertSandColorMixer = inSand + inRedSand;
            vec3 sandColor = mix(
                vec3(0.9216, 0.8353, 0.6196), (inSand * vec3(0.9216, 0.8353, 0.6196) + inRedSand * vec3(0.5843, 0.3412, 0.1569)), desertSandColorMixer);
        #else
            vec3 sandColor = vec3(0.9216, 0.8353, 0.6196);
        #endif

        #if SAND_SIDE_INTENSITY == 0
            float sandSide = 0.0;
        #else
            float sandSide = SAND_SIDE_INTENSITY * 0.1;
        #endif

        vec2 sandVec = getOverlayNoise(sandSide, SAND_IN_CAVES, true, 0.1, SAND_SIZE, worldPos, SAND_TRANSPARENCY, SAND_NOISE_REMOVE_INTENSITY * 2.0);

        float sandNoise = sandVec.y;
        float sandVariable = sandVec.x;

        #if SAND_CONDITION == 0
            sandVariable *= desertSandColorMixer;
        #elif SAND_CONDITION == 1
            sandVariable *= inDry;
        #endif

        sandColor *= 1.1;
        sandColor += 0.13 * sandNoise * SAND_NOISE_INTENSITY; // make the noise less noticeable & configurable with option

        #ifdef GBUFFERS_TERRAIN
            #if SAND_CONDITION == 0
                emission *= mix(1.0, overlayNoiseEmission, desertSandColorMixer * overlayNoiseIntensity * sandNoiseIntensity);
                smoothnessG = mix(smoothnessG, pow(color.g, 16.0) * 2.0, sandVariable * desertSandColorMixer * overlayNoiseIntensity * sandNoiseIntensity);
                smoothnessG = mix(smoothnessG, min1(smoothnessG), sandVariable * desertSandColorMixer * overlayNoiseIntensity * sandNoiseIntensity);
                #ifndef DH_TERRAIN
                smoothnessD = mix(smoothnessD, smoothnessG * 0.7, sandVariable * desertSandColorMixer * overlayNoiseIntensity * sandNoiseIntensity);
                #endif
                highlightMult = mix(highlightMult, 2.0, sandVariable * desertSandColorMixer * overlayNoiseIntensity * sandNoiseIntensity);
            #elif SAND_CONDITION == 1
                emission *= mix(1.0, overlayNoiseEmission, inDry * overlayNoiseIntensity * sandNoiseIntensity);
                smoothnessG = mix(smoothnessG, pow(color.g, 16.0) * 2.0, sandVariable * inDry * overlayNoiseIntensity * sandNoiseIntensity);
                smoothnessG = mix(smoothnessG, min1(smoothnessG), sandVariable * inDry * overlayNoiseIntensity * sandNoiseIntensity);
                #ifndef DH_TERRAIN
                smoothnessD = mix(smoothnessD, smoothnessG * 0.7, sandVariable * inDry * overlayNoiseIntensity * sandNoiseIntensity);
                #endif
                highlightMult = mix(highlightMult, 2.0, sandVariable * inDry * overlayNoiseIntensity * sandNoiseIntensity);
            #else
                emission *= overlayNoiseEmission;
                smoothnessG = mix(smoothnessG, pow(color.g, 16.0) * 2.0, sandVariable * overlayNoiseIntensity * sandNoiseIntensity);
                smoothnessG = mix(smoothnessG, min1(smoothnessG), sandVariable * overlayNoiseIntensity * sandNoiseIntensity);
                #ifndef DH_TERRAIN
                smoothnessD = mix(smoothnessD, smoothnessG * 0.7, sandVariable * overlayNoiseIntensity * sandNoiseIntensity);
                #endif
                highlightMult = mix(highlightMult, 2.0, sandVariable * overlayNoiseIntensity * sandNoiseIntensity);
            #endif
        #endif

        #ifdef GBUFFERS_WATER
            #if SAND_CONDITION == 0
                overlayNoiseTransparentOverwrite = mix(0.0, overlayNoiseAlpha, desertSandColorMixer);
                fresnel = mix(fresnel, 0.01, sandVariable * overlayNoiseFresnelMult * desertSandColorMixer);
            #elif SAND_CONDITION == 1
                overlayNoiseTransparentOverwrite = mix(0.0, overlayNoiseAlpha, inDry);
                fresnel = mix(fresnel, 0.01, sandVariable * overlayNoiseFresnelMult * inDry);
            #else
                overlayNoiseTransparentOverwrite = overlayNoiseAlpha;
                fresnel = mix(fresnel, 0.01, sandVariable * overlayNoiseFresnelMult);
            #endif
        #endif

        sandVariable *= sandDecider;

        color.rgb = mix(color.rgb, sandColor, sandVariable * overlayNoiseIntensity * sandNoiseIntensity * SAND_TRANSPARENCY);
        color.a = mix(color.a, 1.0, clamp(overlayNoiseTransparentOverwrite * sandVariable * overlayNoiseIntensity * sandNoiseIntensity * SAND_TRANSPARENCY, 0.0, 1.0));
    }
#endif
#if !defined AURORA_BOREALIS_GLSL
#define AURORA_BOREALIS_GLSL
#ifdef ATM_COLOR_MULTS
    #include "/lib/colors/colorMultipliers.glsl"
#endif
#include "/lib/util/colorConversion.glsl"

#define AURORA_COLOR_PRESET 0 //[-1 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14] // 0 is manual and default, 1 is daily, 2 is monthly and 3 is one color preset same with all numbers after

#define AURORA_UP_R 112 //[0 4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100 104 108 112 116 120 124 128 132 136 140 144 148 152 156 160 164 168 172 176 180 184 188 192 196 200 204 208 212 216 220 224 228 232 236 240 244 248 252 255]
#define AURORA_UP_G 36 //[0 4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100 104 108 112 116 120 124 128 132 136 140 144 148 152 156 160 164 168 172 176 180 184 188 192 196 200 204 208 212 216 220 224 228 232 236 240 244 248 252 255]
#define AURORA_UP_B 192 //[0 4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100 104 108 112 116 120 124 128 132 136 140 144 148 152 156 160 164 168 172 176 180 184 188 192 196 200 204 208 212 216 220 224 228 232 236 240 244 248 252 255]
#define AURORA_UP_I 33 //[0 3 5 8 10 13 15 18 20 23 25 28 30 33 35 38 40 43 45 48 50 53 55 58 60 63 65 68 70 73 75 78 80 83 85 88 90 93 95 98 100]

#define AURORA_DOWN_R 96 //[0 4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100 104 108 112 116 120 124 128 132 136 140 144 148 152 156 160 164 168 172 176 180 184 188 192 196 200 204 208 212 216 220 224 228 232 236 240 244 248 252 255]
#define AURORA_DOWN_G 255 //[0 4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100 104 108 112 116 120 124 128 132 136 140 144 148 152 156 160 164 168 172 176 180 184 188 192 196 200 204 208 212 216 220 224 228 232 236 240 244 248 252 255]
#define AURORA_DOWN_B 192 //[0 4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100 104 108 112 116 120 124 128 132 136 140 144 148 152 156 160 164 168 172 176 180 184 188 192 196 200 204 208 212 216 220 224 228 232 236 240 244 248 252 255]
#define AURORA_DOWN_I 33 //[0 3 5 8 10 13 15 18 20 23 25 28 30 33 35 38 40 43 45 48 50 53 55 58 60 63 65 68 70 73 75 78 80 83 85 88 90 93 95 98 100]

#define AURORA_SIZE 1.00 //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00 2.05 2.10 2.15 2.20 2.25 2.30 2.35 2.40 2.45 2.50 2.55 2.60 2.65 2.70 2.75 2.80 2.85 2.90 2.95 3.00]

//#define RGB_AURORA

#define AURORA_CLOUD_INFLUENCE_INTENSITY 1.00 //[0.00 0.25 0.50 0.75 1.00 1.25 1.50 1.75 2.00 2.50 3.00]
#define AURORA_TERRAIN_INFLUENCE_INTENSITY 1.00 //[0.00 0.25 0.50 0.75 1.00 1.25 1.50]

#define AURORA_NOISE_SCALE 1.00 //[0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00 2.05 2.10 2.15 2.20 2.25 2.30 2.35 2.40 2.45 2.50 2.55 2.60 2.65 2.70 2.75 2.80 2.85 2.90 2.95 3.00 3.05 3.10 3.15 3.20 3.25 3.30 3.35 3.40 3.45 3.50 3.55 3.60 3.65 3.70 3.75 3.80 3.85 3.90 3.95 4.00 4.05 4.10 4.15 4.20 4.25 4.30 4.35 4.40 4.45 4.50 4.55 4.60 4.65 4.70 4.75 4.80 4.85 4.90 4.95 5.00]
#define AURORA_PATTERN_WARP 0 //[0 1 2 3 4 5 6 7 8 9 10]
#define AURORA_SATURATION 10 //[0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20]
#define AURORA_COLOR_MIX_POWER 2.0 //[0.5 1.0 1.5 2.0 2.5 3.0 3.5 4.0 4.5 5.0]

#include "/lib/atmospherics/auroraBorealisVisibility.glsl"

vec3 auroraUpA[] = vec3[](
    vec3(112.0, 36.0, 192.0),   // [1] [2] Complementary
    vec3(112.0, 80.0, 255.0),   // [3] Legacy Complementary (v4)
    vec3(168.0, 36.0, 88.0),    // [4] permafrost
    vec3(255.0, 68.0, 124.0),   // [5] Blossoming Lights (Pink)
    vec3(72.0, 96.0, 192.0),    // [6] Nebula
    vec3(24.0, 255.0, 140.0),   // [7] Celestial Dance
    vec3(255.0, 220.0, 255.0),  // [8] Green Flash
    vec3(64.0, 255.0, 255.0),   // [9] Ethereal Lights
    vec3(0.0, 20.0, 60.0),      // [10] Glacial Blessing
    vec3(132.0, 0.0, 200.0),    // [11] Mythical Lights
    vec3(120.0, 212.0, 56.0),   // [12] watermelon
    vec3(0.0, 255.0, 255.0),    // [13] blood bath
    vec3(255.0, 80.0, 112.0)    // [14] Ghost
);
vec3 auroraDownA[] = vec3[](
    vec3(96.0, 255.0, 192.0),   // [1] [2] Complementary
    vec3(80.0, 255.0, 180.0),   // [3] Legacy Complementary (v4)
    vec3(60.0, 184.0, 152.0),   // [4] permafrost
    vec3(160.0, 96.0, 255.0),   // [5] Blossoming Lights (Pink)
    vec3(172.0, 44.0, 88.0),    // [6] Nebula
    vec3(108.0, 72.0, 255.0),   // [7] Celestial Dance
    vec3(68.0, 255.0, 72.0),    // [8] Green Flash
    vec3(128.0, 64.0, 128.0),   // [9] Ethereal Lights
    vec3(0.0, 24.0, 36.0),      // [10] Glacial Blessing
    vec3(56.0, 168.0, 255.0),   // [11] Mythical Lights
    vec3(176.0, 88.0, 72.0),    // [12] watermelon
    vec3(180.0, 0.0, 0.0),      // [13] blood bath
    vec3(80.0, 255.0, 180.0)    // [14] Ghost
);

vec2 warpAuroraCoords(vec2 coord, float warpAmount) {
    float angle = texture2D(noisetex, coord * 0.5).r * 6.28318 * warpAmount;
    float strength = texture2D(noisetex, coord * 0.7 + 0.5).r * warpAmount;
    vec2 offset = vec2(cos(angle), sin(angle)) * strength;
    return coord + offset;
}

void GetAuroraColor(in vec2 wpos, out vec3 auroraUp, out vec3 auroraDown) {
    #ifdef RGB_AURORA
        auroraUp = getRainbowColor(wpos, 0.06);
        auroraDown = getRainbowColor(wpos, 0.05);
    #elif AURORA_COLOR_PRESET == 0
        auroraUp = vec3(AURORA_UP_R, AURORA_UP_G, AURORA_UP_B);
        auroraDown = vec3(AURORA_DOWN_R, AURORA_DOWN_G, AURORA_DOWN_B);
    #elif AURORA_COLOR_PRESET == -1
        float randomValue = hash11(float(worldDay));
        randomValue = pow(randomValue, 0.7); // Bias towards higher values (more transitions)
        float transitionsPerNight = min(randomValue * 2.0, 1.75);
        float idx, frac = modf(nightFactor * transitionsPerNight, idx);

        int dayOffset = worldDay % auroraUpA.length();

        int colorsCount = auroraUpA.length();
        int i0 = (int(idx) + dayOffset) % colorsCount;
        int i1 = (i0 + 1) % colorsCount;

        // Interpolate in OKLab color space for perceptually uniform transitions
        vec3 oklabUp0 = rgb2oklab(auroraUpA[i0] / 255.0);
        vec3 oklabUp1 = rgb2oklab(auroraUpA[i1] / 255.0);
        vec3 oklabDown0 = rgb2oklab(auroraDownA[i0] / 255.0);
        vec3 oklabDown1 = rgb2oklab(auroraDownA[i1] / 255.0);

        auroraUp = oklab2rgb(mix(oklabUp0, oklabUp1, frac)) * 255.0;
        auroraDown = oklab2rgb(mix(oklabDown0, oklabDown1, frac)) * 255.0;
    #else
        #if AURORA_COLOR_PRESET == 1
            int p = worldDay % auroraUpA.length();
        #elif AURORA_COLOR_PRESET == 2
            int p = worldDay % (auroraUpA.length() * 8) / 8;
        #else
            const int p = AURORA_COLOR_PRESET - 2;
        #endif

        auroraUp = auroraUpA[p];
        auroraDown = auroraDownA[p];
    #endif
    auroraUp = max(auroraUp, vec3(0.001));
    auroraDown = max(auroraDown, vec3(0.001));

    auroraUp *= (AURORA_UP_I * 0.093 + 3.1) / GetLuminance(auroraUp);
    auroraDown *= (AURORA_DOWN_I * 0.245 + 8.15) / GetLuminance(auroraDown);

    #if AURORA_SATURATION != 10
        auroraUp = rgb2hsv(auroraUp);
        auroraUp.g *= AURORA_SATURATION * 0.1;
        auroraUp = hsv2rgb(auroraUp);

        auroraDown = rgb2hsv(auroraDown);
        auroraDown.g *= AURORA_SATURATION * 0.1;
        auroraDown = hsv2rgb(auroraDown);
    #endif
}

vec3 getAuroraAmbientColor(vec3 color, vec3 viewPos, float multiplier, float influence, float VdotUAmount) {
    float visibility = GetAuroraVisibility(0.5, VdotUAmount);
    if (visibility > 0) {
        vec3 wpos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
        wpos.xz /= (abs(wpos.y) + length(wpos.xz));

        vec3 auroraUp, auroraDown;
        GetAuroraColor(wpos.xz, auroraUp, auroraDown);

        vec3 auroraColor = mix(auroraUp, auroraDown, 0.8);
        #ifdef COMPOSITE1
            visibility *= influence;
            return mix(color, auroraColor, visibility);
        #endif
        auroraColor *= multiplier;
        visibility *= influence;
        #ifdef DEFERRED1
            return mix(color, saturateColors(auroraColor, 0.8) * visibility * 0.45, visibility);
        #endif
        float luminanceColor = GetLuminance(color);
        vec3 newColor = mix(color, mix(color, vec3(luminanceColor), 0.88), visibility);
        newColor *= mix(vec3(1.0), auroraColor * luminanceColor * 10.0, visibility);
        return clamp01(newColor);
        // return mix(color, color * auroraColor, visibility); // old, keep it for now
    }
    return color;
}

vec3 GetAuroraBorealis(vec3 viewPos, float VdotU, float dither) {
    float visibility = GetAuroraVisibility(VdotU, 1.0);

    if (visibility > 0.0) {
        vec3 aurora = vec3(0.0);

        vec3 wpos = mat3(gbufferModelViewInverse) * viewPos;
             wpos.xz /= wpos.y;
        vec2 cameraPositionM = cameraPosition.xz * 0.0075;
             cameraPositionM.x += syncedTime * 0.04;

        #ifdef DEFERRED1
            int sampleCount = 25;
            int sampleCountP = sampleCount + 5;
        #else
            int sampleCount = 10;
            int sampleCountP = sampleCount + 10;
        #endif

        float ditherM = dither + 5.0;
        float auroraAnimate = frameTimeCounter * 0.001;

        vec3 auroraUp, auroraDown;
        GetAuroraColor(wpos.xz, auroraUp, auroraDown);

        for (int i = 0; i < sampleCount; i++) {
            float current = pow2((i + ditherM) / sampleCountP);

            vec2 planePos = wpos.xz * (AURORA_SIZE * 0.8 + current) * 11.0 * AURORA_NOISE_SCALE + cameraPositionM;

            #if AURORA_STYLE == 1
                planePos = floor(planePos) * 0.0007;

                #if AURORA_PATTERN_WARP > 0
                    planePos = warpAuroraCoords(planePos, AURORA_PATTERN_WARP * 0.0057);
                #endif

                float noise = texture2DLod(noisetex, planePos, 0.0).b;
                noise = pow2(pow2(pow2(pow2(1.0 - 2.0 * abs(noise - 0.5)))));

                noise *= pow1_5(texture2DLod(noisetex, planePos * 100.0 + auroraAnimate, 0.0).b);
            #else
                planePos *= 0.0007;

                #if AURORA_PATTERN_WARP > 0
                    planePos = warpAuroraCoords(planePos, AURORA_PATTERN_WARP * 0.0082);
                #endif

                float noise = texture2DLod(noisetex, planePos, 0.0).r;
                noise = pow2(pow2(pow2(pow2(1.0 - 2.0 * abs(noise - 0.5)))));

                noise *= texture2DLod(noisetex, planePos * 3.0 + auroraAnimate, 0.0).b;
                noise *= texture2DLod(noisetex, planePos * 5.0 - auroraAnimate, 0.0).b;
            #endif

            float currentM = 1.0 - current;

            aurora += noise * currentM * mix(auroraUp, auroraDown, pow(pow2(currentM), AURORA_COLOR_MIX_POWER));
        }

        #if AURORA_STYLE == 1
            aurora *= 1.3;
        #else
            aurora *= 1.8;
        #endif

        #ifdef ATM_COLOR_MULTS
            aurora *= sqrtAtmColorMult; // C72380KD - Reduced atmColorMult impact on some things
        #endif

        return aurora * visibility / sampleCount;
    }

    return vec3(0.0);
}
#endif

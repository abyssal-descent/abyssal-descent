#ifndef WORLD_MOTION_BLUR_SETTINGS_FILE
#define WORLD_MOTION_BLUR_SETTINGS_FILE

#include "/lib/shaderSettings/bloom.glsl"

#define WORLD_BLUR 0 //[0 1 2]

//#define MOTION_BLURRING
#define MOTION_BLURRING_STRENGTH 1.00 //[0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]

// Euphoria Patches Settings

#define TILT_SHIFT 0 //[-20 -19 -18 -17 -16 -15 -14 -13 -12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20]
#define TILT_SHIFT2 0 //[-20 -19 -18 -17 -16 -15 -14 -13 -12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20]

#ifdef BLOOM_FOG
    #if WORLD_BLUR > 0 || TILT_SHIFT != 0 || TILT_SHIFT2 != 0
        #define BLOOM_FOG_COMPOSITE3
    #elif defined MOTION_BLURRING
        #define BLOOM_FOG_COMPOSITE2
    #else
        #define BLOOM_FOG_COMPOSITE
    #endif
#endif

#endif
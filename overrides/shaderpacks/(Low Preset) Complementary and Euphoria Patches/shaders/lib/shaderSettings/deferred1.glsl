#ifndef DEFERRED1_SETTINGS_FILE
#define DEFERRED1_SETTINGS_FILE

#include "/lib/shaderSettings/SSAO.glsl"

// Euphoria Patches

//#define BEDROCK_NOISE

#define NETHER_NOISE 0 //[0 1]

//#define END_SMOKE

#define EP_END_FLASH 0 //[0 1 2]
#ifdef EP_END_FLASH
#endif

//#define PALETTE_SWAP
#define PIXELATED_SCREEN_SIZE 0 //[0 8 10 12 14 16 20 24 28 32 48 64]
#ifdef PALETTE_SWAP
    #define PIXELATED_SCREEN_SIZE_INTERNAL (PIXELATED_SCREEN_SIZE * 2)
#else
    #define PIXELATED_SCREEN_SIZE_INTERNAL PIXELATED_SCREEN_SIZE
#endif

#define DISTANT_HORIZONS_SSAO
#ifdef DISTANT_HORIZONS_SSAO
#endif

#endif

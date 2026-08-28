/*---------------------------------------------------------------------
         ___ __  __ ____   ___  ____ _____  _    _   _ _____
        |_ _|  \/  |  _ \ / _ \|  _ \_   _|/ \  | \ | |_   _|
         | || |\/| | |_) | | | | |_) || | / _ \ |  \| | | |
         | || |  | |  __/| |_| |  _ < | |/ ___ \| |\  | | |
        |___|_|  |_|_|    \___/|_| \_\|_/_/   \_\_| \_| |_|

  -> -> -> EDITING THIS FILE HAS A HIGH CHANCE TO BREAK THE SHADER PACK
  -> -> -> DO NOT CHANGE ANYTHING UNLESS YOU KNOW WHAT YOU ARE DOING
  -> -> -> DO NOT EXPECT SUPPORT AFTER MODIFYING SHADER FILES
---------------------------------------------------------------------*/

// PLEASE NOTE:
// Euphoria Patches moves a lot of the shader settings to the shaderSettings folder.

//User Settings//
    #define SHADER_STYLE 4 //[1 4]

    #define RP_MODE 1 //[1 0 3 2]

    #define SHADOW_QUALITY 2 //[-1 0 1 2 3 4 5]
    const float shadowDistance = 192.0; //[64.0 80.0 96.0 112.0 128.0 160.0 192.0 224.0 256.0 320.0 384.0 512.0 768.0 1024.0]
    #define ENTITY_SHADOWS_DEFINE -1 //[-1 1]
    #define FXAA_DEFINE 1 //[-1 1]
    #define DETAIL_QUALITY 2 //[0 2 3]
    #define CLOUD_QUALITY 2 //[0 1 2 3]
    #define LIGHTSHAFT_QUALI_DEFINE 2 //[0 1 2 3 4]
    #define WATER_REFLECT_QUALITY 2 //[-1 0 1 2]
    #define BLOCK_REFLECT_QUALITY 3 //[0 1 2 3]
    #define ANISOTROPIC_FILTER 0 //[0 4 8 16]

    #define COLORED_LIGHTING 0 //[128 192 256 384 512 768 1024]
    #if defined IRIS_FEATURE_CUSTOM_IMAGES && SHADOW_QUALITY > -1 && !defined MC_OS_MAC && !(defined DH_TERRAIN || defined DH_WATER)
        #define COLORED_LIGHTING_INTERNAL COLORED_LIGHTING
        #if COLORED_LIGHTING_INTERNAL > 0
            #define COLORED_LIGHT_SATURATION 100 //[50 55 60 65 70 75 80 85 90 95 100 105 110 115 120 125]

            #define COLORED_LIGHT_FOG
            #define COLORED_LIGHT_FOG_I 0.65 //[0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50]

            #define PORTAL_EDGE_EFFECT
            #ifndef IRIS_HAS_CONNECTED_TEXTURES
                #define CONNECTED_GLASS_EFFECT
            #endif
            #define LAVA_EDGE_EFFECT 0 //[0 1 2]
            //#define CAVE_SMOKE
        #endif
    #else
        #define COLORED_LIGHTING_INTERNAL 0
    #endif

    //#define COLORED_CANDLE_LIGHT

    #define WATER_STYLE_DEFINE -1 //[-1 1 2 3]
    #define WATER_CAUSTIC_STYLE_DEFINE -1 //[-1 1 3]
    #define WATER_REFRACTION_INTENSITY 2.0 //[0.0 0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 3.0]
    #define WATER_FOG_MULT 100 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300 325 350 375 400 425 450 475 500 550 600 650 700 750 800 850 900]
    #define WATERCOLOR_MODE 3 //[3 2 0]
    #define WATERCOLOR_R 100 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300]
    #define WATERCOLOR_G 100 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300]
    #define WATERCOLOR_B 100 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300]
    #define UNDERWATERCOLOR_R 100 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150]
    #define UNDERWATERCOLOR_G 100 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150]
    #define UNDERWATERCOLOR_B 100 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150]
    #define WATER_SPEED_MULT 1.10 //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00 2.20 2.40 2.60 2.80 3.00 3.25 3.50 3.75 4.00 4.50 5.00]

    #define SHADOW_SMOOTHING 4 //[1 2 3 4]
    #define RAIN_PUDDLES 0 //[0 1 2 3 4]

    #define AURORA_STYLE_DEFINE -1 //[-1 0 1 2]
    #define AURORA_CONDITION 3 //[0 1 2 3 4]
    //#define NIGHT_NEBULA
    #define NIGHT_NEBULA_I 100 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300]
    #define WEATHER_TEX_OPACITY 100 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300 325 350 375 400 425 450 475 500 550 600 650 700 750 800 850 900]
    #define SPECIAL_BIOME_WEATHER
    #define RAIN_STYLE 1 //[1 2]
    #define SUN_MOON_STYLE_DEFINE -1 //[-1 1 2 3]
    #define SUN_MOON_HORIZON
    #define SUN_MOON_DURING_RAIN
    #define CLOUD_STYLE_DEFINE -1 //[-1 0 1 3 50]
    //#define CLOUD_SHADOWS
    #define CLOUD_ALT1 192 //[-96 -92 -88 -84 -80 -76 -72 -68 -64 -60 -56 -52 -48 -44 -40 -36 -32 -28 -24 -20 -16 -10 -8 -4 0 4 8 12 16 20 22 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100 104 108 112 116 120 124 128 132 136 140 144 148 152 156 160 164 168 172 176 180 184 188 192 196 200 204 208 212 216 220 224 228 232 236 240 244 248 252 256 260 264 268 272 276 280 284 288 292 296 300 304 308 312 316 320 324 328 332 336 340 344 348 352 356 360 364 368 372 376 380 384 388 392 396 400 404 408 412 416 420 424 428 432 436 440 444 448 452 456 460 464 468 472 476 480 484 488 492 496 500 510 520 530 540 550 560 570 580 590 600 610 620 630 640 650 660 670 680 690 700 710 720 730 740 750 760 770 780 790 800]
    #define CLOUD_SPEED_MULT 100 //[0 5 7 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300 325 350 375 400 425 450 475 500 550 600 650 700 750 800 850 900]

    #define CLOUD_UNBOUND_SIZE_MULT 100 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300]

    //#define DOUBLE_REIM_CLOUDS
    #define CLOUD_ALT2 288 //[-96 -92 -88 -84 -80 -76 -72 -68 -64 -60 -56 -52 -48 -44 -40 -36 -32 -28 -24 -20 -16 -10 -8 -4 0 4 8 12 16 20 22 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100 104 108 112 116 120 124 128 132 136 140 144 148 152 156 160 164 168 172 176 180 184 188 192 196 200 204 208 212 216 220 224 228 232 236 240 244 248 252 256 260 264 268 272 276 280 284 288 292 296 300 304 308 312 316 320 324 328 332 336 340 344 348 352 356 360 364 368 372 376 380 384 388 392 396 400 404 408 412 416 420 424 428 432 436 440 444 448 452 456 460 464 468 472 476 480 484 488 492 496 500 510 520 530 540 550 560 570 580 590 600 610 620 630 640 650 660 670 680 690 700 710 720 730 740 750 760 770 780 790 800]

    #define NETHER_VIEW_LIMIT 256.0 //[96.0 112.0 128.0 160.0 192.0 224.0 256.0 320.0 384.0 512.0 768.0 1024.0 99999.0]
    #define NETHER_COLOR_MODE 3 //[3 2 0]

    #define BORDER_FOG
    #define ATM_FOG_MULT 0.95 //[0.50 0.65 0.80 0.95]
    #define ATM_FOG_DISTANCE 100 //[10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300]
    #define ATM_FOG_ALTITUDE 63 //[0 5 10 15 20 25 30 35 40 45 50 52 54 56 58 60 61 62 63 64 65 66 67 68 69 70 72 74 76 78 80 85 90 95 100 105 110 115 120 125 130 135 140 145 150 155 160 165 170 175 180 185 190 195 200 210 220 230 240 250 260 270 280 290 300]
    #define CAVE_FOG
    #define LIGHTSHAFT_BEHAVIOUR 1 //[0 1 2 3]
    
    #define LENSFLARE_MODE 0 //[0 1 2]
    #define LENSFLARE_I 1.00 //[0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00 2.20 2.40 2.60 2.80 3.00 3.25 3.50 3.75 4.00 4.25 4.50 4.75 5.00]
    #define TAA_MODE 1 //[1 2 0]
    #define DISTANT_LIGHT_BOKEH

    #define IPBR_EMISSIVE_MODE 1 //[1 3 2]
    //#define IPBR_COMPATIBILITY_MODE

    #define NORMAL_MAP_STRENGTH 100 //[0 10 15 20 30 40 60 80 100 120 140 160 180 200]
    #define CUSTOM_EMISSION_INTENSITY 100 //[0 5 7 10 15 20 25 30 35 40 45 50 60 70 80 90 100 110 120 130 140 150 160 170 180 190 200 225 250]
    #define POM_DEPTH 0.80 //[0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]
    #define POM_QUALITY 128 //[16 32 64 128 256 512]
    #define POM_DISTANCE 32 //[16 24 32 48 64 128 256 512 1024]
    #define POM_LIGHTING_MODE 2 //[1 2]
    //#define POM_ALLOW_CUTOUT
    #define DIRECTIONAL_BLOCKLIGHT 0 //[0 3 7 11]

    #define CAVE_LIGHTING 100 //[0 5 7 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300 325 350 375 400 425 450 475 500 550 600 650 700 750 800 850 900 950 1000 1100 1200 1300 1400 1500 1600]

    #define WAVING_RAIN

    #define SPECIAL_PORTAL_EFFECTS

    #define SUN_ANGLE -1 //[-1 0 -20 -30 -40 -50 -60 60 50 40 30 20]

    #define SELECT_OUTLINE 1 //[0 1 3 4 2]
    //#define SELECT_OUTLINE_AUTO_HIDE
    #define SELECT_OUTLINE_I 1.00 //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00 2.20 2.40 2.60 2.80 3.00 3.25 3.50 3.75 4.00 4.50 5.00]
    #define SELECT_OUTLINE_R 1.35 //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]
    #define SELECT_OUTLINE_G 0.35 //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]
    #define SELECT_OUTLINE_B 1.75 //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]

    //#define WORLD_OUTLINE
    #define WORLD_OUTLINE_THICKNESS 1 //[1 2 3 4]
    #define WORLD_OUTLINE_I 1.50 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00 2.20 2.40 2.60 2.80 3.00 3.25 3.50 3.75 4.00]
    #define WORLD_OUTLINE_ON_ENTITIES
    //#define DARK_OUTLINE
    #define DARK_OUTLINE_THICKNESS 1 //[1 2]

    #define HAND_SWAYING 0 //[0 1 2 3]
    #define SHOW_LIGHT_LEVEL 0 //[0 1 2 3]
    //#define REDUCE_CLOSE_PARTICLES
    //#define SNOWY_WORLD
    //#define COLOR_CODED_PROGRAMS

    //#define MOON_PHASE_INF_ATMOSPHERE
    #define MOON_PHASE_INF_REFLECTION
    #define MOON_PHASE_FULL 1.00 //[0.01 0.03 0.05 0.07 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define MOON_PHASE_PARTIAL 0.85 //[0.01 0.03 0.05 0.07 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define MOON_PHASE_DARK 0.60 //[0.01 0.03 0.05 0.07 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]

    //#define PIXELATED_SHADOWS
    //#define PIXELATED_BLOCKLIGHT
    //#define PIXELATED_AO
    #define PIXEL_SCALE 1 //[-2 -1 1 2 3 4 5]

    //#define LIGHT_COLOR_MULTS
    //#define ATM_COLOR_MULTS

    #define XLIGHT_R 1.00 //[0.01 0.03 0.05 0.07 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define XLIGHT_G 1.00 //[0.01 0.03 0.05 0.07 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define XLIGHT_B 1.00 //[0.01 0.03 0.05 0.07 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
    #define XLIGHT_I 1.00 //[0.01 0.03 0.05 0.07 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]

    //#define DREAM_TWEAKED_LIGHTING
    //#define DREAM_TWEAKED_BORDERFOG
    //#define FOLIAGE_ALT_SUBSURFACE



//════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
// ███████╗██╗   ██╗██████╗ ██╗  ██╗ ██████╗ ██████╗ ██╗ █████╗     ██████╗  █████╗ ████████╗ ██████╗██╗  ██╗███████╗███████╗
// ██╔════╝██║   ██║██╔══██╗██║  ██║██╔═══██╗██╔══██╗██║██╔══██╗    ██╔══██╗██╔══██╗╚══██╔══╝██╔════╝██║  ██║██╔════╝██╔════╝
// █████╗  ██║   ██║██████╔╝███████║██║   ██║██████╔╝██║███████║    ██████╔╝███████║   ██║   ██║     ███████║█████╗  ███████╗
// ██╔══╝  ██║   ██║██╔═══╝ ██╔══██║██║   ██║██╔══██╗██║██╔══██║    ██╔═══╝ ██╔══██║   ██║   ██║     ██╔══██║██╔══╝  ╚════██║
// ███████╗╚██████╔╝██║     ██║  ██║╚██████╔╝██║  ██║██║██║  ██║    ██║     ██║  ██║   ██║   ╚██████╗██║  ██║███████╗███████║
// ╚══════╝ ╚═════╝ ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝    ╚═╝     ╚═╝  ╚═╝   ╚═╝    ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝
// by SpacEagle17



////////////////////////////////////////////////
// ╔═════════════════════════════════════════╗//
// ║                                         ║//
// ║    █████████████████████████████████    ║//
// ║    ██ ▄▄▄▄▄ █▀▄▄▄ █ ▀█▀▀▄ █ ▄▄▄▄▄ ██    ║//
// ║    ██ █   █ █▀▄ ▄█▀▀▀▀▀▀█▄█ █   █ ██    ║//
// ║    ██ █▄▄▄█ █▀▀█▄▄▀▄▀▄ ▄▄▄█ █▄▄▄█ ██    ║//
// ║    ██▄▄▄▄▄▄▄█▄▀▄▀ █ ▀▄█ █▄█▄▄▄▄▄▄▄██    ║//
// ║    ██▄ ▄▄▄█▄▄▄   ▄▄ █▀▄▀ ▀ ▀ ▀▄█▄▀██    ║//
// ║    ██ █  ▀ ▄█▄ █▀███▄▄▄▄▀▄█ █▄▀█▀███    ║//
// ║    ██▀▄▄ ██▄█  █▀▀▄▄▄▄ ▀▀▀█▀▀▀▄▄█▀██    ║//
// ║    ██▄▀▄█ ▀▄▄▀▀▄█▀█▀ ▀▄██▀ ▀█ ▄▄▀███    ║//
// ║    ██ █▄▄█ ▄ █▀ ▀▀▄▄▀▀ ▀▀ ▀▀ ▀▄ █▀██    ║//
// ║    ██ ██  █▄▄█▄▀██▄▀▄ ███▄▄▄  █▄▀███    ║//
// ║    ██▄█▄▄██▄▄▀▄ ▀▄▄▄▄▄  █ ▄▄▄ ▀   ██    ║//
// ║    ██ ▄▄▄▄▄ █▄▄▀█▄█ ▄ ▄█  █▄█ ▄▄████    ║//
// ║    ██ █   █ █ ▀▀ ▄▄▄▄ ▀██▄▄▄ ▄▀ █▀██    ║//
// ║    ██ █▄▄▄█ █ ▀ ▀██▀ ▄█ ▀▀ ▄   ▄ ███    ║//
// ║    ██▄▄▄▄▄▄▄█▄█▄█▄▄▄█▄▄▄▄███▄▄█▄████    ║//
// ║    █████████████████████████████████    ║//
// ║               Potato is always watching ║//
// ╚═════════════════════════════════════════╝//
////////////////////////////////////////////////
    //#define DAYLIGHT_CYCLE_COMPAT
    //#define FROZEN_TIME

    //#define AURORA_INFLUENCE

    //#define HIGH_QUALITY_CLOUDS
    #define INCREASED_RAIN_STRENGTH 0 //[0 1 2]

    #define E_SKY_COLORR 24.225 //[0.0 4.0 8.0 12.0 16.0 20.0 24.0 24.225 28.0 32.0 36.0 40.0 44.0 48.0 52.0 56.0 60.0 64.0 68.0 72.0 76.0 80.0 84.0 88.0 92.0 96.0 100.0 104.0 108.0 112.0 116.0 120.0 124.0 128.0 132.0 136.0 140.0 144.0 148.0 152.0 156.0 160.0 164.0 168.0 172.0 176.0 180.0 184.0 188.0 192.0 196.0 200.0 204.0 208.0 212.0 216.0 220.0 224.0 228.0 232.0 236.0 240.0 244.0 248.0 252.0 255.0]
    #define E_SKY_COLORG 17.85 //[0.0 4.0 8.0 12.0 16.0 17.85 20.0 24.0 28.0 32.0 36.0 40.0 44.0 48.0 52.0 56.0 60.0 64.0 68.0 72.0 76.0 80.0 84.0 88.0 92.0 96.0 100.0 104.0 108.0 112.0 116.0 120.0 124.0 128.0 132.0 136.0 140.0 144.0 148.0 152.0 156.0 160.0 164.0 168.0 172.0 176.0 180.0 184.0 188.0 192.0 196.0 200.0 204.0 208.0 212.0 216.0 220.0 224.0 228.0 232.0 236.0 240.0 244.0 248.0 252.0 255.0]
    #define E_SKY_COLORB 38.25 //[0.0 4.0 8.0 12.0 16.0 20.0 24.0 28.0 32.0 36.0 38.25 40.0 44.0 48.0 52.0 56.0 60.0 64.0 68.0 72.0 76.0 80.0 84.0 88.0 92.0 96.0 100.0 104.0 108.0 112.0 116.0 120.0 124.0 128.0 132.0 136.0 140.0 144.0 148.0 152.0 156.0 160.0 164.0 168.0 172.0 176.0 180.0 184.0 188.0 192.0 196.0 200.0 204.0 208.0 212.0 216.0 220.0 224.0 228.0 232.0 236.0 240.0 244.0 248.0 252.0 255.0]
    #define E_SKY_COLORI 1.50 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]
    #define END_SKY_FOG_INFLUENCE 1.00 // [0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00]

    //#define DRAGON_DEATH_EFFECT
    #define END_CRYSTAL_VORTEX 0 //[0 1 2 3]
    //#define END_PORTAL_BEAM

    //#define BIOME_COLORED_NETHER_PORTALS

    //#define MIRROR_DIMENSION
    //#define WORLD_CURVATURE

    //#define RAIN_ATMOSPHERE

    #define CLOUD_NARROWNESS 0.05 //[0.1 0.075 0.05 0.025]

    #define NETHER_BRIGHTNESS 1.0 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0]

    //#define REDSTONE_IPBR
    #define REDSTONE_IPBR_R 1.000 //[0.000 0.010 0.020 0.030 0.040 0.050 0.060 0.070 0.080 0.090 0.100 0.110 0.120 0.130 0.140 0.150 0.160 0.170 0.180 0.190 0.200 0.210 0.220 0.230 0.240 0.250 0.260 0.270 0.280 0.290 0.300 0.310 0.320 0.330 0.340 0.350 0.360 0.370 0.380 0.390 0.400 0.410 0.420 0.430 0.440 0.450 0.460 0.470 0.480 0.490 0.500 0.510 0.520 0.530 0.540 0.550 0.560 0.570 0.580 0.590 0.600 0.610 0.620 0.630 0.640 0.650 0.660 0.670 0.680 0.690 0.700 0.710 0.720 0.730 0.740 0.750 0.760 0.770 0.780 0.790 0.800 0.810 0.820 0.830 0.840 0.850 0.860 0.870 0.880 0.890 0.900 0.910 0.920 0.930 0.940 0.950 0.960 0.970 0.980 0.990 1.000]
    #define REDSTONE_IPBR_G 1.000 //[0.000 0.010 0.020 0.030 0.040 0.050 0.060 0.070 0.080 0.090 0.100 0.110 0.120 0.130 0.140 0.150 0.160 0.170 0.180 0.190 0.200 0.210 0.220 0.230 0.240 0.250 0.260 0.270 0.280 0.290 0.300 0.310 0.320 0.330 0.340 0.350 0.360 0.370 0.380 0.390 0.400 0.410 0.420 0.430 0.440 0.450 0.460 0.470 0.480 0.490 0.500 0.510 0.520 0.530 0.540 0.550 0.560 0.570 0.580 0.590 0.600 0.610 0.620 0.630 0.640 0.650 0.660 0.670 0.680 0.690 0.700 0.710 0.720 0.730 0.740 0.750 0.760 0.770 0.780 0.790 0.800 0.810 0.820 0.830 0.840 0.850 0.860 0.870 0.880 0.890 0.900 0.910 0.920 0.930 0.940 0.950 0.960 0.970 0.980 0.990 1.000]
    #define REDSTONE_IPBR_B 1.000 //[0.000 0.010 0.020 0.030 0.040 0.050 0.060 0.070 0.080 0.090 0.100 0.110 0.120 0.130 0.140 0.150 0.160 0.170 0.180 0.190 0.200 0.210 0.220 0.230 0.240 0.250 0.260 0.270 0.280 0.290 0.300 0.310 0.320 0.330 0.340 0.350 0.360 0.370 0.380 0.390 0.400 0.410 0.420 0.430 0.440 0.450 0.460 0.470 0.480 0.490 0.500 0.510 0.520 0.530 0.540 0.550 0.560 0.570 0.580 0.590 0.600 0.610 0.620 0.630 0.640 0.650 0.660 0.670 0.680 0.690 0.700 0.710 0.720 0.730 0.740 0.750 0.760 0.770 0.780 0.790 0.800 0.810 0.820 0.830 0.840 0.850 0.860 0.870 0.880 0.890 0.900 0.910 0.920 0.930 0.940 0.950 0.960 0.970 0.980 0.990 1.000]
    #define REDSTONE_IPBR_I 1.0 //[0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]

    //#define REFLECTIVE_WORLD
    //#define WAVE_EVERYTHING
    #define MONOTONE_WORLD 0 //[0 1 2 3]
    //#define ATLAS_ROTATION

    #define SEASONS 0 //[0 1 2 3 4 5] 0 = off, 1 = cycling, 2 = summer, 3 = autumn, 4 = winter, 5 = spring
    #define SEASON_LENGTH 28 //[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120] in MC days: 1, 3, 7, 8, 14, 24, 28, 30, 60 , 91, 120. Default 28 - 672000
    #define SEASON_TRANSITION_START 4 //[0 1 2 3 4 9] 0 is immediately, 1 is 50%, 2 is 66%, 3 is 75%, 4 is 80%, 9 is 90% of the season
    #define SEASON_COLOR_DESATURATION 0.3 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
    #define SEASON_START 3 //[0 1 2 3]
    #define LEAVES_ON_GROUND

    #if defined LEAVES_ON_GROUND && COLORED_LIGHTING_INTERNAL > 0
        #define ACL_GROUND_LEAVES_FIX
    #endif

    #define SNOW_CONDITION 2 // [0 1 2] 0 = only in snowy biomes when raining, 1 = only in snowy biomes, 2 = everywhere
    //#define AUTUMN_CONDITION

    //#define MOSS_NOISE
    //#define SAND_NOISE

    //#define ENTITIES_ARE_LIGHT

    //#define MULTICOLORED_BLOCKLIGHT // Kept for legacy reasons
    #ifdef MULTICOLORED_BLOCKLIGHT
        #define SSBL_OVERRIDE
    #endif
    #define MCBL_MAIN_DEFINE 0 //[0 1 2] 2 disabled for this release
    #if COLORED_LIGHTING_INTERNAL == 0 || MCBL_MAIN_DEFINE == 2 || defined ENTITIES_ARE_LIGHT
        #if (MCBL_MAIN_DEFINE >= 1 || defined SSBL_OVERRIDE || defined ENTITIES_ARE_LIGHT) && (MC_VERSION >= 11604 || defined IS_IRIS || defined IS_ANGELICA)
            #define SS_BLOCKLIGHT
        #endif
    #endif

    //#define RANDOM_BLOCKLIGHT
    #if MCBL_MAIN_DEFINE > 0
        #undef RANDOM_BLOCKLIGHT
    #endif
    #define MCBL_INFLUENCE 1.00 //[0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00]

    //#define SOUL_SAND_VALLEY_OVERHAUL
    //#define PURPLE_END_FIRE

    //#define NO_RAIN_ABOVE_CLOUDS
    //#define CLEAR_SKY_WHEN_RAINING

    #define RETRO_LOOK 0 //[0 1 2]
    #define RETRO_LOOK_R 0.00 // [0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00]
    #define RETRO_LOOK_G 1.00 // [0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00]
    #define RETRO_LOOK_B 0.00 // [0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00]
    #define RETRO_LOOK_I 1.00 //[0.25 0.50 0.75 1.00 1.25 1.50 1.75 2.00]

    //#define SPOOKY
    #define BLOOD_MOON 1 //[0 1 2] Off, Full Moon, Every Moon

    #define PIXEL_WATER 0 //[0 1] // Based on Helgust's code

    //#define CELESTIAL_BOTH_HEMISPHERES

    //#define DOUBLE_UNBOUND_CLOUDS // Thanks to FoZy STYLE
    #define CLOUD_UNBOUND_LAYER2_ALTITUDE 384 //[-96 -92 -88 -84 -80 -76 -72 -68 -64 -60 -56 -52 -48 -44 -40 -36 -32 -28 -24 -20 -16 -10 -8 -4 0 4 8 12 16 20 22 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100 104 108 112 116 120 124 128 132 136 140 144 148 152 156 160 164 168 172 176 180 184 188 192 196 200 204 208 212 216 220 224 228 232 236 240 244 248 252 256 260 264 268 272 276 280 284 288 292 296 300 304 308 312 316 320 324 328 332 336 340 344 348 352 356 360 364 368 372 376 380 384 388 392 396 400 404 408 412 416 420 424 428 432 436 440 444 448 452 456 460 464 468 472 476 480 484 488 492 496 500 510 520 530 540 550 560 570 580 590 600 610 620 630 640 650 660 670 680 690 700 710 720 730 740 750 760 770 780 790 800]

    //#define PIXELATED_WATER_REFLECTIONS // Using Nestorboy's pixelation functions

    //#define PIXELATED_HANDHELD_LIGHT


//Internal Settings//
    #define SIDE_SHADOWING
    #define SHADOW_FILTERING

    #define GLASS_OPACITY 0.25

    #define DIRECTIONAL_SHADING

    #define ATMOSPHERIC_FOG

    #define GLOWING_ENTITY_FIX
    #define FLICKERING_FIX
    //#define SAFER_GENERATED_NORMALS

    #define SHADOW_FRUSTUM_FIT

    #include "/lib/misc/myFile.glsl"

//Extensions//

//Visual Style and Performance Setting Handling//
    #if RP_MODE == 1
        #define IPBR
        #define IPBR_PARTICLE_FEATURES
        //#define GENERATED_NORMALS
        //#define COATED_TEXTURES
        //#define FANCY_GLASS
        //#define GREEN_SCREEN_LIME
    #endif
    #if RP_MODE >= 2
        #define CUSTOM_PBR
        #define POM
    #endif

    #ifdef SPOOKY
        #define WATER_STYLE_DEFAULT 3
        //#define WATER_CAUSTIC_STYLE_DEFAULT 3
        #define AURORA_STYLE_DEFAULT 2
        #define SUN_MOON_STYLE_DEFAULT 3
        #define CLOUD_STYLE_DEFAULT 3
    #elif SHADER_STYLE == 1
        #define WATER_STYLE_DEFAULT 1
        //#define WATER_CAUSTIC_STYLE_DEFAULT 1
        #define AURORA_STYLE_DEFAULT 1
        #define SUN_MOON_STYLE_DEFAULT 1
        #define CLOUD_STYLE_DEFAULT 1
    #elif SHADER_STYLE == 4
        #define WATER_STYLE_DEFAULT 3
        //#define WATER_CAUSTIC_STYLE_DEFAULT 3
        #define AURORA_STYLE_DEFAULT 2
        #define SUN_MOON_STYLE_DEFAULT 2
        #define CLOUD_STYLE_DEFAULT 3
    #endif
    #if WATER_STYLE_DEFINE == -1
        #define WATER_STYLE WATER_STYLE_DEFAULT
    #else
        #define WATER_STYLE WATER_STYLE_DEFINE
    #endif
    #if WATER_CAUSTIC_STYLE_DEFINE == -1
        #define WATER_CAUSTIC_STYLE WATER_STYLE
    #else
        #define WATER_CAUSTIC_STYLE WATER_CAUSTIC_STYLE_DEFINE
    #endif
    #if AURORA_STYLE_DEFINE == -1
        #define AURORA_STYLE AURORA_STYLE_DEFAULT
    #else
        #define AURORA_STYLE AURORA_STYLE_DEFINE
    #endif
    #if SUN_MOON_STYLE_DEFINE == -1
        #define SUN_MOON_STYLE SUN_MOON_STYLE_DEFAULT
    #else
        #define SUN_MOON_STYLE SUN_MOON_STYLE_DEFINE
    #endif
    #if CLOUD_STYLE_DEFINE == -1
        #define CLOUD_STYLE CLOUD_STYLE_DEFAULT
    #else
        #define CLOUD_STYLE CLOUD_STYLE_DEFINE
    #endif
    // Thanks to SpacEagle17 and isuewo for the sun angle handling
    #ifdef SPOOKY
        const float sunPathRotation = -40.0;
    #elif defined END
        const float sunPathRotation = 0.0;
    #else
        #if SUN_ANGLE == -1
            #if SHADER_STYLE == 1
                const float sunPathRotation = 0.0;
                #define PERPENDICULAR_TWEAKS
            #elif SHADER_STYLE == 4
                const float sunPathRotation = -40.0;
            #endif
        #elif SUN_ANGLE == 0
            const float sunPathRotation = 0.0;
            #define PERPENDICULAR_TWEAKS
        #elif SUN_ANGLE == 20
            const float sunPathRotation = 20.0;
        #elif SUN_ANGLE == 30
            const float sunPathRotation = 30.0;
        #elif SUN_ANGLE == 40
            const float sunPathRotation = 40.0;
        #elif SUN_ANGLE == 50
            const float sunPathRotation = 50.0;
        #elif SUN_ANGLE == 60
            const float sunPathRotation = 60.0;
        #elif SUN_ANGLE == -20
            const float sunPathRotation = -20.0;
        #elif SUN_ANGLE == -30
            const float sunPathRotation = -30.0;
        #elif SUN_ANGLE == -40
            const float sunPathRotation = -40.0;
        #elif SUN_ANGLE == -50
            const float sunPathRotation = -50.0;
        #elif SUN_ANGLE == -60
            const float sunPathRotation = -60.0;
        #endif
    #endif

    #if SHADOW_QUALITY >= 1
        #if SHADOW_QUALITY > 4 || SHADOW_SMOOTHING < 3
            const int shadowMapResolution = 4096;
        #else
            const int shadowMapResolution = 2048;
        #endif
    #else
        const int shadowMapResolution = 1024;
    #endif

    const int noiseTextureResolution = 128;

    #if LIGHTSHAFT_BEHAVIOUR > 0
        #define LIGHTSHAFT_QUALI LIGHTSHAFT_QUALI_DEFINE
    #else
        #define LIGHTSHAFT_QUALI 0
    #endif

    #if BLOCK_REFLECT_QUALITY >= 1
        #define LIGHT_HIGHLIGHT
    #endif
    #if BLOCK_REFLECT_QUALITY >= 2 && RP_MODE >= 1
        #define PBR_REFLECTIONS
    #endif
    #if BLOCK_REFLECT_QUALITY >= 3 && RP_MODE >= 1
        #define TEMPORAL_FILTER
    #endif

    #if DETAIL_QUALITY == 0 // Potato
        #undef PERPENDICULAR_TWEAKS
        #define LOW_QUALITY_NETHER_STORM
        #define LOW_QUALITY_ENDER_NEBULA
        #define WATER_MAT_QUALITY 1
    #endif
    #if DETAIL_QUALITY >= 1 // not an option for now
        #if TAA_MODE >= 1
            #define TAA
        #endif
        #define WATER_MAT_QUALITY 1
    #endif
    #if DETAIL_QUALITY >= 2 // Medium
        #undef WATER_MAT_QUALITY
        #define WATER_MAT_QUALITY 2
        #define FXAA_TAA_INTERACTION
        #define TAA_MOVEMENT_IMPROVEMENT_FILTER
    #endif
    #if DETAIL_QUALITY >= 3 // High
        #undef WATER_MAT_QUALITY
        #define WATER_MAT_QUALITY 3 // we use DETAIL_QUALITY >= 3 when writing in gbuffers_water because optifine bad
        #define HQ_NIGHT_NEBULA
        #define SKY_EFFECT_REFLECTION
        #define CONNECTED_GLASS_CORNER_FIX
        #define ACL_CORNER_LEAK_FIX
        #define DO_NETHER_VINE_WAVING_OUTSIDE_NETHER
        #define DO_MORE_FOLIAGE_WAVING
        #if defined IRIS_FEATURE_CUSTOM_IMAGES && SHADOW_QUALITY > -1 && RAIN_PUDDLES > 0 && COLORED_LIGHTING_INTERNAL > 0
            #define PUDDLE_VOXELIZATION
        #endif
        #if CLOUD_QUALITY >= 3 && CLOUD_STYLE > 0 && CLOUD_STYLE != 50
            #define ENTITY_TAA_NOISY_CLOUD_FIX
        #endif
    #endif

//Define Handling//
    #if CLOUD_QUALITY == 0
        #define CLOUD_QUALITY_INTERNAL 0
    #elif defined HIGH_QUALITY_CLOUDS
        #define CLOUD_QUALITY_INTERNAL 4
    #elif CLOUD_QUALITY == 1
        #define CLOUD_QUALITY_INTERNAL 1
    #elif CLOUD_QUALITY == 2
        #define CLOUD_QUALITY_INTERNAL 2
    #elif CLOUD_QUALITY == 3
        #define CLOUD_QUALITY_INTERNAL 3
    #endif
    #ifdef OVERWORLD
        #if CLOUD_STYLE > 0 && CLOUD_STYLE != 50 && CLOUD_QUALITY_INTERNAL > 0
            #define VL_CLOUDS_ACTIVE
            #if CLOUD_STYLE == 1
                #define CLOUDS_REIMAGINED
            #endif
            #if CLOUD_STYLE == 3
                #define CLOUDS_UNBOUND
            #endif
        #endif
    #else
        #undef LIGHT_HIGHLIGHT
        #undef CAVE_FOG
        #undef CLOUD_SHADOWS
        #undef SNOWY_WORLD
        #undef AURORA_INFLUENCE
    #endif
    #ifdef NETHER
        #undef ATMOSPHERIC_FOG
    #endif

    #if defined PIXELATED_SHADOWS || defined PIXELATED_BLOCKLIGHT || defined PIXELATED_AO || defined PIXELATED_WATER_REFLECTIONS || defined PIXELATED_HANDHELD_LIGHT
        #if !defined GBUFFERS_BASIC && !defined DH_TERRAIN && !defined DH_WATER
            #define DO_PIXELATION_EFFECTS
            #include "/lib/misc/pixelation.glsl"
        #endif
    #endif

    #ifndef GBUFFERS_TERRAIN
        #undef PIXELATED_BLOCKLIGHT
    #endif

    #if defined GBUFFERS_HAND || defined GBUFFERS_ENTITIES
        #undef SNOWY_WORLD
        #undef DISTANT_LIGHT_BOKEH
    #endif
    #if defined GBUFFERS_TEXTURED || defined GBUFFERS_BASIC
        #undef LIGHT_HIGHLIGHT
        #undef DIRECTIONAL_SHADING
        #undef SIDE_SHADOWING
    #endif
    #ifdef GBUFFERS_WATER
        #undef LIGHT_HIGHLIGHT
    #endif

    #ifndef GLOWING_ENTITY_FIX
        #undef GBUFFERS_ENTITIES_GLOWING
    #endif

    #if LIGHTSHAFT_QUALI > 0 && defined OVERWORLD && SHADOW_QUALITY > -1 || defined END
        #define LIGHTSHAFTS_ACTIVE
    #endif

    #if WATERCOLOR_R != 100 || WATERCOLOR_G != 100 || WATERCOLOR_B != 100
        #define WATERCOLOR_RM WATERCOLOR_R * 0.01
        #define WATERCOLOR_GM WATERCOLOR_G * 0.01
        #define WATERCOLOR_BM WATERCOLOR_B * 0.01
        #define WATERCOLOR_CHANGED
    #endif

    #if UNDERWATERCOLOR_R != 100 || UNDERWATERCOLOR_G != 100 || UNDERWATERCOLOR_B != 100
        #define UNDERWATERCOLOR_RM UNDERWATERCOLOR_R * 0.01
        #define UNDERWATERCOLOR_GM UNDERWATERCOLOR_G * 0.01
        #define UNDERWATERCOLOR_BM UNDERWATERCOLOR_B * 0.01
        #define UNDERWATERCOLOR_CHANGED
    #endif

    #if defined IS_IRIS && !defined IRIS_HAS_TRANSLUCENCY_SORTING
        #undef FANCY_GLASS
    #endif

    #ifdef DISTANT_HORIZONS
        #undef DISTANT_LIGHT_BOKEH
    #endif

    #if defined MC_GL_VENDOR_AMD || defined MC_GL_VENDOR_ATI
        #ifndef DEFERRED1
            #define FIX_AMD_REFLECTION_CRASH //BFARC: Fixes a driver crashing problem on AMD GPUs
        #endif
    #endif


    #if SEASONS > 0
        #undef SNOWY_WORLD
    #endif

    #if AURORA_STYLE == 0
        #undef AURORA_INFLUENCE
    #endif

    #ifdef SPOOKY
        #define SPOOKY_RAIN_PUDDLE_OVERRIDE
    #endif

    #if defined RAIN_ATMOSPHERE || defined SPOOKY
        #define EPIC_THUNDERSTORM
    #endif

    #if defined END && defined IRIS_FEATURE_CUSTOM_IMAGES && defined DRAGON_DEATH_EFFECT
        #define DRAGON_DEATH_EFFECT_INTERNAL 1
    #else
        #define DRAGON_DEATH_EFFECT_INTERNAL 0
    #endif
    #if defined END && defined IRIS_FEATURE_CUSTOM_IMAGES && END_CRYSTAL_VORTEX > 0
        #if END_CRYSTAL_VORTEX == 1
            #define END_CRYSTAL_VORTEX_INTERNAL 1
        #elif END_CRYSTAL_VORTEX == 2
            #define END_CRYSTAL_VORTEX_INTERNAL 2
        #elif END_CRYSTAL_VORTEX == 3
            #define END_CRYSTAL_VORTEX_INTERNAL 3
        #else
             #define END_CRYSTAL_VORTEX_INTERNAL 0
        #endif
    #else
        #define END_CRYSTAL_VORTEX_INTERNAL 0
    #endif
    #if defined END_PORTAL_BEAM && defined IS_IRIS && defined OVERWORLD && !defined MC_OS_MAC
        #define END_PORTAL_BEAM_INTERNAL
    #endif
    #if defined SOUL_SAND_VALLEY_OVERHAUL && defined NETHER
        #define SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
    #endif
    #if defined PURPLE_END_FIRE && defined END
        #define PURPLE_END_FIRE_INTERNAL
    #endif
    #if defined SAND_NOISE && defined OVERWORLD
        #define SAND_NOISE_INTERNAL
    #endif
    #if defined MOSS_NOISE && defined OVERWORLD
        #define MOSS_NOISE_INTERNAL
    #endif

//Very Common Stuff//
    #include "/lib/uniforms.glsl"
    #include "/lib/materials/materialHandling/materialDefines.glsl"

    #if SHADOW_QUALITY == -1
      float timeAngle = worldTime / 24000.0;
    #else
      float tAmin     = fract(sunAngle - 0.033333333);
      float tAlin     = tAmin < 0.433333333 ? tAmin * 1.15384615385 : tAmin * 0.882352941176 + 0.117647058824;
      float hA        = tAlin > 0.5 ? 1.0 : 0.0;
      float tAfrc     = fract(tAlin * 2.0);
      float tAfrs     = tAfrc*tAfrc*(3.0-2.0*tAfrc);
      float tAmix     = hA < 0.5 ? 0.3 : -0.1;
      float timeAngle = (tAfrc * (1.0-tAmix) + tAfrs * tAmix + hA) * 0.5;
    #endif

    const vec3 colorSoul = vec3(0.1725, 0.8588, 0.8824);
    const vec3 colorEndBreath = vec3(0.35, 0.25, 1.0);

    const float pi = 3.14159265359;
    const float goldenRatio = 1.61803398875;
    const float tau = 6.28318530717;
    const float eps = 1e-6;

    const float oceanAltitude = 61.9;

    #ifndef DISTANT_HORIZONS
        float renderDistance = far;
    #else
        float renderDistance = float(dhRenderDistance);
    #endif

    const float shadowMapBias = 1.0 - 25.6 / shadowDistance;
    #ifndef DREAM_TWEAKED_LIGHTING
        float noonFactor = sqrt(max(sin(timeAngle*6.28318530718),0.0));
    #else
        float noonFactor = pow(max(sin(timeAngle*6.28318530718),0.0), 0.2);
    #endif
    float nightFactor = max(sin(timeAngle*(-6.28318530718)),0.0);
    float invNightFactor = 1.0 - nightFactor;
    float altitudeVisibility = 0.0;

    float cloudHeightM = isnan(cloudHeight) ? 192.0 : cloudHeight;

    int cloudAlt1i = int(CLOUD_ALT1 + cloudHeightM - 192); // Old setting files can send float values

    #ifdef CLOUDS_UNBOUND
        int cloudAlt2i = int(CLOUD_UNBOUND_LAYER2_ALTITUDE + cloudHeightM - 192); // cloudHeightM used to make modded dimensions work
    #else
        int cloudAlt2i = int(CLOUD_ALT2 + cloudHeightM - 192);
    #endif

    float cloudMaxAdd = 5.0;
    #if defined DOUBLE_REIM_CLOUDS && defined CLOUDS_REIMAGINED || defined CLOUDS_UNBOUND && defined DOUBLE_UNBOUND_CLOUDS
        float maximumCloudsHeight = max(cloudAlt1i, cloudAlt2i) + cloudMaxAdd;
    #elif CLOUD_STYLE_DEFINE == 50
        float maximumCloudsHeight = cloudHeightM + cloudMaxAdd;
    #else
        float maximumCloudsHeight = cloudAlt1i + cloudMaxAdd;
    #endif

    float cloudGradientLength = 20.0; // in blocks, probably...
    float heightRelativeToCloud = clamp(1.0 - (eyeAltitude - maximumCloudsHeight) / cloudGradientLength, 0.0, 1.0);

    float rainFactor2 = rainFactor * rainFactor;
    float invRainFactor = 1.0 - rainFactor;
    float invNoonFactor = 1.0 - noonFactor;
    float invNoonFactor2 = invNoonFactor * invNoonFactor;

    float vsBrightness = clamp(screenBrightness, 0.0, 1.0);

    int modifiedWorldDay = int(mod(worldDay, 100) + 5.0);
    #if defined DAYLIGHT_CYCLE_COMPAT || defined FROZEN_TIME
        float syncedTime = frameTimeCounter;
    #else
        float syncedTime = (worldTime + modifiedWorldDay * 24000) * 0.05;
    #endif

    #if IRIS_VERSION >= 10800
        vec3 cameraPositionBestFract = cameraPositionFract;
    #else
        vec3 cameraPositionBestFract = fract(cameraPosition);
    #endif

    float auroraSpookyMix = 0.0;

    #if WATERCOLOR_MODE >= 2
        vec3 underwaterColorM1 = pow(fogColor, vec3(0.33, 0.21, 0.26));
    #else
        vec3 underwaterColorM1 = vec3(0.46, 0.62, 1.0);
    #endif
    #ifndef UNDERWATERCOLOR_CHANGED
        vec3 underwaterColorM2 = underwaterColorM1;
    #else
        vec3 underwaterColorM2 = underwaterColorM1 * vec3(UNDERWATERCOLOR_RM, UNDERWATERCOLOR_GM, UNDERWATERCOLOR_BM);
    #endif
    vec3 waterFogColor = underwaterColorM2 * vec3(0.2 + 0.1 * vsBrightness);

    #if NETHER_COLOR_MODE == 3
        float netherColorMixer = inNetherWastes + inCrimsonForest + inWarpedForest + inBasaltDeltas + inSoulValley;
        vec3 netherColor = clamp(mix(
            fogColor * 0.6 + 0.2 * normalize(fogColor + 0.0001),
            (
                inNetherWastes * vec3(0.38, 0.15, 0.05) + inCrimsonForest * vec3(0.33, 0.07, 0.04) +
                inWarpedForest * vec3(0.18, 0.1, 0.25) + inBasaltDeltas * vec3(0.25, 0.235, 0.23) +
                inSoulValley * vec3(0.1, vec2(0.24))
            ),
            netherColorMixer
        ) * NETHER_BRIGHTNESS, 0.0, 1.0);
    #elif NETHER_COLOR_MODE == 2
        vec3 netherColor = clamp(fogColor * 0.6 + 0.2 * normalize(fogColor + 0.0001) * NETHER_BRIGHTNESS, 0.0, 1.0);
    #elif NETHER_COLOR_MODE == 0
        vec3 netherColor = vec3(0.7, 0.26, 0.08) * 0.6 * NETHER_BRIGHTNESS;
    #endif
    #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
        vec3 lavaLightColor = mix(vec3(0.15, 0.06, 0.01), vec3(0.034, 0.171, 0.176), inSoulValley);
    #else
        vec3 lavaLightColor = vec3(0.15, 0.06, 0.01);
    #endif

    const vec3 originalEndSkyColor = vec3(E_SKY_COLORR, E_SKY_COLORG, E_SKY_COLORB) / 255.0 * E_SKY_COLORI;
    vec3 endSkyColor = clamp(mix(originalEndSkyColor, fogColor * 0.25 + 0.1 * normalize(fogColor + 0.0001), (-inVanillaEnd + 1.0) * END_SKY_FOG_INFLUENCE * 0.5), 0.0, 1.0);

    #if WEATHER_TEX_OPACITY == 100
        const float rainTexOpacity = 0.25;
        const float snowTexOpacity = 0.5;
    #else
        #define WEATHER_TEX_OPACITY_M 100.0 / WEATHER_TEX_OPACITY
        const float rainTexOpacity = pow(0.25, WEATHER_TEX_OPACITY_M);
        const float snowTexOpacity = pow(0.5, WEATHER_TEX_OPACITY_M);
    #endif

    #ifdef FRAGMENT_SHADER
        ivec2 texelCoord = ivec2(gl_FragCoord.xy);
    #endif

    #include "/lib/util/commonFunctions.glsl"

    #include "/lib/colors/blocklightColors.glsl"

    #include "/lib/materials/seasonsTime.glsl"

    const float OSIEBCA = 1.0 / 255.0; // One Step In Eight Bit Color Attachment
    /* materialMask steps
    0 to 240 - PBR Dependant:
        IntegratedPBR:
            0 to 99: deferredMaterials
                OSIEBCA * 0.0 = *Unused as 0.0 is the default value*
                OSIEBCA * 1.0 = Intense Fresnel
                OSIEBCA * 2.0 = Copper Fresnel
                OSIEBCA * 3.0 = Gold Fresnel
                OSIEBCA * 4.0 =
                OSIEBCA * 5.0 = Redstone Fresnel
            100 to 199: Exact copy of deferredMaterials but toned down reflection handling for entities
                materialMask += OSIEBCA * 100.0; // Entity Reflection Handling
            200 to 240: Random checks
                OSIEBCA * 239.0 = Blue Screen Blue Blocks
                OSIEBCA * 240.0 = Green Screen Lime Blocks
        seuspbr:
            0 to 240: Increasing metalness
        labPBR:
            0 to 229: Increasing f0
            230 to 240: Consistent metalness with still increasing f0
    241 to 255 - PBR Independant:
        OSIEBCA * 241.0 = Water
    
        OSIEBCA * 251.0 = Composite Effects
        OSIEBCA * 252.0 = Versatile Selection Outline
        OSIEBCA * 253.0 = Reduced Edge TAA
        OSIEBCA * 254.0 = No SSAO, No TAA
        OSIEBCA * 255.0 = *Unused as 1.0 is the clear color*
    */

// 62 75 74 20 74 68 4F 73 65 20 77 68 6F 20 68 6F 70 65 20 69 6E 20 74 68 65 20 6C 69 6D 69 4E 61 6C 0A 77 69 6C 6C 20 72 65 6E 65 77 20 74 68 65 69 72 20 73 54 72 65 6E 67 74 48 2E 0A 74 68 65 79 20 77 69 6C 6C 20 73 6F 41 72 20 6F 6E 20 65 6C 79 54 72 61 73 20 6C 69 6B 65 20 70 68 61 6E 74 6F 6D 73 3B 0A 74 68 65 79 20 77 69 6C 6C 20 72 75 6E 20 61 6E 44 20 6E 6F 74 20 67 72 6F 77 20 77 65 41 72 79 2C 0A 74 68 65 59 20 77 69 6C 6C 20 77 61 6C 6B 20 61 6E 64 20 6E 6F 74 20 62 65 20 66 61 69 6E 74 2E

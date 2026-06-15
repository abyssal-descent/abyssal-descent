#ifdef MULTICOLORED_BLOCKLIGHT
    #define OLD_SSBL_ERROR
#endif

#ifdef MC_ANISOTROPIC_FILTERING
    #define OPTIFINE_AF_ERROR
#endif

#if defined VOXY && defined DISTANT_HORIZONS
    #define MULTIPLE_LOD_MODS_ERROR
#endif

#if COLORED_LIGHTING > 0 && defined MC_OS_MAC
    #define APPLE_ACT_ERROR
#endif

#if COLORED_LIGHTING > 0 && (!defined IS_IRIS || !defined IRIS_FEATURE_CUSTOM_IMAGES)
    #define OPTIFINE_ACT_ERROR
#endif

#if defined END_PORTAL_BEAM && !defined IS_IRIS
    #define OPTIFINE_PORTAL_BEAM_ERROR
#endif

#if defined END_PORTAL_BEAM && defined MC_OS_MAC
    #define APPLE_PORTAL_BEAM_ERROR
#endif

#if DRAGON_DEATH_EFFECT > 0 && !defined IS_IRIS
    #define OPTIFINE_DRAGON_DEATH_ERROR
#endif

#if DRAGON_DEATH_EFFECT > 0 && defined MC_OS_MAC
    #define APPLE_DRAGON_DEATH_ERROR
#endif

#if END_CRYSTAL_VORTEX > 0 && !defined IS_IRIS
    #define OPTIFINE_END_CRYSTAL_ERROR
#endif

#if END_CRYSTAL_VORTEX > 0 && defined MC_OS_MAC
    #define APPLE_END_CRYSTAL_ERROR
#endif

#if COLORED_LIGHTING_INTERNAL > 0
    #define COORDINATES_ACT_ERROR
    #define SHADOWDISTANCE_ACT_ERROR
#endif

#if (MCBL_MAIN_DEFINE >= 1 || defined SSBL_OVERRIDE) && MC_VERSION < 11604 && !(defined IS_IRIS || defined IS_ANGELICA)
    #define OLD_VERSION_SSBL_ERROR
#endif

#ifdef COLOR_CODED_PROGRAMS
    #include "/lib/textRendering/color_code_info.glsl"
#endif

#if COLORED_LIGHTING > 0 && SHADOW_QUALITY < 0
    #define ACT_SHADOW_ERROR
#endif

#if WORLD_SPACE_REFLECTIONS > 0 && COLORED_LIGHTING == 0
    #define WSR_MISSING_ACT_ERROR
#endif

#if (defined PHOTONICS || defined EUPHORIA_PATCHES_IS_PHOTONICS_INSTALLED) && (PHOTONICS_VERSION < 301 || !defined PHOTONICS_VERSION) && PHOTONICS_LIGHTING_MODE > 0
    #define OLD_PHOTONICS_ERROR
#endif

#if defined PHOTONICS && defined MC_OS_MAC
    #define APPLE_PHOTONICS_ERROR
#endif

#if defined PHOTONICS && !defined IS_IRIS
    #define OPTIFINE_PHOTONICS_ERROR
#endif

#if defined PHOTONICS_LIGHTING
    #define PHOTONICS_COORDINATES_ERROR
#endif

#if COLORED_LIGHTING_INTERNAL > 0 && WORLD_SPACE_REFLECTIONS > 0 && WORLD_SPACE_PLAYER_REF == 1 && defined EUPHORIA_PATCHES_IS_3D_SKIN_LAYERS_INSTALLED
    #define PLAYER_REFLECTION_3D_LAYERS_ERROR
#endif

vec3 textColor = vec3(0.0);
float animation = min(starter * 0.3, 0.1) * 10.0;

#ifdef MULTIPLE_LOD_MODS_ERROR
        #include "/lib/textRendering/error_multiple_lod_mods.glsl"
#elif defined OLD_VERSION_SSBL_ERROR
    #include "/lib/textRendering/old_version_ssbl_error.glsl"
#elif defined OLD_SSBL_ERROR
    #include "/lib/textRendering/old_ssbl_error.glsl"
#elif defined OPTIFINE_AF_ERROR
    #include "/lib/textRendering/error_optifine_af.glsl"
#elif defined APPLE_ACT_ERROR
    #include "/lib/textRendering/error_apple_act.glsl"
#elif defined WSR_MISSING_ACT_ERROR
    #include "/lib/textRendering/error_wsr_missing_act.glsl"
#elif defined OPTIFINE_ACT_ERROR
    #include "/lib/textRendering/error_optifine_act.glsl"
#elif defined APPLE_PORTAL_BEAM_ERROR
    #include "/lib/textRendering/error_apple_portal_beam.glsl"
#elif defined OPTIFINE_PORTAL_BEAM_ERROR
    #include "/lib/textRendering/error_optifine_portal_beam.glsl"
#elif defined APPLE_DRAGON_DEATH_ERROR
    #include "/lib/textRendering/error_apple_dragon_death.glsl"
#elif defined OPTIFINE_DRAGON_DEATH_ERROR
    #include "/lib/textRendering/error_optifine_dragon_death.glsl"
#elif defined APPLE_END_CRYSTAL_ERROR
    #include "/lib/textRendering/error_apple_end_crystal.glsl"
#elif defined OPTIFINE_END_CRYSTAL_ERROR
    #include "/lib/textRendering/error_optifine_end_crystal.glsl"
#elif defined ACT_SHADOW_ERROR
    #include "/lib/textRendering/error_shadows_act.glsl"
#elif defined APPLE_PHOTONICS_ERROR
    #include "/lib/textRendering/error_apple_photonics.glsl"
#elif defined OPTIFINE_PHOTONICS_ERROR
    #include "/lib/textRendering/error_optifine_photonics.glsl"
#elif defined OLD_PHOTONICS_ERROR
    #include "/lib/textRendering/error_old_photonics.glsl"
#elif defined PLAYER_REFLECTION_3D_LAYERS_ERROR
    #include "/lib/textRendering/error_player_reflection_3d_layers.glsl"
#elif defined NEW_EUPHORIA_PATCHES_UPDATE
    #include "/lib/textRendering/new_Euphoria_Version.glsl"
#elif USE_TEXTURE_PALETTE > 0 && defined PALETTE_SWAP
    #include "/lib/textRendering/error_palette_not_found.glsl"
#else
    #ifdef COORDINATES_ACT_ERROR
        ivec2 absCameraPositionIntXZ = abs(cameraPositionInt.xz);
        if (max(absCameraPositionIntXZ.x, absCameraPositionIntXZ.y) > 8388550) {
            #include "/lib/textRendering/error_coordinates_act.glsl"
        }
    #endif
    #ifdef SHADOWDISTANCE_ACT_ERROR
        if (COLORED_LIGHTING_INTERNAL > shadowDistance*2) {
            #include "/lib/textRendering/error_shadowdistance_act.glsl"
        }
    #endif
    #ifdef PHOTONICS_COORDINATES_ERROR
        if (getPhotonicsAllowedDistance() < 1.0) {
            #include "/lib/textRendering/error_coordinates_photonics.glsl"
        }
    #endif
#endif

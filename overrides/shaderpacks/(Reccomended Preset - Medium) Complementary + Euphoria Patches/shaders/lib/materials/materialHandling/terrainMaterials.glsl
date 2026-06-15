#ifdef VOXY_PATCH
    #undef GENERATED_NORMALS
    #undef COATED_TEXTURES
    #undef CUSTOM_PBR
    #ifndef IPBR_COMPAT_MODE
        #define IPBR_COMPAT_MODE
    #endif
#endif

#ifdef IPBR
    vec3 maRecolor = vec3(0.0);
    #include "/lib/materials/materialHandling/terrainIPBR.glsl"

    #ifdef REFLECTIVE_WORLD
        smoothnessD = 1.0;
        smoothnessG = 1.0;
    #endif

    #ifdef GENERATED_NORMALS
        if (!noGeneratedNormals) GenerateNormals(normalM, colorP);
    #endif

    #if IPBR_EMISSIVE_MODE != 1 && !defined VOXY_PATCH
        emission = GetCustomEmissionForIPBR(color, emission);
    #endif
#else
    #ifdef CUSTOM_PBR
        GetCustomMaterials(color, normalM, lmCoordM, NdotU, shadowMult, smoothnessG, smoothnessD, highlightMult, emission, materialMask, viewPos, lViewPos);
    #endif

    if (mat == 10001) { // No directional shading
        noDirectionalShading = true;
    } else if (mat == 10003 || mat == 10005 || mat == 10029 || mat == 10031) { // Grounded Waving Foliage
        subsurfaceMode = 1, noSmoothLighting = true, noDirectionalShading = true, isFoliage = true;
        #if defined GBUFFERS_TERRAIN || defined VOXY_PATCH
            DoFoliageColorTweaks(color.rgb, shadowMult, snowMinNdotU, viewPos, nViewPos, lViewPos, dither);
        #endif
        sandNoiseIntensity = 0.3, mossNoiseIntensity = 0.0;
    } else if (mat == 10007 || mat == 10009 || mat == 10011) { // Leaves
        #include "/lib/materials/specificMaterials/terrain/leaves.glsl"
    } else if (mat == 10013 || mat == 10923) { // Vine
        subsurfaceMode = 3, centerShadowBias = true; noSmoothLighting = true, isFoliage = true;
        sandNoiseIntensity = 0.3, mossNoiseIntensity = 0.0;
    } else if (mat == 10015 || mat == 10017 || mat == 10019) { // Non-waving Foliage
        subsurfaceMode = 1, noSmoothLighting = true, noDirectionalShading = true, isFoliage = true;
        sandNoiseIntensity = 0.3, mossNoiseIntensity = 0.0;
    } else if (mat == 10021 || mat == 10023) { // Upper Waving Foliage
        subsurfaceMode = 1, noSmoothLighting = true, noDirectionalShading = true, isFoliage = true;
        sandNoiseIntensity = 0.3, mossNoiseIntensity = 0.0;
        #if defined GBUFFERS_TERRAIN || defined VOXY_PATCH
            DoFoliageColorTweaks(color.rgb, shadowMult, snowMinNdotU, viewPos, nViewPos, lViewPos, dither);
        #endif
    } else if (mat == 10068 || mat == 10070) { // Lava
        vec3 previousLavaColor = color.rgb;
        if (emission < 1.0) emission = max(2.0, emission);
        #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
            color.rgb = changeColorFunction(color.rgb, 3.0, colorSoul, inSoulValley);
        #endif
        vec3 lavaNoiseColor = color.rgb;
        #if LAVA_VARIATION > 0
            vec2 lavaPos = (floor(worldPos.xz * 16.0) + worldPos.y * 32.0) * 0.000666;
            vec2 wind = vec2(frameTimeCounter * 0.012, 0.0);
            lavaNoiseIntensity *= 0.95;
            #include "/lib/materials/specificMaterials/terrain/lavaNoise.glsl"
            color.rgb = lavaNoiseColor;
        #else
            if (LAVA_TEMPERATURE != 0.0) color.rgb += LAVA_TEMPERATURE * 0.3;
        #endif
        vec3 maxLavaColor = max(previousLavaColor, lavaNoiseColor);
        vec3 minLavaColor = min(previousLavaColor, lavaNoiseColor);
        #if RAIN_PUDDLES >= 1
            noPuddles = 1.0;
        #endif

        #include "/lib/materials/specificMaterials/terrain/lavaEdge.glsl"

        emission *= LAVA_EMISSION;
    } else if (mat > 20999 && mat < 21025){
        emission = DoAutomaticEmission(noSmoothLighting, noDirectionalShading, color.rgb, lmCoord.x, blockLightEmission, 1.0);
    }

    #ifdef SNOWY_WORLD
    else if (mat == 10132) { // Grass Block:Normal
        if (glColor.b < 0.999) { // Grass Block:Normal:Grass Part
            snowMinNdotU = min(pow2(pow2(color.g)) * 1.9, 0.1);
            color.rgb = color.rgb * 0.5 + 0.5 * (color.rgb / glColor.rgb);
        }
    }
    #endif

    else if (lmCoord.x > 0.99999) lmCoordM.x = 0.95;
#endif

if (mat == 10572) { // Dragon Egg
    overlayNoiseIntensity = 0.0;
    #ifndef EMISSIVE_DRAGON_EGG
        emission *= 0.0;
    #endif
}

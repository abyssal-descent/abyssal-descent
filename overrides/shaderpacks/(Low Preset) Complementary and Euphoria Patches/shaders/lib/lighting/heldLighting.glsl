float getHeldLightFlicker() {
    vec2 flickerNoiseHand = texture2DLod(noisetex, vec2(frameTimeCounter * 0.06), 0.0).rb;
    float flickerMix = mix(1.0, min1(max(flickerNoiseHand.r, flickerNoiseHand.g) * 1.7), pow2(HAND_BLOCKLIGHT_FLICKERING * 0.1));

    return flickerMix;
}

void getHeldLight(out float heldLight, out float heldLight2) {
    heldLight = heldBlockLightValue;
    heldLight2 = heldBlockLightValue2;

    #ifndef IS_IRIS
        if (heldLight > 15.1) heldLight = 0.0;
        if (heldLight2 > 15.1) heldLight2 = 0.0;
    #endif

    if (heldItemId == 45032) heldLight = 15; // Lava Bucket
    if (heldItemId2 == 45032) heldLight2 = 15;
}

vec3 GetHeldLighting(vec3 playerPos, vec3 color, inout float emission, vec3 worldGeoNormal, vec3 normalM, vec3 viewPos) {
    float heldLight = 0; float heldLight2 = 0;
    getHeldLight(heldLight, heldLight2);

    #if COLORED_LIGHTING_INTERNAL == 0
        vec3 heldLightCol = blocklightCol; vec3 heldLightCol2 = blocklightCol;
    #else
        vec3 heldLightCol = GetSpecialBlocklightColor(heldItemId - 44000).rgb;
        vec3 heldLightCol2 = GetSpecialBlocklightColor(heldItemId2 - 44000).rgb;

        if (heldItemId == 45032) heldLightCol = lavaSpecialLightColor.rgb; // Lava Bucket
        if (heldItemId2 == 45032) heldLightCol2 = lavaSpecialLightColor.rgb;

        #if COLORED_LIGHT_SATURATION != 100
            heldLightCol = mix(blocklightCol, heldLightCol, COLORED_LIGHT_SATURATION * 0.01);
            heldLightCol2 = mix(blocklightCol, heldLightCol2, COLORED_LIGHT_SATURATION * 0.01);
        #endif
    #endif

    vec3 playerPosLightM = playerPos + relativeEyePosition;
         playerPosLightM.y += 0.7;
    float lViewPosL = length(playerPosLightM) + 6.0;
    #if HELD_LIGHTING_MODE == 1
        lViewPosL *= 1.5;
    #endif

    #ifdef SPACEAGLE17
        if (heldLight == 0 && heldLight2 == 0 && !bool(firstPersonCamera) && entityId != 50017 && !bool(is_invisible) && currentPlayerArmor < 0.4 && bool(isOnGround)) {
            float powVal = 1.0 + 1.0 * (cos(frameTimeCounter * 1.5) * 0.5 + 0.5);
            float anim = 2.8 * max(pow(0.8, powVal), 0.12);
            heldLight = anim;
            heldLight2 = anim;
            heldLightCol = vec3(0.2392, 0.8235, 0.8667);
            heldLightCol2 = vec3(0.2392, 0.8235, 0.8667);
            playerPosLightM.y += 0.8;
            lViewPosL = length(playerPosLightM) + 6.0;
            lViewPosL = sqrt2(lViewPosL * 0.35) * 1.2;
        }
    #endif

    #ifdef DIRECTIONAL_LIGHTMAP_NORMALS
        vec3 cameraHeldLightPos = (gbufferModelView * vec4(-relativeEyePosition, 1.0)).xyz;
        cameraHeldLightPos.x += 0.66 * (float(heldLight > 0) - float(heldLight2 > 0)); // Held light position offset

        float dirHandLightmap = clamp01(dot(normalize(cameraHeldLightPos - viewPos), normalM));
        float dirHandLightmapMaxInfluence = DIRECTIONAL_LIGHTMAP_NORMALS_HANDHELD_STRENGTH * 0.25;

        dirHandLightmap = 2.0 * dirHandLightmap * dirHandLightmapMaxInfluence - dirHandLightmapMaxInfluence;
        dirHandLightmap = 1.0 + dirHandLightmap;

        heldLight *= dirHandLightmap;
        heldLight2 *= dirHandLightmap;
    #endif

    heldLight = pow2(pow2(heldLight * 0.47 / lViewPosL));
    heldLight2 = pow2(pow2(heldLight2 * 0.47 / lViewPosL));

    vec3 heldLighting = pow2(heldLight * DoLuminanceCorrection(heldLightCol))
                        + pow2(heldLight2 * DoLuminanceCorrection(heldLightCol2));

    #if COLORED_LIGHTING_INTERNAL > 0
        AddSpecialLightDetail(heldLighting, color.rgb, emission);
    #endif

    #if HAND_BLOCKLIGHT_FLICKERING > 0
        heldLighting *= getHeldLightFlicker();
    #endif

    return heldLighting;
}

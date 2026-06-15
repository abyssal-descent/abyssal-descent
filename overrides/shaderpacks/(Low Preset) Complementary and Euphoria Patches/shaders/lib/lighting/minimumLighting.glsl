vec3 GetMinimumLighting(float lightmapYM, vec3 playerPos) {
    float fadeMinLightDistance = 1.0;
    #if DISTANCE_MIN_LIGHT > 0
        float blockMinLightFadeDistance = 250;
        float distMinLightIntensity = DISTANCE_MIN_LIGHT * 0.1;
        fadeMinLightDistance = max(1.0 - length(playerPos) / blockMinLightFadeDistance, 0.0);
        fadeMinLightDistance = exp((1.0 - fadeMinLightDistance) * -15.0 * distMinLightIntensity) * (1.0 - nightVision) + nightVision;
    #endif

    #if !defined END && CAVE_LIGHTING > 0
        vec3 minLighting = vec3(0.005625 + vsBrightness * 0.043) * fadeMinLightDistance;
        #if CAVE_LIGHTING != 100
            #define CAVE_LIGHTING_M CAVE_LIGHTING * 0.01
            minLighting *= CAVE_LIGHTING_M;
        #endif
        minLighting *= vec3(0.45, 0.475, 0.6);
        minLighting *= 1.0 - lightmapYM;
    #else
        vec3 minLighting = vec3(0.0);
    #endif

    minLighting += nightVision * vec3(0.5, 0.5, 0.75);

    return minLighting;
}

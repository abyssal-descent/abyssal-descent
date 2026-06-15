vec3 cloudRainColor = mix(nightMiddleSkyColor, dayMiddleSkyColor, sunFactor);
vec3 cloudAmbientColor = mix(ambientColor * (sunVisibility2 * (0.55 + 0.17 * noonFactor) + 0.35), cloudRainColor * 0.5, rainFactor) * mix(CLOUD_NIGHT_AMBIENT_MULTIPLIER, CLOUD_AMBIENT_MULTIPLIER, sunVisibility2);
vec3 cloudLightColor   = mix(
    lightColor * 1.3,
    cloudRainColor * 0.45,
    noonFactor * rainFactor
) * mix(CLOUD_NIGHT_LIGHT_MULTIPLIER, CLOUD_LIGHT_MULTIPLIER, sunVisibility2);

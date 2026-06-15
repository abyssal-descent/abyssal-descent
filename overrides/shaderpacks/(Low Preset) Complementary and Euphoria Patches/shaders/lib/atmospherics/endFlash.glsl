vec3 DrawEndFlash(vec3 nViewPos, float VdotU, float dither) {
    vec3 worldEndFlashPosition = mat3(gbufferModelViewInverse) * endFlashPosition;
    worldEndFlashPosition = normalize(worldEndFlashPosition);
    vec3 nViewPosWorld = mat3(gbufferModelViewInverse) * nViewPos;
    nViewPosWorld = normalize(nViewPosWorld);

    vec3 horizontalEndPos = normalize(vec3(worldEndFlashPosition.x, 0.0, worldEndFlashPosition.z));
    vec3 horizontalViewPos = normalize(vec3(nViewPosWorld.x, 0.0, nViewPosWorld.z));
    float horizDirFactor = pow(max0(dot(horizontalEndPos, horizontalViewPos)), 0.2);

    float dirFactor = pow(max0(dot(worldEndFlashPosition, nViewPosWorld)), 10.0);

    float verticalDist = abs(nViewPosWorld.y - worldEndFlashPosition.y);
    float verticalFalloff = exp(-pow2(verticalDist * 5.5));

    float endFlashFactor = endFlashIntensityM * dirFactor * verticalFalloff;

    if (endFlashFactor < 0.001) return vec3(0.0);

    float time = frameTimeCounter * 0.05;
    float pulse = sin(time * 3.0) * 0.5 + 0.5;

    vec2 noiseCoord = horizontalViewPos.xz * 0.5 + time * 0.05;
    float noise1 = texture2DLod(noisetex, noiseCoord, 0).r;
    float noise2 = texture2DLod(noisetex, noiseCoord * 2.7 - time * 0.17, 0).g;
    float noise3 = texture2DLod(noisetex, noiseCoord * 0.5 + time * 0.05, 0).b;

    float rayFactor = pow(max0(noise1 * noise2), 1.5) * 2.0;

    float stripeFactor = pow(horizDirFactor, 2.0 + 4.0 * pulse);

    // Inner core and wave animations
    float radius = 1.0 + sin(time * 2.0) * 0.1;
    float distFromCenter = length(dot(horizontalEndPos, horizontalViewPos));
    float waveFront = smoothstep(0.0, 0.2, 1.0 - abs(distFromCenter - radius) * (4.0 + pulse * 4.0));
    float core = pow(horizDirFactor, 1.0 + pulse * 2.0) * (1.0 + noise3 * 0.5);

    float flashIntensity = mix(core, waveFront, 0.5) * endFlashFactor * (0.6 + rayFactor * 0.8);
    flashIntensity *= stripeFactor;

    vec3 orangeColor = mix(endOrangeCol, vec3(1.0), 0.3) * (1.2 + noise2 * 1.3);

    vec3 finalColor = saturateColors(orangeColor, 0.8) * flashIntensity * 0.7;

    return finalColor;
}

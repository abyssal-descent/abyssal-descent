#ifndef INCLUDE_SKY_COLORS
    #define INCLUDE_SKY_COLORS

    #ifdef OVERWORLD
        #ifdef SAVE_SKYBOX_DATA
            vec4 skyColorTexture = texelFetch(colortex14, texelCoord, 0);
            int hasCustomSky = int(texelFetch(colortex6, texelCoord, 0).g * 255.1);
            // float skyTextureLuminance = dot(skyColorTexture.rgb, vec3(0.2126, 0.7152, 0.0722));
            // float skyColorLuminance = dot(skyColor, vec3(0.2126, 0.7152, 0.0722));
            // vec3 skyColorTextureTweaked = nightFactor > 0
            //                             ? (skyTextureLuminance < skyColorLuminance ? skyColorTexture.rgb : skyColor)
            //                             : (skyTextureLuminance > skyColorLuminance ? skyColorTexture.rgb : skyColor);
            vec3 skyColorTweaked = hasCustomSky == 238 || skyColorTexture.rgb != vec3(0.0) ? skyColorTexture.rgb : skyColor;
        #else
            vec3 skyColorTweaked = skyColor;
        #endif

        vec3 skyColorSqrt = sqrt(skyColorTweaked);
        // Doing these things because vanilla skyColor gets to 0 during a thunderstorm
        float invRainStrength2 = (1.0 - rainStrength) * (1.0 - rainStrength);
        vec3 skyColorM = mix(max(skyColorSqrt, vec3(0.63, 0.67, 0.73)), skyColorSqrt, invRainStrength2);
        vec3 skyColorM2 = mix(max(skyColorTweaked, sunFactor * vec3(0.265, 0.295, 0.35)), skyColorTweaked, invRainStrength2);

        #ifdef SPECIAL_BIOME_WEATHER
            vec3 nmscSnowM = inSnowy * vec3(-0.1, 0.3, 0.6);
            vec3 nmscDryM = inDry * vec3(-0.1, -0.2, -0.3);
            vec3 ndscSnowM = inSnowy * vec3(-0.25, -0.01, 0.25);
            vec3 ndscDryM = inDry * vec3(-0.05, -0.09, -0.1);
        #else
            vec3 nmscSnowM = vec3(0.0), nmscDryM = vec3(0.0), ndscSnowM = vec3(0.0), ndscDryM = vec3(0.0);
        #endif
        #if RAIN_STYLE == 2
            vec3 nmscRainMP = vec3(-0.15, 0.025, 0.1);
            vec3 ndscRainMP = vec3(-0.125, -0.005, 0.125);
            #ifdef SPECIAL_BIOME_WEATHER
                vec3 nmscRainM = inRainy * ndscRainMP;
                vec3 ndscRainM = inRainy * ndscRainMP;
            #else
                vec3 nmscRainM = ndscRainMP;
                vec3 ndscRainM = ndscRainMP;
            #endif
        #else
            vec3 nmscRainM = vec3(0.0), ndscRainM = vec3(0.0);
        #endif
        vec3 nuscWeatherM = vec3(0.1, 0.0, 0.1);
        vec3 nmscWeatherM = vec3(-0.1, -0.4, -0.6) + vec3(0.0, 0.06, 0.12) * noonFactor;
        vec3 ndscWeatherM = vec3(-0.15, -0.3, -0.42) + vec3(0.0, 0.02, 0.08) * noonFactor;

        vec3 noonUpSkyColor     = pow(skyColorM, vec3(2.9)) * (vec3(0.85, 0.92, 0.81) + rainFactor * nuscWeatherM);
        vec3 noonMiddleSkyColor = pow(skyColorM, vec3(1.5)) * (vec3(1.3) + rainFactor * (nmscWeatherM + nmscRainM + nmscSnowM + nmscDryM))
                                + noonUpSkyColor * 0.65;
        vec3 noonDownSkyColor   = skyColorM * (vec3(0.9) + rainFactor * (ndscWeatherM + ndscRainM + ndscSnowM + ndscDryM))
                                + noonUpSkyColor * 0.25;

        vec3 sunsetUpSkyColor     = skyColorM2 * (vec3(0.72, 0.522, 0.47) + vec3(0.1, 0.2, 0.35) * rainFactor2);
        vec3 sunsetMiddleSkyColor = skyColorM2 * (vec3(1.8, 1.3, 1.2) + vec3(0.15, 0.25, -0.05) * rainFactor2);
        vec3 sunsetDownSkyColorP  = vec3(1.45, 0.86, 0.5) - vec3(0.8, 0.3, 0.0) * rainFactor;
        vec3 sunsetDownSkyColor   = sunsetDownSkyColorP * 0.5 + 0.25 * sunsetMiddleSkyColor;

        vec3 dayUpSkyColor     = mix(noonUpSkyColor, sunsetUpSkyColor, invNoonFactor2);
        vec3 dayMiddleSkyColor = mix(noonMiddleSkyColor, sunsetMiddleSkyColor, invNoonFactor2);
        vec3 dayDownSkyColor   = mix(noonDownSkyColor, sunsetDownSkyColor, invNoonFactor2);

        vec3 nightColFactor      = 0.9 * vec3(0.07, 0.14, 0.24) * (1.0 - 0.5 * rainFactor) + skyColorTweaked;
        vec3 nightUpSkyColor     = pow(nightColFactor, vec3(0.90)) * 0.45;
        vec3 nightMiddleSkyColor = sqrt(nightUpSkyColor) * 0.65;
        vec3 nightDownSkyColor   = nightMiddleSkyColor * vec3(0.82, 0.82, 0.88);
    #endif

#endif //INCLUDE_SKY_COLORS

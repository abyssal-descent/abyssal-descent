#ifndef INCLUDE_ENDER_BEAMS
    #define INCLUDE_ENDER_BEAMS

    #include "/lib/colors/lightAndAmbientColors.glsl"

    vec2 wind = vec2(frameTimeCounter * 0.001 * END_BEAM_SPEED);

    float BeamNoise(vec2 planeCoord, vec2 wind) {
        float noise = texture2DLod(noisetex, planeCoord * 0.175   - wind, 0.0).b * 0.5;
              noise+= texture2DLod(noisetex, planeCoord * 0.04375 + wind * 0.5, 0.0).b * 2.0;
              noise+= texture2DLod(noisetex, planeCoord * 0.7     - wind, 0.0).b * 0.5;

        return noise / 3.0;
    }

    vec3 DrawEnderBeams(vec3 playerPos, vec3 nViewPos, float scale) {
    #ifndef END_BEAMS
        return vec3(0.0);
    #else
        float beamPowBeforeAltitude = 1.0;
        float beamPowAfterAltitude = END_BEAM_POW;
        float lPlayerPosXZ = length(playerPos.xz);
        float beamPurpleReducer = vlFactor;
        float beamOrangeIncreaser = vlFactor * 1.5;
        float beamHeightIncreaser = 1.0;

        #if defined END_FLASHES && EP_END_FLASH % 2 == 0
            vec3 worldEndFlashPosition = mat3(gbufferModelViewInverse) * endFlashPosition;
            worldEndFlashPosition = normalize(vec3(worldEndFlashPosition.x, 0.0, worldEndFlashPosition.z));
            vec3 nViewPosWorld = mat3(gbufferModelViewInverse) * nViewPos;
            vec3 nViewPosWorldM = normalize(vec3(nViewPosWorld.x, 0.0, nViewPosWorld.z));

            float endFlashDirectionFactor = pow(max0(dot(worldEndFlashPosition, nViewPosWorldM)), (32.0 - 24.0 * vlFactor) * END_BEAM_FLASH_NARROWNESS);
            float endFlashFactor = endFlashIntensityM * endFlashDirectionFactor;

            endFlashFactor *= smoothstep(0.0, 512.0, lPlayerPosXZ);

            beamOrangeIncreaser = mix(beamOrangeIncreaser, 1.5, endFlashFactor);
            beamPurpleReducer = mix(beamPurpleReducer, 1.5, endFlashFactor);
            beamHeightIncreaser = mix(beamHeightIncreaser, END_BEAM_FLASH_HEIGHT_MULTIPLIER, endFlashFactor);

            beamPowBeforeAltitude *= 1.0 - endFlashFactor;
            beamPowAfterAltitude *= 1.0 - 0.4 * endFlashFactor * END_BEAM_FLASH_POW_MULTIPLIER; // make sure that it does not get <= 0
        #endif

        vec3 beamPurple = normalize(endColorBeam * endColorBeam * endColorBeam) * (2.5 - beamPurpleReducer) * E_BEAM_I;
        vec3 beamOrange = endOrangeCol * (300.0 + 700.0 * beamOrangeIncreaser);

        vec2 planeCoordRaw = playerPos.xz + cameraPosition.xz;
        vec2 planeCoord = planeCoordRaw * 0.0007 * scale * END_BEAM_SCALE;

        float noise = BeamNoise(planeCoord, wind);
        float fireNoise = texture2DLod(noisetex, abs(planeCoord * 0.1) - wind, 0.0).b;

        float uncenteredDistance = (2000.0 * pow2(noise) + 40.0 * fireNoise) * 0.001 * END_BEAM_HEIGHT * beamHeightIncreaser * (250.0 + 0.5 * lPlayerPosXZ);
        float altitude = playerPos.y + cameraPosition.y;
        float signedAltitude = altitude - END_BEAM_CENTER_ALT;
        float altitudeDis = abs(signedAltitude);
        float altitudeFactor = 0.5 * smoothstep(uncenteredDistance, 0.0, altitudeDis)
                             + 0.5 * smoothstep(4.0 * uncenteredDistance, 0.0, altitudeDis);

        noise = pow2(noise) * 0.7 + 0.3 * fireNoise;

        #if END_BEAM_DIRECTION_BIAS != 0
            float beamDirectionBias = clamp(END_BEAM_DIRECTION_BIAS * 0.01, -1.0, 1.0);
            float directionTransitionWidth = max(uncenteredDistance * 0.115, 1.0);
            float aboveContribution = smoothstep(-directionTransitionWidth, directionTransitionWidth, signedAltitude);
            float belowContribution = 1.0 - aboveContribution;

            float sideFactor = aboveContribution * (1.0 - max0(-beamDirectionBias))  // above fades out when bias is negative
                            + belowContribution * (1.0 - max0(beamDirectionBias));  // below fades out when bias is positive
            noise *= sideFactor + 0.000001;

            #if END_BEAM_DIRECTION_BIAS == 100 || END_BEAM_DIRECTION_BIAS == -100
                // This brings some wave details, was some happy accident haha
                altitudeFactor *= pow6(sideFactor);
            #endif
        #endif

        noise = pow(noise, beamPowBeforeAltitude);
        noise *= pow(altitudeFactor, 4.0);
        noise = pow(noise, beamPowAfterAltitude);

        vec3 beamColor = beamPurple;
        beamColor += beamOrange * (0.0015 + 0.2 * smoothstep(0.0, 256.0, lPlayerPosXZ) * pow2(pow2(fireNoise - 0.5)));

        vec3 beams = noise * END_BEAM_INTENSITY * beamColor * (1.0 + smoothstep(0.0, 128.0, lPlayerPosXZ));

        if(any(isnan(beams))) beams = vec3(0.0);

        return beams;
    #endif
    }

#endif //INCLUDE_ENDER_BEAMS

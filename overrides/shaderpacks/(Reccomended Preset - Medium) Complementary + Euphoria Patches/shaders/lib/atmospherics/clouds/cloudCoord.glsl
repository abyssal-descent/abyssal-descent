#ifndef INCLUDE_CLOUD_COORD
    #define INCLUDE_CLOUD_COORD

    #include "/lib/shaderSettings/clouds.glsl"

    const float cloudNarrowness = CLOUD_NARROWNESS;

        // Thanks to SixthSurge
        vec2 GetRoundedCloudCoord(vec2 pos, float cloudRoundness) { // cloudRoundness is meant to be 0.125 for clouds and 0.35 for cloud shadows
            vec2 coord = pos.yx + 0.5;
            #ifdef ROTATE_REIMAGINED_CLOUDS_90_NEW
                coord = coord.yx;
            #endif
            vec2 signCoord = sign(coord);
            coord = abs(coord) + 1.0;
            vec2 i, f = modf(coord, i);
            f = smoothstep(0.5 - cloudRoundness, 0.5 + cloudRoundness, f);
            coord = i + f;
            return (coord - 0.5) * signCoord / 256.0;
        }

    vec3 ModifyTracePos(vec3 tracePos, int cloudAltitude) {
        #if CLOUD_SPEED_MULT == 100
            float wind = syncedTime;
        #else
            #define CLOUD_SPEED_MULT_M CLOUD_SPEED_MULT * 0.01
            float wind = frameTimeCounter * CLOUD_SPEED_MULT_M;
        #endif

        if (cloudAltitude != cloudAlt1i) {
            wind *= CLOUD_LAYER2_SPEED_MULT;
        }

        #if CLOUD_DIRECTION == 1
            tracePos.x -= wind;
            tracePos.z += cloudAltitude * 64.0;
        #else
            tracePos.z -= wind;
            tracePos.x += cloudAltitude * 64.0;
        #endif

        tracePos.xz *= cloudNarrowness;
        return tracePos.xyz;
    }

#endif

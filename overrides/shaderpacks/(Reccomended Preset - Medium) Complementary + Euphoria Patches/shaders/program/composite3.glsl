//////////////////////////////////////////
// Complementary Shaders by EminGT      //
// With Euphoria Patches by SpacEagle17 //
//////////////////////////////////////////
//Common//
#include "/lib/common.glsl"
#include "/lib/shaderSettings/composite3.glsl"

//////////Fragment Shader//////////Fragment Shader//////////Fragment Shader//////////
#ifdef FRAGMENT_SHADER

#if WORLD_BLUR > 0 || TILT_SHIFT != 0 || TILT_SHIFT2 != 0
    noperspective in vec2 texCoord;

    flat in vec3 upVec, sunVec;
#endif

//Pipeline Constants//
#if WORLD_BLUR > 0 || TILT_SHIFT != 0 || TILT_SHIFT2 != 0
    const bool colortex0MipmapEnabled = true;
#endif

//Common Variables//
#if WORLD_BLUR > 0 || TILT_SHIFT != 0 || TILT_SHIFT2 != 0
    #if (WORLD_BLUR == 2 || TILT_SHIFT != 0 || TILT_SHIFT2 != 0) && WB_DOF_FOCUS >= 0
        #if WB_DOF_FOCUS == 0
            uniform float centerDepthSmooth;
        #else
            float centerDepthSmooth = (far * (WB_DOF_FOCUS - near)) / (WB_DOF_FOCUS * (far - near));
        #endif
    #endif
#endif

#if WORLD_BLUR > 0 || TILT_SHIFT != 0 || TILT_SHIFT2 != 0
    float SdotU = dot(sunVec, upVec);
    float sunFactor = SdotU < 0.0 ? clamp(SdotU + 0.375, 0.0, 0.75) / 0.75 : clamp(SdotU + 0.03125, 0.0, 0.0625) / 0.0625;

    float DoFSneaking = isSneaking * float(heldItemId == 45014 || heldItemId2 == 45014);
    bool isDoFGUI = hideGUI == 0 && (heldItemId == 45014 || heldItemId2 == 45014); // while holding a spyglass

    vec2 dofOffsets[18] = vec2[18](
        vec2( 0.0    ,  0.25  ),
        vec2(-0.2165 ,  0.125 ),
        vec2(-0.2165 , -0.125 ),
        vec2( 0      , -0.25  ),
        vec2( 0.2165 , -0.125 ),
        vec2( 0.2165 ,  0.125 ),
        vec2( 0      ,  0.5   ),
        vec2(-0.25   ,  0.433 ),
        vec2(-0.433  ,  0.25  ),
        vec2(-0.5    ,  0     ),
        vec2(-0.433  , -0.25  ),
        vec2(-0.25   , -0.433 ),
        vec2( 0      , -0.5   ),
        vec2( 0.25   , -0.433 ),
        vec2( 0.433  , -0.2   ),
        vec2( 0.5    ,  0     ),
        vec2( 0.433  ,  0.25  ),
        vec2( 0.25   ,  0.433 )
    );
#endif

vec2 getPolygonOffset(float angle, int sides, float radius) { // based on the hexablur function by halcy from https://www.shadertoy.com/view/4tK3WK
    float rotationRadians = DOF_SHAPE_ROTATION_DEGREES * (pi / 180.0);

    // Calculate regular polygon coordinates
    float segmentAngle = 2.0 * pi / float(sides);
    float r = cos(pi / float(sides)) / cos(mod(angle, segmentAngle) - pi / float(sides));
    r *= radius;

    vec2 baseCoord = vec2(sin(angle), cos(angle)) * r;
    return rotate(rotationRadians) * baseCoord;
}

//Common Functions//
#if WORLD_BLUR > 0 || TILT_SHIFT != 0 || TILT_SHIFT2 != 0
    void DoWorldBlur(inout vec3 color, float z1, float lViewPos0) {
        if (z1 < 0.56) return;
        vec3 dof = vec3(0.0);
        vec3 cocColor = vec3(1, 0, 0.8) * 10.0;
        vec2 dofScale = vec2(1.0, aspectRatio);

        #if WORLD_BLUR == 1 // Distance Blur
            #ifdef OVERWORLD
                float dbMult;
                if (isEyeInWater == 0) {
                    dbMult = mix(WB_DB_NIGHT_I, WB_DB_DAY_I, sunFactor * eyeBrightnessM);
                    dbMult = mix(dbMult, WB_DB_RAIN_I, rainFactor * eyeBrightnessM);
                } else dbMult = WB_DB_WATER_I;
            #elif defined NETHER
                float dbMult = WB_DB_NETHER_I;
            #elif defined END
                float dbMult = WB_DB_END_I;
            #endif
            float coc = clamp(lViewPos0 * 0.001, 0.0, 0.1) * dbMult * 0.03;
        #elif WORLD_BLUR == 2 || TILT_SHIFT != 0 || TILT_SHIFT2 != 0 // Depth Of Field
            #if TILT_SHIFT != 0
                float tiltOffset = texCoord.y * 2.0 - 1.0;
                tiltOffset *= 0.0007 * TILT_SHIFT;
            #else
                float tiltOffset = 0.0;
            #endif
            #if TILT_SHIFT2 != 0
                float shiftOffset = texCoord.x * 2.0 - 1.0;
                shiftOffset *= 0.0007 * TILT_SHIFT2;
            #else
                float shiftOffset = 0.0;
            #endif
            #if WB_DOF_FOCUS >= 0
                float coc = max(abs(z1 - centerDepthSmooth + tiltOffset + shiftOffset) * 0.125 * WB_DOF_I - 0.0001, 0.0);
            #elif WB_DOF_FOCUS == -1
                float coc = clamp(abs(lViewPos0 * 0.005 - pow2(vsBrightness) + tiltOffset + shiftOffset), 0.0, 0.1) * WB_DOF_I * 0.03;
            #endif
        #endif
        #ifdef DOF_VIEW_FOCUS_NEW2
            float cocView = float(coc < 0.005 + 0.001 * abs(max(float(TILT_SHIFT), float(TILT_SHIFT2))) && coc > 0 && isDoFGUI);
        #endif
        #if TILT_SHIFT == 0 && TILT_SHIFT2 == 0
            coc = coc / sqrt(coc * coc + 0.1);
        #endif

        #ifdef WB_FOV_SCALED
            coc *= gbufferProjection[1][1] * 0.8;
        #endif
        #ifdef WB_CHROMATIC
            float midDistX = texCoord.x - 0.5;
            float midDistY = texCoord.y - 0.5;
            vec2 chromaticScale = vec2(midDistX, midDistY);
            chromaticScale = sign(chromaticScale) * sqrt(abs(chromaticScale));
            chromaticScale *= vec2(1.0, viewHeight / viewWidth);
            vec2 aberration = (15.0 / vec2(viewWidth, viewHeight)) * chromaticScale * coc;
        #endif

        #if DOF_SHAPE == 0 // Original mode
            #ifdef WB_ANAMORPHIC
                dofScale *= vec2(0.5, 1.5);
            #endif
        #endif

        if (coc * 0.5 > 1.0 / max(viewWidth, viewHeight)) {
            #if DOF_SHAPE == 0 // Original implementation
                for (int i = 0; i < 18; i++) {
                    vec2 offset = dofOffsets[i] * coc * 0.0085 * dofScale;
                    float lod = log2(viewHeight * aspectRatio * coc * 0.75 / 320.0);
                    #ifndef WB_CHROMATIC
                        dof += texture2DLod(colortex0, texCoord + offset, lod).rgb;
                    #else
                        dof += vec3(texture2DLod(colortex0, texCoord + offset + aberration, lod).r,
                                    texture2DLod(colortex0, texCoord + offset             , lod).g,
                                    texture2DLod(colortex0, texCoord + offset - aberration, lod).b);
                    #endif
                }
                dof /= 18.0;
            #elif DOF_SHAPE >= 3 && DOF_SHAPE <= 8
                float totalWeight = 0.0;
                float lod = log2(viewHeight * aspectRatio * coc * 0.75 / 320.0);

                int polygonSamples = int(DOF_POLYGON_SAMPLES * 10);

                // Sample in multiple concentric rings to fill the polygon
                for (int ring = 1; ring <= DOF_POLYGON_RINGS; ring++) {
                    float ringFactor = float(ring) / float(DOF_POLYGON_RINGS);

                    // For each polygon ring, sample multiple points
                    for (int i = 0; i < polygonSamples; i++) {
                        float angle = float(i) * (2.0 * pi) / float(polygonSamples);

                        vec2 offset = getPolygonOffset(angle, DOF_SHAPE, ringFactor * coc * 0.01) * dofScale;
                        float weight = 1.0 - 0.2 * ringFactor; // Weight based on distance from center

                        #ifndef WB_CHROMATIC
                            vec3 sampleColor = texture2DLod(colortex0, texCoord + offset, lod).rgb;
                            dof += sampleColor * weight;
                        #else
                            dof += vec3(
                                texture2DLod(colortex0, texCoord + offset + aberration, lod).r,
                                texture2DLod(colortex0, texCoord + offset, lod).g,
                                texture2DLod(colortex0, texCoord + offset - aberration, lod).b
                            ) * weight;
                        #endif

                        totalWeight += weight;
                    }
                }

                dof /= totalWeight;
            #endif

            #ifdef DOF_SNEAKING
                color = mix(color, dof, DoFSneaking);
            #else
                color = dof;
            #endif
        }
        #ifdef DOF_VIEW_FOCUS_NEW2
            #ifdef DOF_SNEAKING
                color = mix(color, cocColor, cocView * DoFSneaking);
            #else
                color = mix(color, cocColor, cocView);
            #endif
        #endif
    }
#endif

//Includes//
#if (WORLD_BLUR > 0 || TILT_SHIFT != 0 || TILT_SHIFT2 != 0) && defined BLOOM_FOG_COMPOSITE3
    #include "/lib/atmospherics/fog/bloomFog.glsl"
#endif

//Program//
void main() {
    vec3 color = texelFetch(colortex0, texelCoord, 0).rgb;

    #if WORLD_BLUR > 0 || TILT_SHIFT != 0 || TILT_SHIFT2 != 0
        float z1 = texelFetch(depthtex1, texelCoord, 0).r;
        float z0 = texelFetch(depthtex0, texelCoord, 0).r;

        vec4 screenPos = vec4(texCoord, z0, 1.0);
        vec4 viewPos = gbufferProjectionInverse * (screenPos * 2.0 - 1.0);
        viewPos /= viewPos.w;
        float lViewPos = length(viewPos.xyz);

        #if defined DISTANT_HORIZONS || defined VOXY
            #ifdef DISTANT_HORIZONS
                float z0lod = texelFetch(dhDepthTex, texelCoord, 0).r;
                vec4 screenPosLod = vec4(texCoord, z0lod, 1.0);
                vec4 viewPosLod = dhProjectionInverse * (screenPosLod * 2.0 - 1.0);
            #elif defined VOXY
                float z0lod = texelFetch(vxDepthTexTrans, texelCoord, 0).r;
                vec4 screenPosLod = vec4(texCoord, z0lod, 1.0);
                vec4 viewPosLod = vxProjInv * (screenPosLod * 2.0 - 1.0);
            #endif
            viewPosLod /= viewPosLod.w;
            lViewPos = min(lViewPos, length(viewPosLod.xyz));
        #endif

        #ifdef DOF_SNEAKING
            if (DoFSneaking > 0.1) {
        #endif
            DoWorldBlur(color, z1, lViewPos);
        #ifdef DOF_SNEAKING
            }
        #endif

        #ifdef BLOOM_FOG_COMPOSITE3
            color *= GetBloomFog(lViewPos); // Reminder: Bloom Fog can move between composite1-3
        #endif
    #endif

    #if PIXELATED_SCREEN_SIZE > 0
        if (int(texelFetch(colortex6, texelCoord, 0).g * 255.1) == 252) { // Selection Outline
            color *= max(abs(100.0 - PIXELATED_SCREEN_SIZE * 2.0), 1.0);
            #if SELECT_OUTLINE == 4 || SELECT_OUTLINE == 1
                color *= 4;
            #endif
        }
    #endif

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(color, 1.0);
}

#endif

//////////Vertex Shader//////////Vertex Shader//////////Vertex Shader//////////
#ifdef VERTEX_SHADER

#if WORLD_BLUR > 0 || TILT_SHIFT != 0 || TILT_SHIFT2 != 0
    noperspective out vec2 texCoord;

    flat out vec3 upVec, sunVec;
#endif

//Attributes//

//Common Variables//

//Common Functions//

//Includes//

//Program//
void main() {
    gl_Position = ftransform();

    #if WORLD_BLUR > 0 || TILT_SHIFT != 0 || TILT_SHIFT2 != 0
        texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
        upVec = normalize(gbufferModelView[1].xyz);
        sunVec = GetSunVector();
    #endif
}

#endif

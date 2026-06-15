#include "/lib/shaderSettings/mainLighting.glsl"
#include "/lib/shaderSettings/cloudsAndLighting.glsl"
#ifdef AURORA_INFLUENCE
    #include "/lib/atmospherics/auroraBorealis.glsl"
#endif

//Lighting Includes//
#include "/lib/colors/lightAndAmbientColors.glsl"
#include "/lib/lighting/ggx.glsl"
#include "/lib/lighting/minimumLighting.glsl"

#if SHADOW_QUALITY > -1 && (defined OVERWORLD || defined END) && !defined DH_TERRAIN && !defined DH_WATER && !defined VOXY_PATCH
    #include "/lib/lighting/shadowSampling.glsl"
#endif

#if HELD_LIGHTING_MODE >= 1
    #include "/lib/lighting/heldLighting.glsl"
#endif

#ifdef BLOCKLIGHT_CAUSTICS
    #include "/lib/lighting/blocklightCaustics.glsl"
#endif

#ifdef CLOUD_SHADOWS
    #include "/lib/lighting/cloudShadows.glsl"
#endif

#ifdef LIGHT_COLOR_MULTS
    #include "/lib/colors/colorMultipliers.glsl"
#endif

#if defined MOON_PHASE_INF_LIGHT || defined MOON_PHASE_INF_REFLECTION
    #include "/lib/colors/moonPhaseInfluence.glsl"
#endif

#if COLORED_LIGHTING_INTERNAL > 0
    #include "/lib/voxelization/lightVoxelization.glsl"
#endif

#if DRAGON_DEATH_EFFECT_INTERNAL > 0
    #define ENDCRYSTAL_SAMPLER_DEFINE
    uniform isampler2D endcrystal_sampler;
#endif

#ifdef PHOTONICS_LIGHTING
    #include "/lib/shaderSettings/photonics.glsl"
#endif

vec3 highlightColor = normalize(pow(lightColor, vec3(0.37))) * (0.3 + 1.5 * sunVisibility2) * (1.0 - 0.85 * rainFactor);

//Lighting//
void DoLighting(inout vec4 color, inout vec3 shadowMult, vec3 playerPos, vec3 viewPos, float lViewPos, vec3 geoNormal, vec3 normalM, float dither,
                vec3 worldGeoNormal, vec2 lightmap, bool noSmoothLighting, bool noDirectionalShading, bool noVanillaAO,
                bool centerShadowBias, int subsurfaceMode, float smoothnessG, float highlightMult, float emission, inout float purkinjeOverwrite, bool isLightSource,
                inout float enderDragonDead) {
    #ifdef WORLD_CURVATURE
        playerPos.y += doWorldCurvature(playerPos.xz);
    #endif

    vec2 oldLightmap = lightmap.xy;
    #ifdef PHOTONICS_LIGHTING
        float phRtCoverage = getPhotonicsFade(playerPos);
    #endif

    #ifdef DO_PIXELATION_EFFECTS
        vec2 pixelationOffset = ComputeTexelOffset(tex, texCoord);

        #if defined PIXELATED_SHADOWS || defined PIXELATED_BLOCKLIGHT
            #if PIXELATED_SHADOWS_MODE == 0
                vec3 playerPosPixelated = TexelSnap(playerPos, pixelationOffset);
            #else
                vec3 playerPosPixelated = floor((playerPos + cameraPosition) * PIXELATED_SHADOWS_MODE + 0.001) / PIXELATED_SHADOWS_MODE - cameraPosition + 0.5 / PIXELATED_SHADOWS_MODE;
            #endif
        #endif

        #ifdef PIXELATED_SHADOWS
            #ifdef GBUFFERS_ENTITIES
                if (entityId == 50076) { // Boats
                    playerPosPixelated.y += 0.38; // consistentBOAT2176
                }
            #endif
            #ifdef GBUFFERS_TERRAIN
                if (subsurfaceMode == 1) {
                    playerPosPixelated.y += 0.05; // Fixes grounded foliage having dark bottom pixels depending on the random y-offset
                }
            #endif
        #endif
        #ifdef PIXELATED_BLOCKLIGHT
            if (!noSmoothLighting) {
                lightmap = clamp(TexelSnap(lightmap, pixelationOffset), 0.0, 1.0);
            }
        #endif
    #endif

    float NdotN = dot(normalM, northVec);
    float absNdotN = abs(NdotN);
    float NdotE = dot(normalM, eastVec);
    float absNdotE = abs(NdotE);
    float NdotL = dot(normalM, lightVec);

    float lightmapY2 = pow2(lightmap.y);
    float lightmapYM = smoothstep1(lightmap.y);
    float subsurfaceHighlight = 0.0;
    float ambientMult = 1.0;
    vec3 subsurfaceColor = vec3(1.0);
    #if defined AURORA_INFLUENCE && !(defined DEFERRED1 || defined COMPOSITE1)
        ambientColor = getAuroraAmbientColor(ambientColor, viewPos, 0.035, AURORA_TERRAIN_INFLUENCE_INTENSITY, 0.9);
    #endif

    #if BLOOD_MOON > 0
        float bloodMoonFactor = getBloodMoon(sunVisibility);
        lightColor *= 1.0 + bloodMoonFactor * vec3(0.6, -0.3, -0.3);
        ambientColor *= 1.0 + bloodMoonFactor * vec3(0.6, -0.3, -0.3);
        subsurfaceColor = mix(vec3(1.0), vec3(1.3, 0.2, 0.2), bloodMoonFactor);
    #endif

    vec3 lightColorM = lightColor;
    vec3 ambientColorM = ambientColor;
    vec3 nViewPos = normalize(viewPos);

    #if defined LIGHT_COLOR_MULTS && !defined GBUFFERS_WATER // lightColorMult is defined early in gbuffers_water
        lightColorMult = GetLightColorMult();
    #endif
    vec2 lightningAdd = vec2(0);
    vec2 deathFlashAdd = vec2(0);
    vec3 lightningPos = vec3(0);
    #ifdef RAIN_ATMOSPHERE
        float lightningDistance = 550.0;
        lightningPos = getLightningPos(playerPos, lightningBoltPosition.xyz, false);
        float lightningFadeOut = max(1.0 - length(lightningPos) / lightningDistance, 0.0);
        float lightningFadeOutExp = exp((1.0 - lightningFadeOut) * -15.0);
        vec3 normalLightning = mat3(gbufferModelViewInverse) * mix(geoNormal, normalM, 0.25);
        float lightningNormalGradient = 0.12;
        if (subsurfaceMode == 1) lightningNormalGradient = mix(lightningNormalGradient, 0.45, lightningFadeOutExp);
        lightningAdd = (lightningFlashEffect(lightningPos, normalLightning, lightningDistance, lightningNormalGradient, subsurfaceMode) * 10.0 + mix(0.1, 0.0 , lightningFadeOut)) * isLightningActive();
        ambientColorM += lightningAdd.x;
    #endif
    #if DRAGON_DEATH_EFFECT_INTERNAL > 0
        vec3 dragonPosition = vec3(0, 80, 0) - cameraPosition;
        int isDying = texelFetch(endcrystal_sampler, ivec2(35, 0), 0).r;
        float dragonDeathFactor = 0.0001 * isDying;
        float deathFadeFactor = exp(-3.0 * (1.0 - dragonDeathFactor)) * dragonDeathFactor;

        if (dragonDeathFactor < 0.99) {
            vec3 normalMDeath = mat3(gbufferModelViewInverse) * mix(geoNormal, normalM, 0.5);
            vec3 deathFlashPos = getLightningPos(playerPos, dragonPosition, true);
            float effectDistance = 800.0;
            deathFlashAdd = lightningFlashEffect(deathFlashPos, normalMDeath, effectDistance, 0.0, subsurfaceMode) * 35.0 * deathFadeFactor;
            ambientColorM *= mix(1.0, 0.0, deathFadeFactor) + deathFlashAdd.x * saturateColors(sqrt(endOrangeCol), 0.5);
            purkinjeOverwrite = 1.0 * deathFlashAdd.y;
        }
    #endif

    #if defined END && END_CENTER_LIGHTING > 0 && MC_VERSION >= 10900 && (defined GBUFFERS_BLOCK || defined GBUFFERS_ENTITIES || defined GBUFFERS_TERRAIN || defined GBUFFERS_HAND || defined GBUFFERS_WATER) && !defined VOXY_PATCH
        enderDragonDead = 1.0 - texelFetch(colortex5, ivec2(viewWidth-1, viewHeight-1), 0).a;
        vec3 endCenterCol = saturateColors(vec3(END_CENTER_LIGHTING_R, END_CENTER_LIGHTING_G, END_CENTER_LIGHTING_B) * 0.8, 1.1);
        vec3 endCenterPos = vec3(0.5, 60.5, 0.5) - (playerPos + cameraPositionBest);
        endCenterPos.y *= 0.66; // Make it a pill-shaped point light
        float rawDistance = length(endCenterPos);
        float endCenterLightDist = exp(-rawDistance * 0.22);

        float endCenterTimeNoise = frameTimeCounter * 0.075;

        // Get the direction of the noise
        float centerDistance = max(abs(endCenterPos.x), abs(endCenterPos.z)); // Square distance
        float angleOffset = endCenterTimeNoise * 0.75;
        vec2 rotatingDir = vec2(cos(angleOffset), sin(angleOffset));
        float blendFactor = smoothstep(0.5, 3.0, centerDistance); // Prevent artifacts at the center by creating square shape
        vec2 normalizedDir = mix(rotatingDir, normalize(endCenterPos.xz), blendFactor); // Blend square shape

        vec2 endCenterNoiseBase = endCenterPos.xz * 0.03 + endCenterPos.y * 0.015;
        vec2 endCenterNoisePos = endCenterNoiseBase - normalizedDir * 0.3 + endCenterTimeNoise * 0.15;
        float endCenterIntensityNoise = texture2DLod(noisetex, endCenterNoisePos, 0.0).r;
        float endCenterNoiseVariation = sin(endCenterTimeNoise * 6.0 + dot(endCenterPos.xy, endCenterPos.yz) * 0.01);
        float endCenterNoiseIntensity = 0.7 + 0.35 * endCenterIntensityNoise + 0.2 * endCenterNoiseVariation;

        // Hybrid lighting calculation - directional for walls, ambient for floors
        vec3 transformedNormal = mat3(gbufferModelViewInverse) * normalM;
        float normalDot = clamp01(dot(normalize(endCenterPos), transformedNormal));
        float isFloor = clamp01(dot(transformedNormal, vec3(0.0, 1.0, 0.0)) * 2.0);

        // Strong directional lighting for walls, softer lighting for floors
        float directionalFactor = normalDot * 1.3;
        float floorFactor = 0.6 + 0.25 * normalDot;
        float endCenterLight = endCenterLightDist * mix(directionalFactor, floorFactor, isFloor);

        ambientColorM += endCenterLight * endCenterCol * endCenterNoiseIntensity * 5.0 * enderDragonDead;
    #else
        enderDragonDead = 1.0;
    #endif

    int oldSubsurfaceMode = subsurfaceMode;
    #if SSS_STRENGTH == 0
        subsurfaceMode = 0;
    #endif

    #ifdef OVERWORLD
        float skyLightShadowMult = pow2(pow2(lightmapY2));
    #else
        float skyLightShadowMult = 1.0;
    #endif

    #if defined CUSTOM_PBR || defined GENERATED_NORMALS
        float NPdotU = abs(dot(geoNormal, upVec));
    #endif

    // Shadows
    #if defined OVERWORLD || defined END
        #ifdef GBUFFERS_WATER
            //NdotL = mix(NdotL, 1.0, 1.0 - color.a);
        #endif
        #ifdef CUSTOM_PBR
            float geoNdotL = dot(geoNormal, lightVec);
            float geoNdotLM = geoNdotL > 0.0 ? geoNdotL * 10.0 : geoNdotL;
            NdotL = min(geoNdotLM, NdotL);

            NdotL *= 1.0 - 0.7 * (1.0 - pow2(pow2(NdotUmax0))) * NPdotU;
        #endif
        #if SHADOW_QUALITY == -1 && (defined GBUFFERS_TERRAIN || defined DH_TERRAIN || defined DH_WATER || defined VOXY_PATCH)
            if (subsurfaceMode == 1) {
                NdotU = 1.0;
                NdotUmax0 = 1.0;
                NdotL = dot(upVec, lightVec);
            } else if (subsurfaceMode == 2) {
                highlightMult *= NdotL;
                NdotL = mix(NdotL, 1.0, 0.35);
            }

            subsurfaceMode = 0;
        #endif
        float NdotLmax0 = max0(NdotL);
        float NdotLM = NdotLmax0 * 0.9999;

        #ifdef GBUFFERS_TEXTURED
            NdotLM = 1.0;
        #else
            #ifdef GBUFFERS_TERRAIN
                if (subsurfaceMode != 0) {
                    #if defined CUSTOM_PBR && defined POM && POM_QUALITY >= 128 && POM_LIGHTING_MODE == 2
                        shadowMult *= max(pow2(pow2(dot(normalM, geoNormal))), sqrt2(NdotLmax0));
                    #endif
                    NdotLM = 1.0;
                }
                #ifdef SIDE_SHADOWING
                    else
                #endif
            #endif
            #ifdef SIDE_SHADOWING
                NdotLM = max0(NdotL + 0.4) * 0.714;

                #ifdef END
                    NdotLM = sqrt3(NdotLM);
                #endif
            #endif
        #endif

        #if ENTITY_SHADOW == -1 && defined GBUFFERS_ENTITIES || ENTITY_SHADOW <= 1 && defined GBUFFERS_BLOCK
            lightColorM = mix(lightColorM * 0.75, ambientColorM, 0.5 * pow2(pow2(1.0 - NdotLM)));
            NdotLM = NdotLM * 0.75 + 0.25;
        #endif

        if (shadowMult.r > 0.00001) {
            #if SHADOW_QUALITY > -1 && !defined DH_TERRAIN && !defined DH_WATER && !defined VOXY_PATCH
                if (NdotLM > 0.0001) {
                    vec3 shadowMultBeforeLighting = shadowMult;
                    float shadowLength = shadowDistance * 0.9166667 - lViewPos; //consistent08JJ622

                    if (shadowLength > 0.000001) {
                        #if SHADOW_SMOOTHING == 4 || SHADOW_QUALITY == 0
                            float offset = 0.00098;
                        #elif SHADOW_SMOOTHING == 3
                            float offset = 0.00075;
                        #elif SHADOW_SMOOTHING == 2
                            float offset = 0.0005;
                        #elif SHADOW_SMOOTHING == 1
                            float offset = 0.0003;
                        #endif

                        vec3 playerPosM = playerPos;
                        vec3 centerPlayerPos = floor(playerPos + cameraPosition + worldGeoNormal * 0.01) - cameraPosition + 0.5;

                        #if defined DO_PIXELATION_EFFECTS && defined PIXELATED_SHADOWS
                            playerPosM = playerPosPixelated;
                            offset *= 0.75;
                        #endif

                        // Fix light leaking in caves //
                        #ifdef GBUFFERS_TERRAIN
                            if (centerShadowBias || subsurfaceMode == 1) {
                                #ifdef OVERWORLD
                                    playerPosM = mix(centerPlayerPos, playerPosM, 0.5 + 0.5 * lightmapYM);
                                #endif
                            } else {
                                float centerFactor = max(glColor.a, lightmapYM);

                                #if defined PERPENDICULAR_TWEAKS && SHADOW_QUALITY >= 2
                                    // Fake Variable Penumbra Shadows
                                    // Making centerFactor also work in daylight if AO gradient is facing towards sun
                                    if (geoNdotU > 0.99) {
                                        float dFdxGLCA = dFdx(glColor.a);
                                        float dFdyGLCA = dFdy(glColor.a);

                                        if (abs(dFdxGLCA) + abs(dFdyGLCA) > 0.00001) {
                                            vec3 aoGradView = dFdxGLCA * normalize(dFdx(playerPos.xyz))
                                                            + dFdyGLCA * normalize(dFdy(playerPos.xyz));
                                            if (dot(normalize(aoGradView.xz), normalize(ViewToPlayer(lightVec).xz)) < 0.3 + 0.4 * dither)
                                                if (dot(lightVec, upVec) < 0.99999) centerFactor = sqrt1(max0(glColor.a - 0.55) / 0.45);
                                        }
                                    }
                                #endif

                                playerPosM = mix(playerPosM, centerPlayerPos, 0.2 * (1.0 - pow2(pow2(centerFactor))));
                            }
                        #elif defined GBUFFERS_HAND
                            playerPosM = mix(vec3(0.0), playerPosM, 0.2 + 0.8 * lightmapYM);
                        #elif defined GBUFFERS_TEXTURED
                            playerPosM = mix(centerPlayerPos, playerPosM + vec3(0.0, 0.02, 0.0), lightmapYM);
                        #else
                            playerPosM = mix(playerPosM, centerPlayerPos, 0.2 * (1.0 - lightmapYM));
                        #endif

                        // Shadow bias without peter-panning //
                        #ifndef GBUFFERS_TEXTURED
                            #ifdef GBUFFERS_TERRAIN
                                if (subsurfaceMode != 1)
                            #endif
                            {
                                float distanceBias = pow(dot(playerPos, playerPos), 0.75);
                                distanceBias = 0.12 + 0.0008 * distanceBias;
                                float NdotLmax0M = NdotLmax0;
                                #ifdef END_FLASH_SHADOW_INTERNAL
                                    NdotLmax0M = mix(NdotLmax0M, 1.0, endFlashIntensityM);
                                #endif
                                vec3 bias = worldGeoNormal * distanceBias * (2.0 - 0.95 * NdotLmax0M); // 0.95 fixes pink petals noon shadows

                                #ifdef GBUFFERS_TERRAIN
                                    if (subsurfaceMode == 2) {
                                        bias *= vec3(0.0, 0.0, -0.5);
                                        bias.z += 0.25 * signMidCoordPos.x * NdotE;
                                    }
                                #endif

                                playerPosM += bias;
                            }
                        #endif

                        vec3 shadowPos = GetShadowPos(playerPosM);

                        bool leaves = false;
                        #ifdef GBUFFERS_TERRAIN
                            if (subsurfaceMode == 0) {
                                #if defined PERPENDICULAR_TWEAKS && defined SIDE_SHADOWING
                                    offset *= 1.0 + pow2(absNdotN);
                                #endif
                            } else {
                                float VdotL = dot(nViewPos, lightVec);

                                float lightFactor = pow(max(VdotL, 0.0), 10.0) * float(isEyeInWater == 0);
                                if (subsurfaceMode == 1) {
                                    offset = 0.0005235 * lightmapYM + 0.0009765;
                                    shadowPos.z -= max(NdotL * 0.0001, 0.0) * lightmapYM;
                                    subsurfaceHighlight = lightFactor * 0.8;
                                    #ifndef SHADOW_FILTERING
                                        shadowPos.z -= 0.0002;
                                    #endif
                                } else if (subsurfaceMode == 2) {
                                    leaves = true;
                                    offset = 0.0005235 * lightmapYM + 0.0009765;
                                    shadowPos.z -= 0.000175 * lightmapYM;
                                    subsurfaceHighlight = lightFactor * 0.6;
                                    #ifndef SHADOW_FILTERING
                                        NdotLM = mix(NdotL, NdotLM, 0.5);
                                    #endif
                                } else {

                                }
                            }
                        #endif

                        int shadowSampleBooster = int(subsurfaceMode > 0 && lViewPos < 10.0);
                        #if SHADOW_QUALITY == 2 // Medium
                            int shadowSamples = 2 + 2 * shadowSampleBooster;
                        #elif SHADOW_QUALITY == 3 // High
                            int shadowSamples = 4 + 4 * shadowSampleBooster;
                        #elif SHADOW_QUALITY == 4 // Very High
                            int shadowSamples = 8 + 8 * shadowSampleBooster;
                        #elif SHADOW_QUALITY == 5 // Ultra
                            int shadowSamples = 16 + 16 * shadowSampleBooster;
                        #else
                            int shadowSamples = 0;
                        #endif

                        shadowMult *= GetShadow(shadowPos, lightmap.y, offset, shadowSamples, leaves, playerPos);
                    }

                    float shadowSmooth = 16.0;
                    if (shadowLength < shadowSmooth) {
                        float shadowMixer = max0(shadowLength / shadowSmooth);

                        #ifdef GBUFFERS_TERRAIN
                            if (subsurfaceMode != 0) {
                                float shadowMixerM = pow2(shadowMixer);

                                if (subsurfaceMode == 1) skyLightShadowMult *= mix(0.6 + 0.3 * pow2(noonFactor), 1.0, shadowMixerM);
                                else skyLightShadowMult *= mix(NdotL * 0.4999 + 0.5, 1.0, shadowMixerM);

                                subsurfaceHighlight *= shadowMixer;
                            }
                        #endif

                        shadowMult = mix(vec3(skyLightShadowMult * shadowMultBeforeLighting), shadowMult, shadowMixer);
                    }
                }
            #else
                #if SHADOW_QUALITY == -1 || !defined VOXY_PATCH
                    shadowMult *= skyLightShadowMult;
                #else
                    // Screenspace shadows rendered in deferred1 of previous frame for Voxy
                    // Previous frame reprojection from Chocapic13
                    vec3 screenSpaceShadowPos = vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z);
                    vec4 viewPosPrev = vxProjInv * vec4(screenSpaceShadowPos * 2.0 - 1.0, 1.0);
                    viewPosPrev /= viewPosPrev.w;

                    viewPosPrev = vxModelViewInv * viewPosPrev;

                    vec4 previousPosition = viewPosPrev + vec4(cameraPosition - previousCameraPosition, 0.0);
                    previousPosition = vxModelViewPrev * previousPosition;
                    previousPosition = vxProjPrev * previousPosition;
                    screenSpaceShadowPos.xy = previousPosition.xy / previousPosition.w * 0.5 + 0.5;

                    float screenSpaceShadowSample = texture2D(colortex18, screenSpaceShadowPos.xy).r;
                    if (screenSpaceShadowSample >= OSIEBCA) {
                        if (subsurfaceMode == 1) {
                            shadowMult *= 0.82 * (0.2 + 0.8 * sqrt2(max(SdotU, nightFactor)));
                        } else if (subsurfaceMode == 2) {
                            float baseLeafShadowMult = 1.0;

                            #ifdef LEAF_SHADOW_OPTIMISATION
                                float extraLeafShadeMix = 0.25 + 0.125 * pow2(noonFactor);
                            #else
                                float extraLeafShadeMix = 0.125 + 0.125 * pow2(noonFactor);
                            #endif

                            shadowMult *= mix(baseLeafShadowMult, NdotU, extraLeafShadeMix);
                        }
                        shadowMult *= screenSpaceShadowSample * skyLightShadowMult;
                    } else {
                        shadowMult *= skyLightShadowMult;
                    }
                #endif
            #endif

            #ifdef END_FLASH_SHADOW_INTERNAL
                shadowTime = mix(shadowTime, 1.0, endFlashIntensityM);
            #endif

            #ifdef CLOUD_SHADOWS
                shadowMult *= GetCloudShadow(playerPos);
            #endif

            shadowMult *= max(NdotLM * shadowTime, 0.0);
        }
        #ifdef GBUFFERS_WATER
            else { // Low Quality Water
                shadowMult = vec3(pow2(lightmapY2) * max(NdotLM * shadowTime, 0.0));
            }
        #endif
    #endif

    #ifdef END_FLASH_SHADOW_INTERNAL
        vec3 endFlashShadowColor = END_FLASH_SHADOW * 0.12 * 0.82 + endOrangeCol * 0.18;
        shadowMult = mix(vec3(0.0), endFlashShadowColor * shadowMult, endFlashIntensityM) + 1;
    #endif

    // Blocklight
    float lightmapXM;
    #if defined LIGHTMAP_CURVES && !defined GBUFFERS_TEXTURED
        if (!noSmoothLighting || oldSubsurfaceMode > 0 && !isLightSource) {
            float lx4 = pow2(pow2(lightmap.x));
            float lx8 = pow2(lx4);
            float vsBrightFactor = 2.8 - 0.6 * vsBrightness + XLIGHT_CURVE;

            float transitionFactor = ((UPPER_LIGHTMAP_CURVE * 0.1 + 0.9) - 1.0) *
                                    mix(1.0, 10.0, float(int(max(0.0, UPPER_LIGHTMAP_CURVE - 0.01))));

            float transitions = (pow2(lx8) * (10 - vsBrightness) * 2 +
                            lx8 * (2.8 + XLIGHT_CURVE - vsBrightness) * 0.8 +
                            lx4 * (2.8 + XLIGHT_CURVE - vsBrightness * 0.7)) * transitionFactor;

            float lightmapXMSteep = max(0.0, pow2(pow2(lightmap.x * lightmap.x)) * vsBrightFactor + transitions);
            float lightmapXMCalm = lightmap.x * (2.8 - XLIGHT_CURVE + 0.6 * vsBrightness) * LOWER_LIGHTMAP_CURVE;
            lightmapXM = pow(lightmapXMSteep + lightmapXMCalm, 2.25);
        } else {
            float xLightCurveM = XLIGHT_CURVE > 0.999 ? XLIGHT_CURVE : sqrt2(XLIGHT_CURVE);
            lightmapXM = pow(lightmap.x, 3.0 * xLightCurveM * pow2(UPPER_LIGHTMAP_CURVE)) * 10.0 * UPPER_LIGHTMAP_CURVE * (UPPER_LIGHTMAP_CURVE * 0.7 + 0.3);
        }
    #else
        if (!noSmoothLighting) {
            float lightmapXMSteep = pow2(pow2(lightmap.x * lightmap.x)) * (2.8 - 0.6 * vsBrightness + XLIGHT_CURVE);
            float lightmapXMCalm = lightmap.x * (2.8 + 0.6 * vsBrightness - XLIGHT_CURVE);
            lightmapXM = pow(lightmapXMSteep + lightmapXMCalm, 2.25);
        } else {
        float xLightCurveM = XLIGHT_CURVE > 0.999 ? XLIGHT_CURVE : sqrt2(XLIGHT_CURVE);
        lightmapXM = pow(lightmap.x, 3.0 * xLightCurveM) * 10.0;
    }
    #endif

    float daylightFactor = lightmapYM * invRainFactor * sunVisibility;
    emission *= 1.0 - 0.25 * daylightFactor; // Less emission under direct skylight

    #ifdef GBUFFERS_TEXTURED
        lightmapXM *= 1.5 - 0.5 * daylightFactor; // Brighter lit particles
    #endif

    #if defined DIRECTIONAL_LIGHTMAP_NORMALS && (defined GBUFFERS_TERRAIN || defined GBUFFERS_WATER || defined GBUFFERS_BLOCK)
        if (oldLightmap.x > 0.035 && mat != 32008) { // very specific value, do not change
            float lightmapDir = lightmapXM;
            #ifdef USE_FINE_DERIVATIVES
                vec2 dFdBlock = vec2(dFdxFine(oldLightmap.x), dFdyFine(oldLightmap.x)); // Get higher precision derivatives when available
            #else
                vec2 dFdBlock = vec2(dFdx(oldLightmap.x), dFdy(oldLightmap.x));
            #endif
            vec3 blockLightDir;

            if (length(dFdBlock) < 1e-6) {
                vec3 blockCenterPos = floor(playerPos + cameraPosition + 0.001 * worldGeoNormal) - cameraPosition + 0.5; // + 0.001 fixes percision issues
                blockLightDir = blockCenterPos - worldGeoNormal * dot(worldGeoNormal, blockCenterPos - playerPos) - playerPos;
                blockLightDir = mat3(gbufferModelView) * blockLightDir;
            } else {
                #ifdef USE_FINE_DERIVATIVES
                    blockLightDir = dFdxFine(viewPos) * dFdBlock.x + dFdyFine(viewPos) * dFdBlock.y; // Get higher precision derivatives when available
                #else
                    blockLightDir = dFdx(viewPos) * dFdBlock.x + dFdy(viewPos) * dFdBlock.y;
                #endif
            }
            float dotNormal = dot(normalize(blockLightDir), normalM);

            lightmapDir *= pow(dotNormal + 1.0, DIRECTIONAL_LIGHTMAP_NORMALS_BLOCK_STRENGTH_NEW + 0.25);
            lightmapXM = mix(lightmapXM, lightmapDir, 0.01 * max0(100.0 - lViewPos));
        }
    #endif

    #if BLOCKLIGHT_FLICKERING > 0
        vec2 flickerNoiseBlock = texture2DLod(noisetex, vec2(frameTimeCounter * 0.06), 0.0).rb;
        lightmapXM *= mix(1.0, min1(max(flickerNoiseBlock.r, flickerNoiseBlock.g) * 1.7), pow2(BLOCKLIGHT_FLICKERING * 0.1));
    #endif

    #ifdef RANDOM_BLOCKLIGHT
        float RandR = texture2DLod(noisetex, 0.00016 * RANDOM_BLOCKLIGHT_SIZE * (playerPos.xz + cameraPosition.xz), 0.0).r * XLIGHT_R;
        float RandG = texture2DLod(noisetex, 0.00029 * RANDOM_BLOCKLIGHT_SIZE * (playerPos.xz + cameraPosition.xz), 0.0).r * XLIGHT_G;
        float RandB = texture2DLod(noisetex, 0.00034 * RANDOM_BLOCKLIGHT_SIZE * (playerPos.xz + cameraPosition.xz), 0.0).r * XLIGHT_B;
        blocklightCol = vec3(RandR, RandG, RandB) * 0.875;
    #endif

    vec3 blockLighting = lightmapXM * blocklightCol;

    #if defined PHOTONICS_LIGHTING && !defined GBUFFERS_WATER && !defined GBUFFERS_HAND && PHOTONICS_MAX_LIGHTS > 0
        // Keep a small vanilla fallback near camera so scenes do not go black if RT energy is weak.
        if (!isLightSource){
            blockLighting *= 1.0 - (1.0 - PHOTONICS_VANILLA_LIGHT_FALLBACK * 0.01) * phRtCoverage;
            lightmapXM *= 1.0 - (1.0 - PHOTONICS_VANILLA_LIGHT_FALLBACK * 0.01) * phRtCoverage;
        }
    #endif

    #if COLORED_LIGHTING_INTERNAL > 0
        // Prepare
        #if defined GBUFFERS_HAND
            vec3 voxelPos = SceneToVoxel(vec3(0.0));
        #elif defined GBUFFERS_TEXTURED
            vec3 voxelPos = SceneToVoxel(playerPos);
        #else
            vec3 voxelPos = SceneToVoxel(playerPos);
            voxelPos = voxelPos + worldGeoNormal * 0.55; // should be close to 0.5 for ACT_CORNER_LEAK_FIX but 0.5 makes slabs flicker
        #endif

        vec3 specialLighting = vec3(0.0);
        vec4 lightVolume = vec4(0.0);
        if (CheckInsideVoxelVolume(voxelPos)) {
            vec3 voxelPosM = clamp01(voxelPos / vec3(voxelVolumeSize));
            lightVolume = GetLightVolume(voxelPosM);
            lightVolume = sqrt(lightVolume);
            specialLighting = lightVolume.rgb;
        }

        // Add extra articial light for blocks that request it
        lightmapXM = max(lightmapXM, mix(lightmapXM, 10.0, lightVolume.a));
        specialLighting *= 1.0 + 50.0 * lightVolume.a;

        purkinjeOverwrite += 17.0 * lightVolume.a;

        // Color Balance
        specialLighting = lightmapXM * 0.13 * DoLuminanceCorrection(specialLighting + blocklightCol * 0.05);

        // Add some extra non-contrasty detail
        AddSpecialLightDetail(specialLighting, color.rgb, emission);

        #if COLORED_LIGHT_SATURATION != 100
            specialLighting = mix(blockLighting, specialLighting, COLORED_LIGHT_SATURATION * 0.01);
        #endif

        // Serve with distance fade
        vec3 absPlayerPosM = abs(playerPos);
        #if COLORED_LIGHTING_INTERNAL <= 512
            absPlayerPosM.y *= 2.0;
        #elif COLORED_LIGHTING_INTERNAL == 768
            absPlayerPosM.y *= 3.0;
        #elif COLORED_LIGHTING_INTERNAL == 1024
            absPlayerPosM.y *= 4.0;
        #endif
        float maxPlayerPos = max(absPlayerPosM.x, max(absPlayerPosM.y, absPlayerPosM.z));
        float blocklightDecider = pow2(min1(maxPlayerPos / effectiveACTdistance * 2.0));
        //if (heldItemId != 40000 || heldItemId2 == 40000) // Hold spider eye to see vanilla lighting
        blockLighting = mix(specialLighting, blockLighting, blocklightDecider);
        //if (heldItemId2 == 40000 && heldItemId != 40000) blockLighting = lightVolume.rgb; // Hold spider eye to see light volume
    #endif

    #if defined END && END_CENTER_LIGHTING > 0 && MC_VERSION >= 10900 && defined END_CENTER_LIGHTING_AFFECT_BLOCKLIGHT && (defined GBUFFERS_BLOCK || defined GBUFFERS_ENTITIES || defined GBUFFERS_TERRAIN || defined GBUFFERS_HAND) && !defined VOXY_PATCH
        blockLighting = mix(blockLighting, lightmapXM * clamp01(saturateColors(endCenterCol, 1.3)), clamp01(endCenterLightDist) * enderDragonDead);
    #endif

    #if HELD_LIGHTING_MODE >= 1
        #if !defined DO_PIXELATION_EFFECTS || !defined PIXELATED_BLOCKLIGHT
            vec3 playerPosForHeldLighting = playerPos;
        #else
            vec3 playerPosForHeldLighting = playerPosPixelated;
        #endif

        #if defined PHOTONICS_LIGHTING && PHOTONICS_MAX_LIGHTS > 0
            vec3 vanillaHeldLighting = GetHeldLighting(playerPosForHeldLighting, color.rgb, emission, worldGeoNormal, normalM, viewPos);
            vec3 heldLighting = vanillaHeldLighting * (1.0 - (1.0 - PHOTONICS_VANILLA_LIGHT_FALLBACK * 0.01) * phRtCoverage);
        #else
            vec3 heldLighting = GetHeldLighting(playerPosForHeldLighting, color.rgb, emission, worldGeoNormal, normalM, viewPos);
        #endif

        #if HAND_BLOCKLIGHT_FLICKERING > 0 && defined GBUFFERS_HAND
            float heldLightHand1 = 0, heldLightHand2 = 0;
            getHeldLight(heldLightHand1, heldLightHand2);
            emission *= mix(1.0, getHeldLightFlicker(), min1(heldLightHand1 + heldLightHand2));
        #endif

        #ifdef GBUFFERS_HAND
            blockLighting *= 0.5;
            heldLighting *= 2.0;
        #endif
    #endif

    vec3 minLighting = GetMinimumLighting(lightmapYM, playerPos);
    vec3 shadowLightMult = shadowMult;
    float shadowMultFloat = min1(GetLuminance(shadowMult));

    // Lighting Tweaks
    #ifdef OVERWORLD
        ambientMult = mix(lightmapYM, pow2(lightmapYM) * lightmapYM, rainFactor);

        #if SHADOW_QUALITY == -1
            float tweakFactor = 1.0 + 0.6 * (1.0 - pow2(pow2(pow2(noonFactor))));
            lightColorM /= tweakFactor;
            ambientMult *= mix(tweakFactor, 1.0, 0.5 * NdotUmax0);
        #endif

        #if AMBIENT_MULT != 100
            #if AMBIENT_MULT < 100
                #define AMBIENT_MULT_M (AMBIENT_MULT - 100) * 0.006
                vec3 shadowMultP = shadowMult / (0.1 + 0.9 * sqrt2(max0(NdotLM)));
                ambientMult *= 1.0 + pow2(pow2(max0(1.0 - dot(shadowMultP, shadowMultP)))) * AMBIENT_MULT_M *
                            (0.5 + 0.2 * sunFactor + 0.8 * noonFactor) * (1.0 - rainFactor * 0.5);
            #else
                #define AMBIENT_MULT_M (AMBIENT_MULT - 100) * 0.002
                shadowLightMult = mix(shadowLightMult, vec3(1.0), AMBIENT_MULT_M * ambientMult);
                lightColorM = mix(lightColorM, GetLuminance(lightColorM) * DoLuminanceCorrection(ambientColorM), (1.0 - shadowMultFloat) * AMBIENT_MULT_M);
            #endif
        #endif

        if (isEyeInWater != 1) {
            float lxFactor = (sunVisibility2 * 0.4 + (0.6 - 0.6 * pow2(invNoonFactor))) * (6.0 - 5.0 * rainFactor);
            lxFactor *= lightmapY2 + lightmapY2 * 2.0 * pow2(shadowMultFloat);
            lxFactor = max0(lxFactor - emission * 1000000.0);
            blockLighting *= pow(lightmapXM / 60.0 + 0.001, 0.09 * lxFactor);

            // Less light in the distance / more light closer to the camera during rain or night to simulate thicker fog
            float rainLF = 0.1 * rainFactor;
            float lightFogTweaks = 1.0 + max0(96.0 - lViewPos) * (0.002 * (1.0 - sunVisibility2) + 0.0104 * rainLF) - rainLF;
            ambientMult *= lightFogTweaks;
            lightColorM *= lightFogTweaks;
        }
    #endif
    #ifdef END
        #ifdef END_FLASHES
            vec3 worldEndFlashPosition = mat3(gbufferModelViewInverse) * endFlashPosition;
            worldEndFlashPosition = normalize(vec3(
                worldEndFlashPosition.x,
                0.15 * (END_BEAM_CENTER_ALT - playerPos.y),
                worldEndFlashPosition.z
            ));
            float endFlashDirectionFactor = max0(1.0 + dot(worldGeoNormal, normalize(worldEndFlashPosition))) * 0.5;
                  endFlashDirectionFactor = pow2(pow2(endFlashDirectionFactor));

            vec3 endFlashColor = (endOrangeCol + endLightColor) * endFlashIntensityM * pow2(lightmapYM);

            #ifdef END_FLASH_SHADOW_INTERNAL
                endFlashColor *= clamp01(shadowMult - 1);
            #endif

            ambientColorM += endFlashColor  * (0.2 * endFlashDirectionFactor);
        #endif
    #endif

    #ifdef GBUFFERS_HAND
        ambientMult *= 1.3; // To improve held map visibility
    #endif

    #if defined PHOTONICS_LIGHTING && !defined GBUFFERS_WATER && PHOTONICS_INDIRECT_INTENSITY > 0
        float photonicsAmbientLightMult = 2.0 - PHOTONICS_AMBIENT_LIGHT_MULT;
        ambientMult *= 1.0 - mix(0.0, 0.367 * photonicsAmbientLightMult, PHOTONICS_INDIRECT_INTENSITY * 0.06) * phRtCoverage;
    #endif

    // Directional Shading
    float directionShade = 1.0;
    #ifdef DIRECTIONAL_SHADING
        if (!noDirectionalShading) {
            float absNdotE2 = pow2(absNdotE);

            #if !defined NETHER
                float NdotUM = 0.75 + NdotU * 0.25;
            #else
                float NdotUM = 0.75 + abs(NdotU + 0.5) * 0.16666;
            #endif
            float NdotNM = 1.0 + 0.075 * absNdotN;
            float NdotEM = 1.0 - 0.1 * absNdotE2;
            directionShade = NdotUM * NdotEM * NdotNM;

            #ifdef OVERWORLD
                lightColorM *= 1.0 + absNdotE2 * 0.75;
            #elif defined NETHER
                directionShade *= directionShade;
                ambientColorM += lavaLightColor * pow2(absNdotN * 0.5 + max0(-NdotU)) * (0.7 + 0.35 * vsBrightness);
            #endif

            #if defined CUSTOM_PBR || defined GENERATED_NORMALS
                float cpbrAmbFactor = NdotN * NPdotU;
                cpbrAmbFactor = 1.0 - 0.3 * cpbrAmbFactor;
                ambientColorM *= cpbrAmbFactor;
                minLighting *= cpbrAmbFactor;
            #endif

            #if defined OVERWORLD && defined PERPENDICULAR_TWEAKS && defined SIDE_SHADOWING
                // Fake bounced light
                ambientColorM = mix(ambientColorM, lightColorM, (0.05 + 0.03 * subsurfaceMode) * absNdotN * lightmapY2);

                // Get a bit more natural looking lighting during noon
                lightColorM *= 1.0 + max0(1.0 - subsurfaceMode) * pow(noonFactor, 20.0) * (pow2(absNdotN) * 0.8 - absNdotE2 * 0.2);
            #endif
        }
    #endif

    // Scene Lighting Stuff
    #ifdef GBUFFERS_VOXELS
        shadowLightMult = vec3(0.0);
    #endif

    vec3 sceneLighting = lightColorM * shadowLightMult + ambientColorM * ambientMult;
    float dotSceneLighting = dot(sceneLighting, sceneLighting);

    #if HELD_LIGHTING_MODE >= 1
        blockLighting = sqrt(pow2(blockLighting) + heldLighting);
    #endif

    blockLighting *= XLIGHT_I;

    #ifdef BLOCKLIGHT_CAUSTICS
        vec3 worldPos = playerPos + cameraPosition;
        #if defined DO_PIXELATION_EFFECTS && defined PIXELATED_SHADOWS
            worldPos = playerPosPixelated + cameraPosition;
        #endif

        blockLighting *= GetBlocklightCaustics(worldGeoNormal, worldPos);
    #endif

    #ifdef LIGHT_COLOR_MULTS
        sceneLighting *= lightColorMult;
    #endif
    #ifdef MOON_PHASE_INF_LIGHT
        sceneLighting *= moonPhaseInfluence;
    #endif

    #ifdef GBUFFERS_VOXELS
        blockLighting = vec3(0.0);
    #endif

    // Vanilla Ambient Occlusion
    float vanillaAO = 1.0;
    #if VANILLAAO_I > 0 && !defined GBUFFERS_VOXELS
        vanillaAO = glColor.a;

        #if defined DO_PIXELATION_EFFECTS && defined PIXELATED_AO
            vanillaAO = TexelSnap(vanillaAO, pixelationOffset);
        #endif

        if (subsurfaceMode != 0) vanillaAO = mix(min1(vanillaAO * 1.15), 1.0, shadowMultFloat);
        else if (!noVanillaAO) {
            #ifdef GBUFFERS_TERRAIN
                vanillaAO = min1(vanillaAO + 0.08);
                #ifdef OVERWORLD
                    vanillaAO = pow(
                        pow1_5(vanillaAO),
                        1.0 + dotSceneLighting * 0.02 + NdotUmax0 * (0.15 + 0.25 * pow2(noonFactor * pow2(lightmapY2)))
                    );
                #elif defined NETHER
                    vanillaAO = pow(
                        pow1_5(vanillaAO),
                        1.0 + NdotUmax0 * 0.5
                    );
                #else
                    vanillaAO = pow(
                        vanillaAO,
                        0.75 + NdotUmax0 * 0.25
                    );
                #endif
            #endif
            vanillaAO = vanillaAO * 0.9 + 0.1;

            #if VANILLAAO_I != 100
                #define VANILLAAO_IM VANILLAAO_I * 0.01
                vanillaAO = pow(vanillaAO, VANILLAAO_IM);
            #endif
        }
    #endif

    #ifdef RAIN_ATMOSPHERE
        vanillaAO += lightningAdd.y * 0.1 * (-vanillaAO + 1);
    #endif

    // Light Highlight
    vec3 lightHighlight = vec3(0.0);
    #ifdef LIGHT_HIGHLIGHT
        float specularHighlight = GGX(normalM, nViewPos, lightVec, NdotLmax0, smoothnessG);

        specularHighlight *= highlightMult;

        lightHighlight = isEyeInWater != 1 ? shadowMult : pow(shadowMult, vec3(0.25)) * 0.35;
        lightHighlight *= (subsurfaceHighlight * subsurfaceColor + specularHighlight) * highlightColor;

        #ifdef LIGHT_COLOR_MULTS
            lightHighlight *= lightColorMult;
        #endif
        #ifdef MOON_PHASE_INF_REFLECTION
            lightHighlight *= pow2(moonPhaseInfluence);
        #endif
        #if BLOOD_MOON > 0
            lightHighlight *= mix(vec3(1.0), vec3(1.0, 0.1294, 0.1294), getBloodMoon(sunVisibility));
        #endif
    #endif

    // Mix Colors
    vec3 finalDiffuse = pow2(directionShade * vanillaAO) * (blockLighting + pow2(sceneLighting) + minLighting) + pow2(emission);
    finalDiffuse = sqrt(max(finalDiffuse, vec3(0.0))); // sqrt() for a bit more realistic light mix, max() to prevent NaNs

    // Apply Lighting
    color.rgb *= finalDiffuse;
    color.rgb += lightHighlight;
    color.rgb *= pow2(1.0 - darknessLightFactor);
}

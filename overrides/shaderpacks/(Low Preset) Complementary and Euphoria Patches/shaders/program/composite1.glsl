/////////////////////////////////////
// Complementary Shaders by EminGT //
/////////////////////////////////////

//Common//
#include "/lib/common.glsl"
#include "/lib/shaderSettings/composite1.glsl"
#include "/lib/shaderSettings/endBeams.glsl"
#include "/lib/shaderSettings/overworldBeams.glsl"
#include "/lib/shaderSettings/longExposure.glsl"
#include "/lib/shaderSettings/raindropColor.glsl"
#define NETHER_STORM
#define NETHER_STORM_LOWER_ALT 28 //[-296 -292 -288 -284 -280 -276 -272 -268 -264 -260 -256 -252 -248 -244 -240 -236 -232 -228 -224 -220 -216 -212 -208 -204 -200 -196 -192 -188 -184 -180 -176 -172 -168 -164 -160 -156 -152 -148 -144 -140 -136 -132 -128 -124 -120 -116 -112 -108 -104 -100 -96 -92 -88 -84 -80 -76 -72 -68 -64 -60 -56 -52 -48 -44 -40 -36 -32 -28 -24 -20 -16 -12 -8 -4 0 4 8 12 16 20 22 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100 104 108 112 116 120 124 128 132 136 140 144 148 152 156 160 164 168 172 176 180 184 188 192 196 200 204 208 212 216 220 224 228 232 236 240 244 248 252 256 260 264 268 272 276 280 284 288 292 296 300]
#define NETHER_STORM_HEIGHT 200 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300 325 350 375 400 425 450 475 500 550 600 650 700 750 800 850 900]
#define NETHER_STORM_I 0.40 //[0.05 0.06 0.07 0.08 0.09 0.10 0.12 0.14 0.16 0.18 0.22 0.26 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50]
#ifndef NETHER
    #undef NETHER_STORM
#endif
#define COLORED_LIGHT_FOG_RAIN_I 0 //[0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 105 110 115 120 125 130 135 140 145 150 155 160 165 170 175 180 185 190 195 200]
#ifdef COLORED_LIGHT_FOG_RAIN_I
#endif

//////////Fragment Shader//////////Fragment Shader//////////Fragment Shader//////////
#ifdef FRAGMENT_SHADER

noperspective in vec2 texCoord;

flat in vec3 upVec, sunVec;

// #undef LIGHTSHAFTS_ACTIVE

#ifdef LIGHTSHAFTS_ACTIVE
    flat in float vlFactor;
#endif

//Pipeline Stuff//
#define ALLOW_REFRACTION
#define SMOOTHNESS_AFFECTED_REF_BLUR
#define UNDERWATER_LIGHT_SOURCE_DETECTION

#if defined MC_OS_MAC && (defined DISTANT_HORIZONS || defined VOXY)
    // Remove the uses of colortex6 to stay below the 8 sampler limit of macos
    #undef IRIS_FEATURE_FADE_VARIABLE
    #undef ALLOW_REFRACTION
    #undef SMOOTHNESS_AFFECTED_REF_BLUR
    #undef UNDERWATER_LIGHT_SOURCE_DETECTION
#endif

//Common Variables//
float SdotU = dot(sunVec, upVec);
float sunFactor = SdotU < 0.0 ? clamp(SdotU + 0.375, 0.0, 0.75) / 0.75 : clamp(SdotU + 0.03125, 0.0, 0.0625) / 0.0625;
float sunVisibility = clamp(SdotU + 0.0625, 0.0, 0.125) / 0.125;
float sunVisibility2 = sunVisibility * sunVisibility;

vec2 view = vec2(viewWidth, viewHeight);

#ifdef OVERWORLD
    vec3 lightVec = sunVec * ((timeAngle < 0.5325 || timeAngle > 0.9675) ? 1.0 : -1.0);
#else
    vec3 lightVec = sunVec;
#endif

#ifdef LIGHTSHAFTS_ACTIVE
    float shadowTimeVar1 = abs(sunVisibility - 0.5) * 2.0;
    float shadowTimeVar2 = shadowTimeVar1 * shadowTimeVar1;
    float shadowTime = shadowTimeVar2 * shadowTimeVar2;
#endif

//Common Functions//
float GetLinearDepth(float depth) {
    return (2.0 * near) / (far + near - depth * (far - near));
}

//Includes//
#include "/lib/atmospherics/fog/waterFog.glsl"
#include "/lib/atmospherics/fog/caveFactor.glsl"
#include "/lib/util/spaceConversion.glsl"
#include "/lib/colors/lightAndAmbientColors.glsl"

#if defined PBR_REFLECTIONS || WATER_REFLECT_QUALITY > 0 && WORLD_SPACE_REFLECTIONS_INTERNAL > 0
    #include "/lib/materials/materialMethods/reflectionBlurFilter.glsl"
#endif

#ifdef BLOOM_FOG_COMPOSITE1
    #include "/lib/atmospherics/fog/bloomFog.glsl"
#endif

#ifdef ATM_COLOR_MULTS
    #include "/lib/colors/colorMultipliers.glsl"
#endif

#ifdef AURORA_INFLUENCE
    #include "/lib/atmospherics/auroraBorealis.glsl"
#endif

#ifdef LIGHTSHAFTS_ACTIVE
    #include "/lib/lighting/shadowSampling.glsl"
    #ifdef END
        #include "/lib/atmospherics/volumetricLight/enderBeams.glsl"
    #elif defined OVERWORLD && defined OVERWORLD_BEAMS
        #include "/lib/atmospherics/overworldBeams.glsl"
    #endif
    #include "/lib/atmospherics/volumetricLight/volumetricLight.glsl"
#endif

#if WATER_MAT_QUALITY >= 3
    #include "/lib/materials/materialMethods/refraction.glsl"
#endif

#ifdef NETHER_STORM
    #include "/lib/atmospherics/netherStorm.glsl"
#endif

#ifdef MOON_PHASE_INF_ATMOSPHERE
    #include "/lib/colors/moonPhaseInfluence.glsl"
#endif

#if RAINBOWS > 0 && defined OVERWORLD
    #include "/lib/atmospherics/rainbow.glsl"
#endif

#ifdef COLORED_LIGHT_FOG
    #include "/lib/voxelization/lightVoxelization.glsl"
    #include "/lib/atmospherics/fog/coloredLightFog.glsl"
#endif

#if END_CRYSTAL_VORTEX_INTERNAL > 0 || DRAGON_DEATH_EFFECT_INTERNAL > 0
    #include "/lib/atmospherics/endCrystalVortex.glsl"
#endif

#ifdef END_PORTAL_BEAM_INTERNAL
    #include "/lib/atmospherics/endPortalBeam.glsl"
#endif

#ifdef IMPROVED_RAIN
    #include "/lib/colors/lightAndAmbientColors.glsl"
#endif

//Program//
void main() {
    vec3 color = texelFetch(colortex0, texelCoord, 0).rgb;
    float z0 = texelFetch(depthtex0, texelCoord, 0).r;
    float z1 = texelFetch(depthtex1, texelCoord, 0).r;

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

    float dither = texture2DLod(noisetex, texCoord * view / 128.0, 0.0).b;
    #ifdef TAA
        dither = fract(dither + goldenRatio * mod(float(frameCounter), 3600.0));
    #endif

    /* TM5723: The "1.0 - translucentMult" trick is done because of the default color attachment
    value being vec3(0.0). This makes it vec3(1.0) to avoid issues especially on improved glass */
    vec3 translucentMult = 1.0 - texelFetch(colortex3, texelCoord, 0).rgb; //TM5723
    vec4 volumetricEffect = vec4(0.0);

    vec2 texCoordM = texCoord;
    #if WATER_MAT_QUALITY >= 3 && defined ALLOW_REFRACTION
        texCoordM = DoRefraction(color, z0, z1, viewPos.xyz, lViewPos);
    #endif

    #if defined PBR_REFLECTIONS || WATER_REFLECT_QUALITY > 0 && WORLD_SPACE_REFLECTIONS_INTERNAL > 0
        if (z0 < 1.0) {
            vec4 compositeReflection = texture2D(colortex7, texCoord);

            // Partial fix for half resolution WSR-only reflections having a lot of sky gaps
            #if WORLD_SPACE_REF_MODE == 1
                if (REFLECTION_RES < 0.6) {
                    vec2 refOffsets[4] = vec2[4](
                        vec2( 1.0, 1.0),
                        vec2(-1.0, 1.0),
                        vec2( 1.0,-1.0),
                        vec2(-1.0,-1.0)
                    );

                    for (int i = 0; i < 4; i++) {
                        vec4 compositeRefSample = texture2D(colortex7, texCoord + refOffsets[i] * 1.5 / view);
                        if (compositeRefSample.a > compositeReflection.a * 1.01) compositeReflection = compositeRefSample;
                    }
                }
            #endif

            float fresnelM = pow2(texture2D(colortex4, texCoord).a); // including attenuation through fog and clouds
            if (abs(fresnelM - 0.5) < 0.5) { // 0.0 fresnel doesnt need ref calculations, and 1.0 fresnel basically means error
                if (z0 == z1 || z0 <= 0.56) { // Solids
                    #ifdef PBR_REFLECTIONS
                        if (fresnelM > 0.00001) {
                            compositeReflection = sampleBlurFilteredReflection(compositeReflection, dither, z0);

                            compositeReflection.rgb = max(compositeReflection.rgb, vec3(0.0)); // We seem to have some negative values for some reason

                            // This physically doesn't make sense but fits Minecraft
                            const float texturePreservation = 0.7;
                            compositeReflection.rgb = mix(compositeReflection.rgb, max(color, compositeReflection.rgb), texturePreservation);

                            color = mix(color, compositeReflection.rgb, fresnelM);
                        }
                    #endif
                }
                #if WORLD_SPACE_REFLECTIONS_INTERNAL > 0
                    else { // Translucents
                        vec4 ssrReflection = texture2D(colortex8, texCoordM);
                        color = max(color - ssrReflection.rgb, vec3(0.0));

                        compositeReflection.rgb *= fresnelM;
                        compositeReflection = mix(compositeReflection, ssrReflection, float(ssrReflection.a > 0.999));
                        vec3 combinedRef = mix(ssrReflection.rgb, compositeReflection.rgb, compositeReflection.a);

                        color += combinedRef;
                    }
                #endif
            }
        }
    #endif

    vec4 screenPos1 = vec4(texCoord, z1, 1.0);
    vec4 viewPos1 = gbufferProjectionInverse * (screenPos1 * 2.0 - 1.0);
    viewPos1 /= viewPos1.w;
    float lViewPos1 = length(viewPos1.xyz);

    float z1lod = 1.0;
    #if defined DISTANT_HORIZONS || defined VOXY
        #ifdef DISTANT_HORIZONS
            z1lod = texelFetch(dhDepthTex1, texelCoord, 0).r;
            vec4 screenPos1Lod = vec4(texCoord, z1lod, 1.0);
            vec4 viewPos1Lod = dhProjectionInverse * (screenPos1Lod * 2.0 - 1.0);
        #elif defined VOXY
            z1lod = texelFetch(vxDepthTexOpaque, texelCoord, 0).r;
            vec4 screenPos1Lod = vec4(texCoord, z1lod, 1.0);
            vec4 viewPos1Lod = vxProjInv * (screenPos1Lod * 2.0 - 1.0);
        #endif
        viewPos1Lod /= viewPos1Lod.w;
        lViewPos1 = min(lViewPos1, length(viewPos1Lod.xyz));
    #endif

    #if defined LIGHTSHAFTS_ACTIVE || RAINBOWS > 0 && defined OVERWORLD
        vec3 nViewPos = normalize(viewPos1.xyz);
        float VdotL = dot(nViewPos, lightVec);
        float VdotU = dot(nViewPos, upVec);
    #endif

    #if defined NETHER_STORM || defined COLORED_LIGHT_FOG || END_CRYSTAL_VORTEX_INTERNAL > 0 || DRAGON_DEATH_EFFECT_INTERNAL > 0 || defined END_PORTAL_BEAM_INTERNAL || (defined END && END_CENTER_LIGHTING > 0 && MC_VERSION >= 10900) || GLITTER_RAIN > 0
        vec3 playerPos = ViewToPlayer(viewPos1.xyz);
        vec3 nPlayerPos = normalize(playerPos);
    #endif

    #if RAINBOWS > 0 && defined OVERWORLD
        color += GetRainbow(translucentMult, nViewPos, z0, z1, lViewPos, lViewPos1, VdotL, VdotU, dither);
    #endif

    float vlFactorM = 0.0;
    #ifdef LIGHTSHAFTS_ACTIVE
        vlFactorM = vlFactor;

        volumetricEffect = GetVolumetricLight(vlFactorM, translucentMult, lViewPos, lViewPos1, nViewPos, VdotL, VdotU, z0, z1, z1lod, dither);
    #endif

    float lightFogLength = 0.0;
    #if END_CRYSTAL_VORTEX_INTERNAL > 0 || DRAGON_DEATH_EFFECT_INTERNAL > 0
        vec4 endCrystalVortex = pow4(EndCrystalVortices(vec3(0.0), playerPos, dither));
        volumetricEffect = sqrt(pow2(volumetricEffect) + endCrystalVortex);
        lightFogLength = sqrt(pow2(lightFogLength) + length(endCrystalVortex.rgb));
    #endif

    #ifdef NETHER_STORM
        volumetricEffect = GetNetherStorm(color, translucentMult, nPlayerPos, playerPos, lViewPos, lViewPos1, dither);
    #endif

    #ifdef ATM_COLOR_MULTS
        volumetricEffect.rgb *= GetAtmColorMult();
    #endif
    #ifdef MOON_PHASE_INF_ATMOSPHERE
        volumetricEffect.rgb *= moonPhaseInfluence;
    #endif

    #ifdef END_PORTAL_BEAM_INTERNAL
        vec4 endPortalBeam = pow2(GetEndPortalBeam(vec3(0.0), playerPos));
        volumetricEffect = sqrt(pow2(volumetricEffect) + endPortalBeam);
        lightFogLength = sqrt(pow2(lightFogLength) + length(endPortalBeam.rgb));
    #endif

    #ifdef NETHER_STORM
        color = mix(color, volumetricEffect.rgb, volumetricEffect.a);
    #endif

    #ifdef COLORED_LIGHT_FOG
        vec3 lightFog = GetColoredLightFog(nPlayerPos, translucentMult, lViewPos, lViewPos1, dither, vlFactorM);
        float lightFogMult = COLORED_LIGHT_FOG_I;
        #ifdef NIGHT_DESATURATION_REMOVE_NEAR_LIGHTS
            lightFogLength += length(lightFog);
        #endif

        #ifdef OVERWORLD
            #if COLORED_LIGHT_FOG_RAIN_I > 0
                lightFogMult = mix(lightFogMult, COLORED_LIGHT_FOG_RAIN_I * 0.01, rainFactor * inRainy);
            #endif
            lightFogMult *= 0.2 + 0.6 * mix(1.0, 1.0 - sunFactor * invRainFactor, eyeBrightnessM);
        #endif
    #else
        vec3 lightFog = vec3(0.0);
    #endif

    if (isEyeInWater == 1) {
        if (z0 == 1.0) color.rgb = waterFogColor;

        vec3 underwaterMult = vec3(0.80, 0.87, 0.97);
        #if DARKER_DEPTH_OCEANS > 0
            float renderDistanceFade = lViewPos * 20.0 / far;
            #ifdef UNDERWATER_LIGHT_SOURCE_DETECTION
                vec4 texture6 = texelFetch(colortex6, texelCoord, 0);
                float lightSourceFactor = pow3(1.0 - texture6.a);
            #else
                float lightSourceFactor = 1.0 - eyeBrightnessXM;
            #endif
            lightSourceFactor += renderDistanceFade;
            lightSourceFactor = clamp01(lightSourceFactor);

            float heldLight = max(heldBlockLightValue, heldBlockLightValue2);
            if (heldLight > 0){
                if (heldItemId == 45032 || heldItemId2 == 45032) heldLight = 15; // Lava Bucket
                heldLight = clamp(heldLight, 0.0, 15.0);
                heldLight = sqrt2(heldLight / 15.0) * -1.0 + 1.0; // Normalize and invert
                heldLight = mix(heldLight, 1.0, clamp01((lViewPos) * 35.0 / far)); // Only do it around the player
            } else {
                heldLight = 1.0;
            }
            float mixFactor = heldLight * lightSourceFactor * (1.0 - nightVision);

            float waterDepthStart = waterAltitude + 10;
            float depthFactor = clamp01(10.0 / abs(min(cameraPosition.y, waterDepthStart + 0.001) - waterDepthStart));
            float depthDarkness = clamp(abs(1.0 - (1.0 - depthFactor) * (1.0 - depthFactor)), DARKER_DEPTH_OCEANS * 0.05, 1.0);

            underwaterMult *= mix(1.0, depthDarkness, mixFactor);
        #endif
        color.rgb *= underwaterMult * 0.85;
        volumetricEffect.rgb *= pow2(underwaterMult * 0.55);

        #ifdef COLORED_LIGHT_FOG
            lightFog *= underwaterMult;
        #endif
    } else if (isEyeInWater == 2) {
        if (z1 == 1.0) color.rgb = fogColor * 5.0;

        #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
            color.rgb = changeColorFunction(color.rgb, 1.0, colorSoul, inSoulValley);
        #endif
        #ifdef PURPLE_END_FIRE_INTERNAL
            color.rgb = changeColorFunction(color.rgb, 1.0, colorEndBreath, 1.0);
        #endif

        volumetricEffect.rgb *= 0.0;

        #ifdef COLORED_LIGHT_FOG
            lightFog *= 0.0;
        #endif
    }

    #ifdef COLORED_LIGHT_FOG
        color /= 1.0 + pow2(GetLuminance(lightFog)) * lightFogMult * 2.0;

        lightFog = lightFog * lightFogMult * 0.5;
        #ifdef TAA // Fix banding
            lightFog = max(vec3(0.0), lightFog + (dither - 0.5) * 0.02);
        #endif
        color += lightFog;
    #endif

    #ifdef IMPROVED_RAIN
        vec4 rainData = texelFetch(colortex12, texelCoord, 0);
        if (rainData.r > 0.0) {
            float rainDistance = rainData.r * 100.0;
            if (rainDistance < lViewPos1) {
                int packedRain = int(rainData.g * 255.0 + 0.5);
                bool isRain = (packedRain & 1) != 0;
                int glitterFactor = int((packedRain & 2) != 0);
                bool isSnow = !isRain;

                float blocklight = rainData.b;

                vec3 rainColor = isSnow ? vec3(1.0, 1.0, 1.0) : vec3(0.925, 0.96, 1.0);
                rainColor *= blocklightCol * 2.0 * blocklight + (ambientColor + 0.2 * lightColor) * (0.6 + 0.3 * sunFactor);

                vec3 rainMix = vec3(rainData.a);
                if (rainDistance > lViewPos) rainMix *= pow2(DoReducedLuminanceCorrection(translucentMult, 0.25));

                #ifdef NO_RAIN_ABOVE_CLOUDS
                    if (cameraPosition.y > maximumCloudsHeight) rainMix = vec3(0.0);
                #endif

                rainColor *= vec3(WEATHER_TEX_R, WEATHER_TEX_G, WEATHER_TEX_B);

                #if GLITTER_RAIN > 0
                    rainColor += glitterFactor * (vec3(0.752) * 5.0 - rainColor);
                #endif

                rainColor += lightFog * (1.0 + 4.0 * rainData.g) + color.rgb * rainData.g * 0.25;

                color = mix(color, rainColor, rainMix);
            }
        }
    #endif

    color = pow(color, vec3(2.2));

    #if defined LIGHTSHAFTS_ACTIVE || defined END_PORTAL_BEAM_INTERNAL
        #if defined END && defined TAA // Fix banding
            volumetricEffect.rgb = max(vec3(0.0), volumetricEffect.rgb + (dither - 0.5) * 0.02);
        #endif
        // We add volumetric effect AFTER the "pow color by 2.2" line to get nicer blending
        color += volumetricEffect.rgb;
    #endif

    #ifdef BLOOM_FOG_COMPOSITE1
        color *= GetBloomFog(lViewPos); // Reminder: Bloom Fog can move between composite1-2-3
    #endif

    #if RETRO_LOOK == 1
        color.rgb *= vec3(RETRO_LOOK_R, RETRO_LOOK_G, RETRO_LOOK_B) * 0.5 * RETRO_LOOK_I;
    #elif RETRO_LOOK == 2
        color.rgb *= mix(vec3(1.0), vec3(RETRO_LOOK_R, RETRO_LOOK_G, RETRO_LOOK_B) * 0.5, nightVision) * RETRO_LOOK_I;
    #endif

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(color, 1.0);

    #if LIGHTSHAFT_QUALI_DEFINE > 0 && LIGHTSHAFT_BEHAVIOUR == 1 && SHADOW_QUALITY >= 1 && defined OVERWORLD || defined END || END_CRYSTAL_VORTEX_INTERNAL > 0 || DRAGON_DEATH_EFFECT_INTERNAL > 0 || defined END_PORTAL_BEAM_INTERNAL || defined COLORED_LIGHT_FOG
        vec4 texture5 = vec4(0.0);
        #if LENSFLARE_MODE > 0 || defined ENTITY_TAA_NOISY_CLOUD_FIX || END_CRYSTAL_VORTEX_INTERNAL > 0 || DRAGON_DEATH_EFFECT_INTERNAL > 0 || defined END_PORTAL_BEAM_INTERNAL || defined COLORED_LIGHT_FOG
            texture5 = texelFetch(colortex5, texelCoord, 0);
            if (viewWidth + viewHeight - gl_FragCoord.x - gl_FragCoord.y > 1.5)
                vlFactorM = texture5.a;
        #endif

        /* DRAWBUFFERS:05 */
        gl_FragData[1] = vec4(lightFogLength, 0.0, 0.0, vlFactorM);
    #endif
}

#endif

//////////Vertex Shader//////////Vertex Shader//////////Vertex Shader//////////
#ifdef VERTEX_SHADER

noperspective out vec2 texCoord;

flat out vec3 upVec, sunVec;

#ifdef LIGHTSHAFTS_ACTIVE
    flat out float vlFactor;
#endif

//Attributes//

//Common Variables//

//Common Functions//

//Includes//

//Program//
void main() {
    gl_Position = ftransform();

    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

    upVec = normalize(gbufferModelView[1].xyz);
    sunVec = GetSunVector();

    #ifdef LIGHTSHAFTS_ACTIVE
        #if LIGHTSHAFT_BEHAVIOUR == 1 && SHADOW_QUALITY >= 1 || defined END
            vlFactor = texelFetch(colortex5, ivec2(viewWidth-1, viewHeight-1), 0).a;
        #else
            #if LIGHTSHAFT_BEHAVIOUR == 2
                vlFactor = 0.0;
            #elif LIGHTSHAFT_BEHAVIOUR == 3
                vlFactor = 1.0;
            #endif
        #endif
    #endif
}

#endif

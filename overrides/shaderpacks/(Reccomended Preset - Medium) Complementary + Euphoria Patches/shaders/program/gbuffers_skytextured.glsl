//////////////////////////////////////////
// Complementary Shaders by EminGT      //
// With Euphoria Patches by SpacEagle17 //
//////////////////////////////////////////

//Common//
#include "/lib/common.glsl"
#include "/lib/shaderSettings/tonemaps.glsl"
#define SUN_MOON_IPBR 3 //[0 1 2 3]
#ifdef SUN_MOON_IPBR
#endif

//////////Fragment Shader//////////Fragment Shader//////////Fragment Shader//////////
#ifdef FRAGMENT_SHADER

in vec2 texCoord;

#ifdef SAVE_SKYBOX_DATA
    in vec4 averageSkyColorM;
#endif

flat in vec4 glColor;

#ifdef OVERWORLD
    flat in vec3 upVec, sunVec;
#endif

//Pipeline Constants//

//Common Variables//
#ifdef OVERWORLD
    float SdotU = dot(sunVec, upVec);
    float sunVisibility = clamp(SdotU + 0.0625, 0.0, 0.125) / 0.125;
    float sunVisibility2 = sunVisibility * sunVisibility;
#endif

const int DoCompTonemap = 0;
const int DoBSLTonemap = 1;
const int ACESTonemap = 2;
const int ACESRedModified = 3;
const int BurgessTonemap = 4;
const int LottesTonemap = 5;
const int Uncharted2 = 6;
const int uncharted2_tonemap_partial = 7;
const int uncharted2_filmic = 8;
const int reinhard2 = 9;
const int filmic = 10;
const int GTTonemap = 11;
const int uchimura = 12;
const int agxTonemap = 13;
const int unreal = 14;
const int doSimpleTonemap = 15;

//Common Functions//

//Includes//
#include "/lib/colors/lightAndAmbientColors.glsl"
#ifdef END
    #include "/lib/colors/skyColors.glsl"
#endif

#ifdef CAVE_FOG
    #include "/lib/atmospherics/fog/caveFactor.glsl"
#endif

#ifdef COLOR_CODED_PROGRAMS
    #include "/lib/misc/colorCodedPrograms.glsl"
#endif

//Program//
void main() {
    float materialMask = 0.0;
    int hasCustomSky = 0;
    vec4 skyColor = vec4(0);
    vec4 averageSkyColor = vec4(0);
    #ifdef OVERWORLD
        vec2 tSize = textureSize(tex, 0);
        vec4 color = texture2D(tex, texCoord);
        color.rgb *= max0(glColor.rgb);
        #ifdef SAVE_SKYBOX_DATA
            if (renderStage == MC_RENDER_STAGE_SUNSET || renderStage == MC_RENDER_STAGE_CUSTOM_SKY || renderStage == MC_RENDER_STAGE_SKY) {
                skyColor = color * glColor.a;
                hasCustomSky = int(step(0.5, textureSize(tex, 0).x));
                materialMask = OSIEBCA * 238.0 * hasCustomSky;
                averageSkyColor = averageSkyColorM;
            }
        #endif

        vec4 screenPos = vec4(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z, 1.0);
        vec4 viewPos = gbufferProjectionInverse * (screenPos * 2.0 - 1.0);
        viewPos /= viewPos.w;
        vec3 nViewPos = normalize(viewPos.xyz);

        float VdotS = dot(nViewPos, sunVec);
        float VdotU = dot(nViewPos, upVec);

        float sunMaskRadius = 0.95;
        #ifdef IS_IRIS
            bool sunSideCheck = VdotS > sunMaskRadius;
            bool isSun = renderStage == MC_RENDER_STAGE_SUN;
            bool isMoon = renderStage == MC_RENDER_STAGE_MOON;
            bool aroundSunMoon = isSun || isMoon;
            #if IRIS_VERSION < 10902
                if (sunSideCheck) isSun = true; // Workaround for sun rendering as MC_RENDER_STAGE_MOON in some Iris versions
                isMoon = VdotS < -sunMaskRadius; // Workaround for moon rendering as MC_RENDER_STAGE_SUN in some Iris versions
                aroundSunMoon = abs(VdotS) > sunMaskRadius;
                #ifdef EUPHORIA_PATCHES_IS_SPACE_MOD_INSTALLED
                    isSun = false;
                    isMoon = false;
                    aroundSunMoon = false;
                #endif
            #endif
        #else
            bool sunSideCheck = VdotS > 0.0;
            bool tSizeCheck = abs(tSize.y - 264.0) < 248.5; //tSize.y must range from 16 to 512
            bool isSun = tSizeCheck && sunSideCheck;
            bool isMoon = tSizeCheck && !sunSideCheck;
            bool aroundSunMoon = isSun || isMoon;
        #endif

        if (isSun || isMoon) {
            #if SUN_MOON_STYLE >= 2 && IRIS_VERSION >= 10902
                discard;
            #endif

            #if defined SAVE_SKYBOX_DATA && defined EUPHORIA_PATCHES_IS_SKYBOX_MOD_INSTALLED && IRIS_VERSION < 10902 && SUN_MOON_STYLE >= 2
                if (hasCustomSky < 1) discard;
            #endif

            #ifndef EUPHORIA_PATCHES_IS_SKYBOX_MOD_INSTALLED
                #if SUN_MOON_STYLE >= 2 && IRIS_VERSION < 10902
                    discard;
                #endif

                #if SUN_MOON_IPBR == 1 || SUN_MOON_IPBR == 3
                if (isSun) {
                    float sunBrightness = 4.5;
                    color.rgb = vec3(pow(dot(color.rgb, color.rgb) * 0.45, 6.0 - 5.0 * rainFactor));
                    if (tonemap == ACESTonemap) color.rgb *= mix(vec3(1.0, 0.6275, 0.4549) * 1.2, vec3(0.35), rainFactor * 0.75) * sunBrightness * 0.5;
                    else color.rgb *= mix(vec3(1.1, 0.55, 0.0), vec3(0.35), rainFactor * 0.75) * sunBrightness; // all other tonemaps
                    color.rgb *= 0.25 + 0.75 * sunVisibility2 + 0.5 * noonFactor;
                }
                #endif

                #if SUN_MOON_IPBR == 2 || SUN_MOON_IPBR == 3
                if (isMoon) {
                    // vec3 pixelGlareColor = color.rgb;
                    // pixelGlareColor = mix(pixelGlareColor, pixelGlareColor * vec3(0.9, 0.95, 1.1), 0.5) * 1.3;
                    color.rgb *= smoothstep1(min1(length(color.rgb))) * 1.3;

                    #if BLOOD_MOON > 0
                        float luminance = GetLuminance(color.rgb);
                        color.rgb = mix(color.rgb, pow2(luminance) * vec3(0.702, 0.0, 0.0) * 1.7, getBloodMoon(sunVisibility));
                    #endif

                    // float pixelGlareFactor = 1 - step(0.09,luminance);
                    // color.rgb = mix(color.rgb, pixelGlareColor, pixelGlareFactor);
                }
                #endif

                color.rgb *= GetHorizonFactor(VdotU);

                #ifdef CAVE_FOG
                    color.rgb *= 1.0 - 0.75 * GetCaveFactor();
                #endif
            #endif
        } else { // Custom Sky
            #if MC_VERSION >= 11300 || defined IS_ANGELICA
                #ifdef CUSTOM_SKY_SUPPORT
                    color.rgb *= mix(vec3(1.0), color.rgb * smoothstep1(sqrt1(max0(VdotU))), float(aroundSunMoon)); // we only want it near the sun and moon
                #else
                    color.rgb *= color.rgb * smoothstep1(sqrt1(max0(VdotU)));
                #endif
            #else
                discard;
                // Old mc custom skyboxes are weirdly broken, so we discard.
            #endif
        }

        if (isEyeInWater == 1) color.rgb *= 0.25;

        // Reduced visibility in rain
        #ifndef EUPHORIA_PATCHES_IS_SKYBOX_MOD_INSTALLED
            float rainFactorM = rainFactorDynamic;
            #ifdef SUN_MOON_DURING_RAIN
                rainFactorM *= 0.8;
            #endif
            color.a *= 1.0 - rainFactorM;
        #endif

        #ifdef CUSTOM_SKY_SUPPORT
            // Complementary by default shows the sun/moon while raining. But in vanilla they have an alpha of 0 while raining.
            float vanillaSunMoonMask = float(isSun || isMoon);
            #ifdef EUPHORIA_PATCHES_IS_SKYBOX_MOD_INSTALLED
                vanillaSunMoonMask = 0; // No mask with skybox mod as it breaks visuals
            #endif
            color.rgb *= max0(clamp01(glColor.a) + vanillaSunMoonMask * rainStrength); // Support fop skybox altering mods
            color.a *= max(mix(0.0, clamp01(glColor.a), step(0.02, glColor.a)), vanillaSunMoonMask); // Based on vanilla mask we only set alpha to 0 when glColor.a is 0 and not sun/moon
        #endif
    #endif

    #ifdef NETHER
        vec4 color = vec4(0.0);
    #endif

    #ifdef END
        vec4 color = vec4(endSkyColor, 1.0);
    #endif

    #if RETRO_LOOK == 1
        color.rgb = GetLuminance(color.rgb) * vec3(RETRO_LOOK_R, RETRO_LOOK_G, RETRO_LOOK_B) * 0.3 * RETRO_LOOK_I;
    #elif RETRO_LOOK == 2
        color.rgb = mix(color.rgb, GetLuminance(color.rgb) * vec3(RETRO_LOOK_R, RETRO_LOOK_G, RETRO_LOOK_B) * 0.3 * RETRO_LOOK_I, nightVision);
    #endif

    #ifdef COLOR_CODED_PROGRAMS
        ColorCodeProgram(color, -1);
    #endif

    #ifdef SAVE_SKYBOX_DATA
        /* RENDERTARGETS:0,6,13,14 */
        gl_FragData[0] = color;
        gl_FragData[1] = vec4(0.0, materialMask, 0.0, 0.0);
        gl_FragData[2] = skyColor;
        gl_FragData[3] = averageSkyColor;
    #else
        /* DRAWBUFFERS:0 */
        gl_FragData[0] = color;
    #endif
}

#endif

//////////Vertex Shader//////////Vertex Shader//////////Vertex Shader//////////
#ifdef VERTEX_SHADER

out vec2 texCoord;

#ifdef SAVE_SKYBOX_DATA
    out vec4 averageSkyColorM;
#endif

flat out vec4 glColor;

#ifdef OVERWORLD
    flat out vec3 upVec, sunVec;
#endif

//Attributes//

//Common Variables//

//Common Functions//

#ifdef SAVE_SKYBOX_DATA
vec4 getAverageColor(sampler2D tex) {
    vec4 acc = vec4(0.0);
    float grid = 4.0;
    float invGrid = 1.0 / grid;

    for (float x = 0.0; x < grid; x++) {
        for (float y = 0.0; y < grid; y++) {
            vec2 sampleUV = (vec2(x, y) + 0.5) * invGrid;
            acc += textureLod(tex, sampleUV, 0.0);
        }
    }
    return acc * (invGrid * invGrid);
}
#endif

//Includes//

//Program//
void main() {
    gl_Position = ftransform();
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    #ifdef ATLAS_ROTATION
        texCoord += texCoord * float(hash33(mod(cameraPosition * 0.5, vec3(100.0))));
    #endif

    glColor = gl_Color;

    #ifdef SAVE_SKYBOX_DATA
        averageSkyColorM = getAverageColor(tex) * glColor;
    #endif

    #ifdef OVERWORLD
        upVec = normalize(gbufferModelView[1].xyz);
        sunVec = GetSunVector();
    #endif
}

#endif

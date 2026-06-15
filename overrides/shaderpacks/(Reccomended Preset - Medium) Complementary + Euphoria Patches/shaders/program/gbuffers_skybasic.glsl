//////////////////////////////////////////
// Complementary Shaders by EminGT      //
// With Euphoria Patches by SpacEagle17 //
//////////////////////////////////////////

//Common//
#include "/lib/common.glsl"
#include "/lib/shaderSettings/tonemaps.glsl"
#include "/lib/shaderSettings/stars.glsl"
#define CUSTOM_SKY_MOD_SUPPORT
#ifdef CUSTOM_SKY_MOD_SUPPORT
#endif
#define HIDE_VANILLA_STARS
#ifdef HIDE_VANILLA_STARS
#endif

#if defined MIRROR_DIMENSION || defined WORLD_CURVATURE
    #include "/lib/misc/distortWorld.glsl"
#endif

//////////Fragment Shader//////////Fragment Shader//////////Fragment Shader//////////
#ifdef FRAGMENT_SHADER

flat in vec3 upVec, sunVec;

flat in vec4 glColor;

#ifdef OVERWORLD
    flat in float vanillaStars;
#endif

//Pipeline Constants//

//Common Variables//
float SdotU = dot(sunVec, upVec);
float sunFactor = SdotU < 0.0 ? clamp(SdotU + 0.375, 0.0, 0.75) / 0.75 : clamp(SdotU + 0.03125, 0.0, 0.0625) / 0.0625;
float sunVisibility = clamp(SdotU + 0.0625, 0.0, 0.125) / 0.125;
float sunVisibility2 = sunVisibility * sunVisibility;
float shadowTimeVar1 = abs(sunVisibility - 0.5) * 2.0;
float shadowTimeVar2 = shadowTimeVar1 * shadowTimeVar1;
float shadowTime = shadowTimeVar2 * shadowTimeVar2;

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
#include "/lib/util/dither.glsl"

#ifdef OVERWORLD
    #include "/lib/atmospherics/sky.glsl"
    #include "/lib/atmospherics/stars.glsl"
    #include "/lib/atmospherics/shootingStars.glsl"
#endif

#ifdef CAVE_FOG
    #include "/lib/atmospherics/fog/caveFactor.glsl"
#endif

#ifdef ATM_COLOR_MULTS
    #include "/lib/colors/colorMultipliers.glsl"
#endif
#ifdef MOON_PHASE_INF_ATMOSPHERE
    #include "/lib/colors/moonPhaseInfluence.glsl"
#endif

#ifdef COLOR_CODED_PROGRAMS
    #include "/lib/misc/colorCodedPrograms.glsl"
#endif

#if SUN_MOON_STYLE >= 2
    #include "/lib/util/spaceConversion.glsl"
#endif

//Program//
void main() {
    vec4 color = vec4(glColor.rgb, 1.0);
    float alphaColor = glColor.a;

    #ifdef OVERWORLD
        #if defined HIDE_VANILLA_STARS && !defined EUPHORIA_PATCHES_IS_ASTROCRAFT_INSTALLED
            if (vanillaStars > 0.5) {
                discard;
            }
        #endif

        #if IRIS_VERSION >= 10800 && IRIS_VERSION < 10805
            if (renderStage == MC_RENDER_STAGE_MOON) {
                discard; // Fixes the vanilla sky gradient causing the sun to disappear
            }
        #endif

        vec4 screenPos = vec4(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z, 1.0);
        vec4 viewPos = gbufferProjectionInverse * (screenPos * 2.0 - 1.0);
        viewPos /= viewPos.w;
        vec3 nViewPos = normalize(viewPos.xyz);

        float VdotU = dot(nViewPos, upVec);
        float VdotS = dot(nViewPos, sunVec);
        float dither = Bayer8(gl_FragCoord.xy);

        bool isCustomSky;
        color.rgb = GetSky(VdotU, VdotS, dither, true, false, isCustomSky, false);
        #if defined CUSTOM_SKY_MOD_SUPPORT && MC_VERSION >= 11605
            if (alphaColor < 1.0 && alphaColor > 0.0 && renderStage != MC_RENDER_STAGE_SKY) color.rgb = glColor.rgb * alphaColor;
        #endif

        #ifdef ATM_COLOR_MULTS
            color.rgb *= GetAtmColorMult();
        #endif
        #ifdef MOON_PHASE_INF_ATMOSPHERE
            color.rgb *= moonPhaseInfluence;
        #endif

        vec2 starCoord = GetStarCoord(viewPos.xyz, 0.5);
        #if STAR_BRIGHTNESS != 3
            vec3 starColor = GetStars(starCoord, VdotU, VdotS, 1.0, 0.0);

            #define ADD_STAR_LAYER_OW1 (STAR_LAYER_OW == 1 || STAR_LAYER_OW == 3)
            #define ADD_STAR_LAYER_OW2 (STAR_LAYER_OW == 2 || STAR_LAYER_OW == 3)

            #if ADD_STAR_LAYER_OW1
                starColor = max(starColor, GetStars(starCoord, VdotU, VdotS, 0.66, 0.0));
            #endif

            #if ADD_STAR_LAYER_OW2
                starColor = max(starColor, GetStars(starCoord, VdotU, VdotS, 2.2, 0.45));
            #endif

            color.rgb += starColor;
            #ifdef SHOOTING_STARS
                color.rgb += GetShootingStars(starCoord, VdotU, VdotS);
            #endif
        #endif

        #if SUN_MOON_STYLE >= 2
            float absVdotS = abs(VdotS);
            #if SUN_MOON_STYLE == 2
                float sunSizeFactor1 = 0.9975;
                float sunSizeFactor2 = 400.0;
                float moonCrescentOffset = 0.0055;
                float moonPhaseFactor1 = 2.45;
                float moonPhaseFactor2 = 750.0;
            #else
                float sunSizeFactor1 = 0.9983;
                float sunSizeFactor2 = 588.235;
                float moonCrescentOffset = 0.0042;
                float moonPhaseFactor1 = 2.2;
                float moonPhaseFactor2 = 1000.0;
            #endif
            if (absVdotS > sunSizeFactor1) {
                float sunMoonMixer = sqrt1(sunSizeFactor2 * (absVdotS - sunSizeFactor1));

                #ifdef SUN_MOON_DURING_RAIN
                    sunMoonMixer *= 1.0 - 0.4 * rainFactor2;
                #else
                    sunMoonMixer *= 1.0 - rainFactor2;
                #endif

                if (VdotS > 0.0) {
                    sunMoonMixer = pow2(sunMoonMixer) * GetHorizonFactor(SdotU);

                    #ifdef CAVE_FOG
                        sunMoonMixer *= 1.0 - 0.65 * GetCaveFactor();
                    #endif
                    float sunBrightness = 25.0;
                    if (tonemap == ACESTonemap) color.rgb = mix(color.rgb, vec3(1.0, 0.698, 0.5451) * sunBrightness, sunMoonMixer);
                    else
                    color.rgb = mix(color.rgb, vec3(0.9, 0.5, 0.3) * sunBrightness, sunMoonMixer);
                } else {
                    float horizonFactor = GetHorizonFactor(-SdotU);
                    sunMoonMixer = max0(sunMoonMixer - 0.25) * 1.33333 * horizonFactor;

                    starCoord = GetStarCoordUpperHemisphere(viewPos.xyz, 1.0) * 0.5 + 0.617;
                    float moonNoise = texture2DLod(noisetex, starCoord, 0.0).g
                                    + texture2DLod(noisetex, starCoord * 2.5, 0.0).g * 0.7
                                    + texture2DLod(noisetex, starCoord * 5.0, 0.0).g * 0.5;
                    moonNoise = max0(moonNoise - 0.75) * 1.7;
                    vec3 moonColor = vec3(0.38, 0.4, 0.5);
                    #if BLOOD_MOON > 0
                        moonColor = mix(moonColor, vec3(0.4588, 0.149, 0.149) * 1.5, getBloodMoon(sunVisibility));
                    #endif
                    moonColor *= (1.2 - (0.2 + 0.2 * sqrt1(nightFactor)) * moonNoise);

                    if (moonPhase >= 1) {
                        float moonPhaseOffset = 0.0;
                        if (moonPhase != 4) {
                            moonPhaseOffset = moonCrescentOffset;
                            moonColor *= 8.5;
                        } else moonColor *= 10.0;
                        if (moonPhase > 4) {
                            moonPhaseOffset = -moonPhaseOffset;
                        }

                        float ang = fract(timeAngle - (0.25 + moonPhaseOffset));
                        ang = (ang + (cos(ang * 3.14159265358979) * -0.5 + 0.5 - ang) / 3.0) * 6.28318530717959;
                        vec2 sunRotationData2 = vec2(cos(sunPathRotation * 0.01745329251994), -sin(sunPathRotation * 0.01745329251994));
                        vec3 rawSunVec2 = (gbufferModelView * vec4(vec3(-sin(ang), cos(ang) * sunRotationData2) * 2000.0, 1.0)).xyz;

                        float moonPhaseVdosS = dot(nViewPos, normalize(rawSunVec2.xyz));

                        sunMoonMixer *= pow2(1.0 - min1(pow(abs(moonPhaseVdosS), moonPhaseFactor2) * moonPhaseFactor1));
                    } else moonColor *= 4.0;

                    #ifdef CAVE_FOG
                        sunMoonMixer *= 1.0 - 0.5 * GetCaveFactor();
                    #endif

                    color.rgb = mix(color.rgb, moonColor, sunMoonMixer);
                }
            }
        #endif
    #endif

    color.rgb *= 1.0 - maxBlindnessDarkness;

    #ifdef COLOR_CODED_PROGRAMS
        ColorCodeProgram(color, -1);
    #endif

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = color;
}

#endif

//////////Vertex Shader//////////Vertex Shader//////////Vertex Shader//////////
#ifdef VERTEX_SHADER

flat out vec3 upVec, sunVec;

flat out vec4 glColor;

#ifdef OVERWORLD
    flat out float vanillaStars;
#endif

//Attributes//

#ifdef WAVE_EVERYTHING
    attribute vec4 mc_midTexCoord;
    vec2 lmCoord = GetLightMapCoordinates();
#endif

//Common Variables//

//Common Functions//

//Includes//

#ifdef WAVE_EVERYTHING
    #include "/lib/materials/materialMethods/wavingBlocks.glsl"
#endif

//Program//
void main() {
    gl_Position = ftransform();

    glColor = gl_Color;

    upVec = normalize(gbufferModelView[1].xyz);
    sunVec = GetSunVector();

    #ifdef OVERWORLD
        #if MC_VERSION >= 11605 && (defined IS_ANGELICA || defined IS_IRIS)
            vanillaStars = float(renderStage == MC_RENDER_STAGE_STARS);
        #else
            //Vanilla Star Dedection by Builderb0y
            vanillaStars = float(glColor.r == glColor.g && glColor.g == glColor.b && glColor.r > 0.0 && glColor.r < 0.51);
        #endif
    #endif
}

#endif

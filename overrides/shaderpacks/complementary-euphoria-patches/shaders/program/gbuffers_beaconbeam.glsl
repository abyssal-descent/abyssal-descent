/////////////////////////////////////
// Complementary Shaders by EminGT //
// With Euphoria Patches by SpacEagle17 //
/////////////////////////////////////

//Common//
#include "/lib/common.glsl"
#define BEACON_BEAM_EMISSION 1.0 //[0.5 1.0 1.5 2.0 2.5 3.0 3.5 4.0 4.5 5.0]

//////////Fragment Shader//////////Fragment Shader//////////Fragment Shader//////////
#ifdef FRAGMENT_SHADER

in vec2 texCoord;

flat in vec3 upVec, sunVec;

in vec4 glColor;

//Pipeline Constants//

//Common Variables//
float SdotU = dot(sunVec, upVec);
float sunFactor = SdotU < 0.0 ? clamp(SdotU + 0.375, 0.0, 0.75) / 0.75 : clamp(SdotU + 0.03125, 0.0, 0.0625) / 0.0625;
float sunVisibility = clamp(SdotU + 0.0625, 0.0, 0.125) / 0.125;
float sunVisibility2 = sunVisibility * sunVisibility;
float shadowTimeVar1 = abs(sunVisibility - 0.5) * 2.0;
float shadowTimeVar2 = shadowTimeVar1 * shadowTimeVar1;
float shadowTime = shadowTimeVar2 * shadowTimeVar2;

//Common Functions//

//Includes//
#include "/lib/util/spaceConversion.glsl"
#include "/lib/util/dither.glsl"
#include "/lib/atmospherics/fog/mainFog.glsl"

#ifdef TAA
    #include "/lib/antialiasing/jitter.glsl"
#endif

#ifdef COLOR_CODED_PROGRAMS
    #include "/lib/misc/colorCodedPrograms.glsl"
#endif

//Program//
void main() {
    vec4 color = texture2D(tex, texCoord);
    vec3 colorP = color.rgb;
    color *= glColor;

    vec3 screenPos = vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z);
    #ifdef TAA
        vec3 viewPos = ScreenToView(vec3(TAAJitter(screenPos.xy, -0.5), screenPos.z));
    #else
        vec3 viewPos = ScreenToView(screenPos);
    #endif

    #ifdef DISTANT_HORIZONS
        vec3 screenPosDH = vec3(screenPos.xy, texture2D(dhDepthTex, screenPos.xy).r);
        #ifdef TAA
            vec3 viewPosDH = ScreenToViewDH(vec3(TAAJitter(screenPosDH.xy, -0.5), screenPosDH.z));
        #else
            vec3 viewPosDH = ScreenToViewDH(screenPosDH);
        #endif

        if (viewPos.z < viewPosDH.z)
            discard;
    #endif

    float lViewPos = length(viewPos);
    vec3 nViewPos = normalize(viewPos);
    vec3 playerPos = ViewToPlayer(viewPos);
    float VdotU = dot(nViewPos, upVec);
    float VdotS = dot(nViewPos, sunVec);

    float dither = Bayer64(gl_FragCoord.xy);
    #ifdef TAA
        dither = fract(dither + goldenRatio * mod(float(frameCounter), 3600.0));
    #endif

    #ifdef ATM_COLOR_MULTS
        atmColorMult = GetAtmColorMult();
    #endif
    float emission = 1.0;

    #ifdef IPBR
        emission = dot(colorP, colorP);

        if (0.5 > color.a && color.a > 0.01) {
            color.a = 0.101;
            emission = pow2(pow2(emission)) * 0.1;
        }

        emission *= BEACON_BEAM_EMISSION;

        color.rgb *= color.rgb * emission * 1.75;
        color.rgb += emission * 0.05;
    #else
        color.rgb *= color.rgb * 4.0 * BEACON_BEAM_EMISSION;
    #endif

    #ifdef SS_BLOCKLIGHT
        vec3 lightAlbedo = normalize(color.rgb) * min1(emission);
    #endif

    color.rgb *= 0.5 + 0.5 * exp(-lViewPos * 0.04);

    #ifdef COLOR_CODED_PROGRAMS
        ColorCodeProgram(color, -1);
    #endif

    // We do border fog here as well because the outer layer of the beam has broken depth in later programs
    float sky = 0.0;
    #ifndef NETHER
        if (playerPos.y > 0.0) {
            playerPos.y = pow(playerPos.y / far, 0.15) * far;
        }
    #endif
    DoFog(color.rgb, sky, lViewPos, playerPos, VdotU, VdotS, dither);
    color.a *= 1.0 - sky;

    /* DRAWBUFFERS:06 */
    gl_FragData[0] = color;
    gl_FragData[1] = vec4(0.0, 0.0, 0.0, 1.0);

    #ifdef SS_BLOCKLIGHT
        /* DRAWBUFFERS:068 */
        gl_FragData[2] = vec4(lightAlbedo, 1);
    #endif
}

#endif

//////////Vertex Shader//////////Vertex Shader//////////Vertex Shader//////////
#ifdef VERTEX_SHADER

out vec2 texCoord;

flat out vec3 upVec, sunVec;

out vec4 glColor;

//Attributes//

#if defined ATLAS_ROTATION || defined WAVE_EVERYTHING
    attribute vec4 mc_midTexCoord;
    vec2 lmCoord = GetLightMapCoordinates();
#endif

//Common Variables//

//Common Functions//

//Includes//
#ifdef TAA
    #include "/lib/antialiasing/jitter.glsl"
#endif

#if defined MIRROR_DIMENSION || defined WORLD_CURVATURE
    #include "/lib/misc/distortWorld.glsl"
#endif

#ifdef WAVE_EVERYTHING
    #include "/lib/materials/materialMethods/wavingBlocks.glsl"
#endif

//Program//
void main() {
    gl_Position = ftransform();
    #ifdef TAA
        gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
    #endif

    upVec = normalize(gbufferModelView[1].xyz);
    sunVec = GetSunVector();

    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    #ifdef ATLAS_ROTATION
        texCoord += texCoord * float(hash33(mod(cameraPosition * 0.5, vec3(100.0))));
    #endif

    #if defined MIRROR_DIMENSION || defined WORLD_CURVATURE || defined WAVE_EVERYTHING
        vec4 position = gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;
        #ifdef MIRROR_DIMENSION
            doMirrorDimension(position);
        #endif
        #ifdef WORLD_CURVATURE
            position.y += doWorldCurvature(position.xz);
        #endif
        #ifdef WAVE_EVERYTHING
            DoWaveEverything(position.xyz);
        #endif
        gl_Position = gl_ProjectionMatrix * gbufferModelView * position;
    #endif

    glColor = gl_Color;
}

#endif

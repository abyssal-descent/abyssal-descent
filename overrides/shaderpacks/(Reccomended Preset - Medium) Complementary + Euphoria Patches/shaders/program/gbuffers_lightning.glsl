/////////////////////////////////////
// Complementary Shaders by EminGT //
/////////////////////////////////////

//Common//
#include "/lib/common.glsl"

#if defined MIRROR_DIMENSION || defined WORLD_CURVATURE
    #include "/lib/misc/distortWorld.glsl"
#endif

//////////Fragment Shader//////////Fragment Shader//////////Fragment Shader//////////
#ifdef FRAGMENT_SHADER

in vec2 texCoord;
in vec2 lmCoord;

flat in vec3 upVec, sunVec, northVec, eastVec;
in vec3 normal;

in vec4 glColor;

//Pipeline Constants//

//Common Variables//
float NdotU = dot(normal, upVec);
float NdotUmax0 = max(NdotU, 0.0);
float SdotU = dot(sunVec, upVec);
float sunFactor = SdotU < 0.0 ? clamp(SdotU + 0.375, 0.0, 0.75) / 0.75 : clamp(SdotU + 0.03125, 0.0, 0.0625) / 0.0625;
float sunVisibility = clamp(SdotU + 0.0625, 0.0, 0.125) / 0.125;
float sunVisibility2 = sunVisibility * sunVisibility;
float shadowTimeVar1 = abs(sunVisibility - 0.5) * 2.0;
float shadowTimeVar2 = shadowTimeVar1 * shadowTimeVar1;
float shadowTime = shadowTimeVar2 * shadowTimeVar2;

#ifdef OVERWORLD
    vec3 lightVec = sunVec * ((timeAngle < 0.5325 || timeAngle > 0.9675) ? 1.0 : -1.0);
#else
    vec3 lightVec = sunVec;
#endif

//Common Functions//

//Includes//
#include "/lib/util/spaceConversion.glsl"
#include "/lib/lighting/mainLighting.glsl"
#include "/lib/util/dither.glsl"

#ifdef COLOR_CODED_PROGRAMS
    #include "/lib/misc/colorCodedPrograms.glsl"
#endif

//Program//
void main() {
    vec4 color = texture2D(tex, texCoord);
    vec3 colorP = color.rgb;
    color *= glColor;

    float dither = Bayer64(gl_FragCoord.xy);
    #ifdef TAA
        dither = fract(dither + goldenRatio * mod(float(frameCounter), 3600.0));
    #endif

    float materialMask = 0.0;

    if (entityId == 50004
        #if MC_VERSION >= 12105 && defined IS_IRIS
            // Iris broken lightning bolt detection after 1.21.5
            || dot(color.rgb, color.rgb) > 0.01 && color.r < 0.45 && color.g < 0.45 && color.b < 0.5
        #endif
    ) { // Lightning Bolt
        #include "/lib/materials/specificMaterials/others/lightningBolt.glsl"
        materialMask = OSIEBCA * 254.0; // No SSAO, No TAA, Reduce Reflection
    } else { // Dragon Death Beams, and possibly modded effects
        #ifdef END
            if (dither < 0.8) discard;
            color.rgb *= 15.0;
            #if DRAGON_DEATH_EFFECT_INTERNAL == 1
                discard;
            #endif
        #endif
    }

    color.rgb = mix(color.rgb, entityColor.rgb, entityColor.a);

    #ifdef SS_BLOCKLIGHT
        vec3 lightAlbedo = normalize(color.rgb);
    #endif

    #ifdef COLOR_CODED_PROGRAMS
        ColorCodeProgram(color, -1);
    #endif

    /* DRAWBUFFERS:06 */
    gl_FragData[0] = color;
    gl_FragData[1] = vec4(0.0, materialMask, 1.0, 1.0);

    #if BLOCK_REFLECT_QUALITY >= 2 && RP_MODE >= 1
        /* DRAWBUFFERS:064 */
        gl_FragData[2] = vec4(0.0, 1.0, 0.0, 1.0);
        #ifdef SS_BLOCKLIGHT
            /* DRAWBUFFERS:0649 */
            gl_FragData[3] = vec4(lightAlbedo, 1.0);
        #endif
    #elif defined SS_BLOCKLIGHT
        /* DRAWBUFFERS:069 */
        gl_FragData[2] = vec4(lightAlbedo, 1.0);
    #endif
}

#endif

//////////Vertex Shader//////////Vertex Shader//////////Vertex Shader//////////
#ifdef VERTEX_SHADER

out vec2 texCoord;
out vec2 lmCoord;

flat out vec3 upVec, sunVec, northVec, eastVec;
out vec3 normal;

out vec4 glColor;

//Pipeline Constants//
#if DRAGON_DEATH_EFFECT_INTERNAL > 0
    #extension GL_ARB_shader_image_load_store : enable
#endif

//Attributes//
attribute vec4 at_midBlock;

//Common Variables//

//Common Functions//

//Includes//
#if DRAGON_DEATH_EFFECT_INTERNAL > 0
    #include "/lib/voxelization/endCrystalVoxelization.glsl"
#endif

//Program//
void main() {
    gl_Position = ftransform();

    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmCoord  = GetLightMapCoordinates();

    lmCoord.x = min(lmCoord.x, 0.9);
    //Fixes some servers/mods making entities insanely bright, while also slightly reducing the max blocklight on a normal entity

    glColor = gl_Color;

    normal = normalize(gl_NormalMatrix * gl_Normal);

    upVec = normalize(gbufferModelView[1].xyz);
    eastVec = normalize(gbufferModelView[0].xyz);
    northVec = normalize(gbufferModelView[2].xyz);
    sunVec = GetSunVector();

    #if defined FLICKERING_FIX && SHADOW_QUALITY == -1
        if (glColor.a < 0.5) gl_Position.z += 0.0005;
    #endif

    #if DRAGON_DEATH_EFFECT_INTERNAL > 0
        if ((entityId == 0 || entityId == 50204) && (glColor.a < 0.2 || glColor.a == 1.0)) { // Only lightning bolts and dragon death effect run in this program, lightning has an entity ID assigned
            SetEndDragonDeath();
            #if DRAGON_DEATH_EFFECT_INTERNAL == 1
                gl_Position = vec4(0);
            #endif
        }
    #endif
}

#endif

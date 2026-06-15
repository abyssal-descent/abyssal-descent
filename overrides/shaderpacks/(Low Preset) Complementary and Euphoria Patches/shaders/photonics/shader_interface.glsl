#define shadow2D texture
#define texture2D texture
#define texture2DLod textureLod
#define PHOTONICS_SHADER_INTERFACE
#define FRAGMENT_SHADER

#include "/lib/common.glsl"
#include "/lib/util/spaceConversion.glsl"
#include "/lib/util/dither.glsl"
#include "/lib/antialiasing/jitter.glsl"
#include "/lib/shaderSettings/photonics.glsl"
#include "/lib/shaderSettings/materials.glsl"
#include "/lib/shaderSettings/mainLighting.glsl"

uniform vec3 sunPosition;
uniform vec3 upPosition;

vec3 sunVec = normalize(sunPosition);
vec3 upVec = normalize(upPosition);
vec3 sunVecWorld = normalize(mat3(gbufferModelViewInverse) * sunVec);

float SdotU = dot(sunVec, upVec);
float sunVisibility = clamp(SdotU + 0.0625, 0.0, 0.125) / 0.125;
float sunVisibility2 = sunVisibility * sunVisibility;

#include "/lib/colors/lightAndAmbientColors.glsl"

float sunVisibilitySaturated = clamp((dot(sunVec, upVec) + 0.0625f) / 0.125f, 0.0f, 1.0f);
vec3 lightVecWorld = (sunVecWorld.y < 0.0f) ? -sunVecWorld : sunVecWorld;

const float rcp_render_scale = 1f / PHOTONICS_RENDER_SCALE;
ivec2 ph_tex_coord = ivec2(texelCoord * rcp_render_scale + 0.5);

vec3 load_world_position() {
    #if PHOTONICS_LIGHTING_MODE == 1
        #define fixThisStupidShaderBugWithDifferentDepthTex depthtex1
    #else
        #define fixThisStupidShaderBugWithDifferentDepthTex depthtex0
    #endif
    vec2 texCoord = gl_FragCoord.xy / floor(vec2(viewWidth, viewHeight) * PHOTONICS_RENDER_SCALE);
    float depth = texelFetch(fixThisStupidShaderBugWithDifferentDepthTex, ph_tex_coord, 0).r;
    #ifdef TAA
        vec3 screenPos = vec3(TAAJitter(texCoord, -0.5), depth);
    #else
        vec3 screenPos = vec3(texCoord, depth);
    #endif
    vec3 playerPos = ViewToPlayer(ScreenToView(screenPos));
    #ifdef PHOTONICS_PIXELATED_SHADOWS_INTERNAL
        playerPos += texelFetch(colortex11, ph_tex_coord, 0).rgb;
    #endif

    return playerPos + cameraPositionBest;
}

void load_fragment_variables(out vec3 albedo, out vec3 world_pos, out vec3 world_normal, out vec3 world_normal_mapped) {
    albedo = texelFetch(colortex10, ph_tex_coord, 0).xyz;
    world_normal = texelFetch(colortex20, ph_tex_coord, 0).xyz;
    world_normal_mapped = texelFetch(colortex4, ph_tex_coord, 0).xyz;
    world_pos = load_world_position() - 0.01f * world_normal;
}

vec3 sun_direction = normalize(lightVecWorld);

vec3 indirect_light_color = pow(mix(lightColor, vec3(GetLuminance(lightColor)), 0.8f) * mix(2.5, 1.0, sunVisibility2), vec3(1.5));

vec2 get_taa_jitter() { return vec2(0.0f); }

vec3 get_sky_color(ivec2 gBufferLoc, vec3 worldPos, vec3 newNormal) {
    return vec3(0);
}

bool is_in_world() { return texelFetch(depthtex0, ph_tex_coord, 0).x <= 0.99999f; }

#define PH_USE_CUSTOM_ALPHA
#define PH_ALPHA_FUNC(color) apply_tint_impl(color)

vec3 apply_tint_impl(vec4 color) {
    #if PHOTONICS_LIGHTING_MODE == 1
        float tintStrength = 1.66;
        float tintSaturation = 1.35;
    #elif PHOTONICS_LIGHTING_MODE == 2
        float tintStrength = 1.0;
        float tintSaturation = 1.2;
    #endif
    return clamp01(saturateColors(mix(
        color.rgb,
        vec3(step(color.a, 0.5)),
        abs((color.a * 2f) - 1f)
    ), tintSaturation) * tintStrength);
}

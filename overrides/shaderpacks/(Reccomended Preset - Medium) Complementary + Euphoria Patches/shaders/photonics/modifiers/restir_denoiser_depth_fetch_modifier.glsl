#include "/lib/common.glsl"
#include "/lib/shaderSettings/photonics.glsl"

ivec2 modify_denoiser_depth_fetch(ivec2 texCoord) {
    const float render_factor = 1f / PHOTONICS_RENDER_SCALE ;

    return ivec2(texCoord * render_factor + 0.5);
}

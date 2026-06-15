#include "/lib/shaderSettings/photonics.glsl"

bool modify_is_hand() {
  const float render_factor = 1f / PHOTONICS_RENDER_SCALE;

  return texelFetch(depthtex0, ivec2(gl_FragCoord.xy * render_factor + 0.5), 0).x < 0.56;
}

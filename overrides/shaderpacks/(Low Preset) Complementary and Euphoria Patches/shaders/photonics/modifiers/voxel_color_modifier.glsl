#include "/lib/common.glsl"
#include "/lib/shaderSettings/materials.glsl"

void voxel_color_modifier(inout vec4 color, vec3 rt_pos, ivec3 rt_block_pos) {
    int mat = result_block_id;
    #if defined NETHER && defined BIOME_COLORED_NETHER_PORTALS
        if (mat == 30020) color.rgb = normalize(netherColor) * GetLuminance(color.rgb) * 2.5;
    #endif
}

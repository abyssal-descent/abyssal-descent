layout(location = 0) out vec4 fragColor;
void write_indirect(vec3 color) {
    /* RENDERTARGETS:9 */
    color = saturateColors(color, 1.25f);
    fragColor = vec4(color, 1.0f);
}

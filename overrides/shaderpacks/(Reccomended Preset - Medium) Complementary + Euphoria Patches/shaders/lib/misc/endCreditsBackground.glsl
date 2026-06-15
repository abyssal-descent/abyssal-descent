vec3 endCreditsEffect(vec2 texCoord) {
    vec3 color = vec3(0.0);

    float time = frameTimeCounter * 1.08;
    vec2 uv = texCoord;

    float flow1 = sin(uv.y * 2.5 + time * 0.3) * 0.4;
    flow1 += sin(uv.x * 2.8 - time * 0.2) * 0.4;
    flow1 += sin((uv.x + uv.y) * 3.2 + time * 0.4) * 0.25;

    float flow2 = sin(uv.x * 4.8 + time * 0.25) * 0.4;
    flow2 += sin(uv.y * 12.7 - time * 0.35) * 0.4;

    float flow3 = sin(uv.x * 7.5 + uv.y * 6.5 + time * 0.5) * 0.35;
    flow3 += sin(uv.x * 9.0 - uv.y * 7.0 - time * 0.3) * 0.25;

    float gooey = flow1 + flow2 + flow3;
    gooey = smoothstep(0.2, 0.8, gooey);

    vec2 centerDist = (uv - 0.5) * 2.0;
    float falloff = exp(-length(centerDist) * 0.6);
    gooey *= falloff;

    vec3 darkPurple = vec3(0.25, 0.0, 0.35);
    vec3 mutedMagenta = vec3(0.45, 0.0, 0.40);
    vec3 softPurple = vec3(0.35, 0.0, 0.50);

    vec3 flowColor = mix(darkPurple, mutedMagenta, flow1 * 0.5 + 0.5);
    flowColor = mix(flowColor, softPurple, flow2 * 0.5);
    flowColor = mix(flowColor, mutedMagenta, flow3 * 0.4);

    color = flowColor * gooey * 0.35;
    color += (softPurple * 0.7) * smoothstep(0.0, 0.5, flow3) * falloff * 0.25;
    color += (mutedMagenta * 0.5) * smoothstep(0.0, 0.5, gooey) * falloff * 0.15;

    return color * 0.75;
}

#if !defined END_CENTER_FOG
#define END_CENTER_FOG
float doEndCenterFog(vec3 ro, vec3 rayDir, float wsdist, float falloff) { // Thanks to FoZy STYLE
    vec3 d = ro - vec3(0.5, 60.5, 0.5); // Light source vector
    d.y *= 0.7;
    rayDir.y *= 0.7;

    float a = falloff * dot(rayDir, rayDir);
    float b  = 2.0 * falloff * dot(rayDir, d);
    float c = 1.0 + falloff * dot(d, d);

    float sqrtDiscr = max(0.001, sqrt(4.0 * a * c - b * b));
    float upper = (2.0 * a * wsdist + b) / sqrtDiscr;
    float lower = b / sqrtDiscr;

    return 2.0 * (atan(upper) - atan(lower)) / sqrtDiscr;
}
#endif

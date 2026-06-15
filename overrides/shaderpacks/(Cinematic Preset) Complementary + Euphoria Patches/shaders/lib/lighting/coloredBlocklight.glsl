vec3 linearRGB_to_Oklab(vec3 c) {
    // Linear RGB to XYZ
    float l = 0.4122214708 * c.r + 0.5363325363 * c.g + 0.0514459929 * c.b;
    float m = 0.2119034982 * c.r + 0.6806995451 * c.g + 0.1073969566 * c.b;
    float s = 0.0883024619 * c.r + 0.2817188376 * c.g + 0.6299787005 * c.b;

    // XYZ to Oklab
    float l_ = pow(l, 1.0/3.0);
    float m_ = pow(m, 1.0/3.0);
    float s_ = pow(s, 1.0/3.0);

    return vec3(
        0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_,
        1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_,
        0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_
    );
}

vec3 Oklab_to_linearRGB(vec3 lab) {
    // Oklab to XYZ
    float l_ = lab.x + 0.3963377774 * lab.y + 0.2158037573 * lab.z;
    float m_ = lab.x - 0.1055613458 * lab.y - 0.0638541728 * lab.z;
    float s_ = lab.x - 0.0894841775 * lab.y - 1.2914855480 * lab.z;

    float l = l_*l_*l_;
    float m = m_*m_*m_;
    float s = s_*s_*s_;

    // XYZ to linear RGB
    return vec3(
        +4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
        -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
        -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s
    );
}

vec3 saturateMCBL(vec3 color) {
    vec3 oklab = linearRGB_to_Oklab(color);
    float L = oklab.x;
    vec2 ab = oklab.yz;
    float chroma = length(ab);
    float maxChroma = 0.11;
    float targetChroma = min(chroma * 1.7, maxChroma);

    float chromaFactor = (chroma > 0.0001) ? min(targetChroma / chroma, 2.0) : 1.0;
    ab *= chromaFactor;

    return Oklab_to_linearRGB(vec3(L, ab.xy));
}

vec3 ApplyMultiColoredBlocklight(vec3 blocklightCol, vec3 screenPos, vec3 playerPos, float lmCoord) {
    float ACLDecider = 1.0;
    vec4 coloredLight = texture2D(colortex9, screenPos.xy);
    float entityMask = step(0.5, sqrt3(coloredLight.a)) * step(0.1, lmCoord);
    #if MCBL_MAIN_DEFINE == 2 && COLORED_LIGHTING_INTERNAL != 0
        vec3 absPlayerPos = abs(playerPos);
        float maxPlayerPos = max(absPlayerPos.x, max(absPlayerPos.y * 2.0, absPlayerPos.z));
        ACLDecider = pow2(min1(maxPlayerPos / min(effectiveACLdistance, far) * 2.0)); // this is to make the effect fade at the edge of ACL range
        if (ACLDecider < 0.5 && entityMask < 0.5) return blocklightCol;
    #endif
    
    vec3 cameraOffset = cameraPosition - previousCameraPosition;
    cameraOffset *= float(screenPos.z * 2.0 - 1.0 > 0.56);

    if (screenPos.z > 0.56) {
        screenPos.xy = Reprojection(screenPos, cameraOffset);
    }

    coloredLight.rgb = saturateMCBL(coloredLight.rgb); // make colors pop!

    vec3 coloredLightNormalized = normalize(coloredLight.rgb + 0.00001);

    // do luminance correction for a seamless transition from the default blocklight color
    coloredLightNormalized *= GetLuminance(blocklightCol) / GetLuminance(coloredLightNormalized);

    float coloredLightMix = min1((coloredLight.r + coloredLight.g + coloredLight.b) * 2048);
    coloredLightMix = mix(0, coloredLightMix, mix(ACLDecider, 1.0, entityMask));

    // coloredLightNormalized = vec3(2,0,0);

    return mix(blocklightCol, coloredLightNormalized, coloredLightMix * clamp01(MCBL_INFLUENCE));
}
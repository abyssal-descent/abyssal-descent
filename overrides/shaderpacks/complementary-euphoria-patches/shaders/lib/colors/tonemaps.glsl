vec3 DoBSLTonemap(vec3 color) {
    color = T_EXPOSURE * color;
    color = color / pow(pow(color, vec3(TM_WHITE_CURVE)) + 1.0, vec3(1.0 / TM_WHITE_CURVE));
    color = pow(color, mix(vec3(T_LOWER_CURVE), vec3(T_UPPER_CURVE), sqrt(color)));

    return pow(color, vec3(1.0 / 2.2));
}

void linearToRGB(inout vec3 color) {
    const vec3 k = vec3(0.055);
    color = mix((vec3(1.0) + k) * pow(color, vec3(1.0 / 2.4)) - k, 12.92 * color, lessThan(color, vec3(0.0031308)));
}

void doColorAdjustments(inout vec3 color) {
    color = (T_EXPOSURE - 0.40) * color;
    // color = color / pow(pow(color, vec3(TM_WHITE_CURVE * 0.5)) + 1.0, vec3(1.0 / (TM_WHITE_CURVE * 0.5)));
    color = pow(color, mix(vec3(T_LOWER_CURVE - 0.20), vec3(T_UPPER_CURVE - 0.30), sqrt(color)));
}

float saturationTM = T_SATURATION;

vec3 LottesTonemap(vec3 color) {
    // Lottes 2016, "Advanced Techniques and Optimization of HDR Color Pipelines"
    // http://32ipi028l5q82yhj72224m8j.wpengine.netdna-cdn.com/wp-content/uploads/2016/03/GdcVdrLottes.pdf
    const vec3 a      = vec3(1.3);
    const vec3 d      = vec3(0.95);
    const vec3 hdrMax = vec3(8.0);
    const vec3 midIn  = vec3(0.25);
    const vec3 midOut = vec3(0.25);

    const vec3 a_d = a * d;
    const vec3 hdrMaxA = pow(hdrMax, a);
    const vec3 hdrMaxAD = pow(hdrMax, a_d);
    const vec3 midInA = pow(midIn, a);
    const vec3 midInAD = pow(midIn, a_d);
    const vec3 HM1 = hdrMaxA * midOut;
    const vec3 HM2 = hdrMaxAD - midInAD;

    const vec3 b = (-midInA + HM1) / (HM2 * midOut);
    const vec3 c = (hdrMaxAD * midInA - HM1 * midInAD) / (HM2 * midOut);

    color = pow(color, a) / (pow(color, a_d) * b + c);

    doColorAdjustments(color);

    linearToRGB(color);
    return color;
}

// From https://github.com/godotengine/godot/blob/master/servers/rendering/renderer_rd/shaders/effects/tonemap.glsl
// Adapted from https://github.com/TheRealMJP/BakingLab/blob/master/BakingLab/ACES.hlsl
// (MIT License).
vec3 ACESTonemap(vec3 color) {
    float white = ACES_WHITE;
    const float exposure_bias = ACES_EXPOSURE;
    const float A = 0.0245786f;
    const float B = 0.000090537f;
    const float C = 0.983729f;
    const float D = 0.432951f;
    const float E = 0.238081f;

    const mat3 rgb_to_rrt = mat3(
            vec3(0.59719f * exposure_bias, 0.35458f * exposure_bias, 0.04823f * exposure_bias),
            vec3(0.07600f * exposure_bias, 0.90834f * exposure_bias, 0.01566f * exposure_bias),
            vec3(0.02840f * exposure_bias, 0.13383f * exposure_bias, 0.83777f * exposure_bias));

    const mat3 odt_to_rgb = mat3(
            vec3(1.60475f, -0.53108f, -0.07367f),
            vec3(-0.10208f, 1.10813f, -0.00605f),
            vec3(-0.00327f, -0.07276f, 1.07602f));
    color *= rgb_to_rrt;
    vec3 color_tonemapped = (color * (color + A) - B) / (color * (C * color + D) + E);
    color_tonemapped *= odt_to_rgb;

    white *= exposure_bias;
    float white_tonemapped = (white * (white + A) - B) / (white * (C * white + D) + E);

    color = color_tonemapped / white_tonemapped;
    color = clamp(color, vec3(0.0), vec3(1.0));
    doColorAdjustments(color);
    linearToRGB(color);
    return color;
}

vec3 ACESRedModified(vec3 color) {
    float white = ACES_WHITE;
    const float exposure_bias = ACES_EXPOSURE;
    const float A = 0.0245786f;
    const float B = 0.000090537f;
    const float C = 0.983729f;
    const float D = 0.432951f;
    const float E = 0.238081f;

    const mat3 rgb_to_rrt = mat3(
            vec3(0.50719f * exposure_bias, 0.40458f * exposure_bias, 0.03823f * exposure_bias),
            vec3(0.01300f * exposure_bias, 0.90834f * exposure_bias, 0.00966f * exposure_bias),
            vec3(0.00200f * exposure_bias, 0.15383f * exposure_bias, 0.83777f * exposure_bias));

    const mat3 odt_to_rgb = mat3(
            vec3(1.60475f, -0.53108f, -0.07367f),
            vec3(-0.10208f, 1.10813f, -0.00605f),
            vec3(-0.00327f, -0.07276f, 1.07602f));
    color *= rgb_to_rrt;
    vec3 color_tonemapped = (color * (color + A) - B) / (color * (C * color + D) + E);
    color_tonemapped *= odt_to_rgb;

    white *= exposure_bias;
    float white_tonemapped = (white * (white + A) - B) / (white * (C * white + D) + E);

    color = color_tonemapped / white_tonemapped;
    color = clamp(color, vec3(0.0), vec3(1.0));
    doColorAdjustments(color);
    linearToRGB(color);
    return color;
}

// Filmic tonemapping operator made by Jim Hejl and Richard Burgess
// Modified by Tech to not lose color information below 0.004
vec3 BurgessTonemap(vec3 rgb) {
       rgb = rgb * min(vec3(1.0), 1.0 - 0.8 * exp(1.0/-0.004 * rgb));
    rgb = (rgb * (6.2 * rgb + 0.5)) / (rgb * (6.2 * rgb + 1.7) + 0.06);
    doColorAdjustments(rgb);
    return rgb;
}

// Hable 2010, "Filmic Tonemapping Operators"
vec3 Uncharted2(vec3 x) {
    x *= 16.0;
    const float A = 0.15;
    const float B = 0.50;
    const float C = 0.10;
    const float D = 0.20;
    const float E = 0.02;
    const float F = 0.30;
    
    return ((x*(A*x+C*B)+D*E)/(x*(A*x+B)+D*F))-E/F;
}

// Filmic tonemapping operator made by John Hable for Uncharted 2
vec3 uncharted2_tonemap_partial(vec3 color) {
    const float a = 0.15;
    const float b = 0.50;
    const float c = 0.10;
    const float d = 0.20;
    const float e = 0.02;
    const float f = 0.30;
    color = ((color * (a * color + (c * b)) + (d * e)) / (color * (a * color + b) + d * f)) - e / f;
    doColorAdjustments(color);
    linearToRGB(color);
    return color;
}

vec3 uncharted2_filmic(vec3 v) {
    float exposure_bias = 1.0f;
    vec3 curr = uncharted2_tonemap_partial(v * exposure_bias);

    vec3 W = vec3(11.2f);
    vec3 white_scale = vec3(1.0f) / uncharted2_tonemap_partial(W);
    v = curr * white_scale;
    doColorAdjustments(v);
    linearToRGB(v);
    return v;
}

vec3 reinhard2(vec3 x) {
    const float L_white = 4.0;
    linearToRGB(x);
      x = (x * (1.1 + x / (L_white * L_white))) / (1.0 + x);
    doColorAdjustments(x);
    return x;
}

vec3 filmic(vec3 x) {
    linearToRGB(x);
    vec3 X = max(vec3(0.0), x - 0.004);
    vec3 result = (X * (6.2 * X + 0.5)) / (X * (6.2 * X + 1.7) + 0.06);
    x = pow(result, vec3(2.2));
    doColorAdjustments(x);
    return x;
}

float GTTonemap(float x) { // source https://gist.github.com/shakesoda/1dcb3e159f586995ca076c8b21f05a67
    float m = 0.22; // linear section start
    float a = 1.0;  // contrast
    float c = 1.33; // black brightness
    float P = 1.0;  // maximum brightness
    float l = 0.4;  // linear section length
    float l0 = ((P-m)*l) / a; // 0.312
    float S0 = m + l0; // 0.532
    float S1 = m + a * l0; // 0.532
    float C2 = (a*P) / (P - S1); // 2.13675213675
    float L = m + a * (x - m);
    float T = m * pow(x/m, c);
    float S = P - (P - S1) * exp(-C2*(x - S0)/P);
    float w0 = 1 - smoothstep(0.0, m, x);
    float w2 = (x < m+l)?0:1;
    float w1 = 1 - w0 - w2;
    return float(T * w0 + L * w1 + S * w2);
}

// this costs about 0.2-0.3ms more than aces, as-is
vec3 GTTonemap(vec3 x) {
    linearToRGB(x);
    x = vec3(GTTonemap(x.r), GTTonemap(x.g), GTTonemap(x.b));
    doColorAdjustments(x);
    return x;
}

vec3 uchimura(vec3 x, float P, float a, float m, float l, float c, float b) { //Uchimura, H. (2017). HDR Theory and practice. https://www.slideshare.net/nikuque/hdr-theory-and-practicce-jp; https://github.com/dmnsgn/glsl-tone-map/blob/main/uchimura.glsl
    float l0 = ((P - m) * l) / a;
    float L0 = m - m / a;
    float L1 = m + (1.0 - m) / a;
    float S0 = m + l0;
    float S1 = m + a * l0;
    float C2 = (a * P) / (P - S1);
    float CP = -C2 / P;

    vec3 w0 = vec3(1.0 - smoothstep(0.0, m, x));
    vec3 w2 = vec3(step(m + l0, x));
    vec3 w1 = vec3(1.0 - w0 - w2);

    vec3 T = vec3(m * pow(x / m, vec3(c)) + b);
    vec3 S = vec3(P - (P - S1) * exp(CP * (x - S0)));
    vec3 L = vec3(m + a * (x - m));

    return T * w0 + L * w1 + S * w2;
}

vec3 uchimura(vec3 color) {
    const float P = 1.0;  // max display brightness
    const float a = 1.0;  // contrast
    const float m = 0.22; // linear section start
    const float l = 0.4;  // linear section length
    const float c = 1.33; // black
    const float b = 0.0;  // pedestal
    linearToRGB(color);
    color = uchimura(color, P, a, m, l, c, b);
    doColorAdjustments(color);
    return color;
}

vec3 agxDefaultContrastApprox(vec3 x) {
  vec3 x2 = x * x;
  vec3 x4 = x2 * x2;
  
  return x*(+0.12410293f
    +x*(+0.2078625f
    +x*(-5.9293431f
    +x*(+30.376821f
    +x*(-38.901506f
    +x*(+15.122061f))))));
}

vec3 agx(vec3 val) {
    const mat3 agx_mat = mat3(
        0.842479062253094, 0.0423282422610123, 0.0423756549057051,
        0.0784335999999992,  0.878468636469772,  0.0784336,
        0.0792237451477643, 0.0791661274605434, 0.879142973793104);
    const float minEv = -12.47393f;
    const float maxEv = 4.026069f;

    // Input transform
    val = agx_mat * val;
    
    // Log2 space encoding
    val = clamp(log2(val), minEv, maxEv);
    val = (val - minEv) / (maxEv - minEv);
    
    // Apply sigmoid function approximation
    val = agxDefaultContrastApprox(val);

    return val;
}

vec3 inv_agx(vec3 val) {
    const mat3 inv_agx_mat = mat3(
        1.1968790051201738155, -0.052896851757456180321, -0.052971635514443794537,
        -0.098020881140136776078,  1.1519031299041727435,  -0.098043450117124120312,
        -0.099029744079720471434, -0.098961176844843346553, 1.1510736726411610622);

    // Input transform
    val = inv_agx_mat * val;

    return val;
}

vec3 agxLook(vec3 val) {
    const vec3 lw = vec3(0.2126, 0.7152, 0.0722);
    float luma = dot(val, lw);

    vec3 offset = vec3(0.0);

    #if AGX_LOOK == 0
        // Default
        const vec3 slope = vec3(1.0);
        const vec3 power = vec3(1.0);
        const float sat = 1.0;
    #elif AGX_LOOK == 1
        // Golden
        const vec3 slope = vec3(1.0, 0.9, 0.5);
        const vec3 power = vec3(0.8);
        const float sat = 0.8;
    #elif AGX_LOOK == 2
        // Punchy
        const vec3 slope = vec3(1.0);
        const vec3 power = vec3(1.35, 1.35, 1.35);
        const float sat = 1.4;
    #else
        const vec3 slope = vec3(AGX_R, AGX_G, AGX_B) / 256;
        const vec3 power = vec3(AGX_POWER);
        const float sat = AGX_SATURATION;
    #endif

    // ASC CDL
    val = pow(val * slope + offset, power);
    return luma + sat * (val - luma);
}

vec3 agxTonemap(vec3 color) { // Minimal version of Troy Sobotka's AgX by bwrensch https://www.shadertoy.com/view/mdcSDH
    color = agx(color);
    color = agxLook(color);
    color = inv_agx(color);
    doColorAdjustments(color);
    return color;
}

vec3 unreal(vec3 x) { // source: https://mini.gmshaders.com/p/tonemaps
    // Unreal 3, Documentation: "Color Grading"
    // Adapted to be close to Tonemap_ACES, with similar range
    // Gamma 2.2 correction is baked in, don't use with sRGB conversion!
    return x / (x + 0.155) * 1.019;
}
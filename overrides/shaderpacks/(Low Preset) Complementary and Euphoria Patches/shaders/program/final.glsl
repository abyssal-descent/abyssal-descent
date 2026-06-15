//////////////////////////////////////////
// Complementary Shaders by EminGT      //
// With Euphoria Patches by SpacEagle17 //
//////////////////////////////////////////

//Common//
#include "/lib/common.glsl"
#include "/lib/shaderSettings/final.glsl"
#include "/lib/shaderSettings/activateSettings.glsl"
#include "/lib/shaderSettings/longExposure.glsl"


//////////Fragment Shader//////////Fragment Shader//////////Fragment Shader//////////
#ifdef FRAGMENT_SHADER

noperspective in vec2 texCoord;

//Pipeline Constants//
#include "/lib/pipelineSettings.glsl"

//Common Variables//
vec2 view = vec2(viewWidth, viewHeight);

#if WORLD_SPACE_REFLECTIONS_INTERNAL > 0 && WORLD_SPACE_PLAYER_REF == 1
    #include "/lib/voxelization/SSBOs/clearSSBOs.glsl"
#endif

//Common Functions//
#if IMAGE_SHARPENING > 0
    vec2 viewD = 1.0 / vec2(viewWidth, viewHeight);

    vec2 sharpenOffsets[4] = vec2[4](
        vec2( viewD.x,  0.0),
        vec2( 0.0,  viewD.x),
        vec2(-viewD.x,  0.0),
        vec2( 0.0, -viewD.x)
    );

    void SharpenImage(inout vec3 color, vec2 texCoordM) {
        #ifdef TAA
            float sharpenMult = IMAGE_SHARPENING;
        #else
            float sharpenMult = IMAGE_SHARPENING * 0.5;
        #endif
        float mult = 0.0125 * sharpenMult;
        color *= 1.0 + 0.05 * sharpenMult;

        for (int i = 0; i < 4; i++) {
            color -= texture2D(colortex3, texCoordM + sharpenOffsets[i]).rgb * mult;
        }
    }
#endif

float retroNoise (vec2 noise) {
    return fract(sin(dot(noise.xy,vec2(10.998,98.233)))*12433.14159265359);
}

vec2 curveDisplay(vec2 texCoord, float curvatureAmount, int screenRoundness) {
    texCoord = texCoord * 2.0 - 1.0;
    vec2 offset = abs(texCoord.yx) * curvatureAmount * 0.5;

    if (screenRoundness == 1) {
        offset *= offset;
    } else if (screenRoundness == 2) {
        offset *= pow2(offset);
    } else if (screenRoundness == 3) {
        offset *= pow3(offset);
    }
    texCoord += texCoord * offset;
    return texCoord * 0.5 + 0.5;
}

vec2 border(vec2 texCoord) {
    const float borderAmount = 2.0 + BORDER_AMOUNT * 0.1;
    texCoord = texCoord * borderAmount - borderAmount * 0.5;
    return texCoord * 0.5 + 0.5;
}

vec3 scanline(vec2 texCoord, vec3 color, float frequency, float intensity, float speed, float amount, vec3 scanlineRGB, bool monochrome, bool flipDirection) {
    if (flipDirection) {
        texCoord = texCoord.yx;
    }

    float count = viewHeight * amount;
    vec2 scanlineColor = vec2(
        sin(mod(texCoord.y + frameTimeCounter * 0.2 * speed, frequency) * count),
        cos(mod(texCoord.y + frameTimeCounter * 0.5 * speed, 0.7 * frequency) * count)
    );

    vec3 scanlines;
    if (monochrome) {
        scanlines = vec3(scanlineColor.y + scanlineColor.x * 0.2);
    } else {
        scanlines = vec3(scanlineColor.x * scanlineRGB.r, scanlineColor.y * scanlineRGB.g, scanlineColor.x * scanlineRGB.b);
    }

    return color += color * scanlines * intensity * 0.1;
}

float halftones(vec2 texCoord, float angle, float scale) { // Thanks to https://www.shadertoy.com/view/4sBBDK by starea
    vec2 coord = texCoord * viewSize;
    vec2 dots = rotate(angle) * coord * scale;
    return sin(dots.x) * sin(dots.y) * 4.0;
}

float noiseSpeedLines(float a, float p, float s) {
    float p1 = hash11Modified(mod(floor(a), p), s);
    float p2 = hash11Modified(mod(floor(a) + 2.0, p), s);
    return smoothstep(0.0, 0.1, mix(p1, p2, smoothstep(0.0, 1.0, fract(a))) - 0.3);
}

float layeredNoiseSpeedLines(float a, float s) {
    return noiseSpeedLines(a, 20.0, s) + noiseSpeedLines(a * 5.0, 20.0 * 5.0, s);
}

float speedLines(vec2 uv, float speed) { // Thanks to https://www.shadertoy.com/view/NldyDn by HalbFettKaese - modified a bit
    uv = uv * 2.0 - 1.0;
    float a = atan(uv.x, uv.y) / pi;
    float value = layeredNoiseSpeedLines((a * 17) * (1.9 - SPEED_LINE_THICKNESS) * 1.5, (floor(frameTimeCounter * 10.0 * SPEED_LINES_SPEED) / 10.0) * 2.0);
    value -= 1.0 / length(uv) * 0.9;
    return clamp(value, 0.0, 0.1 * speed);
}

float randomNoiseOverlay1(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float grid(float uv) {
    if (hideGUI == 1) return 0.0;
    float mainLine = smoothstep(0.9995 * (1.0 - MAIN_GRID_INTERVAL * 0.00005), 1.0, cos(uv * tau / (1.0 / MAIN_GRID_INTERVAL))) * 0.3;
    float subLine = smoothstep(0.9998 * (1.0 - SUB_GRID_INTERVAL * 0.00075), 1.0, cos(uv * tau * SUB_GRID_INTERVAL / (1.0 / MAIN_GRID_INTERVAL))) * 0.1;
    return mainLine + subLine;
}

float GetLinearDepth(float depth) {
    return (2.0 * near) / (far + near - depth * (far - near));
}

// Function to apply horizontal noise
vec2 applyHorizontalNoise(vec2 texCoordM, float resolution, float intensity, float speed) {
    float horizontalNoiseResolution = resolution * 100.0;
    float horizontalNoiseIntensity = intensity * 0.002;
    float horizontalNoiseSpeed = speed * 0.0001;

    texCoordM.y *= horizontalNoiseResolution;
    texCoordM.y = float(int(texCoordM.y)) * (1.0 / horizontalNoiseResolution);
    float noise = retroNoise(vec2(frameTimeCounter * horizontalNoiseSpeed, texCoordM.y));
    texCoordM.x += noise * horizontalNoiseIntensity;
    return texCoordM;
}

// Function to apply vertical screen displacement
void applyVerticalScreenDisplacement(inout vec2 texCoordM, inout float verticalOffset, float verticalScrollSpeed, float verticalStutterSpeed, float verticalEdgeGlitch, bool isVertical) {
    float displaceEffectOn = 1.0;
    float scrollSpeed = verticalScrollSpeed * 2.0;
    float stutterSpeed = verticalStutterSpeed * 0.2;
    float scroll = (1.0 - step(retroNoise(vec2(frameTimeCounter * 0.00002, 8.0)), 0.9 * (1.0 - VERTICAL_SCROLL_FREQUENCY * 0.3))) * scrollSpeed;
    float stutter = (1.0 - step(retroNoise(vec2(frameTimeCounter * 0.00005, 9.0)), 0.8 * (1.0 - VERTICAL_STUTTER_FREQUENCY * 0.3))) * stutterSpeed;
    float stutter2 = (1.0 - step(retroNoise(vec2(frameTimeCounter * 0.00003, 5.0)), 0.7 * (1.0 - VERTICAL_STUTTER_FREQUENCY * 0.3))) * stutterSpeed;
    verticalOffset = sin(frameTimeCounter) * scroll + stutter * stutter2;
    if(isVertical) texCoordM.y = mix(texCoordM.y, mod(texCoordM.y + verticalOffset, verticalEdgeGlitch), displaceEffectOn);
    else texCoordM.x = mix(texCoordM.x, mod(texCoordM.x + verticalOffset, verticalEdgeGlitch), displaceEffectOn);
}

#if defined IS_IRIS || defined IS_ANGELICA && ANGELICA_VERSION >= 20000009
vec4 waterMarkFunction(ivec2 pixelSize, vec2 textCoord, vec2 screenUV, float watermarkSizeMult, bool hideWatermark){
    float watermarkAspectRatio = float(pixelSize.x) / pixelSize.y;
    float watermarkSize = 1 / watermarkSizeMult;

    if (aspectRatio < 3) textCoord += vec2(3 * screenUV.x * watermarkSize * 1.5 - 3 * watermarkSize * 1.5, 1.0 - 3 * watermarkAspectRatio * screenUV.y * watermarkSize * 1.5 / aspectRatio);
    else                 textCoord += vec2(screenUV.x * aspectRatio - aspectRatio, 1.0 - watermarkAspectRatio * screenUV.y);

    // Only sample texture if we're in the valid range
    if (textCoord.x > -1 && textCoord.x < 0 && textCoord.y > 0 && textCoord.y < 1) {
        vec2 texCoordMapped = fract(textCoord);
        ivec2 fetchCoord = ivec2(texCoordMapped * pixelSize);
        vec4 EuphoriaPatchesText = texelFetch(epWatermark, fetchCoord, 0);

        float guiIsNotHidden = 1.0;
        if (hideWatermark) {
            #if WATERMARK == 2
                if (hideGUI == 0) guiIsNotHidden = 0.0;
            #elif WATERMARK == 3
                if (hideGUI == 0 || heldItemId != 40000 && heldItemId2 != 40000) guiIsNotHidden = 0.0;
            #endif
        }
        return vec4(EuphoriaPatchesText.rgb, EuphoriaPatchesText.a * guiIsNotHidden);
    }
    return vec4(0.0); // Transparent
}
#endif

vec3 staticColor(vec3 color, float staticIntensity, float minStaticStrength, float maxStaticStrength, float staticSpeed) { // credit to arananderson https://www.shadertoy.com/view/tsX3RN
    float maxStrength = max(minStaticStrength, maxStaticStrength);
    float minStrength = min(minStaticStrength, maxStaticStrength);
    float speed = staticSpeed * 10.0;

    vec2 fractCoord = fract(texCoord * fract(sin(frameTimeCounter * speed + 1.0)));

    maxStrength = clamp(sin(frameTimeCounter * 0.5), minStrength, maxStrength);

    vec3 staticColor = vec3(retroNoise(fractCoord)) * maxStrength;
    return mix(vec3(1.0), color - staticColor, staticIntensity);
}

float getUnderwaterDistortion(vec2 uv, float intensity) {
    return WATER_REFRACTION_INTENSITY * intensity * sin((uv.x + uv.y) * 25.0 + frameTimeCounter * UNDERWATER_DISTORTION_STRENGTH);
}

vec2 getNetherHeatDistortion(vec2 uv, float z0, float lightmap) {
    float heatAmount = max(0.0, eyeBrightnessSmooth.x / 240.0 - 0.2) * 1.25;
    float verticalFalloff = 1.0 - pow3(uv.y); // More intensity at bottom of screen (heat rising effect)

    float depthFactor = clamp01((z0 - 0.06) * 4.0); // Adjusted depth to only be 0 close to the player
    float distanceAdjustedLightmap = pow3(lightmap) * 0.23 * (0.3 + min(depthFactor, 0.7)); // Boost distant lights, reduce close ones

    // Blend frequencies based on distance - near:far
    float freqY1 = mix(25.0, 14.0, depthFactor);
    float freqY2 = mix(18.0, 27.0, depthFactor);
    float freqX1 = mix(22.0, 14.8, depthFactor);
    float freqX2 = mix(15.0, 21.7, depthFactor);

    vec2 heatDistort = vec2(
        sin((uv.y * NETHER_HEAT_DISTORTION_SCALE * freqY1) + frameTimeCounter * NETHER_HEAT_DISTORTION_SPEED * 1.3) * 0.7 +
        sin((uv.y * NETHER_HEAT_DISTORTION_SCALE * freqY2) + frameTimeCounter * NETHER_HEAT_DISTORTION_SPEED * 0.9) * 0.2,

        sin((uv.x * NETHER_HEAT_DISTORTION_SCALE * freqX1) + frameTimeCounter * NETHER_HEAT_DISTORTION_SPEED * 1.5) * 0.7 +
        sin((uv.x * NETHER_HEAT_DISTORTION_SCALE * freqX2) + frameTimeCounter * NETHER_HEAT_DISTORTION_SPEED * 1.1) * 0.3
    );

    float playerSpeed = smoothstep(0.0, 0.75, 1.0 - clamp01(length(cameraPosition - previousCameraPosition) / sqrt3(frameTime)));

    float distortionMask = max(heatAmount * pow2(verticalFalloff), distanceAdjustedLightmap) * playerSpeed;

    return heatDistort * 0.00012 * NETHER_HEAT_DISTORTION * distortionMask;
}

#include "/lib/textRendering/textRenderer.glsl"

void beginTextM(int textSize, vec2 offset) {
    float scale = 860;
    beginText(ivec2(vec2(scale * viewWidth / viewHeight, scale) * texCoord) / textSize, ivec2(0 + offset.x, scale / textSize - offset.y));
    text.bgCol = vec4(0.0);
}
#ifdef EUPHORIA_PATCHES_POTATO_REMOVED
    #include "/lib/misc/potato.glsl"
#endif

#ifdef ENTITIES_ARE_LIGHT
    #include "/lib/misc/worldOutline.glsl"
#endif

#include "/lib/misc/pixelCraft.glsl"
#include "/lib/misc/endCreditsBackground.glsl"

//Program//
void main() {
    vec3 color = vec3(0.0);
    float viewWidthM = viewWidth;
    float viewHeightM = viewHeight;
    #if PIXELATED_SCREEN_SIZE > 0 || defined SCREEN_DITHERING_INTERNAL
        vec2 cellSize = getCellSize();
    #endif

    #if BORDER_AMOUNT != 0
        vec2 texCoordM = border(texCoord);
    #else
        vec2 texCoordM = texCoord;
    #endif

    #ifdef CURVE_DISPLAY
        texCoordM = curveDisplay(texCoordM, CURVATURE_AMOUNT, SCREEN_ROUNDNESS);
    #endif

    vec2 texCoordBorder = texCoordM;

    #if HORIZONTAL_NOISE > 0 && defined RETRO_ON
        texCoordM = applyHorizontalNoise(texCoordM, HORIZONTAL_NOISE, HORIZONTAL_NOISE_INTENSITY, HORIZONTAL_NOISE_SPEED);
    #endif

    #if defined VERTICAL_SCREEN_DISPLACEMENT && defined RETRO_ON
        float verticalOffset = 0.0;
        applyVerticalScreenDisplacement(texCoordM, verticalOffset, VERTICAL_SCROLL_SPEED, VERTICAL_STUTTER_SPEED, VERTICAL_EDGE_GLITCH, true);
    #endif

    #if WATERMARK > 0 && (defined IS_IRIS || defined IS_ANGELICA && ANGELICA_VERSION >= 20000009)
        vec4 watermarkColor = waterMarkFunction(ivec2(100, 29), vec2(0.05), texCoordM.xy, WATERMARK_SIZE, true);
    #endif

    #if CAMERA_NOISE_OVERLAY == 1
        texCoordM += vec2(randomNoiseOverlay1(texCoordM + vec2(0.0, 0.0)), randomNoiseOverlay1(texCoordM + vec2(1.0, 1.0))) * 0.01 * CAMERA_NOISE_OVERLAY_INTENSITY;
    #endif

    #if defined UNDERWATER_DISTORTION && PIXELATED_SCREEN_SIZE == 0
        if (isEyeInWater == 1)
            texCoordM += getUnderwaterDistortion(texCoord, 0.00035);
    #endif

    #if LETTERBOXING > 0 && defined EXCLUDE_ENTITIES || defined BAD_APPLE || DELTARUNE_BATTLE_BACKGROUND == 2 || defined ENTITIES_ARE_LIGHT || NETHER_HEAT_DISTORTION > 0 && defined NETHER
        vec4 texture6 = texelFetch(colortex6, texelCoord, 0);
        #if defined ENTITIES_ARE_LIGHT || NETHER_HEAT_DISTORTION > 0 && defined NETHER
            float z0 = GetLinearDepth(texelFetch(depthtex0, texelCoord, 0).r);
        #endif
    #endif

    #if NETHER_HEAT_DISTORTION > 0 && defined NETHER && PIXELATED_SCREEN_SIZE == 0
        texCoordM += getNetherHeatDistortion(texCoordM, z0, texture6.a);
    #endif

    #if PIXELATED_SCREEN_SIZE > 0
        #define textureFinal(tex) createPixelation(tex, texCoordM, PIXELATED_SCREEN_SMOOTHNESS, cellSize);
    #else
        #define textureFinal(tex) texture2D(tex, texCoordM).rgb
    #endif

    #if LONG_EXPOSURE > 0
        if (hideGUI == 0 || isViewMoving()) {
            color = textureFinal(colortex3);
        } else {
            color = textureFinal(colortex2);
        }
    #else
        color = textureFinal(colortex3);
    #endif

    #ifdef SCREEN_DITHERING_INTERNAL
        color = ditherColor(color, texCoordM, cellSize);
    #endif
    #ifdef PALETTE_SWAP
        color = convertToPaletteColor(color);
    #endif

    #if CHROMA_ABERRATION > 0
        #if PIXELATED_SCREEN_SIZE > 0
            float scale = cellSize.x * viewWidth * 0.25;
            vec2 aberration = (texCoordM - 0.5) * (2.0 / vec2(viewWidth, viewHeight)) * scale * CHROMA_ABERRATION;
            #if LONG_EXPOSURE > 0
                if (hideGUI == 0 || isViewMoving()) {
                    color.rb = vec2(createPixelation(colortex3, texCoordM + aberration, PIXELATED_SCREEN_SMOOTHNESS, cellSize).r,
                                    createPixelation(colortex3, texCoordM - aberration, PIXELATED_SCREEN_SMOOTHNESS, cellSize).b);
                } else {
                    color.rb = vec2(createPixelation(colortex2, texCoordM + aberration, PIXELATED_SCREEN_SMOOTHNESS, cellSize).r,
                                    createPixelation(colortex2, texCoordM - aberration, PIXELATED_SCREEN_SMOOTHNESS, cellSize).b);
                }
            #else
                color.rb = vec2(createPixelation(colortex3, texCoordM + aberration, PIXELATED_SCREEN_SMOOTHNESS, cellSize).r,
                                createPixelation(colortex3, texCoordM - aberration, PIXELATED_SCREEN_SMOOTHNESS, cellSize).b);
            #endif
        #else
            vec2 scale = vec2(1.0, viewHeight / viewWidth);
            float aberrationStrength = CHROMA_ABERRATION;
            vec2 aberration = (texCoordM - 0.5) * (2.0 / vec2(viewWidth, viewHeight)) * scale * aberrationStrength;
            #if LONG_EXPOSURE > 0
                if (hideGUI == 0 || isViewMoving()) {
                    color.rb = vec2(texture2D(colortex3, texCoordM + aberration).r, texture2D(colortex3, texCoordM - aberration).b);
                } else {
                    color.rb = vec2(texture2D(colortex2, texCoordM + aberration).r, texture2D(colortex2, texCoordM - aberration).b);
                }
            #else
                color.rb = vec2(texture2D(colortex3, texCoordM + aberration).r, texture2D(colortex3, texCoordM - aberration).b);
            #endif
        #endif
    #endif

    #if IMAGE_SHARPENING > 0 && PIXELATED_SCREEN_SIZE == 0
        #if LONG_EXPOSURE > 0
        if(hideGUI == 0 || isViewMoving()){ // GUI visible OR moving
        #endif
            SharpenImage(color, texCoordM);
        #if LONG_EXPOSURE > 0
        }
        #endif
    #endif

    #if LETTERBOXING > 0
        #if BORDER_AMOUNT > 0
            viewWidthM = viewWidth - viewWidth * BORDER_AMOUNT * 0.04;
        #endif
        float letterboxMargin = 0.5 - viewWidthM / (2 * viewHeightM * ASPECT_RATIO);
        #if LETTERBOXING == 2
            letterboxMargin = mix(0.0, letterboxMargin, isSneaking);
        #endif

        if (texCoord.y > 1.0 - letterboxMargin || texCoord.y < letterboxMargin) {
            #ifdef EXCLUDE_ENTITIES
                if (int(texture6.g * 255.1) != 254) color *= 0.0;
            #else
                color *= mix(0.0, 1.0, LETTERBOXING_TRANSPARENCY);
            #endif
        }
    #endif

    #ifdef BAD_APPLE
        color = vec3((int(texture6.g * 255.1) != 254) ? 0.0 : 1.0);
    #endif

    #if DELTARUNE_BATTLE_BACKGROUND > 0
            vec3 deltaruneColor = movingCheckerboard(texCoord, 100.0, 1.0, vec2(0.05, -0.05), vec3(1.0, 0.0, 1.0));
            deltaruneColor += movingCheckerboard(texCoord, 100.0, 1.0, vec2(-0.025, 0.025), vec3(1.0, 0.0, 1.0) * 0.5);
        #if DELTARUNE_BATTLE_BACKGROUND == 1
            if (texture2D(depthtex0, texCoord).r == 1.0) color = deltaruneColor;
        #elif DELTARUNE_BATTLE_BACKGROUND == 2
            if ((int(texture6.g * 255.1) != 254)) {
                color = deltaruneColor;
            }
        #endif
    #endif

    /*ivec2 boxOffsets[8] = ivec2[8](
        ivec2( 1, 0),
        ivec2( 0, 1),
        ivec2(-1, 0),
        ivec2( 0,-1),
        ivec2( 1, 1),
        ivec2( 1,-1),
        ivec2(-1, 1),
        ivec2(-1,-1)
    );

    for (int i = 0; i < 8; i++) {
        color = max(color, texelFetch(colortex3, texelCoord + boxOffsets[i], 0).rgb);
    }*/

    #ifdef ENTITIES_ARE_LIGHT
        vec4 texture10 = texture2D(colortex10, texCoordM);
        color = texture10.a * mix(vec3(1), texture10.rgb, texture6.a);
        DoWorldOutline(color, z0, vec3(1.0), 0.0, 1.0);
    #endif

    #if WATERMARK > 0 && (defined IS_IRIS || defined IS_ANGELICA && ANGELICA_VERSION >= 20000009)
        #if WATERMARK < 4
            color.rgb = mix(color.rgb, watermarkColor.rgb, watermarkColor.a);
        #elif WATERMARK == 4
            color.rgb = mix(color.rgb, vec3(GetLuminance(watermarkColor.rgb)), watermarkColor.a);
        #endif
    #endif

    #ifdef LET_THERE_BE_COLORS
        color = hash33(color * frameTimeCounter);
    #endif

    #if STATIC_NOISE > 0 && defined RETRO_ON
        float staticIntensity = 0.0;
        staticIntensity = STATIC_NOISE * 0.1;
        color *= staticColor(color, staticIntensity, MIN_STATIC_STRENGTH, MAX_STATIC_STRENGTH, STATIC_SPEED);
    #endif

    #if SCANLINE > 0 && defined RETRO_ON
        color = scanline(texCoord, color, SCANLINE_FREQUENCY, SCANLINE, SCANLINE_SPEED, SCANLINE_AMOUNT, vec3(SCANLINE_R, SCANLINE_G, SCANLINE_B), SCANLINE_NEW_MONOCHROME, SCANLINE_NEW_DIRECTION);
    #endif

    #ifdef HALFTONE
        #ifdef HALFTONE_MONOCHROME
            float colorOld = GetLuminance(color);
        #else
            vec3 colorOld = color;
        #endif
        const float dotAngle = HALFTONE_ANGLE * pi * 0.5;
        const float dotScale = HALFTONE_SCALE;
        const float dotBrightness = HALFTONE_BRIGHTNESS * 2.0;
        color = vec3(colorOld * dotBrightness * 5.0 - 5.0 + halftones(texCoordM, dotAngle, dotScale));
    #endif

    #if SPEED_LINES > 0
        #if SPEED_LINES != 3
            float speedIntensity = (length(cameraPosition - previousCameraPosition) / frameTime) * 0.08;
            float speedThreshold = 3.0;
            float speedFactor = smoothstep(speedThreshold * 0.45, speedThreshold, speedIntensity);
            float isSprintingM = 0.0;
            #if SPEED_LINES == 2
                isSprintingM = isSprinting;
            #endif
            speedIntensity = max(speedFactor, isSprintingM);
        #else
            float speedIntensity = 1.0;
        #endif
        float speedLines = speedLines(texCoordM, speedIntensity);
        speedLines = mix(0.0, speedLines, SPEED_LINES_TRANSPARENCY);
        color += vec3(speedLines);
    #endif

    #if MAIN_GRID_INTERVAL > 1
        float grid = max(grid(texCoordM.x), grid(texCoordM.y));
        #if GRID_CONDITION == 0
            color += grid;
        #elif GRID_CONDITION == 1
            color += mix(0.0, grid, isSneaking);
        #elif GRID_CONDITION == 2
            float isHoldingSpyglass = 0.0;
            if (heldItemId == 45014 || heldItemId2 == 45014) isHoldingSpyglass = 1.0; //holding spyglass
            color += mix(0.0, grid, isHoldingSpyglass);
        #endif
    #endif

    #if WORLD_SPACE_REFLECTIONS_INTERNAL > 0 && WORLD_SPACE_PLAYER_REF == 1
        clearSSBOs();
    #endif

    #ifdef VIGNETTE_R
        vec2 texCoordMin = texCoordM.xy - 0.5;
        float vignette = 1.0 - dot(texCoordMin, texCoordMin) * (1.0 - GetLuminance(color));
        color *= vignette;
    #endif

    float dither = texture2DLod(noisetex, texCoord * view / 128.0, 0.0).b;
    color += vec3((dither - 0.25) / 128.0);

    #if defined CURVE_DISPLAY || BORDER_AMOUNT != 0
        if (texCoordBorder.x < 0.0 || texCoordBorder.x > 1.0) color = vec3(0.0);
        if (texCoordBorder.y < 0.0 || texCoordBorder.y > 1.0) color = vec3(0.0);
    #endif

    #ifdef EUPHORIA_PATCHES_POTATO_REMOVED
        color.rgb = potatoError();
    #endif

    #include "/lib/textRendering/all_text_messages.glsl"
    // color.rgb = endCreditsEffect(texCoord);

    // Example of printing a float value (for debugging)
    // float placeholder = texelFetch(endcrystal_sampler, ivec2(35, 8), 0).r;
    // beginTextM(2, vec2(5));
    // text.bgCol = vec4(0.0, 0.0, 0.0, 0.8);
    // text.fpPrecision = 6;
    // printFloat(placeholder);
    // printLine();
    // endText(color.rgb);

    // color.rgb = texture2D(colortex13, texCoord).rgb;

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(color, 1.0);
}

#endif

//////////Vertex Shader//////////Vertex Shader//////////Vertex Shader//////////
#ifdef VERTEX_SHADER

noperspective out vec2 texCoord;

//Attributes//

//Common Variables//

//Common Functions//

//Includes//

//Program//
void main() {
    gl_Position = ftransform();
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif

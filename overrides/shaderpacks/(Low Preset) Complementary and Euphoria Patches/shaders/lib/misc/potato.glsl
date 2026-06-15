vec3 getPixelPotato(vec2 pixelCoord, vec3 color, vec2 size) { // Original Pixel art by Memokii
    if (pixelCoord.x < 0.0 || pixelCoord.x >= size.x ||
        pixelCoord.y < 0.0 || pixelCoord.y >= size.y) {
        return color;
    }

    int x = int(pixelCoord.x);
    int y = int(pixelCoord.y);

    if ((y == 0 || y == 8) && x >= 4 && x < 10) return hex2rgb(y == 0 ? 0x7C552Au : 0x652C14u);

    if (y == 1) {
        if (x >= 2 && x < 4 || x >= 10 && x < 12) return hex2rgb(0x7C552Au);
        if (x >= 4 && x < 7 || x == 9) return hex2rgb(0xD1A34Bu);
        return x >= 7 && x < 9 ? hex2rgb(0xD8B95Bu) : color;
    }
    if (y == 2) {
        return (x == 1) ? hex2rgb(0x7C552Au) :
            (x == 2 || x == 11) ? hex2rgb(0xD1A34Bu) :
            (x == 3 || x == 9) ? hex2rgb(0xE3D872u) :
            (x == 4) ? hex2rgb(0x9A7D45u) :
            (x >= 5 && x < 7 || x == 8) ? hex2rgb(0x353330u) :
            (x == 7) ? hex2rgb(0x292623u) :
            (x == 10) ? hex2rgb(0xD8B95Bu) :
            (x == 12) ? hex2rgb(0x703F1Eu) : color;
    }
    if (y == 3) {
        return (x == 0 || x == 13) ? hex2rgb(0x703F1Eu) :
            (x == 1 || x == 11) ? hex2rgb(0xD1A34Bu) :
            (x >= 2 && x < 4 || x == 6) ? hex2rgb(0xD8B95Bu) :
            (x == 4 || x >= 7 && x < 10) ? hex2rgb(0xE3D872u) :
            (x == 5) ? hex2rgb(0x353330u) :
            (x == 10) ? hex2rgb(0x916E3Cu) :
            (x == 12) ? hex2rgb(0xC58539u) : color;
    }
    if (y == 4) {
        return (x == 0) ? hex2rgb(0x703F1Eu) :
            (x >= 1 && x < 3 || x >= 10 && x < 13) ? hex2rgb(0xD1A34Bu) :
            (x >= 3 && x < 5 || x >= 7 && x < 10) ? hex2rgb(0xD8B95Bu) :
            (x >= 5 && x < 7) ? hex2rgb(0x292623u) :
            (x == 13) ? hex2rgb(0x652C14u) : color;
    }
    if (y == 5) {
        return (x == 0) ? hex2rgb(0x703F1Eu) :
            (x == 1) ? hex2rgb(0xC58539u) :
            (x >= 2 && x < 4 || x >= 9 && x < 12) ? hex2rgb(0xD1A34Bu) :
            (x == 4 || x >= 6 && x < 8) ? hex2rgb(0xD8B95Bu) :
            (x == 5) ? hex2rgb(0x1D1917u) :
            (x == 8) ? hex2rgb(0x916E3Cu) :
            (x == 12) ? hex2rgb(0x652C14u) : color;
    }
    if (y == 6) {
        return (x == 1) ? hex2rgb(0x703F1Eu) :
            (x == 2) ? hex2rgb(0x916E3Cu) :
            (x == 3 || x >= 10 && x < 12) ? hex2rgb(0xC58539u) :
            (x == 4 || x == 9) ? hex2rgb(0xD1A34Bu) :
            (x >= 5 && x < 7 || x >= 7 && x < 9) ? hex2rgb(0x1D1917u) :
            (x == 6) ? hex2rgb(0x292623u) :
            (x == 12) ? hex2rgb(0x652C14u) : color;
    }
    if (y == 7) {
        return (x == 2) ? hex2rgb(0x703F1Eu) :
            (x == 3 || x >= 10 && x < 12) ? hex2rgb(0x652C14u) :
            (x >= 4 && x < 6 || x == 8) ? hex2rgb(0xC58539u) :
            (x >= 6 && x < 8) ? hex2rgb(0xD1A34Bu) :
            (x == 9) ? hex2rgb(0x916E3Cu) : color;
    }
    return color;
}

uint randomLetter(float offset){
    uint letters[36] = uint[](
        _A, _B, _C, _D, _E, _F, _G, _H, _I, _J, _K, _L, _M, _N, _O, _P, _Q, _R, _S, _T, _U, _V, _W, _X, _Y, _Z,
        _0, _1, _2, _3, _4, _5, _6, _7, _8, _9
    );
    int randomIndex = int(hash11(frameTimeCounter * 0.1 + offset) * 36);
    return letters[randomIndex];
}

uint letterAnimation(float offset, float verticalOffset) {

    float animation = min(shaderStartSmooth * 0.3 - offset * 0.3, 0.1) * 10.0;
    if (animation < 0.95) {
        return randomLetter(offset);
    } else {
        float noise = texture2DLod(noisetex, vec2(frameTimeCounter * 0.002), 0.0).r;
        if (abs(verticalOffset) > 0.05 && noise > 0.6 || noise > 0.8) {
            if (offset == 0.0) return _G;
            else if (offset == 0.1) return _L;
            else if (offset == 0.2) return _a;
            else if (offset == 0.3) return _D;
            else if (offset == 0.4) return _O;
            else if (offset == 0.5) return _S;
        } else {
            if (offset == 0.0) return _P;
            else if (offset == 0.1) return _O;
            else if (offset == 0.2) return _T;
            else if (offset == 0.3) return _A;
            else if (offset == 0.4) return _T;
            else if (offset == 0.5) return _O;
        }
    }
    return _space;
}

vec3 printPhrase(vec3 color, int verticalTextOffset){
    beginTextM(10, vec2(6, 10 + verticalTextOffset));
    text.fgCol = vec4(1.0, 0.0, 0.0, 0.85);

    // For each letter position, check if it should be randomized
    printString((
        texture2DLod(noisetex, vec2(frameTimeCounter * 0.01 + 0.1), 0.0).r > 0.85 ? randomLetter(0.1) : _Y,
        texture2DLod(noisetex, vec2(frameTimeCounter * 0.01 + 0.2), 0.0).r > 0.85 ? randomLetter(0.2) : _o,
        texture2DLod(noisetex, vec2(frameTimeCounter * 0.01 + 0.3), 0.0).r > 0.85 ? randomLetter(0.3) : _u,
        texture2DLod(noisetex, vec2(frameTimeCounter * 0.01 + 0.4), 0.0).r > 0.85 ? randomLetter(0.4) : _r,
        _space,
        texture2DLod(noisetex, vec2(frameTimeCounter * 0.01 + 0.5), 0.0).r > 0.85 ? randomLetter(0.5) : _A,
        texture2DLod(noisetex, vec2(frameTimeCounter * 0.01 + 0.6), 0.0).r > 0.85 ? randomLetter(0.6) : _c,
        texture2DLod(noisetex, vec2(frameTimeCounter * 0.01 + 0.7), 0.0).r > 0.85 ? randomLetter(0.7) : _t,
        texture2DLod(noisetex, vec2(frameTimeCounter * 0.01 + 0.8), 0.0).r > 0.85 ? randomLetter(0.8) : _i,
        texture2DLod(noisetex, vec2(frameTimeCounter * 0.01 + 0.9), 0.0).r > 0.85 ? randomLetter(0.9) : _o,
        texture2DLod(noisetex, vec2(frameTimeCounter * 0.01 + 1.0), 0.0).r > 0.85 ? randomLetter(1.0) : _n,
        texture2DLod(noisetex, vec2(frameTimeCounter * 0.01 + 1.1), 0.0).r > 0.85 ? randomLetter(1.1) : _s,
        _space,
        texture2DLod(noisetex, vec2(frameTimeCounter * 0.01 + 1.2), 0.0).r > 0.85 ? randomLetter(1.2) : _h,
        texture2DLod(noisetex, vec2(frameTimeCounter * 0.01 + 1.3), 0.0).r > 0.85 ? randomLetter(1.3) : _a,
        texture2DLod(noisetex, vec2(frameTimeCounter * 0.01 + 1.4), 0.0).r > 0.85 ? randomLetter(1.4) : _v,
        texture2DLod(noisetex, vec2(frameTimeCounter * 0.01 + 1.5), 0.0).r > 0.85 ? randomLetter(1.5) : _e
    ));
    printLine();

    // Second line with similar randomization
    printString((
        texture2DLod(noisetex, vec2(frameTimeCounter * 0.01 + 1.6), 0.0).r > 0.85 ? randomLetter(1.6) : _C,
        texture2DLod(noisetex, vec2(frameTimeCounter * 0.01 + 1.7), 0.0).r > 0.85 ? randomLetter(1.7) : _o,
        texture2DLod(noisetex, vec2(frameTimeCounter * 0.01 + 1.8), 0.0).r > 0.85 ? randomLetter(1.8) : _n,
        texture2DLod(noisetex, vec2(frameTimeCounter * 0.01 + 1.9), 0.0).r > 0.85 ? randomLetter(1.9) : _s,
        texture2DLod(noisetex, vec2(frameTimeCounter * 0.01 + 2.0), 0.0).r > 0.85 ? randomLetter(2.0) : _e,
        texture2DLod(noisetex, vec2(frameTimeCounter * 0.01 + 2.1), 0.0).r > 0.85 ? randomLetter(2.1) : _q,
        texture2DLod(noisetex, vec2(frameTimeCounter * 0.01 + 2.2), 0.0).r > 0.85 ? randomLetter(2.2) : _u,
        texture2DLod(noisetex, vec2(frameTimeCounter * 0.01 + 2.3), 0.0).r > 0.85 ? randomLetter(2.3) : _e,
        texture2DLod(noisetex, vec2(frameTimeCounter * 0.01 + 2.4), 0.0).r > 0.85 ? randomLetter(2.4) : _n,
        texture2DLod(noisetex, vec2(frameTimeCounter * 0.01 + 2.5), 0.0).r > 0.85 ? randomLetter(2.5) : _c,
        texture2DLod(noisetex, vec2(frameTimeCounter * 0.01 + 2.6), 0.0).r > 0.85 ? randomLetter(2.6) : _e,
        texture2DLod(noisetex, vec2(frameTimeCounter * 0.01 + 2.7), 0.0).r > 0.85 ? randomLetter(2.7) : _s,
        _exclm
    ));
    endText(color);
    return color;
}

vec3 printNumbers(vec3 color, int verticalTextOffset) {
    beginTextM(5, vec2(12, 140 + verticalTextOffset * 2));
    text.fgCol = vec4(0.2157, 0.0, 1.0, 0.85);
    printFloat(frameTimeCounter);printLine();
    printFloat(worldDay + worldTime / 24000.0);printLine();
    printFloat(aspectRatio);
    printString((_space));
    float cameraRotateNumber = 0.0;
    mat3 currentModelView = mat3(gbufferModelView);
    for (int i = 0; i < 3; i++) {
        vec3 rotation = currentModelView[i];
        for (int j = 0; j < 3; j++) {
            cameraRotateNumber += rotation[j];
        }
    }
    printFloat(cameraRotateNumber);printLine();
    endText(color);
    return color;
}

vec4 getWatermarkColor(vec3 color, vec2 displacedCoord) {
    #if defined IS_IRIS || defined IS_ANGELICA && ANGELICA_VERSION >= 20000009
        return waterMarkFunction(ivec2(100, 29), vec2(0.1, 0.3), displacedCoord, 1.3, false);
    #else
        beginTextM(7, vec2(110  + displacedCoord.x, 105 + displacedCoord.y));
        text.fgCol = vec4(0.9137, 0.3059, 0.9137, 0.85);
        printString((_E, _u, _p, _h, _o, _r, _i, _a, _space, _P, _a, _t, _c, _h, _e, _s));
        endText(color);
        return vec4(color, 1.0);
    #endif
}

vec3 potatoWatermark(vec3 color, vec2 displacedCoord, vec2 flickerNoiseVec) {
    // Apply offset to watermark position
    vec4 watermarkColor = getWatermarkColor(color, displacedCoord);

    // Rest of the effect processing remains the same
    float flickerNoise = max(flickerNoiseVec.r, flickerNoiseVec.g);
    float flickerFactor = step(0.4, flickerNoise);

    float rareBlend = smoothstep(0.3, 0.6, texture2DLod(noisetex, vec2(frameTimeCounter * 0.09), 0.0).r);
    flickerFactor = mix(flickerFactor, rareBlend, 0.3);

    vec3 newWatermarkColors = saturateColors(watermarkColor.rgb, flickerFactor * 0.4 + flickerNoiseVec.r);

    float noise = texture2DLod(noisetex, displacedCoord.xy * 3.0 + vec2(frameTimeCounter * 0.1, sin(frameTimeCounter * 0.05) * 0.5), 0.0).r * 10.0;
    noise = smoothstep(0.3, 0.7, noise) * sin(frameTimeCounter * 3.0 + displacedCoord.x * 10.0);
    float invertAlpha = watermarkColor.a * noise;
    vec4 flickeringWatermarkColor = vec4(newWatermarkColors, invertAlpha);

    color.rgb = mix(color.rgb, flickeringWatermarkColor.rgb, flickeringWatermarkColor.a);
    return mix(color.rgb, newWatermarkColors, watermarkColor.a * flickerFactor);
}

vec3 rareShaderError(vec2 texCoordBorder) {
    vec3 color = vec3(0.2);
    vec2 displacedCoord = texCoordBorder;
    float verticalIndicator = 0.0;

    applyVerticalScreenDisplacement(displacedCoord, verticalIndicator, 1.0, 1.0, 1.0, false);

    // Convert the offset to screen space for text positioning
    int verticalTextOffset = int(displacedCoord.y * 8); // Adjust multiplier to match your text scale
    verticalTextOffset += int(displacedCoord.x * 10.0);

    beginTextM(15, vec2(8 + verticalTextOffset, 25)); text.fgCol = vec4(1.0, 0.0, 0.0, 0.85);
        printString((_S, _h, _a, _d, _e, _r, _space, _E, _R, _R, _O, _R));
    endText(color);
    return color;
}

vec3 potatoError(){
    vec3 color = vec3(0.6);

    // Calculate displacement value that we'll use for all elements
    vec2 texCoordBorder = curveDisplay(texCoord, 1.2, 3);
    vec2 displacedCoord = texCoordBorder;
    float verticalIndicator = 0.0;
    vec2 noiseVec = texture2DLod(noisetex, vec2(frameTimeCounter * 0.06), 0.0).rb;

    applyVerticalScreenDisplacement(displacedCoord, verticalIndicator, 1.0, 1.0, 1.0, true);
    float verticalOffset = displacedCoord.y - texCoordBorder.y;

    // Convert the offset to screen space for text positioning
    int verticalTextOffset = int(verticalOffset * 100.0); // Adjust multiplier to match your text scale

    // Apply offset to text position
    color = printPhrase(color, verticalTextOffset);

    beginTextM(20, vec2(3, 20 + verticalTextOffset * 0.5)); text.fgCol = vec4(1.0, 0.0, 0.0, 0.85);
        printString((letterAnimation(0.0, verticalIndicator), letterAnimation(0.1, verticalIndicator), letterAnimation(0.2, verticalIndicator),
        letterAnimation(0.3, verticalIndicator), letterAnimation(0.4, verticalIndicator), letterAnimation(0.5, verticalIndicator)));
    endText(color);

    color = printNumbers(color, verticalTextOffset);

    // Apply offset to potato position
    float pixelPotatoSize = 0.15;
    vec2 transformedCoords = (applyHorizontalNoise(displacedCoord, 1, noiseVec.r * 1.5 + 0.5, noiseVec.g + 0.3) - vec2(0.8, 0.6)) / pixelPotatoSize;
    vec2 potatoSize = vec2(14.0, 9.0);
    vec2 pixelCoords = (vec2(transformedCoords.x, transformedCoords.y * -1) + 1.0) * potatoSize * 0.5;
    color.rgb = getPixelPotato(floor(pixelCoords), color, potatoSize);

    color.rgb = potatoWatermark(color.rgb, displacedCoord + verticalTextOffset, noiseVec);

    if(mod(frameTimeCounter + 10, 42.0) < 8.0) color = rareShaderError(texCoordBorder); // Why 42? Because it's the answer to everything

    color *= staticColor(color, 1, 0.1, 0.6, 1.0);
    color = scanline(texCoordBorder, color, 0.66, 2, 1.5, 1.2, vec3(1.0), true, false);

    if (texCoordBorder.x < 0.0 || texCoordBorder.x > 1.0) color = vec3(0.0);
    if (texCoordBorder.y < 0.0 || texCoordBorder.y > 1.0) color = vec3(0.0);
    return color;
}

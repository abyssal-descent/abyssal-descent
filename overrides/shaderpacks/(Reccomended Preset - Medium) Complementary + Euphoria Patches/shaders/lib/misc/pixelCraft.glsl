vec3 posterizeColor(vec3 color) {
    return mix(color, hsv2rgb(vec3(rgb2hsv(color).x, floor(rgb2hsv(color).yz*COLOR_LEVELS)/(COLOR_LEVELS-1.0))), POSTERIZE_STRENGTH);
}

vec3 sampleCell(sampler2D tex, vec2 origin, vec2 size, int count) {
    vec2 cellCoord = floor(origin / size);
    vec3 sum = vec3(0.0);
    float fCount = float(count);
    #ifdef UNDERWATER_DISTORTION
        if (isEyeInWater == 1){
            origin += getUnderwaterDistortion(cellCoord, 0.0005);
        }
    #endif
    for (int i = 0; i < count * count; i++) {
        vec2 offset = vec2(mod(float(i), fCount) + 0.5, floor(float(i) / fCount) + 0.5) / fCount;
        sum += texture2D(tex, origin + size * offset).rgb;
    }
    return sum / (fCount * fCount);
}

vec2 getCellSize() {
    return vec2(float(int(ceil(256.0 / PIXELATED_SCREEN_SIZE_INTERNAL) + 1) & ~1)) / vec2(viewWidth, viewHeight);
}

vec3 createPixelation(sampler2D tex, vec2 uv, float sampleCount, vec2 cellSize) {
    vec2 cellOrigin = floor(uv / cellSize) * cellSize;
    sampleCount = max0(sampleCount) + 1.0;

    vec3 pixelated = mix(
        sampleCell(tex, cellOrigin, cellSize, int(sampleCount)),
        sampleCell(tex, cellOrigin, cellSize, int(sampleCount) + 1),
        fract(sampleCount)
    );

    return posterizeColor(pixelated);
}

// Precomputed threshold map for dithering
const mat4x4 DITHER_THRESHOLD = mat4x4(
    0., 8., 2., 10.,
    12., 4., 14., 6.,
    3., 11., 1., 9.,
    15., 7., 13., 5.
);

vec3 ditherColor(vec3 color, vec2 uv, vec2 cellSize) {
    ivec2 gridCoord = ivec2(floor(uv / cellSize));

    ivec2 ditherIndex = gridCoord % 4;
    float ditherValue = (DITHER_THRESHOLD[ditherIndex.x][ditherIndex.y] / 16.0) - SCREEN_DITHER_I;

    float luminance = GetLuminance(color);
    float variance = length(color - luminance);

    float ditherSpread = SCREEN_DITHER_AMOUNT * 0.1 * variance;
    return color + ditherSpread * ditherValue;
}

#ifdef PALETTE_SWAP
    #if USE_TEXTURE_PALETTE > 0
        const int MAX_PALETTE_SIZE = 32;
    #else
        const int MAX_PALETTE_SIZE = 6;
        vec3 FIXED_COLOR_PALETTE[MAX_PALETTE_SIZE] = vec3[](
        vec3(PALETTE1R, PALETTE1G, PALETTE1B),
        vec3(PALETTE2R, PALETTE2G, PALETTE2B),
        vec3(PALETTE3R, PALETTE3G, PALETTE3B),
        vec3(PALETTE4R, PALETTE4G, PALETTE4B),
        vec3(PALETTE5R, PALETTE5G, PALETTE5B),
        vec3(PALETTE6R, PALETTE6G, PALETTE6B)
    );
    #endif

    int getPaletteTextureSize() {
        return int(textureSize(depthtex2, 0).x);
    }

    void sortPaletteByLuminance(inout vec3 pal[MAX_PALETTE_SIZE], int size) {
        for (int i = 0; i < size - 1; i++) {
            for (int j = 0; j < size - i - 1; j++) {
                if (GetLuminance(pal[j]) > GetLuminance(pal[j + 1])) {
                    vec3 temp = pal[j];
                    pal[j] = pal[j + 1];
                    pal[j + 1] = temp;
                }
            }
        }
    }

    vec3 samplePaletteFromTexture(inout vec3 paletteOut[MAX_PALETTE_SIZE], int size) {
        for (int x = 0; x < size; x++) {
            vec3 paletteColor = texelFetch(depthtex2, ivec2(x, 0), 0).rgb;
            paletteOut[x] = paletteColor;
        }

        return paletteOut[0];
    }

    vec3 convertToPaletteColor(vec3 inputColor) {
        vec3 localPalette[MAX_PALETTE_SIZE];
        int paletteSize = MAX_PALETTE_SIZE;
        #if USE_TEXTURE_PALETTE > 0
            paletteSize = getPaletteTextureSize();
            if (paletteSize == viewWidth) {
                    return mix(mix(inputColor, vec3(GetLuminance(inputColor)), 0.93), vec3(1.0, 0.0, 0.0), 0.2); // Bright red for visibility
            }
            samplePaletteFromTexture(localPalette, paletteSize);
        #else
            for (int i = 0; i < MAX_PALETTE_SIZE; i++) {
                localPalette[i] = FIXED_COLOR_PALETTE[i] / 255.0;
            }
        #endif

        sortPaletteByLuminance(localPalette, paletteSize);

        // Quantize the color based on the available palette levels.
        inputColor.r = floor(inputColor.r * float(paletteSize - 1) + 0.5) / float(paletteSize - 1);
        inputColor.g = floor(inputColor.g * float(paletteSize - 1) + 0.5) / float(paletteSize - 1);
        inputColor.b = floor(inputColor.b * float(paletteSize - 1) + 0.5) / float(paletteSize - 1);

        int paletteIndex = int(floor(GetLuminance(inputColor) * float(paletteSize)));
        paletteIndex = clamp(paletteIndex, 0, paletteSize - 1);

        return localPalette[paletteIndex];
    }
#endif

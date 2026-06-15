if (getPaletteTextureSize() == viewWidth) {
    #if USE_TEXTURE_PALETTE == 1
        #define PALETTE_NUM _1
    #elif USE_TEXTURE_PALETTE == 2
        #define PALETTE_NUM _2
    #elif USE_TEXTURE_PALETTE == 3
        #define PALETTE_NUM _3
    #elif USE_TEXTURE_PALETTE == 4
        #define PALETTE_NUM _4
    #elif USE_TEXTURE_PALETTE == 5
        #define PALETTE_NUM _5
    #elif USE_TEXTURE_PALETTE == 6
        #define PALETTE_NUM _6
    #elif USE_TEXTURE_PALETTE == 7
        #define PALETTE_NUM _7
    #elif USE_TEXTURE_PALETTE == 8
        #define PALETTE_NUM _8
    #elif USE_TEXTURE_PALETTE == 9
        #define PALETTE_NUM _9
    #elif USE_TEXTURE_PALETTE == 10
        #define PALETTE_NUM _1, _0
    #endif
    beginTextM(8, vec2(15, 30));
        text.fgCol = vec4(1.0, 0.0, 0.0, 1.0);
        printString((_E, _R, _R, _O, _R));
        printLine();
    endText(color.rgb);
    beginTextM(4, vec2(30, 80));
        printString((_N, _o, _space, _p, _a, _l, _e, _t, _t, _e, PALETTE_NUM, _dot, _p, _n, _g, _space, _f, _o, _u, _n, _d, _space, _i, _n, _space, _t, _h, _e, _space, _p, _a, _l, _e, _t, _t, _e, _space, _f, _o, _l, _d, _e, _r));
        printLine();
        printString((_P, _l, _e, _a, _s, _e, _space, _c, _h, _e, _c, _k, _space, _s, _h, _a, _d, _e, _r, _s, _space, _gt, _space, _p, _a, _l, _e, _t, _t, _e, _s, _space, _gt, _space, _p, _a, _l, _e, _t, _t, _e, PALETTE_NUM, _dot, _p, _n, _g));
        printLine();
    endText(color.rgb);
}

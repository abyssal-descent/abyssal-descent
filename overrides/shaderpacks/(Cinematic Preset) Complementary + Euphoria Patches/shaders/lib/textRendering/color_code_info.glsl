int displayIndex = int(mod(frameTimeCounter, 90.0) / 5.0);
// int displayIndex = 0;

beginTextM(3, vec2(10, 7));
    text.bgCol = vec4(0.0, 0.0, 0.0, 0.5);
    text.fgCol = vec4(1.0, 1.0, 1.0, 1.0);
    printString((_C, _o, _l, _o, _r, _space, _C, _o, _d, _e, _space, _I, _n, _f, _o, _r, _m, _a, _t, _i, _o, _n));
    printLine();
endText(color.rgb);

if (displayIndex == 0) {
    beginTextM(3, vec2(10, 20));
        text.bgCol = vec4(0.0, 0.0, 0.0, 0.5);
        text.fgCol = vec4(0.0, 1.0, 0.0, 1.0);  // Green
        printString((_G, _r, _e, _e, _n, _colon, _space, _G, _B, _U, _F, _F, _E, _R, _S, _under, _T, _E, _R, _R, _A, _I, _N));
        printLine();
    endText(color.rgb);
} else if (displayIndex == 1) {
    beginTextM(3, vec2(10, 20));
        text.bgCol = vec4(0.0, 0.0, 0.0, 0.5);
        text.fgCol = vec4(0.0, 0.0, 1.0, 1.0);  // Dark Blue
        printString((_D, _a, _r, _k, _space, _B, _l, _u, _e, _colon, _space, _G, _B, _U, _F, _F, _E, _R, _S, _under, _W, _A, _T, _E, _R));
        printLine();
    endText(color.rgb);
} else if (displayIndex == 2) {
    beginTextM(3, vec2(10, 20));
        text.bgCol = vec4(0.0, 0.0, 0.0, 0.5);
        text.fgCol = vec4(0.0, 1.0, 2.0, 1.0);  // Light Blue
        printString((_L, _i, _g, _h, _t, _space, _B, _l, _u, _e, _colon, _space, _G, _B, _U, _F, _F, _E, _R, _S, _under, _S, _K, _Y, _B, _A, _S, _I, _C));
        printLine();
    endText(color.rgb);
} else if (displayIndex == 3) {
    beginTextM(3, vec2(10, 20));
        text.bgCol = vec4(0.0, 0.0, 0.0, 0.5);
        text.fgCol = vec4(3.0, 0.0, 3.0, 1.0);  // Magenta
        printString((_M, _a, _g, _e, _n, _t, _a, _colon, _space, _G, _B, _U, _F, _F, _E, _R, _S, _under, _W, _E, _A, _T, _H, _E, _R));
        printLine();
    endText(color.rgb);
} else if (displayIndex == 4) {
    beginTextM(3, vec2(10, 20));
        text.bgCol = vec4(0.0, 0.0, 0.0, 0.5);
        text.fgCol = vec4(1.5, 1.5, 0.0, 1.0);  // Yellow
        printString((_Y, _e, _l, _l, _o, _w, _colon, _space, _G, _B, _U, _F, _F, _E, _R, _S, _under, _B, _L, _O, _C, _K));
        printLine();
    endText(color.rgb);
} else if (displayIndex == 5) {
    beginTextM(3, vec2(10, 20));
        text.bgCol = vec4(0.0, 0.0, 0.0, 0.5);
        text.fgCol = vec4(1.5, 0.7, 0.0, 1.0);  // Orange
        printString((_O, _r, _a, _n, _g, _e, _colon, _space, _G, _B, _U, _F, _F, _E, _R, _S, _under, _H, _A, _N, _D));
        printLine();
    endText(color.rgb);
} else if (displayIndex == 6) {
    beginTextM(3, vec2(10, 20));
        text.bgCol = vec4(0.0, 0.0, 0.0, 0.5);
        text.fgCol = vec4(1.5, 0.0, 0.0, 1.0);  // Red
        printString((_R, _e, _d, _colon, _space, _G, _B, _U, _F, _F, _E, _R, _S, _under, _E, _N, _T, _I, _T, _I, _E, _S));
        printLine();
    endText(color.rgb);
} else if (displayIndex == 7) {
    beginTextM(3, vec2(10, 20));
        text.bgCol = vec4(0.0, 0.0, 0.0, 0.5);
        text.fgCol = vec4(3.0, 3.0, 3.0, 1.0);  // White
        printString((_W, _h, _i, _t, _e, _colon, _space, _G, _B, _U, _F, _F, _E, _R, _S, _under, _B, _A, _S, _I, _C));
        printLine();
    endText(color.rgb);
} else if (displayIndex == 8) {
    beginTextM(3, vec2(10, 20));
        text.bgCol = vec4(0.0, 0.0, 0.0, 0.5);
        text.fgCol = vec4(2.0, 0.0, 0.0, 1.0);  // Red
        printString((_R, _e, _d, _minus));
        text.fgCol = vec4(0.0, 0.0, 2.0, 1.0);  // Blue
        printString((_B, _l, _u, _e, _space, _V, _e, _r, _t, _space, _S, _t, _r, _i, _p, _e, _s, _colon, _space));
        
        // Alternating colors for SPIDEREYES
        text.fgCol = vec4(2.0, 0.0, 0.0, 1.0);  // Red
        printString((_S));
        text.fgCol = vec4(0.0, 0.0, 2.0, 1.0);  // Blue
        printString((_P));
        text.fgCol = vec4(2.0, 0.0, 0.0, 1.0);  // Red
        printString((_I));
        text.fgCol = vec4(0.0, 0.0, 2.0, 1.0);  // Blue
        printString((_D));
        text.fgCol = vec4(2.0, 0.0, 0.0, 1.0);  // Red
        printString((_E));
        text.fgCol = vec4(0.0, 0.0, 2.0, 1.0);  // Blue
        printString((_R));
        text.fgCol = vec4(2.0, 0.0, 0.0, 1.0);  // Red
        printString((_E));
        text.fgCol = vec4(0.0, 0.0, 2.0, 1.0);  // Blue
        printString((_Y));
        text.fgCol = vec4(2.0, 0.0, 0.0, 1.0);  // Red
        printString((_E));
        text.fgCol = vec4(0.0, 0.0, 2.0, 1.0);  // Blue
        printString((_S));
        printLine();
    endText(color.rgb);
} else if (displayIndex == 9) {
    beginTextM(3, vec2(10, 20));
        text.bgCol = vec4(0.0, 0.0, 0.0, 0.5);
        text.fgCol = vec4(2.0, 0.0, 0.0, 1.0);  // Red
        printString((_R, _e, _d, _minus));
        text.fgCol = vec4(0.0, 0.0, 2.0, 1.0);  // Blue
        printString((_B, _l, _u, _e, _space, _H, _o, _r, _i, _z, _space, _S, _t, _r, _i, _p, _e, _s, _colon, _space));
        
        // Alternating colors for TEXTURED
        text.fgCol = vec4(2.0, 0.0, 0.0, 1.0);  // Red
        printString((_T));
        text.fgCol = vec4(0.0, 0.0, 2.0, 1.0);  // Blue
        printString((_E));
        text.fgCol = vec4(2.0, 0.0, 0.0, 1.0);  // Red
        printString((_X));
        text.fgCol = vec4(0.0, 0.0, 2.0, 1.0);  // Blue
        printString((_T));
        text.fgCol = vec4(2.0, 0.0, 0.0, 1.0);  // Red
        printString((_U));
        text.fgCol = vec4(0.0, 0.0, 2.0, 1.0);  // Blue
        printString((_R));
        text.fgCol = vec4(2.0, 0.0, 0.0, 1.0);  // Red
        printString((_E));
        text.fgCol = vec4(0.0, 0.0, 2.0, 1.0);  // Blue
        printString((_D));
        printLine();
    endText(color.rgb);
} else if (displayIndex == 10) {
    beginTextM(3, vec2(10, 20));
        text.bgCol = vec4(0.0, 0.0, 0.0, 0.5);
        text.fgCol = vec4(2.0, 0.0, 0.0, 1.0);  // Red
        printString((_R, _e, _d, _minus));
        text.fgCol = vec4(0.0, 2.0, 0.0, 1.0);  // Green
        printString((_G, _r, _e, _e, _n, _space, _V, _e, _r, _t, _space, _S, _t, _r, _i, _p, _e, _s, _colon, _space));
        
        // Alternating colors for CLOUDS
        text.fgCol = vec4(2.0, 0.0, 0.0, 1.0);  // Red
        printString((_C));
        text.fgCol = vec4(0.0, 2.0, 0.0, 1.0);  // Green
        printString((_L));
        text.fgCol = vec4(2.0, 0.0, 0.0, 1.0);  // Red
        printString((_O));
        text.fgCol = vec4(0.0, 2.0, 0.0, 1.0);  // Green
        printString((_U));
        text.fgCol = vec4(2.0, 0.0, 0.0, 1.0);  // Red
        printString((_D));
        text.fgCol = vec4(0.0, 2.0, 0.0, 1.0);  // Green
        printString((_S));
        printLine();
    endText(color.rgb);
} else if (displayIndex == 11) {
    beginTextM(3, vec2(10, 20));
        text.bgCol = vec4(0.0, 0.0, 0.0, 0.5);
        text.fgCol = vec4(2.0, 0.0, 0.0, 1.0);  // Red
        printString((_R, _e, _d, _minus));
        text.fgCol = vec4(0.0, 2.0, 0.0, 1.0);  // Green
        printString((_G, _r, _e, _e, _n, _space, _H, _o, _r, _i, _z, _space, _S, _t, _r, _i, _p, _e, _s, _colon, _space));
        
        // Alternating colors for BEACONBEAM
        text.fgCol = vec4(2.0, 0.0, 0.0, 1.0);  // Red
        printString((_B));
        text.fgCol = vec4(0.0, 2.0, 0.0, 1.0);  // Green
        printString((_E));
        text.fgCol = vec4(2.0, 0.0, 0.0, 1.0);  // Red
        printString((_A));
        text.fgCol = vec4(0.0, 2.0, 0.0, 1.0);  // Green
        printString((_C));
        text.fgCol = vec4(2.0, 0.0, 0.0, 1.0);  // Red
        printString((_O));
        text.fgCol = vec4(0.0, 2.0, 0.0, 1.0);  // Green
        printString((_N));
        text.fgCol = vec4(2.0, 0.0, 0.0, 1.0);  // Red
        printString((_B));
        text.fgCol = vec4(0.0, 2.0, 0.0, 1.0);  // Green
        printString((_E));
        text.fgCol = vec4(2.0, 0.0, 0.0, 1.0);  // Red
        printString((_A));
        text.fgCol = vec4(0.0, 2.0, 0.0, 1.0);  // Green
        printString((_M));
        printLine();
    endText(color.rgb);
} else if (displayIndex == 12) {
    beginTextM(3, vec2(10, 20));
        text.bgCol = vec4(0.0, 0.0, 0.0, 0.5);
        text.fgCol = vec4(0.0, 0.0, 0.0, 1.0);  // Black
        printString((_B, _l, _a, _c, _k, _minus));
        text.fgCol = vec4(1.5, 1.5, 1.5, 1.0);  // White
        printString((_W, _h, _i, _t, _e, _space, _V, _e, _r, _t, _space, _S, _t, _r, _i, _p, _e, _s, _colon, _space));
        
        // Alternating colors for ARMOR_GLINT
        text.fgCol = vec4(0.0, 0.0, 0.0, 1.0);  // Black
        printString((_A));
        text.fgCol = vec4(1.5, 1.5, 1.5, 1.0);  // White
        printString((_R));
        text.fgCol = vec4(0.0, 0.0, 0.0, 1.0);  // Black
        printString((_M));
        text.fgCol = vec4(1.5, 1.5, 1.5, 1.0);  // White
        printString((_O));
        text.fgCol = vec4(0.0, 0.0, 0.0, 1.0);  // Black
        printString((_R));
        text.fgCol = vec4(1.5, 1.5, 1.5, 1.0);  // White
        printString((_under));
        text.fgCol = vec4(0.0, 0.0, 0.0, 1.0);  // Black
        printString((_G));
        text.fgCol = vec4(1.5, 1.5, 1.5, 1.0);  // White
        printString((_L));
        text.fgCol = vec4(0.0, 0.0, 0.0, 1.0);  // Black
        printString((_I));
        text.fgCol = vec4(1.5, 1.5, 1.5, 1.0);  // White
        printString((_N));
        text.fgCol = vec4(0.0, 0.0, 0.0, 1.0);  // Black
        printString((_T));
        printLine();
    endText(color.rgb);
} else if (displayIndex == 13) {
    beginTextM(3, vec2(10, 20));
        text.bgCol = vec4(0.0, 0.0, 0.0, 0.5);
        text.fgCol = vec4(0.0, 0.0, 0.0, 1.0);  // Black
        printString((_B, _l, _a, _c, _k, _minus));
        text.fgCol = vec4(1.5, 1.5, 1.5, 1.0);  // White
        printString((_W, _h, _i, _t, _e, _space, _H, _o, _r, _i, _z, _space, _S, _t, _r, _i, _p, _e, _s, _colon, _space));
        
        // Alternating colors for DAMAGEDBLOCK
        text.fgCol = vec4(0.0, 0.0, 0.0, 1.0);  // Black
        printString((_D));
        text.fgCol = vec4(1.5, 1.5, 1.5, 1.0);  // White
        printString((_A));
        text.fgCol = vec4(0.0, 0.0, 0.0, 1.0);  // Black
        printString((_M));
        text.fgCol = vec4(1.5, 1.5, 1.5, 1.0);  // White
        printString((_A));
        text.fgCol = vec4(0.0, 0.0, 0.0, 1.0);  // Black
        printString((_G));
        text.fgCol = vec4(1.5, 1.5, 1.5, 1.0);  // White
        printString((_E));
        text.fgCol = vec4(0.0, 0.0, 0.0, 1.0);  // Black
        printString((_D));
        text.fgCol = vec4(1.5, 1.5, 1.5, 1.0);  // White
        printString((_B));
        text.fgCol = vec4(0.0, 0.0, 0.0, 1.0);  // Black
        printString((_L));
        text.fgCol = vec4(1.5, 1.5, 1.5, 1.0);  // White
        printString((_O));
        text.fgCol = vec4(0.0, 0.0, 0.0, 1.0);  // Black
        printString((_C));
        text.fgCol = vec4(1.5, 1.5, 1.5, 1.0);  // White
        printString((_K));
        printLine();
    endText(color.rgb);
} else if (displayIndex == 14) {
    beginTextM(3, vec2(10, 20));
        text.bgCol = vec4(0.0, 0.0, 0.0, 0.5);
        text.fgCol = vec4(0.0, 2.0, 0.0, 1.0);  // Green
        printString((_G, _r, _e, _e, _n, _minus));
        text.fgCol = vec4(0.0, 0.0, 2.0, 1.0);  // Blue
        printString((_B, _l, _u, _e, _space, _H, _o, _r, _i, _z, _space, _S, _t, _r, _i, _p, _e, _s, _colon, _space));
        
        // Alternating colors for SKYTEXTURED
        text.fgCol = vec4(0.0, 2.0, 0.0, 1.0);  // Green
        printString((_S));
        text.fgCol = vec4(0.0, 0.0, 2.0, 1.0);  // Blue
        printString((_K));
        text.fgCol = vec4(0.0, 2.0, 0.0, 1.0);  // Green
        printString((_Y));
        text.fgCol = vec4(0.0, 0.0, 2.0, 1.0);  // Blue
        printString((_T));
        text.fgCol = vec4(0.0, 2.0, 0.0, 1.0);  // Green
        printString((_E));
        text.fgCol = vec4(0.0, 0.0, 2.0, 1.0);  // Blue
        printString((_X));
        text.fgCol = vec4(0.0, 2.0, 0.0, 1.0);  // Green
        printString((_T));
        text.fgCol = vec4(0.0, 0.0, 2.0, 1.0);  // Blue
        printString((_U));
        text.fgCol = vec4(0.0, 2.0, 0.0, 1.0);  // Green
        printString((_R));
        text.fgCol = vec4(0.0, 0.0, 2.0, 1.0);  // Blue
        printString((_E));
        text.fgCol = vec4(0.0, 2.0, 0.0, 1.0);  // Green
        printString((_D));
        printLine();
    endText(color.rgb);
} else if (displayIndex == 15) {
    beginTextM(3, vec2(10, 20));
        text.bgCol = vec4(0.0, 0.0, 0.0, 0.5);
        text.fgCol = vec4(2.0, 2.0, 0.0, 1.0);  // Yellow
        printString((_Y, _e, _l, _l, _o, _w, _minus));
        text.fgCol = vec4(0.0, 0.0, 2.0, 1.0);  // Blue
        printString((_B, _l, _u, _e, _space, _H, _o, _r, _i, _z, _space, _S, _t, _r, _i, _p, _e, _s, _colon, _space));
        
        // Alternating colors for LIGHTNING
        text.fgCol = vec4(2.0, 2.0, 0.0, 1.0);  // Yellow
        printString((_L));
        text.fgCol = vec4(0.0, 0.0, 2.0, 1.0);  // Blue
        printString((_I));
        text.fgCol = vec4(2.0, 2.0, 0.0, 1.0);  // Yellow
        printString((_G));
        text.fgCol = vec4(0.0, 0.0, 2.0, 1.0);  // Blue
        printString((_H));
        text.fgCol = vec4(2.0, 2.0, 0.0, 1.0);  // Yellow
        printString((_T));
        text.fgCol = vec4(0.0, 0.0, 2.0, 1.0);  // Blue
        printString((_N));
        text.fgCol = vec4(2.0, 2.0, 0.0, 1.0);  // Yellow
        printString((_I));
        text.fgCol = vec4(0.0, 0.0, 2.0, 1.0);  // Blue
        printString((_N));
        text.fgCol = vec4(2.0, 2.0, 0.0, 1.0);  // Yellow
        printString((_G));
        printLine();
    endText(color.rgb);
} else if (displayIndex == 16) {
    beginTextM(3, vec2(10, 20));
        text.bgCol = vec4(0.0, 0.0, 0.0, 0.5);
        text.fgCol = vec4(1.0, 1.0, 1.0, 1.0);  // Text info
        printString((_H, _o, _l, _d, _space, _s, _p, _i, _d, _e, _r, _space, _e, _y, _e, _s, _space, _i, _n, _space, _b, _o, _t, _h));
        printLine();
        printString((_h, _a, _n, _d, _s, _space, _t, _o, _space, _d, _i, _s, _a, _b, _l, _e, _space, _c, _o, _l, _o, _r, _space, _c, _o, _d, _i, _n, _g));
        printLine();
    endText(color.rgb);
} else {
    beginTextM(3, vec2(10, 20));
        text.bgCol = vec4(0.0, 0.0, 0.0, 0.5);
        text.fgCol = vec4(1.0, 1.0, 1.0, 1.0);
        printString((_H, _o, _l, _d, _space, _s, _p, _i, _d, _e, _r, _space, _e, _y, _e, _space, _i, _n, _space, _o, _n, _e));
        printLine();
        printString((_h, _a, _n, _d, _space, _f, _o, _r, _space, _u, _n, _k, _o, _w, _n, _space, _b, _l, _o, _c, _k, _s, _space, _i, _n, _space, _p, _r, _o, _p, _e, _r, _t, _i, _e, _s, _space, _f, _i, _l, _e, _s));
        printLine();
    endText(color.rgb);
}
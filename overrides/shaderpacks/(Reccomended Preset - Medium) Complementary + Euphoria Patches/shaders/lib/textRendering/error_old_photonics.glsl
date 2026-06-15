color.rgb = mix(mix(vec3(GetLuminance(color.rgb)), vec3(0.0), 0.65), color.rgb, animation);
beginTextM(8, vec2(6, 10));
    text.fgCol = vec4(1.0, 0.0, 0.0, 1.0);
    printString((_I, _m, _p, _o, _r, _t, _a, _n, _t, _space, _E, _r, _r, _o, _r));
    printLine();
    textColor = color.rgb;
endText(textColor);
color.rgb = mix(textColor, color.rgb, animation);
beginTextM(4, vec2(15, 36));
    text.fgCol = vec4(1.0, 1.0, 1.0, 1.0);
    printString((_T, _h, _e, _space, _c, _u, _r, _r, _e, _n, _t, _l, _y, _space, _i, _n, _s, _t, _a, _l, _l, _e, _d, _space, _P, _h, _o, _t, _o, _n, _i, _c, _s, _space, _v, _e, _r, _s, _i, _o, _n, _space, _i, _s, _space, _N, _O, _T, _space));
    printLine();
    printString((_c, _o, _m, _p, _a, _t, _i, _b, _l, _e, _space, _w, _i, _t, _h, _space, _E, _u, _p, _h, _o, _r, _i, _a, _space, _P, _a, _t, _c, _h, _e, _s, _dot));
    printLine();
    printString((_P, _h, _o, _t, _o, _n, _i, _c, _s, _space, _0, _dot, _3, _dot, _1, _plus, _space, _r, _e, _q, _u, _i, _r, _e, _d, _space, _t, _o, _space, _u, _s, _e, _space, _P, _h, _o, _t, _o, _n, _i, _c, _s, _space, _f, _u, _n, _c, _t, _i, _o, _n, _a, _l, _i, _t, _y, _dot));
    printLine();
    printLine();
    printString((_M, _o, _v, _e, _space, _t, _o, _space, _d, _i, _s, _c, _a, _r, _d, _space, _e, _r, _r, _o, _r, _space, _m, _e, _s, _s, _a, _g, _e));
    textColor = color.rgb;
endText(textColor);

color.rgb = mix(textColor, color.rgb, animation);
beginTextM(3, vec2(19, 106));
    printString((_D, _i, _s, _a, _b , _l, _e, _space, _t, _h, _e, _space, _e, _r, _r, _o, _r, _space, _m, _e, _s, _s, _a, _g, _e, _space, _p, _e, _r, _m, _a, _n, _e, _n, _t, _l, _y));
    printString((_b, _y, _space, _d, _i, _s, _a, _b, _l, _i, _n, _g, _space, _P, _h, _o, _t, _o, _n, _i, _c, _s, _space, _u, _n, _d, _e, _r, _colon));
    printLine();
    printString((_C, _o, _n, _f, _i, _g, _u, _r, _e, _space, _E, _u, _p, _h, _o, _r, _i, _a, _space, _P, _a, _t, _c, _h, _e, _s, _space, _gt, _space, _M, _o, _d, _d, _e, _d, _space, _S, _e, _t, _t, _i, _n, _g, _s, _space, _gt, _space, _P, _h, _o, _t, _o, _n, _i, _c, _s));
    printLine();
    printString((_T, _h, _e, _n, _space, _s, _e, _t, _space, _L, _i, _g, _h, _t, _i, _n, _g, _space, _M, _o, _d, _e, _space, _t, _o, _space, _O, _f, _f));
    textColor = color.rgb;
endText(textColor);

color.rgb = mix(textColor, color.rgb, animation);


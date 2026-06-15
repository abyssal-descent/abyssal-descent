if (photonicsOutsideRange < 0.999) {
color.rgb = mix(mix(vec3(GetLuminance(color.rgb)), color.rgb, 0.35), color.rgb, photonicsOutsideRange);
beginTextM(6, vec2(6, 10));
    text.fgCol = vec4(1.0, 0.0, 0.0, 1.0);
    printString((_I, _m, _p, _o, _r, _t, _a, _n, _t, _space, _E, _r, _r, _o, _r));
    printLine();
    textColor = color.rgb;
endText(textColor);
color.rgb = mix(textColor, color.rgb, photonicsOutsideRange);
beginTextM(3, vec2(15, 36));
    text.fgCol = vec4(1.0, 1.0, 1.0, 1.0);
    printString((_P, _h, _o, _t, _o, _n, _i, _c, _s, _space, _d, _o, _e, _s, _space, _n, _o, _t, _space, _w, _o, _r, _k, _space, _p, _r, _o, _p, _e, _r, _l, _y, _space, _a, _t, _space, _c, _o, _o, _r, _d, _i, _n, _a, _t, _e, _s, _space, _a, _b, _o, _v, _e, _space, _3, _0, _k, _space, _b, _l, _o, _c, _k, _s, _dot));
    printLine();
    printString((_F, _a, _l, _l, _i, _n, _g, _space, _b, _a, _c, _k, _space, _t, _o, _space, _v, _a, _n, _i, _l, _l, _a, _space, _l, _i, _g, _h, _t, _i, _n, _g, _dot));
    printLine();
    printLine();
    printString((_T, _h, _i, _s, _space, _m, _e, _s, _s, _a, _g, _e, _space, _w, _i, _l, _l, _space, _a, _u, _t, _o, _m, _a, _t, _i, _c, _a, _l, _l, _y, _space, _f, _a, _d, _e, _space, _a, _w, _a, _y, _space, _a, _f, _t, _e, _r));
    printLine();
    printString((_a, _space, _f, _e, _w, _space, _s, _e, _c, _o, _n, _d, _s, _dot));
    printLine();
    textColor = color.rgb;
endText(textColor);
color.rgb = mix(textColor, color.rgb, photonicsOutsideRange);
}


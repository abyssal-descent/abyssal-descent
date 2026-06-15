color.rgb = mix(color.rgb, vec3(0.0), 0.65);
beginTextM(8, vec2(6, 10));
    text.fgCol = vec4(1.0, 0.0, 0.0, 1.0);
    printString((_I, _m, _p, _o, _r, _t, _a, _n, _t, _space, _E, _r, _r, _o, _r));
    printLine();
endText(color.rgb);
beginTextM(4, vec2(15, 36));
    text.fgCol = vec4(1.0, 1.0, 1.0, 1.0);
    printString((_P, _h, _o, _t, _o, _n, _i, _c, _s, _space, _d, _o, _e, _s, _space, _n, _o, _t, _space, _w, _o, _r, _k, _space, _o, _n, _space, _O, _p, _t, i, _F, _i, _n, _e));
    printLine();
    printString((_R, _e, _m, _o, _v, _e, _space, _t, _h, _e, _space, _P, _h, _o, _t, _o, _n, _i, _c, _s, _space, _m, _o, _d, _space, _t, _o, _space, _a, _v, _o, _i, _d, _space, _t, _h, _i, _s, _space, _e, _r, _r, _o, _r));
endText(color.rgb);


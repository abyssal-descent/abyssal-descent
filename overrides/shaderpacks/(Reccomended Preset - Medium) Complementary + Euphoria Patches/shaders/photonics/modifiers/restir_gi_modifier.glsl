void modify_restir_gi(inout vec3 color){
    color = saturateColors(color, 1.2);
    color *= mix(0.066, 0.05, sunVisibility2) * PHOTONICS_INDIRECT_INTENSITY  * 0.1;
}

#define ENTITY_GN_AND_CT
#define COATED_TEXTURE_MULT 100 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200]
#define COATED_TEXTURE_RES 64 //[16 32 64 80 96 112 128 144 160 176 192 208 224 240 256 320 384 448 512]
const float packSizeNT = COATED_TEXTURE_RES;

void CoatTextures(inout vec3 color, float noiseFactor, vec3 playerPos, bool doTileRandomisation) {
    #ifndef ENTITY_GN_AND_CT
        #if defined GBUFFERS_ENTITIES || defined GBUFFERS_HAND
            return;
        #endif
    #endif

    #ifndef SAFER_GENERATED_NORMALS
        vec2 noiseCoord = floor(midCoordPos / 16.0 * packSizeNT * atlasSizeM) / packSizeNT / 3.0;
    #else
        vec2 offsetR = max(absMidCoordPos.x, absMidCoordPos.y) * vec2(float(atlasSizeM.y) / float(atlasSizeM.x), 1.0);
        vec2 noiseCoord = floor(midCoordPos / 2.0 * packSizeNT / offsetR) / packSizeNT / 3.0;
    #endif

    if (doTileRandomisation) {
        vec3 floorWorldPos = floor(playerPos + cameraPosition + 0.001);
        noiseCoord += 0.84 * (floorWorldPos.xz + floorWorldPos.y);
    }

    float noiseTexture = texture2D(noisetex, noiseCoord).r;
    noiseTexture = noiseTexture + 0.6;
    float colorBrightness = dot(color, color) * 0.3;
    #define COATED_TEXTURE_MULT_M COATED_TEXTURE_MULT * 0.0027
    noiseFactor *= COATED_TEXTURE_MULT_M * max0(1.0 - colorBrightness);
    noiseFactor *= max(1.0 - miplevel * 0.25, 0.0);
    noiseTexture = pow(noiseTexture, noiseFactor);
    color *= noiseTexture;
}
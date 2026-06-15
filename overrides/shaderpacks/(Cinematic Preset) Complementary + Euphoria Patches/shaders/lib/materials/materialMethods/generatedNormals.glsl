#define ENTITY_GN_AND_CT
#define GENERATED_NORMAL_MULT 100 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 250 300 400]
#define GENERATED_NORMAL_ENTITY_MULT 0 //[0 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 250 300 400]
#define NORMAL_RES 128 //[16 32 64 80 96 112 128 144 160 176 192 208 224 240 256 320 384 448 512]

const float normalThreshold = 0.05;
const float normalClamp = 0.2;
const float packSizeGN = 128.0;

#ifdef GBUFFERS_ENTITIES
    #if GENERATED_NORMAL_ENTITY_MULT > 0
        const float normalMult = GENERATED_NORMAL_ENTITY_MULT * 0.025;
    #else
        const float normalMult = GENERATED_NORMAL_MULT * 0.025;
    #endif
#elif !defined GBUFFERS_HAND
    const float normalMult = GENERATED_NORMAL_MULT * 0.025;
#else
    const float normalMult = GENERATED_NORMAL_MULT * 0.015;
#endif

float GetDif(float lOriginalAlbedo, vec2 offsetCoord) {
    #ifndef GBUFFERS_WATER
        float lNearbyAlbedo = length(texture2D(tex, offsetCoord).rgb);
    #else
        vec4 textureSample = texture2D(tex, offsetCoord);
        float lNearbyAlbedo = length(textureSample.rgb * textureSample.a * 1.5);
    #endif

    #ifdef GBUFFERS_ENTITIES
        lOriginalAlbedo = abs(lOriginalAlbedo - 1.0);
        lNearbyAlbedo = abs(lNearbyAlbedo - 1.0);
    #endif

    float dif = lOriginalAlbedo - lNearbyAlbedo;

    #ifdef GBUFFERS_ENTITIES
        dif = -dif;
    #endif

    #ifndef GBUFFERS_WATER
        if (dif > 0.0) dif = max(dif - normalThreshold, 0.0);
        else           dif = min(dif + normalThreshold, 0.0);
    #endif

    return clamp(dif, -normalClamp, normalClamp);
}

void GenerateNormals(inout vec3 normalM, vec3 color) {
    #ifndef ENTITY_GN_AND_CT
        #if defined GBUFFERS_ENTITIES || defined GBUFFERS_HAND
            return;
        #endif
    #endif

    vec2 absMidCoordPos2 = absMidCoordPos * 2.0;
    float lOriginalAlbedo = length(color.rgb);

    float normalMult = max0(1.0 - mipDelta) * normalMult;

    #ifndef SAFER_GENERATED_NORMALS
        vec2 offsetR = 16.0 / atlasSizeM;
    #else
        vec2 offsetR = max(absMidCoordPos2.x, absMidCoordPos2.y) * vec2(float(atlasSizeM.y) / float(atlasSizeM.x), 1.0);
    #endif
    offsetR /= NORMAL_RES;

    vec2 midCoord = texCoord - midCoordPos;
    vec2 maxOffsetCoord = midCoord + absMidCoordPos;
    vec2 minOffsetCoord = midCoord - absMidCoordPos;
    if (normalMult > 0.0) {
        vec3 normalMap = vec3(0.0, 0.0, 1.0);

        vec2 offsetCoord = texCoord + vec2( 0.0, offsetR.y);
        if (offsetCoord.y < maxOffsetCoord.y)
            normalMap.y += GetDif(lOriginalAlbedo, offsetCoord);

        offsetCoord = texCoord + vec2( offsetR.x, 0.0);
        if (offsetCoord.x < maxOffsetCoord.x)
            normalMap.x += GetDif(lOriginalAlbedo, offsetCoord);

        offsetCoord = texCoord + vec2( 0.0,-offsetR.y);
        if (offsetCoord.y > minOffsetCoord.y)
            normalMap.y -= GetDif(lOriginalAlbedo, offsetCoord);

        offsetCoord = texCoord + vec2(-offsetR.x, 0.0);
        if (offsetCoord.x > minOffsetCoord.x)
            normalMap.x -= GetDif(lOriginalAlbedo, offsetCoord);

        normalMap.xy *= normalMult;
        normalMap.xy = clamp(normalMap.xy, vec2(-1.0), vec2(1.0));

        if (normalMap.xy != vec2(0.0, 0.0))
            normalM = clamp(normalize(normalMap * tbnMatrix), vec3(-1.0), vec3(1.0));
    }
}

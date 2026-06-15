//////////////////////////////////////////
// Complementary Shaders by EminGT      //
// With Euphoria Patches by SpacEagle17 //
//////////////////////////////////////////

//Common//
#include "/lib/common.glsl"
#include "/lib/shaderSettings/composite5.glsl"
#include "/lib/shaderSettings/blueScreen.glsl"
#include "/lib/shaderSettings/bloom.glsl"

//////////Fragment Shader//////////Fragment Shader//////////Fragment Shader//////////
#ifdef FRAGMENT_SHADER

noperspective in vec2 texCoord;

#if defined BLOOM_FOG || (LENSFLARE_MODE > 0 || defined AURORA_INFLUENCE) && defined OVERWORLD
    flat in vec3 upVec, sunVec;
#endif

//Pipeline Constants//

//Common Variables//
float pw = 1.0 / viewWidth;
float ph = 1.0 / viewHeight;

vec2 view = vec2(viewWidth, viewHeight);

#if defined BLOOM_FOG || (LENSFLARE_MODE > 0 || defined AURORA_INFLUENCE) && defined OVERWORLD
    float SdotU = dot(sunVec, upVec);
    float sunVisibility = clamp(SdotU + 0.0625, 0.0, 0.125) / 0.125;
    float sunFactor = SdotU < 0.0 ? clamp(SdotU + 0.375, 0.0, 0.75) / 0.75 : clamp(SdotU + 0.03125, 0.0, 0.0625) / 0.0625;
#endif

//Common Functions//
#include "/lib/colors/tonemaps.glsl"

void DoBSLColorSaturation(inout vec3 color) {
    float saturationFactor = T_SATURATION + 0.07;

    float grayVibrance = (color.r + color.g + color.b) / 3.0;
    float graySaturation = grayVibrance;
    if (saturationFactor < 1.00) graySaturation = dot(color, vec3(0.299, 0.587, 0.114));

    float mn = min(color.r, min(color.g, color.b));
    float mx = max(color.r, max(color.g, color.b));
    float sat = (1.0 - (mx - mn)) * (1.0 - mx) * grayVibrance * 5.0;
    vec3 lightness = vec3((mn + mx) * 0.5);

    color = mix(color, mix(color, lightness, 1.0 - T_VIBRANCE), sat);
    color = mix(color, lightness, (1.0 - lightness) * (2.0 - T_VIBRANCE) / 2.0 * abs(T_VIBRANCE - 1.0));
    color = color * saturationFactor - graySaturation * (saturationFactor - 1.0);
}

#if BLOOM_ENABLED == 1
    vec2 rescale = max(vec2(viewWidth, viewHeight) / vec2(1920.0, 1080.0), vec2(1.0));
    vec3 GetBloomTile(float lod, vec2 coord, vec2 offset) {
        float scale = exp2(lod);
        vec2 bloomCoord = coord / scale + offset;
        bloomCoord = clamp(bloomCoord, offset, 1.0 / scale + offset);

        vec3 bloom = texture2D(colortex3, bloomCoord / rescale).rgb;
        bloom *= bloom;
        bloom *= bloom;
        return bloom * 128.0;
    }

    void DoBloom(inout vec3 color, vec2 coord, float dither, float lViewPos) {
        vec3 blur1 = GetBloomTile(2.0, coord, vec2(0.0      , 0.0   ));
        vec3 blur2 = GetBloomTile(3.0, coord, vec2(0.0      , 0.26  ));
        vec3 blur3 = GetBloomTile(4.0, coord, vec2(0.135    , 0.26  ));
        vec3 blur4 = GetBloomTile(5.0, coord, vec2(0.2075   , 0.26  ));
        vec3 blur5 = GetBloomTile(6.0, coord, vec2(0.135    , 0.3325));
        vec3 blur6 = GetBloomTile(7.0, coord, vec2(0.160625 , 0.3325));
        vec3 blur7 = GetBloomTile(8.0, coord, vec2(0.1784375, 0.3325));

        vec3 blur = (blur1 + blur2 + blur3 + blur4 + blur5 + blur6 + blur7) * 0.14;

        float bloomStrength = BLOOM_STRENGTH + 0.2 * darknessFactor;

        #if defined BLOOM_FOG && defined NETHER && defined BORDER_FOG
            float farM = min(renderDistance, NETHER_VIEW_LIMIT); // consistency9023HFUE85JG
            float netherBloom = lViewPos / clamp(farM, 96.0, 256.0);
            netherBloom *= netherBloom;
            netherBloom *= netherBloom;
            netherBloom = 1.0 - exp(-8.0 * netherBloom);
            netherBloom *= 1.0 - maxBlindnessDarkness;
            bloomStrength = mix(bloomStrength * 0.7, bloomStrength * 1.8, netherBloom);
        #endif

        color = mix(color, blur, bloomStrength);
        //color += blur * bloomStrength * (ditherFactor.x + ditherFactor.y);
    }
#endif

#include "/lib/util/colorConversion.glsl"

#if defined AURORA_INFLUENCE && defined OVERWORLD
    #include "/lib/atmospherics/auroraBorealisVisibility.glsl"
#endif

// #if COLORED_LIGHTING_INTERNAL > 0
//     #include "/lib/voxelization/lightVoxelization.glsl"
// #endif

// http://www.diva-portal.org/smash/get/diva2:24136/FULLTEXT01.pdf
// The MIT License
// Copyright © 2024 Benjamin Stott "sixthsurge"
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
vec3 purkinjeShift(vec3 rgb, vec4 texture6, vec3 playerPos, float lViewPos, float purkinjeOverwrite, float z0, float fogValue, float VdotU) {
    vec3 baseRgb = rgb;
    float skyboxBlend = 1.0;

    #ifdef NO_PURKINJE_IN_SKYBOX
        float z0lod = 1.0;
        #ifdef DISTANT_HORIZONS
            z0lod = texelFetch(dhDepthTex, texelCoord, 0).r;
        #elif defined VOXY
            z0lod = texelFetch(vxDepthTexTrans, texelCoord, 0).r;
        #endif
        if (z0 == 1.0 && z0lod == 1.0) {
            float horizonCenter = 0.0;
            #ifdef OVERWORLD
                // Shift horizon band down as camera height increases so terrain/sky seam stays covered.
                horizonCenter = clamp(-cameraPosition.y / max(renderDistance * 1.35, 1.0), -0.55, 0.0);
            #endif
            float horizonBand = abs(VdotU - horizonCenter);
            // Keep Purkinje only near horizon on pure skybox pixels (mirrored up/down fade).
            skyboxBlend = 1.0 - smoothstep(0.22, 0.38, horizonBand);
        }
    #endif

    float interiorFactorM = 0;
    #ifdef NETHER
        float nightDesaturationIntensity = NIGHT_DESATURATION_NETHER;
        float distanceFadeSetting = PURKINJE_RENDER_DISTANCE_FADE_NETHER;
        interiorFactorM = 1.0;
    #elif defined END
        float nightDesaturationIntensity = NIGHT_DESATURATION_END;
        nightFactor = 1.0;
        float distanceFadeSetting = 0.1;
        interiorFactorM = -10000.0;
    #else
		float distanceFadeSetting = PURKINJE_RENDER_DISTANCE_FADE;
	    #ifdef MOON_PHASE_INF_PURKINJE
			float nightDesaturationIntensity = moonPhase == 0 ? MOON_PHASE_FULL_PURKINJE : moonPhase != 4 ? MOON_PHASE_PARTIAL_PURKINJE : MOON_PHASE_DARK_PURKINJE;
		#else
			float nightDesaturationIntensity = NIGHT_DESATURATION_OW;
		#endif
    #endif

    float lightFogFactor = sqrt2(clamp01(fogValue));
    #if defined VOXY || defined DISTANT_HORIZONS
        float dynamicFar = max(far, 512.0);
    #else
        float dynamicFar = far;
    #endif
    float renderDistanceFade = mix(0, lViewPos * 2.5 / dynamicFar, distanceFadeSetting * (1.0 - lightFogFactor));
    if (isEyeInWater == 1) renderDistanceFade = lViewPos * 7.0 / dynamicFar;
    float nightCaveDesaturation = NIGHT_CAVE_DESATURATION * 0.1;

    float skyLightFactor = texture6.b;

    #ifdef IRIS_FEATURE_FADE_VARIABLE
        if (skyLightFactor > 0.50001) skyLightFactor = eyeBrightnessM;
        else skyLightFactor *= 1.9999;
    #endif

    float interiorFactor = isEyeInWater == 1 ? 0.0 : pow2(1.0 - skyLightFactor * (1.0 - lightFogFactor));
    interiorFactor =  mix(interiorFactor, interiorFactorM, renderDistanceFade);
    interiorFactor -= sqrt2(eyeBrightnessM) * 0.66;
    interiorFactor = smoothstep(0.0, 1.0, clamp01(interiorFactor));

    // interiorFactor = 0.0;

    // return vec3(interiorFactor);

    float lightSourceFactor = 1.0;
    #ifdef NIGHT_DESATURATION_REMOVE_NEAR_LIGHTS
        float lightmap = texture6.a;
        #if defined PHOTONICS_LIGHTING && PHOTONICS_MAX_LIGHTS > 0
            float phRtCoverage = getPhotonicsFade(playerPos);
            lightmap *= mix(1.0, 0.35, phRtCoverage);
            float lightmapTemp = texelFetch(colortex20, texelCoord, 0).r;
            float photonicsLight = clamp01(lightmapTemp);
            const float photonicsBoostCurve = 0.3;
            const float photonicsBoostAmount = 0.9;
            float photonicsBoosted = pow(photonicsLight, photonicsBoostCurve);
            photonicsLight = mix(photonicsLight, photonicsBoosted, photonicsBoostAmount);
            lightmap += photonicsLight * phRtCoverage;
            lightmap = min1(lightmap);
        #endif

        lightSourceFactor = pow3(1.0 - lightmap * (1.0 - lightFogFactor));
        lightSourceFactor += renderDistanceFade;
        lightSourceFactor = clamp01(lightSourceFactor);
    #endif

    float heldLight = 1.0;
    #ifdef NIGHT_DESATURATION_REMOVE_LIGHTS_IN_HAND
        heldLight = max(heldBlockLightValue, heldBlockLightValue2);
        if (heldItemId == 45032 || heldItemId2 == 45032) heldLight = 15; // Lava Bucket
        if (heldLight > 0){
            heldLight = clamp(heldLight, 0.0, 15.0);
            heldLight = sqrt2(heldLight / 15.0) * -1.0 + 1.0; // Normalize and invert
            heldLight = mix(heldLight, 1.0, clamp01(lViewPos * 15 / far)); // Only do it around the player
        } else {
            heldLight = 1.0;
        }
    #endif

    float nightVisionFactor = 1.0;
    #ifdef NIGHT_DESATURATION_REMOVE_NIGHT_VISION
        nightVisionFactor = nightVision * -1.0 + 1.0;
    #endif

    float auroraInfluenceVisibility = 1.0;
    #if defined AURORA_INFLUENCE && defined OVERWORLD
        auroraInfluenceVisibility = GetAuroraVisibility(0.5, 0.0);
        auroraInfluenceVisibility = 1.0 - auroraInfluenceVisibility * 0.66;
    #endif

    float purkinjeIntensity = 0.004 * purkinjeOverwrite * nightDesaturationIntensity;
    purkinjeIntensity  = purkinjeIntensity * fuzzyOr(interiorFactor, sqrt3(nightFactor - 0.1)); // No purkinje shift in daylight
    purkinjeIntensity *= mix(1.0, auroraInfluenceVisibility, 1.0 - interiorFactor); // Remove purkinje shift when aurora is visible, but only when not underground
    purkinjeIntensity *= lightSourceFactor; // Reduce purkinje intensity in blocklight
    purkinjeIntensity *= (1.0 - lightFogFactor);
    purkinjeIntensity *= clamp01(nightCaveDesaturation + (1.0 - nightCaveDesaturation) * pow3(1.0 - interiorFactor)); // Reduce purkinje intensity underground
    purkinjeIntensity *= clamp01(heldLight); // Reduce purkinje intensity when holding light sources
    purkinjeIntensity *= nightVisionFactor * (1.0 - isLightningActive()); // Reduce purkinje intensity when using night vision or during lightning
    purkinjeIntensity = clamp(purkinjeIntensity, 0.01, 1.0); // prevent it going to 0 to avoid NaNs

    if (nightDesaturationIntensity < 300) {
        float blueDominance = rgb.b / max(max(rgb.r, rgb.g), 0.01);
        float blueReduction = smoothstep(0.9, 2.3, blueDominance);

        // Create a darker tint for blue colors
        vec3 purkinjeTint = vec3(0.5, 0.7, 1.0);
        purkinjeTint *= mix(vec3(1.0), vec3(0.6, 0.7, 0.65), blueReduction * 0.7);
        purkinjeTint *= rec709ToRec2020;

        const vec3 rodResponse = vec3(7.15e-5, 4.81e-1, 3.28e-1) * rec709ToRec2020;
        vec3 xyz = rgb * rec2020ToXyz;
        vec3 scotopicLuminance = xyz * (1.33 * (1.0 + (xyz.y + xyz.z) / xyz.x) - 0.5);
        float purkinje = dot(rodResponse, scotopicLuminance * xyzToRec2020) * 0.45;

        float purkinjeFactor = exp2(-rcp(purkinjeIntensity) * purkinje) * (1.0 - blueReduction * 0.5);

        rgb = mix(rgb, purkinje * purkinjeTint, purkinjeFactor);
    } else {
        rgb = mix(rgb, vec3(GetLuminance(rgb) * 0.9), clamp01(purkinjeIntensity));
    }

    // return vec3(purkinjeIntensity);

    #ifdef NO_PURKINJE_IN_SKYBOX
        return mix(baseRgb, max0(rgb), skyboxBlend);
    #else
        return max0(rgb);
    #endif
}

//Includes//
#ifdef BLOOM_FOG
    #include "/lib/atmospherics/fog/bloomFog.glsl"
#endif

#if BLOOM_ENABLED == 1
    #include "/lib/util/dither.glsl"
#endif

#if LENSFLARE_MODE > 0 && defined OVERWORLD
    #include "/lib/misc/lensFlare.glsl"
#endif

#include "/lib/util/spaceConversion.glsl"

//Program//
void main() {
    vec3 color = texture2D(colortex0, texCoord).rgb;

    vec4 texture5 = texelFetch(colortex5, texelCoord, 0);

    #if defined BLOOM_FOG || LENSFLARE_MODE > 0 && defined OVERWORLD || defined NIGHT_DESATURATION
        float z0 = texture2D(depthtex0, texCoord).r;
        vec4 screenPos = vec4(texCoord, z0, 1.0);
        vec4 viewPos = gbufferProjectionInverse * (screenPos * 2.0 - 1.0);
        viewPos /= viewPos.w;
        float lViewPos = length(viewPos.xyz);
        vec3 nViewPos = normalize(viewPos.xyz);
        float VdotU = dot(nViewPos, normalize(gbufferModelView[1].xyz));

        vec3 playerPos = ViewToPlayer(viewPos.xyz);

        #if defined DISTANT_HORIZONS || defined VOXY
            #ifdef DISTANT_HORIZONS
                float z0lod = texelFetch(dhDepthTex, texelCoord, 0).r;
                vec4 screenPosLod = vec4(texCoord, z0lod, 1.0);
                vec4 viewPosLod = dhProjectionInverse * (screenPosLod * 2.0 - 1.0);
            #elif defined VOXY
                float z0lod = texelFetch(vxDepthTexTrans, texelCoord, 0).r;
                vec4 screenPosLod = vec4(texCoord, z0lod, 1.0);
                vec4 viewPosLod = vxProjInv * (screenPosLod * 2.0 - 1.0);
            #endif
            viewPosLod /= viewPosLod.w;
            lViewPos = min(lViewPos, length(viewPosLod.xyz));
        #endif
    #else
        float lViewPos = 0.0;
    #endif

    float dither = texture2DLod(noisetex, texCoord * view / 128.0, 0.0).b;
    #ifdef TAA
        dither = fract(dither + goldenRatio * mod(float(frameCounter), 3600.0));
    #endif

    #ifdef BLOOM_FOG
        color /= GetBloomFog(lViewPos);
    #endif

    #if BLOOM_ENABLED == 1
        DoBloom(color, texCoord, dither, lViewPos);
    #endif

    #ifdef COLORGRADING
        color =
            pow(color.r, GR_RC) * vec3(GR_RR, GR_RG, GR_RB) +
            pow(color.g, GR_GC) * vec3(GR_GR, GR_GG, GR_GB) +
            pow(color.b, GR_BC) * vec3(GR_BR, GR_BG, GR_BB);
        color *= 0.01;
    #endif

    #ifdef TONEMAP_COMPARISON
        color = texCoord.x < mix(0.5, 0.0, isSneaking) ? tonemap_left(color) : tonemap_right(color); // Thanks to SixthSurge
    #else
        color = tonemap(color);
    #endif
    color = clamp01(color);

    #if defined GREEN_SCREEN_LIME || defined BLUE_SCREEN || SELECT_OUTLINE == 4 || defined NIGHT_DESATURATION
        vec4 texture6 = texelFetch(colortex6, texelCoord, 0);
        int materialMaskInt = int(texture6.g * 255.1);
    #endif
    float purkinjeOverwrite = 1.0;

    #ifdef GREEN_SCREEN_LIME
        if (materialMaskInt == 240) { // Green Screen Lime Blocks
            color = vec3(0.0, 1.0, 0.0);
            purkinjeOverwrite = 0.0;
        }
    #endif
    #ifdef BLUE_SCREEN
        if (materialMaskInt == 239) { // Blue Screen Blue Blocks
            color = vec3(0.0, 0.0, 1.0);
            purkinjeOverwrite = 0.0;
        }
    #endif

    #if SELECT_OUTLINE == 4 || defined NIGHT_DESATURATION
        if (materialMaskInt == 252) { // Selection Outline
            #if SELECT_OUTLINE == 4 // Versatile Selection Outline
                float colorMF = 1.0 - dot(color, vec3(0.25, 0.45, 0.1));
                colorMF = smoothstep1(smoothstep1(smoothstep1(smoothstep1(smoothstep1(colorMF)))));
                color = mix(color, 3.0 * (color + 0.2) * vec3(colorMF * SELECT_OUTLINE_I), 0.3);
            #endif
            purkinjeOverwrite = 0.0;
        }
    #endif

    #if LENSFLARE_MODE > 0 && defined OVERWORLD
        DoLensFlare(color, viewPos.xyz, dither);
    #endif

    DoBSLColorSaturation(color);

    #ifdef NIGHT_DESATURATION
        color.rgb = purkinjeShift(color.rgb, texture6, playerPos, lViewPos, purkinjeOverwrite, z0, texture5.r, VdotU);
    #endif

    /* DRAWBUFFERS:35 */
    gl_FragData[0] = vec4(color, 1.0);
    gl_FragData[1] = vec4(vec3(0), texture5.a);
}

#endif

//////////Vertex Shader//////////Vertex Shader//////////Vertex Shader//////////
#ifdef VERTEX_SHADER

noperspective out vec2 texCoord;

#if defined BLOOM_FOG || (LENSFLARE_MODE > 0 || defined AURORA_INFLUENCE) && defined OVERWORLD
    flat out vec3 upVec, sunVec;
#endif

//Attributes//

//Common Variables//

//Common Functions//

//Includes//

//Program//
void main() {
    gl_Position = ftransform();

    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

    #if defined BLOOM_FOG || LENSFLARE_MODE > 0 && defined OVERWORLD
        upVec = normalize(gbufferModelView[1].xyz);
        sunVec = GetSunVector();
    #endif
}

#endif

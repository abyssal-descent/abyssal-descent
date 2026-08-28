vec3 GetBedrockNoise(vec3 viewPos, float VdotU, float dither) {
    float eyeAltitude1 = eyeAltitude * 0.005;
    float visibility = clamp01(-VdotU * 1.875 - 0.225) * (1.0 - maxBlindnessDarkness);
    visibility *= 1.0 + VdotU * 0.75;
    
    float distanceAboveBedrock = bedrockLevel - eyeAltitude;
    
    float fadeStart = 180.0;
    float fadeWidth = 50.0;
    
    float noiseHeight = 2.0 / (1.0 + exp(-(fadeStart - distanceAboveBedrock) / fadeWidth));
    
    visibility *= -eyeAltitude1 * 3.0 + (bedrockLevel / 66.6) + 2.0;
    
    if (visibility >= 0.0) {
        vec3 wpos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
        wpos /= (abs(wpos.y) + length(wpos.xz) * 0.5);
        
        vec2 cameraPositionM = cameraPosition.xz * 0.0075;
        cameraPositionM.x += frameTimeCounter * 0.004;
        float VdotUM = 1.0 - VdotU * VdotU;
        
        // Star calculation
        vec2 starCoord = noiseHeight * wpos.xz * 0.2 + cameraPositionM * 0.1;
        starCoord = floor(starCoord * 1024.0) / 1024.0;
        
        float star = GetStarNoise(starCoord.xy) * 
                     GetStarNoise(starCoord.xy+0.1) * 
                     GetStarNoise(starCoord.xy+0.23);
        star = max0((star - 0.4) * 6.0);
        star *= star;
        
        vec3 stars = star * vec3(0.1765, 0.1569, 0.1804) * (VdotUM + 0.3);
        
        float wind = fract(frameTimeCounter * 0.0125);
        const int sampleCount = 1;
        const int sampleCountP = sampleCount + 5;
        float ditherM = dither + 5.0;
        
        vec3 spots = vec3(0.0);
        
        for (int i = 0; i < sampleCount; i++) {
            float current = pow2((i + ditherM) / sampleCountP);
            float currentM = 1.0 - current;
            
            vec2 planePos = wpos.xz * (0.5 + current) * noiseHeight;
            planePos = (planePos * 0.5 + cameraPositionM * 0.5) * 20.0;
            
            float noiseSpots = texture2D(noisetex, floor(planePos) * 0.1).g;
            vec3 noise = texture2D(noisetex, vec2(noiseSpots) + wind * 0.3).b * vec3(0.3);
            
            spots += noise * currentM * 6.0;
        }
        
        #ifdef OVERWORLD
            spots = (spots - 0.5) * 1.5 + 0.5; // contrast
        #else
            spots = (spots - 0.5) * 3.5 + 0.5; // contrast
        #endif
        
        spots += stars;
        
        float clampedNoiseHeight = clamp01(noiseHeight);
        return spots * visibility / sampleCount * clampedNoiseHeight + clampedNoiseHeight - 1.0;
    }
    
    return vec3(0.0);
}
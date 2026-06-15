#if !defined AURORA_BOREALIS_VISIBILITY_GLSL
#define AURORA_BOREALIS_VISIBILITY_GLSL

#define AURORA_CONDITION 3 //[-1 0 1 2 3 4]
#define RANDOM_AURORA 0 //[0 1 2 3 4 5 6 7 8 9]
#define AURORA_DRAW_DISTANCE 0.65 //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]

float GetAuroraVisibility(in float VdotU, float VdotUAmount) {
    float visibility = sqrt1(clamp01(mix(1.0, VdotU, VdotUAmount) * (AURORA_DRAW_DISTANCE * 1.125 + 0.75) - 0.225)) - sunVisibility - maxBlindnessDarkness;

    #ifdef CLEAR_SKY_WHEN_RAINING
        visibility -= rainFactorDynamic * 0.5;
    #else
        visibility -= rainFactorDynamic;
    #endif

    visibility *= 1.0 - VdotU * 0.9 * VdotUAmount;

    #if AURORA_CONDITION == 1 || AURORA_CONDITION == 3
        visibility -= moonPhase;
    #endif
    #if AURORA_CONDITION == 2 || AURORA_CONDITION == 3
        visibility *= inSnowy;
    #endif
    #if AURORA_CONDITION == 4
        visibility = max(visibility * inSnowy, visibility - moonPhase);
    #endif
    #if AURORA_CONDITION == -1 // Always except new moon
        visibility *= clamp01(max(moonPhase, 1) % 4);
    #endif

    #if RANDOM_AURORA > 0
        float randomValue = hash11(float(worldDay));
        if (randomValue > RANDOM_AURORA * 0.1) {
            visibility = -1.0; // Disable aurora this day
        }
    #endif

    return visibility;
}
#endif

// Shooting stars implementation based on https://www.shadertoy.com/view/ttVXDy and also based on https://github.com/OUdefie17/Photon-GAMS

#define SHOOTING_STARS_SIZE 0.50 //[0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75]
#define SHOOTING_STARS_SPEED 8.0 //[4.0 4.5 5.0 5.5 6.0 6.5 7.0 7.5 8.0 8.5 9.0 9.5 10.0 10.5 11.0 11.5 12.0 12.5 13.0 13.5 14.0 14.5 15.0]
#define SHOOTING_STARS_CHANCE 0.5 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define SHOOTING_STARS_COUNT 4 //[1 2 3 4 5 6 7 8 9 10]
#define SHOOTING_STARS_LINE_THICKNESS 0.60 //[0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00]
#define SHOOTING_STARS_TRAIL_LENGTH 0.60 //[0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85]

// Calculate distance from point p to line segment from a to b
float DistLine(vec2 p, vec2 a, vec2 b) {
    vec2 pa = p - a;
    vec2 ba = b - a;
    float t = clamp01(dot(pa, ba) / dot(ba, ba));
    return length(pa - ba * t);
}

// Draw a line with smooth edges
float DrawLine(vec2 p, vec2 a, vec2 b) {
    float d = DistLine(p, a, b);
    float m = smoothstep(SHOOTING_STARS_LINE_THICKNESS * 0.01, 0.00001, d);
    float d2 = length(a - b);
    m *= smoothstep(1.0, 0.5, d2) + smoothstep(0.04, 0.03, abs(d2 - 0.75));
    return m;
}

// Generate a single shooting star
float ShootingStar(vec2 uv, vec2 startPos, vec2 direction) {
    vec2 id = floor(uv * 0.5);
    float h = hash12(id);

    float newMoonVisibility = 1.0 - abs(moonPhase - 4) / 4.0;
    float moonPhaseFactor = mix(0.8, 1.5, newMoonVisibility);

    if (h >= pow1_5(SHOOTING_STARS_CHANCE * 0.065) * moonPhaseFactor) return 0.0;

    vec2 gv = fract(uv * 0.5) * 2.0 - 1.0;
    float line = DrawLine(gv, startPos, startPos + direction * 0.9);

    vec2 toStart = gv - startPos;
    float alongTrail = dot(toStart, direction);
    float trail = smoothstep(SHOOTING_STARS_TRAIL_LENGTH, -0.1, alongTrail);

    float headBrightness = 1.0 + 3.0 / (1.0 + pow2((alongTrail - 1.0) * 8.0));

    return line * trail * headBrightness;
}

vec3 GetShootingStars(vec2 starCoord, float VdotU, float VdotS) {
    float starsAroundSun = 1.0;
    #ifdef CELESTIAL_BOTH_HEMISPHERES
        float starBelowHorizonBrightness = 1.0;
        float horizonFactor = exp(-pow(VdotU / 0.1, 2.0));
        #ifdef SUN_MOON_HORIZON
            starsAroundSun = max0(sign(VdotU));
        #endif
    #else
        if (VdotU < 0.0) return vec3(0.0);
        float starBelowHorizonBrightness = min1(VdotU * 3.0);
        float horizonFactor = 0.0;
    #endif

    float visibility = max0(1.0 - 1.0 / (1.0 + abs(VdotS) * 1000.0) * starsAroundSun) * starBelowHorizonBrightness - horizonFactor * 0.5;

    #ifndef DAYLIGHT_STARS
        visibility *= pow2(pow2(invNoonFactor2)) * (1.0 - 0.5 * sunVisibility);
    #endif

    #ifdef CLEAR_SKY_WHEN_RAINING
        visibility *= min1(invRainFactorDynamic + 0.4);
    #else
        visibility *= invRainFactorDynamic;
    #endif

    if (visibility <= 0.01) return vec3(0.0);

    vec2 uv = starCoord * 6.0 * (1.0 - SHOOTING_STARS_SIZE);
    float speed = frameTimeCounter * SHOOTING_STARS_SPEED;

    vec2 startPositions[10] = vec2[](
        vec2(-0.4, 0.3),
        vec2(0.2, 0.4),
        vec2(-0.1, -0.3),
        vec2(0.3, -0.2),
        vec2(-0.3, 0.1),
        vec2(0.5, 0.2),
        vec2(-0.5, -0.1),
        vec2(0.1, 0.5),
        vec2(-0.2, -0.4),
        vec2(0.4, -0.3)
    );

    vec2 directions[10] = vec2[](
        vec2(0.7071, 0.7071),
        vec2(0.7071, -0.7071),
        vec2(-1.0, 0.0),
        vec2(1.0, 0.0),
        vec2(0.5299, 0.8480),
        vec2(-0.6000, 0.8000),
        vec2(0.9134, -0.4067),
        vec2(-0.8000, -0.6000),
        vec2(0.3015, 0.9535),
        vec2(-0.2000, -0.9798)
    );

    float stars = 0.0;
    int dayIndex = int(worldDay) % 10;
    vec2 todayDirection = directions[dayIndex];

    for (int i = 0; i < SHOOTING_STARS_COUNT; i++) {
        float offsetAngle = (hash12(vec2(i, worldDay)) - 0.5) * 0.66;
        vec2 starDirection = rotate(offsetAngle) * todayDirection;

        vec2 offsetUV = uv + starDirection * speed * (0.8 + 0.04 * float(i));
        stars += ShootingStar(offsetUV, startPositions[i], starDirection);
    }

    vec3 shootingStarColor = vec3(0.38, 0.4, 0.5) * 2.0 * starBrightness;
    float intensity = min(stars * visibility * 10.0, 1.0);
    return shootingStarColor * intensity;
}

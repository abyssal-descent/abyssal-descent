#include "/lib/shaderSettings/mainLighting.glsl"
#include "/lib/lighting/heldLighting.glsl"

float modify_handheld_pulse() {
    #if HAND_BLOCKLIGHT_FLICKERING > 0
        return getHeldLightFlicker();
    #endif
    return 1.0;
}

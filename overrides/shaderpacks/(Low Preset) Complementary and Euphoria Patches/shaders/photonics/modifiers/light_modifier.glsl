#include "/lib/common.glsl"
#include "/lib/shaderSettings/photonics.glsl"
#include "/lib/shaderSettings/materials.glsl"
#include "/lib/shaderSettings/mainLighting.glsl"

#if PHOTONICS_RESTIR_FLICKER_FIRE > 0 && PHOTONICS_LIGHTING_MODE == 2
    #define PHOTONICS_RESTIR_FLICKER_FIRE_INTERNAL PHOTONICS_RESTIR_FLICKER_FIRE
#else
    #define PHOTONICS_RESTIR_FLICKER_FIRE_INTERNAL 0
#endif

void modify_light(inout Light light, vec3 world_pos) {
    int mat = light.blockId;
    vec3 color = light.color;
    float intensity = 1.0;

    vec3 torchColor = vec3(1.0, 0.6627, 0.3569);
    vec3 fireColor = vec3(1.0, 0.4, 0.0);
    vec3 lavaColor = vec3(1.0, 0.35, 0.0);
    vec3 halfSoulColor = vec3(0.702, 0.7294, 0.6745);
    vec3 halfEndBreathColor = vec3(0.7843, 0.349, 0.3333);

    #if BLOCKLIGHT_FLICKERING > 0 || PHOTONICS_RESTIR_FLICKER_FIRE_INTERNAL > 0
        vec2 flickerNoiseBlock = texture2DLod(noisetex, vec2(frameTimeCounter * 0.09), 0.0).rb;
        float flickerIntensity = mix(1.0, min1(max(flickerNoiseBlock.r, flickerNoiseBlock.g) * 1.7), pow2(max(BLOCKLIGHT_FLICKERING, PHOTONICS_RESTIR_FLICKER_FIRE_INTERNAL) * 0.1));
        if (light.index < 0) flickerIntensity = 1.0; // Don't apply flickering to handHeld light since it already has its own flickering function in handheld_light_pulse_modifier.glsl
    #endif

    if (mat < 10516) {
        if (mat < 10452) {
            if (mat < 10396) {
                if (mat < 10072) { // No fire-related block
                    if (mat == 10068 || mat == 10070) { // Lava
                        color = lavaColor;
                        intensity = light.intensity;
                        #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                            color = mix(lavaColor, colorSoul, inSoulValley);
                        #elif defined PURPLE_END_FIRE_INTERNAL
                            color = colorEndBreath;
                        #endif
                    }
                } else {
                    if (mat == 10072) { // Fire
                        color = fireColor;
                        intensity = light.intensity;
                        #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                            color = mix(fireColor, halfSoulColor, inSoulValley);
                        #elif defined PURPLE_END_FIRE_INTERNAL
                            color = halfEndBreathColor;
                        #endif
                        #if PHOTONICS_RESTIR_FLICKER_FIRE_INTERNAL > 0
                            intensity *= flickerIntensity;
                        #endif
                    }
                    #if PHOTONICS_RESTIR_FLICKER_FIRE_INTERNAL > 0
                        else if (mat == 10076) { // Soul Fire
                            intensity = light.intensity;
                            intensity *= flickerIntensity;
                        }
                    #endif
                }
            } else {
                if (mat == 10396) { // Jack o'Lantern
                    color = torchColor;
                    intensity = light.intensity;
                    #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                        color = mix(torchColor, colorSoul, inSoulValley);
                    #elif defined PURPLE_END_FIRE_INTERNAL
                        color = colorEndBreath;
                    #endif
                    #if PHOTONICS_RESTIR_FLICKER_FIRE_INTERNAL > 0
                        intensity *= flickerIntensity;
                    #endif
                }
            }
        } else {
            if (mat < 10496) {
                if (mat == 10452) { // Magma Block
                    color = fireColor;
                    intensity = light.intensity;
                    #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                        color = mix(fireColor, colorSoul, inSoulValley);
                    #elif defined PURPLE_END_FIRE_INTERNAL
                        color = colorEndBreath;
                    #endif
                }
                #if defined NETHER && defined BIOME_COLORED_NETHER_PORTALS
                    else if (mat == 10476) { // Crying Obsidian
                        color = normalize(netherColor);
                        intensity = light.intensity;
                    }
                #endif
            } else {
                if (mat == 10496) { // Torch
                    color = torchColor;
                    intensity = light.intensity;
                    #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                        color = mix(torchColor, halfSoulColor, inSoulValley);
                    #elif defined PURPLE_END_FIRE_INTERNAL
                        color = halfEndBreathColor;
                    #endif
                    #if PHOTONICS_RESTIR_FLICKER_FIRE_INTERNAL > 0
                        intensity *= flickerIntensity;
                    #endif
                }
                else if (mat == 10500) { // End Rod
                    #if END_ROD_COLOR_PROFILE == 1
                        color = vec3(END_ROD_R, END_ROD_G, END_ROD_B) / 255 * END_ROD_I;
                    #elif (END_ROD_COLOR_PROFILE == 2 || (END_ROD_COLOR_PROFILE == 3 && defined OVERWORLD))
                        color = vec3(pow2(getRainbowColor(vec2(0.0), float(END_ROD_RAINBOW_ANIMATE))));
                    #else
                        #ifdef END
                            color = vec3(1.0, 0.4, 1.0); // End Rod in the End dimension
                        #else
                            color = vec3(0.9, 0.9, 0.95);
                        #endif
                    #endif
                    intensity = light.intensity;
                }
            }
        }
    } else {
        if (mat < 10652) {
            if (mat < 10576) {
                if (mat == 10516) { // Furnace
                    color = fireColor;
                    intensity = light.intensity;
                    #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                        color = mix(fireColor, colorSoul, inSoulValley);
                    #elif defined PURPLE_END_FIRE_INTERNAL
                        color = colorEndBreath;
                    #endif
                    #if PHOTONICS_RESTIR_FLICKER_FIRE_INTERNAL > 0
                        intensity *= flickerIntensity;
                    #endif
                }
                #if PHOTONICS_RESTIR_FLICKER_FIRE_INTERNAL > 0
                    else if (mat == 10528) { // Soul Torch
                        intensity = light.intensity;
                        intensity *= flickerIntensity;
                    }
                #endif
                else if (mat == 10560 || mat == 10562) { // Lantern
                    color = fireColor;
                    intensity = light.intensity;
                    #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                        color = mix(fireColor, halfSoulColor, inSoulValley);
                    #elif defined PURPLE_END_FIRE_INTERNAL
                        color = halfEndBreathColor;
                    #endif
                }
            } else {
                if (mat == 10576) { // Smoker
                    color = fireColor;
                    intensity = light.intensity;
                    #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                        color = mix(fireColor, colorSoul, inSoulValley);
                    #elif defined PURPLE_END_FIRE_INTERNAL
                        color = colorEndBreath;
                    #endif
                    #if PHOTONICS_RESTIR_FLICKER_FIRE_INTERNAL > 0
                        intensity *= flickerIntensity;
                    #endif
                }
                else if (mat == 10580) { // Blast Furnace
                    color = fireColor;
                    intensity = light.intensity;
                    #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                        color = mix(fireColor, colorSoul, inSoulValley);
                    #elif defined PURPLE_END_FIRE_INTERNAL
                        color = colorEndBreath;
                    #endif
                    #if PHOTONICS_RESTIR_FLICKER_FIRE_INTERNAL > 0
                        intensity *= flickerIntensity;
                    #endif
                }
                #if defined NETHER && defined BIOME_COLORED_NETHER_PORTALS
                    else if (mat == 10588) { // Respawn Anchor
                        color = normalize(netherColor);
                        intensity = light.intensity;

                    }
                    else if (mat == 10592) { // Respawn Anchor (charged)
                        color = normalize(netherColor);
                        intensity = light.intensity;
                    }
                #endif
            }
        } else {
            if (mat < 10836) {
                if (mat == 10652) { // Campfire
                    color = fireColor;
                    intensity = light.intensity;
                    #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                        color = mix(fireColor, halfSoulColor, inSoulValley);
                    #elif defined PURPLE_END_FIRE_INTERNAL
                        color = halfEndBreathColor;
                    #endif
                    #if PHOTONICS_RESTIR_FLICKER_FIRE_INTERNAL > 0
                        intensity *= flickerIntensity;
                    #endif
                }
                #if PHOTONICS_RESTIR_FLICKER_FIRE_INTERNAL > 0
                    else if (mat == 10656) { // Soul Campfire
                        intensity = light.intensity;
                        intensity *= flickerIntensity;
                    }
                #endif
            } else {
                if (mat == 10836) { // Brewing Stand
                    color = fireColor;
                    intensity = light.intensity;
                    #ifdef SOUL_SAND_VALLEY_OVERHAUL_INTERNAL
                        color = mix(fireColor, colorSoul, inSoulValley);
                    #elif defined PURPLE_END_FIRE_INTERNAL
                        color = colorEndBreath;
                    #endif
                }
                #if PHOTONICS_RESTIR_FLICKER_FIRE_INTERNAL > 0
                    else if (mat == 10984) { // Soul Fire
                        intensity = light.intensity;
                        intensity *= flickerIntensity;
                    }
                #endif
                #if defined NETHER && defined BIOME_COLORED_NETHER_PORTALS
                    else if (mat == 30020) { // Nether Portal
                        color = normalize(netherColor);
                        intensity = light.intensity;
                    }
                #endif
            }
        }
    }

    #if BLOCKLIGHT_FLICKERING > 0
        intensity *= flickerIntensity;
    #endif

    #ifdef RANDOM_BLOCKLIGHT
        float RandR = texture2DLod(noisetex, 0.00016 * RANDOM_BLOCKLIGHT_SIZE * world_pos.xz, 0.0).r * XLIGHT_R;
        float RandG = texture2DLod(noisetex, 0.00029 * RANDOM_BLOCKLIGHT_SIZE * world_pos.xz, 0.0).r * XLIGHT_G;
        float RandB = texture2DLod(noisetex, 0.00034 * RANDOM_BLOCKLIGHT_SIZE * world_pos.xz, 0.0).r * XLIGHT_B;
        color = vec3(RandR, RandG, RandB) * 0.875;
    #endif

    light.color = color * intensity;
}

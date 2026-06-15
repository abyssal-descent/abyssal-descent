//////////////////////////////////////////
// Complementary Shaders by EminGT      //
// With Euphoria Patches by SpacEagle17 //
//////////////////////////////////////////

//Common//
#include "/lib/common.glsl"
#include "/lib/shaderSettings/longExposure.glsl"

//////////Fragment Shader//////////Fragment Shader//////////Fragment Shader//////////
#ifdef FRAGMENT_SHADER

noperspective in vec2 texCoord;

//Pipeline Constants//
#include "/lib/pipelineSettings.glsl"

const bool colortex3MipmapEnabled = true;

//Common Variables//
vec2 view = vec2(viewWidth, viewHeight);

//Common Functions//
float GetLinearDepth(float depth) {
    return (2.0 * near) / (far + near - depth * (far - near));
}

//Includes//
#ifdef TAA
    #include "/lib/antialiasing/taa.glsl"
#endif

//Program//
void main() {
    vec3 color = texelFetch(colortex3, texelCoord, 0).rgb;
    vec4 texture2 = texture2D(colortex2, texCoord);

    vec3 temp = vec3(0.0);
    float z1 = 0.0;

    #ifdef RENKO_CUT
        temp.g = texelFetch(colortex2, texelCoord, 0).g;
    #else
        #if LONG_EXPOSURE > 0
        if (hideGUI == 0 || isViewMoving()) {
        #endif
            #ifdef TAA
                z1 = texelFetch(depthtex1, texelCoord, 0).r;
                DoTAA(color, temp, z1);
            #endif
        #if LONG_EXPOSURE > 0
        }

        if (hideGUI == 1 && !isViewMoving()) { // GUI not visible AND not moving
            temp = texture2.rgb;
        }
        #endif
    #endif

    /* DRAWBUFFERS:32 */
    gl_FragData[0] = vec4(color, 1.0);
    gl_FragData[1] = vec4(temp, 0.0);
}

#endif

//////////Vertex Shader//////////Vertex Shader//////////Vertex Shader//////////
#ifdef VERTEX_SHADER

noperspective out vec2 texCoord;

//Attributes//

//Common Variables//

//Common Functions//

//Includes//

//Program//
void main() {
    gl_Position = ftransform();

    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif

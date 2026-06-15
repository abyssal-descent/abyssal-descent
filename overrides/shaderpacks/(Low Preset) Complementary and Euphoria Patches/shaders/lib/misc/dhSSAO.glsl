// Improved SSAO function for Distant Horizons
float DoAmbientOcclusionDH(float z0_raw, float linearZ0_current_context, sampler2D depthTextureToSample, float dither_static_per_pixel, float emission) {
    float ao_accumulator = 0.0;
    int num_directions = 4;
    float scm = 0.8;

    float current_near_plane = dhNearPlane;
    float current_far_plane  = dhFarPlane;
    float current_far_minus_near = current_far_plane - current_near_plane;

    float sampleDepthLin_neighbor = 0.0;
    float fovScale = gbufferProjection[1][1];

    float viewSpaceZ0 = linearZ0_current_context * current_far_plane;
    float distScale = max(viewSpaceZ0, 1.0);

    vec2 overall_scale = (vec2(scm / aspectRatio, scm) * fovScale / distScale);

    float goldenAngle = 2.399963229728653f;
    float baseAngleOffset = dither_static_per_pixel * 6.28318530718f;

    for (int i = 0; i < num_directions; i++) {
        float norm_i = (float(i) + dither_static_per_pixel) / float(num_directions);
        vec2 sample_kernel_offset = OffsetDistImproved(norm_i, num_directions);
        vec2 offset_unrotated = sample_kernel_offset * overall_scale;

        float per_sample_static_rotation = float(i) * goldenAngle * 0.1f;
        float total_static_rotation = baseAngleOffset + per_sample_static_rotation;

        mat2 rotationMatrix = mat2(cos(total_static_rotation), -sin(total_static_rotation),
                                    sin(total_static_rotation), cos(total_static_rotation));

        vec2 final_offset = rotationMatrix * offset_unrotated;

        vec2 coord1 = texCoord + final_offset;
        vec2 coord2 = texCoord - final_offset;

        float local_angle_contrib = 0.0;
        float local_dist_contrib = 0.0;

        sampleDepthLin_neighbor = CalculateLinearDepth(texture2D(depthTextureToSample, coord1).r, current_near_plane, current_far_plane);
        float aosample1 = current_far_minus_near * (linearZ0_current_context - sampleDepthLin_neighbor) * 0.9;
        local_angle_contrib += clamp(0.5 - aosample1, 0.0, 1.0);
        local_dist_contrib  += clamp(0.25 * aosample1 - 0.5, 0.0, 1.0);

        sampleDepthLin_neighbor = CalculateLinearDepth(texture2D(depthTextureToSample, coord2).r, current_near_plane, current_far_plane);
        float aosample2 = current_far_minus_near * (linearZ0_current_context - sampleDepthLin_neighbor) * 0.9;
        local_angle_contrib += clamp(0.5 - aosample2, 0.0, 1.0);
        local_dist_contrib  += clamp(0.25 * aosample2 - 0.5, 0.0, 1.0);

        ao_accumulator += clamp(local_angle_contrib + local_dist_contrib, 0.0, 1.0);
    }

    float normalized_ao = ao_accumulator / float(num_directions);
    float smoothstepUpperEdge = 1.0f;
    float shaped_ao = smoothstep(0.0, smoothstepUpperEdge, normalized_ao);

    float ssaoFactorOriginal = 0.075f; // DH-specific factor
    float result_exponent = clamp(SSAO_I * ssaoFactorOriginal * (1.0 - emission), 0.0001, 3.0);

    float powered_ao = pow(max(shaped_ao, 0.0001), result_exponent);

    float base_min_occlusion = 0.5;
    float distance_fade_end = 0.3;

    // Calculate dynamic minimum occlusion that decreases with distance
    float dynamic_min_occlusion = base_min_occlusion * (1.0 - smoothstep(0.0, distance_fade_end, linearZ0_current_context));

    return mix(dynamic_min_occlusion, powered_ao, powered_ao);
}

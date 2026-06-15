const ivec3 leaves_voxelVolumeSize = ivec3(128);

vec3 SceneToLeavesVoxel(vec3 scenePos) {
	return scenePos + fract(cameraPosition) + 0.5 * vec3(leaves_voxelVolumeSize);
}

bool CheckInsideLeavesVoxelVolume(vec3 voxelPos) {
    #ifndef SHADOW
        voxelPos -= leaves_voxelVolumeSize / 2;
        voxelPos += sign(voxelPos) * 0.95;
        voxelPos += leaves_voxelVolumeSize / 2;
    #endif
    voxelPos /= vec3(leaves_voxelVolumeSize);
	return clamp01(voxelPos) == voxelPos;
}

#if defined SHADOW && defined VERTEX_SHADER
    void UpdateLeavesVoxelMap(int mat) {
        if (renderStage == MC_RENDER_STAGE_ENTITIES)
            return;
        
        vec3 model_pos = gl_Vertex.xyz + at_midBlock.xyz / 64.0;
        vec3 view_pos  = mat3(gl_ModelViewMatrix) * model_pos + gl_ModelViewMatrix[3].xyz;
        vec3 scenePos = mat3(shadowModelViewInverse) * view_pos + shadowModelViewInverse[3].xyz;
        vec3 voxelPos = SceneToLeavesVoxel(scenePos);

        if (CheckInsideLeavesVoxelVolume(voxelPos))
            imageStore(leaves_img, ivec3(voxelPos), uvec4(mat == 10009 ? 2u : 1u, 0u, 0u, 0u));
    }
#endif
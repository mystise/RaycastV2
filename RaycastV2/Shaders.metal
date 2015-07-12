//
//  Shaders.metal
//  RaycastV2
//
//  Created by Adalynn Dudney on 7/10/15.
//  Copyright © 2015 Adalynn Dudney. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

vertex VertexOut vertexTransform(uint vid [[ vertex_id ]], constant packed_float4* position [[ buffer(0) ]]) {
    VertexOut outVertex;
    
    outVertex.position = position[vid];
    outVertex.texCoord = float2(clamp(position[vid][0], 0.0, 1.0), clamp(position[vid][1], 0.0, 1.0));
    
    return outVertex;
};

fragment half4 bgFragment(VertexOut inFrag [[ stage_in ]]) {
    if(inFrag.texCoord.y < 0.5) {
        return half4(float(0xCC) / 255.0, float(0xCC) / 255.0, float(0xCC) / 255.0, 1.0);
    }
    return half4(float(0x2D) / 255.0, float(0x48) / 255.0, float(0x92) / 255.0, 1.0);
    //return half4(inFrag.position.x/1024.0, inFrag.position.y/768.0, 0.0, 1.0);
};

fragment half4 fragmentTransform(VertexOut inFrag [[ stage_in ]], texture2d<half> tex2D [[ texture(0) ]]) {
    constexpr sampler quadSampler;
    return tex2D.sample(quadSampler, inFrag.texCoord);
};

struct Billboard {
    half2 position;
    float radius;
    uint tex_index;
};

struct Player {
    half2 pos;
    half fov;
    half rot;
};

struct RaycastUniforms {
    Player player;
    uint billboardCount;
};

kernel void raycast(texture2d<uint, access::read> wallPositionTexture [[ texture(0) ]],
                    texture2d<half, access::read> wallTexture [[ texture(1) ]],
                    constant RaycastUniforms *uniforms [[ buffer(0) ]],
                    texture2d_array<half, access::read> billboardTextures [[ texture(2) ]],
                    constant Billboard *billboards [[ buffer(1) ]],
                    uint gid [[ thread_position_in_grid ]],
                    texture2d<half, access::write> outTexture [[ texture(3) ]]) {
    for (uint i = 0; i < outTexture.get_height(); i++) {
        half4 color;
        if(i < outTexture.get_height() / 2) {
            color = half4(float(0xCC) / 255.0, float(0xCC) / 255.0, float(0xCC) / 255.0, 1.0);
        } else {
            color = half4(float(0x2D) / 255.0, float(0x48) / 255.0, float(0x92) / 255.0, 1.0);
        }
        outTexture.write(color, uint2(gid, i));
    }
    if (gid % 8 == 0) {
        for (uint i = gid / 5; i < outTexture.get_height() - gid / 5; i++) {
            outTexture.write(half4(1.0, 0.0, 1.0, 1.0), uint2(gid, i));
        }
    }
}
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
    float2 pos;
    float fov;
    float rot;
};

kernel void raycast(texture2d<half, access::read> wallPositionTexture [[ texture(0) ]],
                    texture2d<half, access::read> wallTexture [[ texture(1) ]],
                    
                    constant Player *player [[ buffer(0) ]],
                    
                    constant Billboard *billboards [[ buffer(1) ]],
                    constant uint *billboardCount [[ buffer(2) ]], //Single Uint, has to be a pointer to be a buffer
                    texture2d_array<half, access::read> billboardTextures [[ texture(2) ]],
                    
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
    float totalDistance = -1.0;
    float2 position = player->pos;
    int2 iposition = int2(position.x, position.y);
    float playerRot = player->rot - player->fov * float(gid) / float(outTexture.get_width() - 1);
    float2 rayDir = float2(cos(playerRot), sin(playerRot));
    int2 displacement = int2(rayDir.x > 0 ? 1 : -1, rayDir.y > 0 ? 1 : -1);
    
    while (iposition.x < int(outTexture.get_width()) && iposition.y < int(outTexture.get_height()) && iposition.x >= 0 && iposition.y >= 0) {
        half4 value = wallPositionTexture.read(uint2(iposition));
        if (value.r == 1.0) {
            totalDistance = distance_squared(float2(iposition), position);
            break;
        }
        iposition += displacement;
    }
    
    float scale = outTexture.get_height() / 2 / 50.0;
    if (totalDistance >= 0.0) {
        for (uint i = totalDistance * scale; i < outTexture.get_height() - totalDistance * scale; i++) {
            outTexture.write(half4(1.0, 0.0, 1.0, 1.0), uint2(gid, i));
        }
    }
    
    //march until collide
    //Render wall
    //march backwards until entity collide
    //render entity
    /*if (gid % 8 == 0) {
        for (uint i = gid / 5; i < outTexture.get_height() - gid / 5; i++) {
            outTexture.write(half4(1.0, 0.0, 1.0, 1.0), uint2(gid, i));
        }
    }*/
}
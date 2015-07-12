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
    
    float rayRot = player->rot - player->fov * (float(gid)/float(outTexture.get_width() - 1) - 0.5);
    float2 rayVec = float2(cos(rayRot), sin(rayRot));
    
    float distance = -1.0;
    
    float2 pos = player->pos;
    uint2 ipos = uint2(pos);
    
    while (pos.x < outTexture.get_width() && pos.y < outTexture.get_height() && pos.x >= 0.0 && pos.y >= 0.0) {
        half4 color = wallPositionTexture.read(ipos);
        if (color.r > 0.8) {
            float2 dist = player->pos - pos;
            
            distance = sqrt(length(player->pos - pos)); //abs(dist.x) + abs(dist.y); //Need slower falloff, perhaps sqrt again? Or x + y distance
            break;
        }
        
        float dx = (pos.x - ipos.x);
        if (rayVec.x > 0.0) {
            dx = 1.0 - dx;
        } else if (rayVec.x < 0.0) {
            dx = -dx;
        }
        if (rayVec.x != 0.0) {
            dx /= rayVec.x;
        } else {
            dx = 100.0;
        }
        
        float dy = (pos.y - ipos.y);
        if (rayVec.y > 0.0) {
            dy = 1.0 - dy;
        } else if (rayVec.y < 0.0) {
            dy = -dy;
        }
        if (rayVec.y != 0.0) {
            dy /= rayVec.y;
        } else {
            dy = 100.0;
        }
        
        if (dx < dy) {
            pos += rayVec * dx;
            //ipos = uint2(pos);
            if (rayVec.x > 0.0) {
                ipos.x += 1;
            } else if (rayVec.x < 0.0) {
                ipos.x -= 1;
            }
        } else if (dy < dx) {
            pos += rayVec * dy;
            //ipos = uint2(pos);
            if (rayVec.y > 0.0) {
                ipos.y += 1;
            } else if (rayVec.y < 0.0) {
                ipos.y -= 1;
            }
        } else {
            pos += rayVec * dx;
            //ipos = uint2(pos);
            if (rayVec.x > 0.0) {
                ipos.x += 1;
            } else if (rayVec.x < 0.0) {
                ipos.x -= 1;
            }
            if (rayVec.y > 0.0) {
                ipos.y += 1;
            } else if (rayVec.y < 0.0) {
                ipos.y -= 1;
            }
        }
    }
    
    float scale = 1.0;
    
    for (uint i = distance*scale; i < outTexture.get_height() - distance*scale; i++) {
        outTexture.write(half4(1.0, 0.0, 0.0, 1.0), uint2(gid, i)); //TODO: Sample texture.
    }
    /*if (length(pos - float2(ipos)) > 1.0 || flag) {
        for (uint i = 0; i < outTexture.get_height(); i++) {
            outTexture.write(half4(1.0, 0.0, 0.0, 1.0), uint2(gid, i));
        }
    }*/
    
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
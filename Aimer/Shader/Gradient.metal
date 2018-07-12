//
//  Gradient.metal
//  Venus
//
//  Created by Theresa on 2017/11/24.
//  Copyright © 2017年 Carolar. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

typedef struct {
    float4 renderedCoordinate [[position]];
    float2 leftTop;
    float2 top;
    float2 rightTop;
    float2 left;
    float2 right;
    float2 leftBottom;
    float2 bottom;
    float2 rightBottom;
} GradientMappingVertex;

vertex GradientMappingVertex gradientVertex(unsigned int vertex_id [[ vertex_id ]],
                                            const device float *size [[ buffer(0) ]]) {
    const float width    = 1.0 / size[0];
    const float height   = 1.0 / size[1];
    const float2 wStep   = float2(width, 0);
    const float2 hStep   = float2(0, height);
    const float2 whStep  = float2(width, height);
    const float2 wnhStep = float2(width, -height);
    
    float4x4 renderedCoordinates = float4x4(float4( -1.0, -1.0, 0.0, 1.0 ),
                                            float4(  1.0, -1.0, 0.0, 1.0 ),
                                            float4( -1.0,  1.0, 0.0, 1.0 ),
                                            float4(  1.0,  1.0, 0.0, 1.0 ));
    
    float4x2 textureCoordinates = float4x2(float2( 0.0, 1.0 ),
                                           float2( 1.0, 1.0 ),
                                           float2( 0.0, 0.0 ),
                                           float2( 1.0, 0.0 ));
    GradientMappingVertex outVertex;
    outVertex.renderedCoordinate = renderedCoordinates[vertex_id];

    outVertex.leftTop     = textureCoordinates[vertex_id] - wnhStep;
    outVertex.top         = textureCoordinates[vertex_id] + hStep;
    outVertex.rightTop    = textureCoordinates[vertex_id] + whStep;
    outVertex.left        = textureCoordinates[vertex_id] - wStep;
    outVertex.right       = textureCoordinates[vertex_id] + wStep;
    outVertex.leftBottom  = textureCoordinates[vertex_id] - whStep;
    outVertex.bottom      = textureCoordinates[vertex_id] - hStep;
    outVertex.rightBottom = textureCoordinates[vertex_id] + wnhStep;
    
    return outVertex;
}

fragment half4 gradientFragment(GradientMappingVertex mappingVertex [[ stage_in ]],
                                texture2d<float, access::sample> texture [[ texture(0) ]]) {
    constexpr sampler s(address::clamp_to_edge, filter::linear);
    
    half4 s0 = half4(texture.sample(s, mappingVertex.leftTop));
    half4 s1 = half4(texture.sample(s, mappingVertex.top));
    half4 s2 = half4(texture.sample(s, mappingVertex.rightTop));
    half4 s3 = half4(texture.sample(s, mappingVertex.left));
    half4 s5 = half4(texture.sample(s, mappingVertex.right));
    half4 s6 = half4(texture.sample(s, mappingVertex.leftBottom));
    half4 s7 = half4(texture.sample(s, mappingVertex.bottom));
    half4 s8 = half4(texture.sample(s, mappingVertex.rightBottom));
    
    half4 sh = s2 + 2.0 * s5 + s8 - (s1 + 2.0 * s3 + s6);
    half4 sw = -(s0 + 2.0 * s1 + s2) + s6 + 2.0 * s7 + s8;
    half4 sobel = sqrt(sh * sh + sw * sw);
    
    return half4(sobel.rgb, 1);
}

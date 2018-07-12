//
//  Grayscale.metal
//  Venus
//
//  Created by Theresa on 2017/11/23.
//  Copyright © 2017年 Carolar. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

typedef struct {
    float4 renderedCoordinate [[position]];
    float2 textureCoordinate;
} GrayscaleMappingVertex;

vertex GrayscaleMappingVertex grayscaleVertex(unsigned int vertex_id [[ vertex_id ]]) {
    float4x4 renderedCoordinates = float4x4(float4( -1.0, -1.0, 0.0, 1.0 ),
                                            float4(  1.0, -1.0, 0.0, 1.0 ),
                                            float4( -1.0,  1.0, 0.0, 1.0 ),
                                            float4(  1.0,  1.0, 0.0, 1.0 ));
    
    float4x2 textureCoordinates = float4x2(float2( 0.0, 1.0 ),
                                           float2( 1.0, 1.0 ),
                                           float2( 0.0, 0.0 ),
                                           float2( 1.0, 0.0 ));
    GrayscaleMappingVertex outVertex;
    outVertex.renderedCoordinate = renderedCoordinates[vertex_id];
    outVertex.textureCoordinate = textureCoordinates[vertex_id];
    
    return outVertex;
}

fragment half4 grayscaleFragment(GrayscaleMappingVertex mappingVertex [[ stage_in ]],
                                 texture2d<float, access::sample> texture [[ texture(0) ]]) {
    constexpr sampler s(address::clamp_to_edge, filter::linear);
    
    const half3 coe = half3(0.299, 0.587, 0.114);
    half4 sam = half4(texture.sample(s, mappingVertex.textureCoordinate));
    float gary = dot(coe, sam.rgb);
    
    return half4(gary, gary, gary, 1);
}

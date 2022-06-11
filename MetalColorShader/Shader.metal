//
//  Shader.metal
//  MetalColorShader
//
//  Created by ミズキ on 2022/06/11.
//

#include <metal_stdlib>
using namespace metal;

// 構造体　[[]]->属性修飾子
struct ColorInOut {
    float4 position [[ position ]];
};
/// buffer(n)は Swift側から渡されるので実装は絶対に必要。constant(read-only)は参照型,ポインタで渡される。deviceという修飾子もあって、それは
// 読み出し、書き出しできる.
vertex ColorInOut vertexShader(constant float4 *positions [[ buffer(0) ]],
                               uint vid [[vertex_id]]) {
    // ColorInout構造体の
    ColorInOut out;
    // vidを設定することによって頂点一つ一つにアクセスできる。vidにはuint型の頂点インデックスが入っている。
    out.position = positions[vid];
    return out;
}

// フラグメントShader stage_inにはラスタライズされたフラグメントデータが入ってくる。ラスタ形式以外のデータが入ってきた時にラスタ形式にしてくれること。->　ディスプレイに1ピクセル分を描画するために用いられる構造体。
fragment float4 fragmentShader(ColorInOut in [[ stage_in ]]) {
    // (r,g,b,a)
    return float4(1,0,0,1);
}

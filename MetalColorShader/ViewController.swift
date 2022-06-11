//
//  ViewController.swift
//  MetalColorShader
//
//  Created by ミズキ on 2022/06/11.
//

import UIKit
import MetalKit
class ViewController: UIViewController, MTKViewDelegate {
    
    

    @IBOutlet private weak var mtkView: MTKView!
    private let device = MTLCreateSystemDefaultDevice()!
    private var commandQueue: MTLCommandQueue!
    private var vertexBuffer: MTLBuffer!
    // 再利用可能だから一度だけ生成しておけば何回でも使える。ここにセットしておく。
    // もしくはMTKViewのcurrentpassde,,,,,で取れる。エンコーダーの設定をしてくれるやつ
    private let renderPassDescriptor = MTLRenderPassDescriptor()
    private var renderPipeline: MTLRenderPipelineState!
    
    private let vertext: [Float] = [
        -1, -1, 0, 1,
         1, -1, 0, 1,
         -1, 1, 0, 1,
          1, 1, 0, 1
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupMetal()
        makeBuffers()
        makePipeLine()
        mtkView.enableSetNeedsDisplay = true
        mtkView.setNeedsDisplay()
    }

    private func setupMetal() {
        commandQueue = device.makeCommandQueue()
        
        mtkView.device = device
        mtkView.delegate = self
    }
    
    private func makeBuffers() {
        let size = vertext.count * MemoryLayout<Float>.size
        vertexBuffer = device.makeBuffer(bytes: vertext, length: size)
    }
    
    private func makePipeLine() {
        // Metalファイルを取ってくる
        guard let library = device.makeDefaultLibrary() else { fatalError() }
        // パイプラインを生成するためのもの
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = library.makeFunction(name: "vertexShader")
        descriptor.fragmentFunction = library.makeFunction(name: "fragmentShader")
        // ピクセルフォーマットは設定する。レンダリング先のカラー設定をするので必ず必要。
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        // descriptorはパイプラインの設定をするものなので引数に設定する.(生成コストが高いので使いまわして欲しいらしい？）
        renderPipeline = try! device.makeRenderPipelineState(descriptor: descriptor)
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print("\(self.classForCoder)", #function)
    }
    
    func draw(in view: MTKView) {
        // drawableドローアブルを取得-> mtkviewに描画するリソースを取ってくる
        guard let drawable = view.currentDrawable else { return }
        // コマンドキューからコマンドバッファを生成する
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { fatalError() }
       
        // renderPassDescriptorはcolorアタッチメント配列を持っており、グラフィックスレンダリングにより生成されるピクセルデータの色値の出力先を記述する。
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        
        // パイプラインからバッファを生成するためのrenderEncoderを生成する
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        // パイプライン(描画するための一連の処理）
        guard let renderPipeline = renderPipeline else { fatalError() }
        // レンダーエンコーダーにsetPipeLineで設定したパイプラインをセットする
        renderEncoder.setRenderPipelineState(renderPipeline)
        //
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        //
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        // エンコード終わり
        renderEncoder.endEncoding()
        // drawableのセット
        commandBuffer.present(drawable)
        // commandBufferをGPUへコミットする
        commandBuffer.commit()
        // 完了まで待つ
        commandBuffer.waitUntilCompleted()
        
    }
    

}


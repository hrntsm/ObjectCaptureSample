//
//  main.swift
//  ObjectCaptureSample
//
//  Created by hrntsm on 2021/12/02.
//

import Foundation
import os
import RealityKit
import Metal

// 入出力の設定
let inputFolder = "ここにインプットする画像のフォルダのパスを入れる"
let outputFilename = "ここに作成したファイルの出力先を入れる（拡張子は .usdz）"

// Session の設定作成
let inputFolderUrl = URL(fileURLWithPath: inputFolder, isDirectory: true)
var configure = PhotogrammetrySession.Configuration()
configure.sampleOrdering = PhotogrammetrySession.Configuration.SampleOrdering.unordered
configure.featureSensitivity =
    PhotogrammetrySession.Configuration.FeatureSensitivity.normal

let session = try PhotogrammetrySession(
    input: inputFolderUrl,
    configuration: configure
)

// 動作実行時の状態出力の設定作成
let waiter = Task {
    do {
        for try await output in session.outputs {
            switch output {
                case .processingComplete:
                    print("complete!!")
                    Foundation.exit(0)
            @unknown default:
                print("Output: unhandled message")
            }
        }
    } catch {
        print("Output: ERROR")
        Foundation.exit(1)
    }
}

// 処理の実行
withExtendedLifetime((session, waiter)) {
    do {
        let request = makeRequestFromArguments()
        print("Using request: \(String(describing: request))")
        try session.process(requests: [ request ])
        RunLoop.main.run()
    } catch {
        print("Process got error: \(String(describing: error))")
        Foundation.exit(1)
    }
}

// 完成したファイルの出力先とファイル作成の詳細度を設定
private func makeRequestFromArguments() -> PhotogrammetrySession.Request {
    let outputUrl = URL(fileURLWithPath: outputFilename)
    
    return PhotogrammetrySession.Request.modelFile(
        url: outputUrl,
        detail: PhotogrammetrySession.Request.Detail.preview)
}

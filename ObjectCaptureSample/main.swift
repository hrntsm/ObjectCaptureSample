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

run()

func run() {
    let inputFolder = "/Users/hrntsm/Desktop/FruitCakeSlice"
    
    let inputFolderUrl = URL(fileURLWithPath: inputFolder, isDirectory: true)
    var configure = PhotogrammetrySession.Configuration()
    configure.sampleOrdering = PhotogrammetrySession.Configuration.SampleOrdering.unordered
    configure.featureSensitivity =
        PhotogrammetrySession.Configuration.FeatureSensitivity.normal
    
    var maybeSession: PhotogrammetrySession? = nil
    do {
        maybeSession = try PhotogrammetrySession(
            input: inputFolderUrl,
            configuration: configure
        )
    } catch {
        Foundation.exit(1)
    }
    
    guard let session = maybeSession else {
        Foundation.exit(1)
    }
    
    let waiter = Task {
        do {
            for try await output in session.outputs {
                switch output {
                    case .processingComplete:
                        print("complete")
                        Foundation.exit(0)
                    case .requestError(let request, let error):
                        print("Request \(String(describing: request)) had an error: \(String(describing: error))")
                @unknown default:
                    print("Output: unhandled message")
                }
            }
        } catch {
            print("Output: ERROR")
            Foundation.exit(1)
        }
    }
    
    // The compiler may deinitialize these objects since they may appear to be
    // unused. This keeps them from being deallocated until they exit.
    withExtendedLifetime((session, waiter)) {
        // Run the main process call on the request, then enter the main run
        // loop until you get the published completion event or error.
        do {
            let request = makeRequestFromArguments()
            print("Using request: \(String(describing: request))")
            try session.process(requests: [ request ])
            // Enter the infinite loop dispatcher used to process asynchronous
            // blocks on the main queue. You explicitly exit above to stop the loop.
            RunLoop.main.run()
        } catch {
            print("Process got error: \(String(describing: error))")
            Foundation.exit(1)
        }
    }
}

private func makeRequestFromArguments() -> PhotogrammetrySession.Request {
    let outputFilename = "/Users/hrntsm/Desktop/item.usdz"
    let outputUrl = URL(fileURLWithPath: outputFilename)
    
    return PhotogrammetrySession.Request.modelFile(
        url: outputUrl,
        detail: PhotogrammetrySession.Request.Detail.preview)
}

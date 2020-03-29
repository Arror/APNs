//
//  Executor.swift
//  APNs-NG
//
//  Created by 马强 on 2020/3/28.
//  Copyright © 2020 Arror. All rights reserved.
//

import Foundation

public struct Executor {
    
    public let directoryPath: String
    
    public init(directoryPath: String = FileManager.default.currentDirectoryPath) {
        self.directoryPath = directoryPath
    }
    
    @discardableResult
    public func execute(_ arguments: String...) throws -> Data {
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.currentDirectoryPath = self.directoryPath
        var environment = ProcessInfo.processInfo.environment
        environment["PATH"] = "/usr/bin:/bin:/usr/sbin:/sbin"
        process.environment = environment
        process.arguments = arguments
        let output = Pipe()
        process.standardOutput = output
        let error = Pipe()
        process.standardError = error
        process.launch()
        let outputData = output.fileHandleForReading.readDataToEndOfFile()
        try output.fileHandleForReading.close()
        let errorData = error.fileHandleForReading.readDataToEndOfFile()
        try error.fileHandleForReading.close()
        process.waitUntilExit()
        switch process.terminationStatus {
        case 0:
            return outputData
        default:
            let message = String(data: errorData, encoding: .utf8) ?? "Unknown error."
            throw NSError(domain: "Executor", code: -1, userInfo: [NSLocalizedDescriptionKey: message])
        }
    }
}

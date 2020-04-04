//
//  Executor.swift
//  APNs-NG
//
//  Created by 马强 on 2020/3/28.
//  Copyright © 2020 Arror. All rights reserved.
//

import Foundation
import Combine

public struct Executor {
    
    public struct Error: CustomNSError {
        
        public static let errorDomain: String = "com.Arror.APNs.Executor"
        
        public let errorCode: Int
        public let errorUserInfo: [String : Any]
        
        public init(errorCode: Int, errorMessage: String) {
            self.errorCode = errorCode
            self.errorUserInfo = [NSLocalizedDescriptionKey: errorMessage]
        }
    }
    
    public let directoryPath: String
    
    public init(directoryPath: String = FileManager.default.currentDirectoryPath) {
        self.directoryPath = directoryPath
    }
    
    @discardableResult
    public func execute(_ arguments: String...) throws -> Data {
        return try self.execute(arguments)
    }
    
    @discardableResult
    public func execute(_ arguments: [String]) throws -> Data {
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
            throw Executor.Error(errorCode: 0, errorMessage: String(data: errorData, encoding: .utf8) ?? "Uncaught signal")
        }
    }
}

extension Executor {
    
    @discardableResult
    public static func execute(_ arguments: [String]) throws -> Data {
        return try Executor().execute(arguments)
    }
    
    @discardableResult
    public static func execute(_ arguments: String...) throws -> Data {
        return try Executor.execute(arguments)
    }
    
    public static func execute(_ arguments: [String], completion: @escaping (Result<Data, Swift.Error>) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                let data = try Executor.execute(arguments)
                DispatchQueue.main.async { completion(.success(data)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }
}

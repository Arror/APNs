//
//  SimulatorAPNsProvider.swift
//  APNs-NG
//
//  Created by 马强 on 2020/3/29.
//  Copyright © 2020 Arror. All rights reserved.
//

import Foundation

public final class SimulatorAPNsProvider: APNsProvider {
    
    public let bundleID: String
    public let device: APNsDevice
    
    public init(device: APNsDevice, bundleID: String) {
        self.bundleID = bundleID
        self.device = device
    }
    
    public func send(payload: String, token: String, priorty: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            guard !self.bundleID.isEmpty else {
                throw NSError.makeMessageError(message: "套装为空，请填写套装")
            }
            guard let payloadData = payload.data(using: .utf8) else {
                throw NSError.makeMessageError(message: "负载存在问题，请检查负载格式")
            }
            guard let object = try? JSONSerialization.jsonObject(with: payloadData, options: []), JSONSerialization.isValidJSONObject(object) else {
                throw NSError.makeMessageError(message: "负载存在问题，请检查负载格式")
            }
            guard let content = String(data: payloadData, encoding: .utf8) else {
                throw NSError.makeMessageError(message: "负载存在问题，请检查负载格式")
            }
            let path = "\(NSTemporaryDirectory())\(UUID().uuidString).json"
            try content.write(toFile: path, atomically: true, encoding: .utf8)
            let executor = Executor()
            try executor.execute("xcrun", "simctl", "push", self.device.udid, self.bundleID, path)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
}

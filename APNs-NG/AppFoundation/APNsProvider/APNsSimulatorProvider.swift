//
//  SimulatorAPNsProvider.swift
//  APNs-NG
//
//  Created by 马强 on 2020/3/29.
//  Copyright © 2020 Arror. All rights reserved.
//

import Foundation

public final class APNsSimulatorProvider: APNsProvider {
    
    public let bundleID: String
    public let simulator: SimulatorController.Simulator
    
    public init(simulator: SimulatorController.Simulator, bundleID: String) {
        self.bundleID = bundleID
        self.simulator = simulator
    }
    
    public func send(payload: String, token: String, priorty: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            guard !self.bundleID.isEmpty else {
                throw APNsError.bundleIDEmpty
            }
            guard
                let payloadData = payload.data(using: .utf8),
                let object = try? JSONSerialization.jsonObject(with: payloadData, options: []), JSONSerialization.isValidJSONObject(object),
                let content = String(data: payloadData, encoding: .utf8) else {
                    throw APNsError.invalidatePayload
            }
            DispatchQueue.global().async {
                do {
                    let path = "\(NSTemporaryDirectory())\(UUID().uuidString).json"
                    try content.write(toFile: path, atomically: true, encoding: .utf8)
                    let executor = Executor()
                    try executor.execute("xcrun", "simctl", "push", self.simulator.device.udid, self.bundleID, path)
                    DispatchQueue.main.async {
                        completion(.success(()))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
}

//
//  APNsProviderBase.swift
//  APNs-NG
//
//  Created by 马强 on 2020/3/29.
//  Copyright © 2020 Arror. All rights reserved.
//

import Foundation

open class APNsProviderBase: APNsProvider {
    
    open var session: URLSession { fatalError() }
    
    public init() {}
    
    open var authorization: String? {
        return nil
    }
    
    public final func send(payload: String, token: String, priorty: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            guard !AppService.current.bundleIDObject.value.isEmpty else {
                throw APNsError.bundleIDEmpty
            }
            guard !token.isEmpty else {
                throw APNsError.tokenEmpty
            }
            guard
                let payloadData = payload.data(using: .utf8),
                let object = try? JSONSerialization.jsonObject(with: payloadData, options: []), JSONSerialization.isValidJSONObject(object),
                let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
                    throw APNsError.invalidatePayload
            }
            let request: URLRequest = {
                let url: URL = {
                    let base: URL
                    switch AppService.current.environmentObject.value {
                    case .production:
                        base = URL(string: "https://api.push.apple.com")!
                    case .sandbox:
                        base = URL(string: "https://api.development.push.apple.com")!
                    }
                    return base.appendingPathComponent("3/device/\(token)")
                }()
                var req = URLRequest(url: url)
                req.httpMethod = "POST"
                req.httpBody = data
                var reval = req.allHTTPHeaderFields ?? [:]
                reval["authorization"] = self.authorization.flatMap { "bearer \($0)" }
                reval["apns-id"] = UUID().uuidString
                reval["apns-expiration"] = "0"
                reval["apns-priority"] = "\(AppService.current.priorityObject.value)"
                reval["apns-topic"] = AppService.current.bundleIDObject.value
                req.allHTTPHeaderFields = reval
                return req
            }()
            let task = self.session.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    switch APNsResponse(response: response, data: data, error: error) {
                    case .success:
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
            task.resume()
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
}

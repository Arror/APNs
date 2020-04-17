//
//  APNsProviderBase.swift
//  APNs-NG
//
//  Created by 马强 on 2020/3/29.
//  Copyright © 2020 Arror. All rights reserved.
//

import Foundation
import Combine

open class APNsProviderBase: APNsProvider {

    open var session: URLSession { fatalError() }
    
    public let service: APNsService
    public let bundleID: String
    
    public var authorization: String? {
        return nil
    }

    public init(service: APNsService, bundleID: String) {
        self.service = service
        self.bundleID = bundleID
    }

    public final func send(token: String, payload: Data, priority: Int) -> AnyPublisher<Void, Error> {
        let request: URLRequest = {
            let url: URL = {
                let base: URL
                switch self.service {
                case .production:
                    base = URL(string: "https://api.push.apple.com")!
                case .sandbox:
                    base = URL(string: "https://api.development.push.apple.com")!
                }
                return base.appendingPathComponent("3/device/\(token)")
            }()
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.httpBody = payload
            var reval = req.allHTTPHeaderFields ?? [:]
            reval["authorization"] = self.authorization.flatMap { "bearer \($0)" }
            reval["apns-id"] = UUID().uuidString
            reval["apns-expiration"] = "0"
            reval["apns-priority"] = "\(priority)"
            reval["apns-topic"] = self.bundleID
            req.allHTTPHeaderFields = reval
            return req
        }()
        
        return self.session.dataTaskPublisher(for: request)
            .mapError { _ in APNsError.invalidateRequest }
            .tryMap { try Result<Void, Error>(response: $0.response, data: $0.data).get() }
            .eraseToAnyPublisher()
    }
}

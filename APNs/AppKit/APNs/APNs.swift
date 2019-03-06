//
//  APNs.swift
//  APNs
//
//  Created by Arror on 2019/3/3.
//  Copyright © 2019 Arror. All rights reserved.
//

import Foundation

public final class APNs {
    
    public enum Server {
        
        case development
        case production
        
        var hostURL: URL {
            switch self {
            case .development:
                return URL(string: "https://api.development.push.apple.com")!
            case .production:
                return URL(string: "https://api.push.apple.com")!
            }
        }
    }
    
    private let session: URLSession
    private let tokenController: TokenController
    
    public init(teamID: String, keyID: String, keyString: String) throws {
        self.tokenController = try TokenController(teamID: teamID, keyID: keyID, keyString: keyString)
        self.session = URLSession.shared
    }
    
    public func send(server: Server, tokens: [String], payload: Data, completion: @escaping () -> Void) {
        
        let hostURL = server.hostURL.appendingPathComponent("3/device")
        
        tokens.forEach { token in
            
            let url = hostURL.appendingPathComponent(token)
            
            let request: URLRequest = {
                var req = URLRequest(url: url)
                req.httpMethod = "POST"
                req.httpBody = payload
                var reval = req.allHTTPHeaderFields ?? [:]
                reval["authorization"] = self.tokenController.token.flatMap { "bearer \($0)" }
                reval["apns-id"] = UUID().uuidString
                reval["apns-expiration"] = "0"
                reval["apns-priority"] = "10"
                reval["apns-topic"] = "com.Arror.Sample"
                req.allHTTPHeaderFields = reval
                return req
            }()
            
            let task = self.session.dataTask(with: request) { data, response, error in
                if let err = error {
                    print(err)
                } else {
                    
                }
            }
            
            task.resume()
        }
    }
}


//public final class APNs {
//
//    private class _URLSessionDelegate: NSObject, URLSessionDelegate {
//
//        private let identity: SecIdentity
//
//        init(identity: SecIdentity) {
//            self.identity = identity
//            super.init()
//        }
//
//        func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//
//            let certificate: SecCertificate = {
//                var cert: SecCertificate?
//                SecIdentityCopyCertificate(self.identity, &cert)
//                return cert!
//            }()
//
//            let credential = URLCredential(identity: self.identity, certificates: [certificate], persistence: .forSession)
//
//            completionHandler(.useCredential, credential)
//        }
//    }
//
//    public enum Server {
//
//        case development, production
//
//        var hostURL: URL {
//            switch self {
//            case .development:
//                return URL(string: "https://api.development.push.apple.com")!
//            case .production:
//                return URL(string: "https://api.push.apple.com")!
//            }
//        }
//    }
//
//    private let sessionDelegate: _URLSessionDelegate
//    private let session: URLSession
//
//    public init(identity: SecIdentity) {
//        let sessionDelegate = _URLSessionDelegate(identity: identity)
//        let session = URLSession(configuration: .default, delegate: sessionDelegate, delegateQueue: .main)
//        self.sessionDelegate = sessionDelegate
//        self.session = session
//    }
//
//    public func send(server: Server, tokens: [String], payload: Data, completion: @escaping () -> Void) {
//
//        let hostURL = server.hostURL.appendingPathComponent("3/device")
//
//        tokens.forEach { token in
//
//            let url = hostURL.appendingPathComponent(token)
//
//            let request: URLRequest = {
//                var req = URLRequest(url: url)
//                req.httpMethod = "POST"
//                req.httpBody = payload
//                return req
//            }()
//
//            let task = self.session.dataTask(with: request) { data, response, error in
//                if let err = error {
//                    print(err)
//                } else {
//                    // token
//                    // data
//                    // response
//                }
//            }
//
//            task.resume()
//        }
//    }
//}

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
    
    public final class TokenBasedSession: APNsProvider {
        
        private let tokenController: TokenController
        
        public let session: URLSession
        
        public init(teamID: String, keyID: String, keyString: String) throws {
            self.tokenController = try TokenController(teamID: teamID, keyID: keyID, keyString: keyString)
            self.session = URLSession.shared
        }
    }
    
    public final class CertificateBasedSession: APNsProvider {
        
        private let sessionDelegate: CertificateBasedURLSessionDelegate
        
        public let session: URLSession
        
        public init(identity: SecIdentity) {
            let sessionDelegate = CertificateBasedURLSessionDelegate(identity: identity)
            let session = URLSession(configuration: .default, delegate: sessionDelegate, delegateQueue: .main)
            self.sessionDelegate = sessionDelegate
            self.session = session
        }
    }
    
    private class CertificateBasedURLSessionDelegate: NSObject, URLSessionDelegate {
        
        private let identity: SecIdentity
        
        init(identity: SecIdentity) {
            self.identity = identity
            super.init()
        }
        
        func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            
            let certificate: SecCertificate = {
                var cert: SecCertificate?
                SecIdentityCopyCertificate(self.identity, &cert)
                return cert!
            }()
            
            let credential = URLCredential(identity: self.identity, certificates: [certificate], persistence: .forSession)
            
            completionHandler(.useCredential, credential)
        }
    }
}

public protocol APNsProvider: class {
    
    var session: URLSession { get }
    
    func send(server: APNs.Server, tokens: [String], payload: Data, completion: @escaping () -> Void)
}

extension APNsProvider {
    
    public func send(server: APNs.Server, tokens: [String], payload: Data, completion: @escaping () -> Void) {
        
        let hostURL = server.hostURL.appendingPathComponent("3/device")
        
        tokens.forEach { token in
            
            let url = hostURL.appendingPathComponent(token)
            
            let request: URLRequest = {
                var req = URLRequest(url: url)
                req.httpMethod = "POST"
                req.httpBody = payload
                var reval = req.allHTTPHeaderFields ?? [:]
//                reval["authorization"] = self.tokenController.token.flatMap { "bearer \($0)" }
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
                    let httpURLResponse = response as! HTTPURLResponse
                    print(httpURLResponse.statusCode)
                }
            }
            
            task.resume()
        }
    }
}

public protocol SafeCompatible {
    
    associatedtype CompatibleType
    
    var safe: CompatibleType { get }
}

extension SafeCompatible {
    
    public var safe: Safe<Self> { return Safe(self) }
}

public struct Safe<Base> {
    
    let base: Base
    
    init(_ base: Base) {
        self.base = base
    }
}

extension DispatchQueue: SafeCompatible {}

extension Safe where Base == DispatchQueue {
    
    public func sync(execute: () -> Void) {
        if Thread.current == self.base {
            execute()
        } else {
            self.base.sync {
                execute()
            }
        }
    }
}

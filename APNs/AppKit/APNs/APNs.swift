//
//  APNs.swift
//  APNs
//
//  Created by Arror on 2019/3/3.
//  Copyright © 2019 Arror. All rights reserved.
//

import Foundation

public enum APNs {
    
    public enum Server {
        
        case development, production
        
        public var hostURL: URL {
            switch self {
            case .development:
                return URL(string: "https://api.development.push.apple.com")!
            case .production:
                return URL(string: "https://api.push.apple.com")!
            }
        }
    }
    
    public enum Based {
        case certificate(identity: SecIdentity)
        case token(teamID: String, keyID: String, keyString: String)
    }
    
    public static func makeProvider(based: Based) throws -> Provider {
        switch based {
        case .certificate(let identity):
            return CertificateBasedProvider(identity: identity)
        case .token(let teamID, let keyID, let keyString):
            return try TokenBasedProvider(teamID: teamID, keyID: keyID, keyString: keyString)
        }
    }
    
    open class Provider {
        
        private let queue: DispatchQueue
        
        open var session: URLSession { fatalError() }
        
        public init() {
            self.queue = DispatchQueue(label: "", attributes: .concurrent)
        }
        
        open var authorization: String? {
            return nil
        }
        
        public final func send(server: APNs.Server, tokens: [String], payload: Data, completion: @escaping (APNs.Response) -> Void) {
            
            self.queue.async {
                
                let hostURL = server.hostURL.appendingPathComponent("3/device")
                
                tokens.forEach { token in
                    
                    let url = hostURL.appendingPathComponent(token)
                    
                    let request: URLRequest = {
                        var req = URLRequest(url: url)
                        req.httpMethod = "POST"
                        req.httpBody = payload
                        var reval = req.allHTTPHeaderFields ?? [:]
                        reval["authorization"] = self.authorization.flatMap { "bearer \($0)" }
                        reval["apns-id"] = UUID().uuidString
                        reval["apns-expiration"] = "0"
                        reval["apns-priority"] = "10"
                        reval["apns-topic"] = "com.Arror.Sample"
                        req.allHTTPHeaderFields = reval
                        return req
                    }()
                    
                    let task = self.session.dataTask(with: request) { data, response, error in
                        let response = APNs.Response(response: response, data: data, error: error)
                        DispatchQueue.main.sync {
                            completion(response)
                        }
                    }
                    
                    task.resume()
                }
            }
        }
    }
}

private class TokenBasedProvider: APNs.Provider {
    
    override var session: URLSession {
        return self._session
    }
    
    override var authorization: String? {
        return self._tokenController.token
    }
    
    private let _session: URLSession
    private let _tokenController: TokenController
    
    public init(teamID: String, keyID: String, keyString: String) throws {
        self._session = URLSession.shared
        self._tokenController = try TokenController(teamID: teamID, keyID: keyID, keyString: keyString)
    }
}

private class CertificateBasedProvider: APNs.Provider {
    
    private class _URLSessionDelegate: NSObject, URLSessionDelegate {
        
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
    
    private let _sessionDelegate: _URLSessionDelegate
    private let _session: URLSession
    
    public override var session: URLSession {
        return self._session
    }
    
    public init(identity: SecIdentity) {
        let delegate = _URLSessionDelegate(identity: identity)
        self._sessionDelegate = delegate
        self._session = URLSession(configuration: .default, delegate: delegate, delegateQueue: .main)
    }
}

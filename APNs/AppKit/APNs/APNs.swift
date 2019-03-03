//
//  APNs.swift
//  APNs
//
//  Created by Arror on 2019/3/3.
//  Copyright © 2019 Arror. All rights reserved.
//

import Foundation

public final class APNs {
    
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
    
    public enum Environment {
        
        case development, production
        
        var hostURL: URL {
            switch self {
            case .development:
                return URL(string: "https://api.development.push.apple.com:443/3/device/")!
            case .production:
                return URL(string: "https://api.push.apple.com:443/3/device/")!
            }
        }
    }
    
    private let sessionDelegate: _URLSessionDelegate
    private let session: URLSession
    
    public init(identity: SecIdentity) {
        let sessionDelegate = _URLSessionDelegate(identity: identity)
        let session = URLSession(configuration: .default, delegate: sessionDelegate, delegateQueue: .main)
        self.sessionDelegate = sessionDelegate
        self.session = session
    }
    
    public func send(environment: Environment, tokens: [String], payload: Data, completion: @escaping () -> Void) {
        
        let hostURL = environment.hostURL
        
        tokens.forEach { token in
            
            let url = hostURL.appendingPathComponent(token)
            
            let request: URLRequest = {
                var req = URLRequest(url: url)
                req.httpMethod = "POST"
                req.httpBody = payload
                return req
            }()
            
            let task = self.session.dataTask(with: request) { data, response, error in
                if let err = error {
                    print(err)
                } else {
                    // token
                    // data
                    // response
                }
            }
            
            task.resume()
        }
    }
}

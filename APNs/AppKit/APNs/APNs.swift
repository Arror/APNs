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
        case certificate(filePath: String)
        case token(teamID: String, keyID: String, P8FilePath: String)
    }
    
    public static func makeProvider(based: Based) throws -> Provider {
        switch based {
        case .certificate(let filePath):
            return try CertificateBasedProvider(certificateFilePath: filePath)
        case .token(let teamID, let keyID, let P8FilePath):
            return try TokenBasedProvider(teamID: teamID, keyID: keyID, P8FilePath: P8FilePath)
        }
    }
    
    open class Provider {
        
        private let queue: DispatchQueue
        
        open var session: URLSession { fatalError() }
        
        public init() {
            self.queue = DispatchQueue(label: "com.APNs.Provider", attributes: .concurrent)
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
                        completion(response)
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
    
    public init(teamID: String, keyID: String, P8FilePath: String) throws {
        let P8KeyString = try String(contentsOf: URL(fileURLWithPath: P8FilePath))
        self._session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
        self._tokenController = try TokenController(teamID: teamID, keyID: keyID, P8KeyString: P8KeyString)
    }
}

private class CertificateBasedProvider: APNs.Provider {
    
    private class _URLSessionDelegate: NSObject, URLSessionDelegate {
        
        private let identity: SecIdentity
        private let certificate: SecCertificate
        
        init(identity: SecIdentity, certificate: SecCertificate) {
            self.identity = identity
            self.certificate = certificate
            super.init()
        }
        
        func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            
            let credential = URLCredential(identity: self.identity, certificates: [self.certificate], persistence: .forSession)
            
            completionHandler(.useCredential, credential)
        }
    }
    
    private let _sessionDelegate: _URLSessionDelegate
    private let _session: URLSession
    
    override var session: URLSession {
        return self._session
    }
    
    convenience init(certificateFilePath: String) throws {
        let certData = try Data(contentsOf: URL(fileURLWithPath: certificateFilePath))
        guard
            let certificate = SecCertificateCreateWithData(kCFAllocatorDefault, certData as CFData) else {
                throw NSError(domain: "APNs", code: -1, userInfo: [NSLocalizedDescriptionKey: "Certificate create failed."])
        }
        var reval: SecIdentity? = nil
        
        guard
            SecIdentityCreateWithCertificate(nil, certificate, &reval) == errSecSuccess,
            let identify = reval else {
                throw NSError(domain: "APNs", code: -1, userInfo: [NSLocalizedDescriptionKey: "Identity create failed."])
        }
        self.init(identity: identify, certificate: certificate)
    }
    
    init(identity: SecIdentity, certificate: SecCertificate) {
        let delegate = _URLSessionDelegate(identity: identity, certificate: certificate)
        self._sessionDelegate = delegate
        self._session = URLSession(configuration: .default, delegate: delegate, delegateQueue: .main)
    }
}

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
        
        case sandbox, production
        
        public var hostURL: URL {
            switch self {
            case .sandbox:
                return URL(string: "https://api.development.push.apple.com")!
            case .production:
                return URL(string: "https://api.push.apple.com")!
            }
        }
    }
    
    public enum Certificate: Equatable {
        
        case cer(data: Data)
        case p12(data: Data, passphrase: String)
        case p8(data: Data, teamID: String, keyID: String, topic: String)
        
        public static func ==(lhs: Certificate, rhs: Certificate) -> Bool {
            switch (lhs, rhs) {
            case let (.cer(l), .cer(r)):
                return l == r
            case let (.p12(l), .p12(r)):
                return (l.data == r.data) && (l.passphrase == r.passphrase)
            case let (.p8(l), .p8(r)):
                return (l.data == r.data) && (l.teamID == r.teamID) && (l.keyID == r.keyID)
            default:
                return false
            }
        }
    }
    
    public static func makeProvider(certificate: Certificate) throws -> Provider {
        switch certificate {
        case .cer(let data):
            return try CertificateBasedProvider(cerData: data)
        case .p12(let data, let passphrase):
            return try CertificateBasedProvider(P12Data: data, passphrase: passphrase)
        case .p8(let data, let teamID, let keyID, let topic):
            return try TokenBasedProvider(P8Data: data, teamID: teamID, keyID: keyID, topic: topic)
        }
    }
    
    open class Provider {
        
        open var session: URLSession { fatalError() }
        
        public init() {}
        
        open var authorization: String? {
            return nil
        }
        
        open var topic: String? {
            return nil
        }
        
        public final func send(server: APNs.Server, options: Options, token: String, payload: PayloadConvertable, completion: @escaping (APNs.Response) -> Void) {
            do {
                let data = try payload.asData()
                let hostURL = server.hostURL.appendingPathComponent("3/device")
                let url = hostURL.appendingPathComponent(token)
                let request: URLRequest = {
                    var req = URLRequest(url: url)
                    req.httpMethod = "POST"
                    req.httpBody = data
                    var reval = req.allHTTPHeaderFields ?? [:]
                    reval["authorization"] = self.authorization.flatMap { "bearer \($0)" }
                    reval["apns-id"] = UUID().uuidString
                    reval["apns-expiration"] = "\(options.expiration)"
                    reval["apns-priority"] = "\(options.priority)"
                    reval["apns-topic"] = self.topic
                    req.allHTTPHeaderFields = reval
                    return req
                }()
                let task = self.session.dataTask(with: request) { data, response, error in
                    DispatchQueue.main.safe.sync {
                        let response = APNs.Response(response: response, data: data, error: error)
                        completion(response)
                    }
                }
                task.resume()
            } catch {
                DispatchQueue.main.safe.sync {
                    completion(.failure(error))
                }
            }
        }
    }
}

private final class TokenController {
    
    private let teamID: String
    private let keyID: String
    private let es256: ES256
    private let storage: DefaultsStorage
    
    private let tokenStorageKey: String
    
    private struct Pair: Codable {
        let jwt: JSONWebToken
        let token: String
    }
    
    private var pair: Pair? = nil
    
    var token: String? {
        if let p = self.pair, !p.jwt.isExpired {
            return p.token
        } else {
            do {
                self.pair = nil
                try self.storage.clear(for: self.tokenStorageKey)
                let jwt = JSONWebToken(
                    keyID: self.keyID,
                    teamID: self.teamID,
                    issueDate: Date(timeIntervalSinceNow: 0),
                    expireDate: Date(timeIntervalSinceNow: 60 * 60)
                )
                self.pair = Pair(jwt: jwt, token: try jwt.sign(by: self.es256))
                try self.storage.set(item: self.pair, for: self.tokenStorageKey)
                return self.pair?.token
            } catch {
                return nil
            }
        }
    }
    
    init(teamID: String, keyID: String, P8Data: Data) throws {
        guard
            let P8KeyString = String(data: P8Data, encoding: .utf8) else {
                throw NSError(domain: "APNs", code: -1, userInfo: [NSLocalizedDescriptionKey: "Read .p8 file data failed."])
        }
        self.es256 = try ES256(P8String: P8KeyString)
        self.keyID = keyID
        self.teamID = teamID
        self.tokenStorageKey = "\(teamID)\(keyID)"
        self.storage = DefaultsStorage()
        do {
            self.pair = try self.storage.item(for: self.tokenStorageKey)
        } catch {
            self.pair = nil
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
    
    override var topic: String? {
        return self._topic
    }
    
    private let _tokenController: TokenController
    private let _session: URLSession
    private let _queue: OperationQueue
    private let _topic: String
    
    public init(P8Data: Data, teamID: String, keyID: String, topic: String) throws {
        self._topic = topic
        self._tokenController = try TokenController(teamID: teamID, keyID: keyID, P8Data: P8Data)
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 10
        self._session = URLSession(configuration: .default, delegate: nil, delegateQueue: queue)
        self._queue = queue
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
    private let _queue: OperationQueue
    
    override var session: URLSession {
        return self._session
    }
    
    convenience init(cerData: Data) throws {
        guard
            let certificate = SecCertificateCreateWithData(kCFAllocatorDefault, cerData as CFData) else {
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
    
    convenience init(P12Data: Data, passphrase: String) throws {
        let options = [kSecImportExportPassphrase as String: passphrase] as CFDictionary
        var reval: CFArray?
        guard
            SecPKCS12Import(P12Data as CFData, options, &reval) == errSecSuccess,
            let items = reval, CFArrayGetCount(items) > 0 else {
                throw NSError(domain: "APNs", code: -1, userInfo: [:])
        }
        let identity = (items as [AnyObject])[0][kSecImportItemIdentity as String] as! SecIdentity
        let certificate: SecCertificate = {
            var reval: SecCertificate? = nil
            SecIdentityCopyCertificate(identity, &reval)
            return reval!
        }()
        self.init(identity: identity, certificate: certificate)
    }
    
    private init(identity: SecIdentity, certificate: SecCertificate) {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 10
        let delegate = _URLSessionDelegate(identity: identity, certificate: certificate)
        self._sessionDelegate = delegate
        self._session = URLSession(configuration: .default, delegate: delegate, delegateQueue: queue)
        self._queue = queue
    }
}

extension URL {
    
    public func readFile<R>(execute: (URL) throws -> R) throws -> R {
        _ = self.startAccessingSecurityScopedResource()
        defer {
            self.stopAccessingSecurityScopedResource()
        }
        return try execute(self)
    }
}

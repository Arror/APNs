//
//  CertificateBasedProvider.swift
//  APNs-NG
//
//  Created by 马强 on 2020/3/29.
//  Copyright © 2020 Arror. All rights reserved.
//

import Foundation

public final class CertificateBasedProvider: APNsProviderBase {
    
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
    private let _topic: String
    
    public override var session: URLSession {
        return self._session
    }
    
    convenience init(cerData: Data, topic: String) throws {
        guard
            !topic.isEmpty else {
                throw APNsError.bundleIDEmpty
        }
        guard
            let certificate = SecCertificateCreateWithData(kCFAllocatorDefault, cerData as CFData) else {
                throw APNsError.loadCERFailed
        }
        var reval: SecIdentity? = nil
        
        guard
            SecIdentityCreateWithCertificate(nil, certificate, &reval) == errSecSuccess,
            let identify = reval else {
                throw APNsError.createCERFailed
        }
        self.init(identity: identify, certificate: certificate, topic: topic)
    }
    
    convenience init(P12Data: Data, passphrase: String, topic: String) throws {
        guard
            !topic.isEmpty else {
                throw APNsError.bundleIDEmpty
        }
        let options = [kSecImportExportPassphrase as String: passphrase] as CFDictionary
        var reval: CFArray?
        guard
            SecPKCS12Import(P12Data as CFData, options, &reval) == errSecSuccess,
            let items = reval, CFArrayGetCount(items) > 0 else {
                throw APNsError.createP12Failed
        }
        let identity = (items as [AnyObject])[0][kSecImportItemIdentity as String] as! SecIdentity
        let certificate: SecCertificate = {
            var reval: SecCertificate? = nil
            SecIdentityCopyCertificate(identity, &reval)
            return reval!
        }()
        self.init(identity: identity, certificate: certificate, topic: topic)
    }
    
    private init(identity: SecIdentity, certificate: SecCertificate, topic: String) {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 10
        let delegate = _URLSessionDelegate(identity: identity, certificate: certificate)
        self._sessionDelegate = delegate
        self._session = URLSession(configuration: .default, delegate: delegate, delegateQueue: queue)
        self._queue = queue
        self._topic = topic
    }
}

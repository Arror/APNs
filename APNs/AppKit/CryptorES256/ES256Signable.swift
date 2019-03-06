import Foundation
import CommonCrypto

@available(OSX 10.13, *)
protocol ES256Signable {
    func sign(with: ES256PrivateKey) throws -> ES256Signature
}

@available(OSX 10.13, *)
extension String: ES256Signable {
    public func sign(with key: ES256PrivateKey) throws -> ES256Signature {
        return try Data(self.utf8).sign(with: key)
    }
}

@available(OSX 10.13, *)
extension Data: ES256Signable {
    
    public func sign(with key: ES256PrivateKey) throws -> ES256Signature {
        
        let hash: Data = {
            var hash = [UInt8](repeating: 0, count: Int(CC_LONG(CC_SHA256_DIGEST_LENGTH)))
            self.withUnsafeBytes {
                _ = CC_SHA256($0, CC_LONG(self.count), &hash)
            }
            return Data(bytes: hash)
        }()
        
        var error: Unmanaged<CFError>? = nil
        guard let cfSignature = SecKeyCreateSignature(key.secKey,
                                                      .eciesEncryptionStandardVariableIVX963SHA256AESGCM,
                                                      hash as CFData,
                                                      &error)
            else {
                if let thrownError = error?.takeRetainedValue() {
                    throw thrownError
                } else {
                    throw ECError.failedSigningAlgorithm
                }
        }
        return try ES256Signature(asn1: cfSignature as Data)
    }
}

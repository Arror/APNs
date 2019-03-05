//
//  Security.swift
//  APNs
//
//  Created by Arror on 2019/3/3.
//  Copyright © 2019 Arror. All rights reserved.
//

import Foundation

enum DigestAlgorithm: Int {
    case raw = 0
    case sha1 = 1
    case sha224 = 2
    case sha256 = 3
    case sha384 = 4
    case sha512 = 5
}

enum KeyError: Int, Error {
    case unsupportedAlgorithm = 1
}

protocol Key {
    var blockSize: Int { get }
}

protocol PrivateKey: Key {
    
    associatedtype SigningScheme
    associatedtype PairedPublicKey: PublicKey where PairedPublicKey.SigningScheme == SigningScheme
    
    func makePublicKey() -> PairedPublicKey?
    
    func sign(message: Data, withScheme scheme: SigningScheme, digestAlgorithm: DigestAlgorithm) throws -> Data
    
    func sign(digest: Data, withScheme scheme: SigningScheme, digestAlgorithm: DigestAlgorithm) throws -> Data
}

protocol PublicKey: Key {
    
    associatedtype SigningScheme
    
    func verify(signature: Data, forMessage message: Data, withScheme scheme: SigningScheme, digestAlgorithm: DigestAlgorithm) throws -> Bool
    
    func verify(signature: Data, forDigest digest: Data, withScheme scheme: SigningScheme, digestAlgorithm: DigestAlgorithm) throws -> Bool
    
}

@objcMembers
class SecKeyWrapper: NSObject {
    
    let key: SecKey
    
    required init(key: SecKey) {
        self.key = key
        super.init()
    }
    
    var blockSize: Int { return SecKeyGetBlockSize(self.key) }
    
    func sign(data: Data, alg: SecKeyAlgorithm) throws -> Data {
        
        var error: Unmanaged<CFError>?
        
        guard let signed = SecKeyCreateSignature(key, alg, data as CFData, &error) else {
            let err = error!.takeRetainedValue() as Error
            throw err
        }
        return signed as Data
    }
    
    func verify(signature: Data, forData data: Data, alg: SecKeyAlgorithm) throws -> Bool {
        var error: Unmanaged<CFError>?
        
        let result = SecKeyVerifySignature(self.key, alg, data as CFData, signature as CFData, &error)
        
        if let err = error?.takeRetainedValue() {
            throw err
        } else {
            return result
        }
    }
}



enum RSASigningScheme: Int {
    case pkcs1v15 = 1
    case pss = 2
}

enum ECCSigningScheme: Int {
    case x962 = 1
}


protocol SigningSecKeyAlgorithmSource {
    
    func signingMessageScheme(digestAlgorithm: DigestAlgorithm) throws -> SecKeyAlgorithm
    
    func signingDigestScheme(digestAlgorithm: DigestAlgorithm) throws -> SecKeyAlgorithm
}

extension RSASigningScheme: SigningSecKeyAlgorithmSource {
    
    func signingMessageScheme(digestAlgorithm: DigestAlgorithm) throws -> SecKeyAlgorithm {
        switch self {
        case .pkcs1v15:
            switch digestAlgorithm {
            case .sha1:
                return .rsaSignatureMessagePKCS1v15SHA1
            case .sha224:
                return .rsaSignatureMessagePKCS1v15SHA224
            case .sha256:
                return .rsaSignatureMessagePKCS1v15SHA256
            case .sha384:
                return .rsaSignatureMessagePKCS1v15SHA384
            case .sha512:
                return .rsaSignatureMessagePKCS1v15SHA512
            case .raw:
                throw KeyError.unsupportedAlgorithm
            }
        case .pss:
            if #available(iOS 11.0, *) {
                switch digestAlgorithm {
                case .sha1:
                    return .rsaSignatureMessagePSSSHA1
                case .sha224:
                    return .rsaSignatureMessagePSSSHA224
                case .sha256:
                    return .rsaSignatureMessagePSSSHA256
                case .sha384:
                    return .rsaSignatureMessagePSSSHA384
                case .sha512:
                    return .rsaSignatureMessagePSSSHA512
                case .raw:
                    throw KeyError.unsupportedAlgorithm
                }
            } else {
                throw KeyError.unsupportedAlgorithm
            }
            
        }
    }
    func signingDigestScheme(digestAlgorithm: DigestAlgorithm) throws -> SecKeyAlgorithm {
        switch self {
        case .pkcs1v15:
            switch digestAlgorithm {
            case .sha1:
                return .rsaSignatureDigestPKCS1v15SHA1
            case .sha224:
                return .rsaSignatureDigestPKCS1v15SHA224
            case .sha256:
                return .rsaSignatureDigestPKCS1v15SHA256
            case .sha384:
                return .rsaSignatureDigestPKCS1v15SHA384
            case .sha512:
                return .rsaSignatureDigestPKCS1v15SHA512
            case .raw:
                throw KeyError.unsupportedAlgorithm
            }
        case .pss:
            if #available(iOS 11.0, *) {
                switch digestAlgorithm {
                case .sha1:
                    return .rsaSignatureDigestPSSSHA1
                case .sha224:
                    return .rsaSignatureDigestPSSSHA224
                case .sha256:
                    return .rsaSignatureDigestPSSSHA256
                case .sha384:
                    return .rsaSignatureDigestPSSSHA384
                case .sha512:
                    return .rsaSignatureDigestPSSSHA512
                case .raw:
                    throw KeyError.unsupportedAlgorithm
                }
            } else {
                throw KeyError.unsupportedAlgorithm
            }
            
        }
    }
}

extension ECCSigningScheme: SigningSecKeyAlgorithmSource {
    
    func signingMessageScheme(digestAlgorithm: DigestAlgorithm) throws -> SecKeyAlgorithm {
        switch self {
        case .x962:
            switch digestAlgorithm {
            case .sha1:
                return .ecdsaSignatureMessageX962SHA1
            case .sha224:
                return .ecdsaSignatureMessageX962SHA224
            case .sha256:
                return .ecdsaSignatureMessageX962SHA256
            case .sha384:
                return .ecdsaSignatureMessageX962SHA384
            case .sha512:
                return .ecdsaSignatureMessageX962SHA512
            case .raw:
                throw KeyError.unsupportedAlgorithm
            }
        }
    }
    func signingDigestScheme(digestAlgorithm: DigestAlgorithm) throws -> SecKeyAlgorithm {
        switch self {
        case .x962:
            switch digestAlgorithm {
            case .sha1:
                return .ecdsaSignatureDigestX962SHA1
            case .sha224:
                return .ecdsaSignatureDigestX962SHA224
            case .sha256:
                return .ecdsaSignatureDigestX962SHA256
            case .sha384:
                return .ecdsaSignatureDigestX962SHA384
            case .sha512:
                return .ecdsaSignatureDigestX962SHA512
            case .raw:
                throw KeyError.unsupportedAlgorithm
            }
        }
    }
}


class PrivateKeyWrapper<S: SigningSecKeyAlgorithmSource, P: PublicKey>: SecKeyWrapper, PrivateKey where P: SecKeyWrapper, P.SigningScheme == S {
    
    typealias SigningScheme = S
    
    typealias PairedPublicKey = P
    
    func makePublicKey() -> P? {
        return SecKeyCopyPublicKey(self.key).map(P.init(key:))
    }
    
    func sign(message: Data, withScheme scheme: S, digestAlgorithm: DigestAlgorithm) throws -> Data {
        let alg = try scheme.signingMessageScheme(digestAlgorithm: digestAlgorithm)
        return try self.sign(data: message, alg: alg)
    }
    
    func sign(digest: Data, withScheme scheme: S, digestAlgorithm: DigestAlgorithm) throws -> Data {
        let alg = try scheme.signingDigestScheme(digestAlgorithm: digestAlgorithm)
        return try self.sign(data: digest, alg: alg)
    }
}

class PublicKeyWrapper<S: SigningSecKeyAlgorithmSource>: SecKeyWrapper, PublicKey {
    
    typealias SigningScheme = S
    
    func verify(signature: Data, forMessage message: Data, withScheme scheme: S, digestAlgorithm: DigestAlgorithm) throws -> Bool {
        let alg = try scheme.signingMessageScheme(digestAlgorithm: digestAlgorithm)
        return try self.verify(signature: signature, forData: message, alg: alg)
    }
    
    func verify(signature: Data, forDigest digest: Data, withScheme scheme: S, digestAlgorithm: DigestAlgorithm) throws -> Bool {
        let alg = try scheme.signingDigestScheme(digestAlgorithm: digestAlgorithm)
        return try self.verify(signature: signature, forData: digest, alg: alg)
    }
}


typealias RSAPrivateKeyWrapper = PrivateKeyWrapper<RSASigningScheme, RSAPublicKeyWrapper>

typealias RSAPublicKeyWrapper = PublicKeyWrapper<RSASigningScheme>

typealias ECPrivateKeyWrapper = PrivateKeyWrapper<ECCSigningScheme, ECPublicKeyWrapper>

typealias ECPublicKeyWrapper = PublicKeyWrapper<ECCSigningScheme>

protocol RSAPublicKey: PublicKey where SigningScheme == RSASigningScheme {}

protocol RSAPrivateKey: PrivateKey where PairedPublicKey: RSAPublicKey {}

protocol ECCPublicKey: PublicKey where SigningScheme == ECCSigningScheme {}

protocol ECCPrivateKey: PrivateKey where PairedPublicKey: ECCPublicKey {}

extension PrivateKeyWrapper: ECCPrivateKey where P == PublicKeyWrapper<ECCSigningScheme> {}

extension PublicKeyWrapper: ECCPublicKey where S == ECCSigningScheme {}

extension PrivateKeyWrapper: RSAPrivateKey where P == PublicKeyWrapper<RSASigningScheme> {}

extension PublicKeyWrapper: RSAPublicKey where S == RSASigningScheme {}


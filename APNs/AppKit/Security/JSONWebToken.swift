//
//  JSONWebToken.swift
//  APNs
//
//  Created by Qiang Ma 马强 on 2019/3/5.
//  Copyright © 2019 Arror. All rights reserved.
//

import Foundation
import CommonCrypto

public struct JSONWebToken: Codable {
    
    public struct Header: Codable {
        
        public let algorithm: String = "ES256"
        public let keyID: String
        
        private enum CodingKeys: String, CodingKey {
            case algorithm  = "alg"
            case keyID      = "kid"
        }
    }
    
    public struct Claims: Codable {
        
        public let teamID: String
        public let issueDate: Date
        public let expireDate: Date
        
        private enum CodingKeys: String, CodingKey {
            case teamID     = "iss"
            case issueDate  = "iat"
            case expireDate = "exp"
        }
    }
    
    public let header: Header
    public let claims: Claims
    
    public init(keyID: String, teamID: String, issueDate: Date, expireDate: Date) {
        self.header = Header(keyID: keyID)
        self.claims = Claims(teamID: teamID, issueDate: issueDate, expireDate: expireDate)
    }
}

final class JSONWebTokenSigner {
    
    private let wrapper: ECPrivateKeyWrapper
    
    init(wrapper: ECPrivateKeyWrapper) {
        self.wrapper = wrapper
    }
    
    func sign(token: JSONWebToken) -> String? {
        do {
            let headerString = try JSONEncoder().encode(token.header).base64URLEncodedString()
            let claimsString = try JSONEncoder().encode(token.claims).base64URLEncodedString()
            let digestString = "\(headerString).\(claimsString)"
            guard
                let origin = digestString.data(using: .utf8) else {
                    return nil
            }
            let digest = origin.sha256()
            let signature = try self.wrapper.sign(digest: digest, withScheme: .x962, digestAlgorithm: .sha256)
            guard
                let rawData = ASN1.toRawSignature(data: signature as Data) else {
                    return nil
            }
            return rawData.base64URLEncodedString()
        } catch {
            return nil
        }
    }
}

extension Data {
    
    func base64URLEncodedString() -> String {
        return self.base64EncodedString()
            .replacingOccurrences(of: "=", with: "")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
    }
    
    func sha256() -> Data {
        var temp = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256((self as NSData).bytes, CC_LONG(self.count), &temp)
        return Data(bytes: temp)
    }
}

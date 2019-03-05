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
            let headerString = self.base64URLEncodedString(data: try JSONEncoder().encode(token.header))
            let claimsString = self.base64URLEncodedString(data: try JSONEncoder().encode(token.claims))
            let digestString = "\(headerString).\(claimsString)"
            guard
                let origin = digestString.data(using: .utf8) else {
                    return nil
            }
            var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            CC_SHA256((origin as NSData).bytes, CC_LONG(origin.count), &hash)
            let digest = Data(bytes: hash)
            let signature = try self.wrapper.sign(digest: digest, withScheme: .x962, digestAlgorithm: .sha256)
            guard
                let rawData = ASN1.toRawSignature(data: signature as Data) else {
                    return nil
            }
            return self.base64URLEncodedString(data: rawData)
        } catch {
            return nil
        }
    }
    
    private func base64URLEncodedString(data: Data) -> String {
        return data.base64EncodedString()
            .replacingOccurrences(of: "=", with: "")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
    }
}

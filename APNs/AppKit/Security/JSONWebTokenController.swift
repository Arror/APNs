//
//  JSONWebTokenController.swift
//  APNs
//
//  Created by Qiang Ma 马强 on 2019/3/5.
//  Copyright © 2019 Arror. All rights reserved.
//

import Foundation
import CommonCrypto

public final class JSONWebTokenController {
    
    private let wrapper: ECPrivateKeyWrapper
    private let keyID: String
    private let teamID: String
    
    private struct Pair: Codable {
        let token: JSONWebToken
        let tokenString: String
    }
    
    private var _pair: Pair? = nil
    
    private var tokenStorageKey: String {
        return "\(self.teamID)\(self.keyID)"
    }
    
    public var token: String? {
        if let p = self._pair, !p.token.isExpired {
            return p.tokenString
        } else {
            do {
                self._pair = nil
                try self.storage.set(item: self._pair, for: self.tokenStorageKey)
                let newToken = JSONWebToken(
                    keyID: self.keyID,
                    teamID: self.teamID,
                    issueDate: Date(timeIntervalSinceNow: 0),
                    expireDate: Date(timeIntervalSinceNow: 3600)
                )
                guard
                    let digestString = newToken.digestString,
                    let data = digestString.data(using: .utf8) else {
                        return nil
                }
                let signature = try self.wrapper.sign(digest: data.sha256(), withScheme: .x962, digestAlgorithm: .sha256)
                guard
                    let rawData = ASN1.toRawSignature(data: signature as Data) else {
                        return nil
                }
                self._pair = Pair(token: newToken, tokenString: rawData.base64URLEncodedString())
                try self.storage.set(item: self._pair, for: self.tokenStorageKey)
                return self._pair?.tokenString
            } catch {
                return nil
            }
        }
    }
    
    private let storage: DefaultsStorage
    
    public init?(keyID: String, teamID: String, keyString: String) {
        guard
            let wrapper = ECPrivateKeyWrapper.make(withP8String: keyString) else {
                return nil
        }
        self.wrapper = wrapper
        self.keyID = keyID
        self.teamID = teamID
        self.storage = DefaultsStorage()
        do {
            self._pair = try self.storage.item(for: self.tokenStorageKey)
        } catch {
            self._pair = nil
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

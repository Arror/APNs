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
    
    private let teamID: String
    private let keyID: String
    private let signer: ES256Signer
    private let storage: DefaultsStorage
    
    private var tokenStorageKey: String {
        return "\(self.teamID)\(self.keyID)"
    }
    
    private var pair: (JSONWebToken, String)? = nil
    
    public var token: String? {
        if let p = self.pair, !p.0.isExpired {
            return p.1
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
                let digestString = try jwt.digestString()
                guard
                    let data = digestString.data(using: .utf8) else {
                        return nil
                }
                let signature = try self.signer.sign(data: data)
                self.pair = (jwt, "\(digestString).\(signature.base64URLEncodedString())")
                try self.storage.set(item: self.pair?.1, for: self.tokenStorageKey)
                return self.pair?.1
            } catch {
                return nil
            }
        }
    }
    
    public init(teamID: String, keyID: String, keyString: String) throws {
        self.signer = try ES256Signer(P8String: keyString)
        self.keyID = keyID
        self.teamID = teamID
        self.storage = DefaultsStorage()
        do {
            let value: String? = try self.storage.item(for: self.tokenStorageKey)
            guard
                let tokenString = value, let jwt = JSONWebToken(tokenString: tokenString), !jwt.isExpired else {
                    self.pair = nil
                    return
            }
            self.pair = (jwt, tokenString)
        } catch {
            self.pair = nil
        }
    }
}

extension Data {
    
    public func base64URLEncodedString() -> String {
        return self.base64EncodedString()
            .replacingOccurrences(of: "=", with: "")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
    }
    
    public init?(base64URLEncoded: String) {
        let paddingLength = 4 - base64URLEncoded.count % 4
        let padding = (paddingLength < 4) ? String(repeating: "=", count: paddingLength) : ""
        let base64EncodedString = base64URLEncoded
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
            + padding
        self.init(base64Encoded: base64EncodedString)
    }
}

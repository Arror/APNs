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
    private let es256: ES256
    private let storage: DefaultsStorage
    
    private let tokenStorageKey: String
    
    private struct Pair: Codable {
        let jwt: JSONWebToken
        let token: String
    }
    
    private var pair: Pair? = nil
    
    public var token: String? {
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
                let digestString = try jwt.digestString()
                guard
                    let data = digestString.data(using: .utf8) else {
                        return nil
                }
                let signature = try self.es256.sign(data: data)
                self.pair = Pair(jwt: jwt, token: "\(digestString).\(signature.base64URLEncodedString())")
                try self.storage.set(item: self.pair, for: self.tokenStorageKey)
                return self.pair?.token
            } catch {
                return nil
            }
        }
    }
    
    public init(teamID: String, keyID: String, keyString: String) throws {
        self.es256 = try ES256(P8String: keyString)
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

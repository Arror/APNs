//
//  JSONWebTokenController.swift
//  APNs
//
//  Created by Qiang Ma 马强 on 2019/3/5.
//  Copyright © 2019 Arror. All rights reserved.
//

import Foundation
import CommonCrypto

public final class TokenController {
    
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
                self.pair = Pair(jwt: jwt, token: try jwt.sign(by: self.es256))
                try self.storage.set(item: self.pair, for: self.tokenStorageKey)
                return self.pair?.token
            } catch {
                return nil
            }
        }
    }
    
    public init(teamID: String, keyID: String, P8KeyString: String) throws {
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

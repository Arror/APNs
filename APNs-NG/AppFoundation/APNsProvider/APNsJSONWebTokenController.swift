//
//  APNsJSONWebTokenController.swift
//  APNs-NG
//
//  Created by 马强 on 2020/3/29.
//  Copyright © 2020 Arror. All rights reserved.
//

import Foundation
import CryptoKit
import JSONWebToken

public struct APNsJSONWebTokenController {
    
    private let P8Data: Data
    private let teamID: String
    private let keyID: String
    
    private let storeKey: String
    
    init(P8Data: Data, teamID: String, keyID: String) {
        self.P8Data = P8Data
        self.teamID = teamID
        self.keyID = keyID
        self.storeKey = {
            let teamData = teamID.data(using: .utf8) ?? Data()
            let keyData = keyID.data(using: .utf8) ?? Data()
            var md5 = Insecure.MD5()
            md5.update(data: teamData + keyData + P8Data)
            return "TOKEN.KEY-\(md5.finalize().reduce(into: "") { $0.append( String(format:"%02X", $1)) })"
        }()
    }
    
    var jwt: String? {
        return self.generateJWTIfNeeded()
    }
    
    private func generateJWTIfNeeded() -> String? {
        do {
            let stored = UserDefaults.standard.string(forKey: self.storeKey) ?? ""
            if let jwt = try? JSONWebToken(JSONWebTokenString: stored), jwt.isValid {
                return stored
            } else {
                guard let PKCS8DERString = String(data: self.P8Data, encoding: .utf8) else {
                    return nil
                }
                let jwt = JSONWebToken(teamID: self.teamID, keyID: self.keyID, issueDate: Date(timeIntervalSinceNow: 0))
                let jwtString = try jwt.sign(using: try P256.Signing.PrivateKey(PKCS8DERString: PKCS8DERString))
                UserDefaults.standard.set(jwtString, forKey: self.storeKey)
                return jwtString
            }
        } catch {
            return nil
        }
    }
}

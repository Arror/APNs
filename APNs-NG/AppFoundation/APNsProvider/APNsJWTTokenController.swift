//
//  APNsJWTTokenController.swift
//  APNs-NG
//
//  Created by 马强 on 2020/3/29.
//  Copyright © 2020 Arror. All rights reserved.
//

import Foundation
import CryptoKit
import SwiftJWT

public final class APNsJWTTokenController {
    
    let P8Data: Data, teamID: String, keyID: String
    
    let storeKey: String
    
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
    
    func makeJWTToken() -> String? {
        do {
            let jwtString = UserDefaults.standard.string(forKey: self.storeKey) ?? ""
            if let jwt = try? JWT<APNsClaims>(jwtString: jwtString), jwt.validateClaims() == .success {
                return jwtString
            } else {
                var jwt = JWT<APNsClaims>(keyID: self.keyID, teamID: self.teamID, issueDate: Date(timeIntervalSinceNow: 0))
                let newJWTString = try jwt.sign(using: JWTSigner.es256(privateKey: self.P8Data))
                UserDefaults.standard.set(newJWTString, forKey: self.storeKey)
                return newJWTString
            }
        } catch {
            return nil
        }
    }
}

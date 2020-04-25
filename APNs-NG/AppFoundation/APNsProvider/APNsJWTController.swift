//
//  APNsJWTController.swift
//  APNs-NG
//
//  Created by 马强 on 2020/3/29.
//  Copyright © 2020 Arror. All rights reserved.
//

import Foundation
import CryptoKit

public struct APNsJWTController {
    
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
    
    func makeJSONWebToken() -> String? {
        guard let PKCS8DERString = String(data: self.P8Data, encoding: .utf8) else {
            return nil
        }
        do {
            let stored = UserDefaults.standard.string(forKey: self.storeKey) ?? ""
            if let jwt = APNsJSONWebToken(jwtString: stored), jwt.claims.expireDate.compare(Date(timeIntervalSinceNow: 0)) == .orderedDescending {
                return stored
            } else {
                let jwt = APNsJSONWebToken(teamID: self.teamID, keyID: self.keyID, issueDate: Date(timeIntervalSinceNow: 0))
                let jwtString = try jwt.sign(usingPKCS8DERString: PKCS8DERString)
                UserDefaults.standard.set(jwtString, forKey: self.storeKey)
                return jwtString
            }
        } catch {
            return nil
        }
    }
}

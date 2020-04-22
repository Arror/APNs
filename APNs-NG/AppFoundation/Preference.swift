//
//  Preference.swift
//  APNs-NG
//
//  Created by 马强 on 2020/4/18.
//  Copyright © 2020 Arror. All rights reserved.
//

import Foundation

public struct Preference: Codable {
    public let teamID: String
    public let keyID: String
    public let bundleID: String
    public let service: APNsService
    public let certificate: Optional<APNsCertificate>
    public let token: String
    public let priority: Int
}

extension AppService {
    
    private static let preferenceStoreKey = "USER.PREFERENCE"
    
    static func loadPreference() -> Preference? {
        guard let data = UserDefaults.standard.data(forKey: AppService.preferenceStoreKey) else {
            return nil
        }
        do {
            return try JSONDecoder().decode(Preference.self, from: data)
        } catch {
            return nil
        }
    }

    func savePreference() {
        let preference = Preference(
            teamID: self.teamID,
            keyID: self.keyID,
            bundleID: self.bundleID,
            service: self.apnsService,
            certificate: self.apnsCertificate,
            token: self.token,
            priority: self.priority
        )
        do {
            UserDefaults.standard.set(try JSONEncoder().encode(preference), forKey: AppService.preferenceStoreKey)
        } catch {
            
        }
    }
}

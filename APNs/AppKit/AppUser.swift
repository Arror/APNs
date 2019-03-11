//
//  AppUser.swift
//  APNs
//
//  Created by Arror on 2019/3/11.
//  Copyright © 2019 Arror. All rights reserved.
//

import Foundation

public final class AppUser {
    
    static var current: AppUser {
        return AppEnvironment.current.user
    }
    
    public let storage: DefaultsStorage
    
    private var certificate: APNs.Certificate?
    
    public private(set) var provider: APNs.Provider?
    
    init() {
        self.storage = DefaultsStorage()
    }
    
    public func updateProvider(withCertificate certificate: APNs.Certificate) throws {
        if certificate == self.certificate {
            return
        } else {
            self.provider = try APNs.makeProvider(certificate: certificate)
        }
    }
}

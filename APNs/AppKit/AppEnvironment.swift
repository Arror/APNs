//
//  AppEnvironment.swift
//  APNs
//
//  Created by Arror on 2019/3/3.
//  Copyright © 2019 Arror. All rights reserved.
//

import Foundation

public final class AppEnvironment {
    
    public let identifier: Identifier
    
    private var certificate: APNs.Certificate?
    
    public private(set) var provider: APNs.Provider?
    
    init(identifier: Identifier) {
        self.identifier = identifier
        self.certificate = nil
    }
    
    public func updateProvider(withCertificate certificate: APNs.Certificate) throws {
        if certificate == self.certificate {
            return
        } else {
            self.provider = try APNs.makeProvider(certificate: certificate)
        }
    }
}

extension AppEnvironment {
    
    public static var current: AppEnvironment {
        return AppService.current.environment
    }
}

extension AppEnvironment {
    
    public enum Identifier {
        case production
    }
}

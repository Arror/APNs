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
    
    public let user: AppUser
    
    init(identifier: Identifier) {
        self.identifier = identifier
        self.user = AppUser()
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

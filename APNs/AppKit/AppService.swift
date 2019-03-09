//
//  AppService.swift
//  APNs
//
//  Created by Arror on 2019/3/3.
//  Copyright © 2019 Arror. All rights reserved.
//

import Foundation

public final class AppService {
    
    public let logger = Logger()
    
    public static let current: AppService = AppService()
    
    public let environment: AppEnvironment
    
    private init() {
        self.environment = AppEnvironment(identifier: .production)
        self.logger.add(destination: ConsoleLogDestination(name: "com.APNs.ConsoleLogDestination"))
    }
}

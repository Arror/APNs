//
//  APNsPluginRegistrant.swift
//  APNsFlutter
//
//  Created by Arror on 2019/4/22.
//  Copyright © 2019 Arror. All rights reserved.
//

import Foundation
import FlutterMacOS

public enum APNsPluginRegistrant {
    
    public static func register(withRegistry registry: FLEPluginRegistry) {
        APNsSystemPlugin.register(with: registry.registrar(forPlugin: "SystemAction"))
    }
}

//
//  APNsPlugin.swift
//  APNsFlutter
//
//  Created by Qiang Ma 马强 on 2019/4/2.
//  Copyright © 2019 Arror. All rights reserved.
//

import Cocoa
import FlutterMacOS

public final class APNsPlugin: NSObject, FLEPlugin {
    
    public static func register(with registrar: FLEPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.Arror.APNsFlutter.APNsPlugin",
            binaryMessenger: registrar.messenger
        )
        registrar.addMethodCallDelegate(APNsPlugin(), channel: channel)
    }
    
    private override init() {
        super.init()
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print(call)
        result([])
    }
}

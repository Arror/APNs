//
//  APNsSystemPlugin.swift
//  APNsFlutter
//
//  Created by Arror on 2019/4/13.
//  Copyright © 2019 Arror. All rights reserved.
//

import Cocoa
import FlutterMacOS

public final class APNsSystemPlugin: NSObject, FLEPlugin {
    
    public static func register(with registrar: FLEPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.Arror.APNs.SystemAction",
            binaryMessenger: registrar.messenger
        )
        registrar.addMethodCallDelegate(APNsSystemPlugin(), channel: channel)
    }
    
    private override init() {
        super.init()
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "close":
            NSApplication.shared.terminate(self)
            result([])
        case "minimize":
            guard let window = NSApplication.shared.keyWindow else { fatalError("Invalid Window.") }
            window.performMiniaturize(nil)
            result([])
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

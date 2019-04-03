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
    
    private func loadFlutter() -> Optional<FLEViewController> {
        guard
            let window = NSApplication.shared.keyWindow as? Window else {
                return nil
        }
        return window.flutter
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "showProviderEditViewController":
            guard
                let flutter = self.loadFlutter() else {
                    result(FlutterError(code: "Bad Engine", message: "创建 Flutter view controller 失败", details: nil))
                    return
            }
            let vc = ProviderInfoEditViewController.makeViewController(info: .none) { controller, new in
                switch new {
                case .some(let i):
                    result(i.json)
                    controller.dismiss(nil)
                case .none:
                    result(nil)
                    controller.dismiss(nil)
                }
            }
            flutter.presentAsSheet(vc)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

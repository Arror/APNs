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
    
    private func loadFlutter() -> FLEViewController {
        guard
            let window = NSApplication.shared.keyWindow as? Window,
            let flutter = window.flutter else {
                fatalError("Invalid Flutter.")
        }
        return flutter
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "showProviderEditViewController":
            let flutter = self.loadFlutter()
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
        case "showInputDialog":
            let flutter = self.loadFlutter()
            let title: String
            let value: String
            if let args = call.arguments as? [Any], let arg = args.first as? [String: Any] {
                title = arg["title"] as? String ?? ""
                value = arg["value"] as? String ?? ""
            } else {
                title = ""
                value = ""
            }
            let vc = InputViewController.makeViewController(title: title, value: value) { viewController, r in
                switch r {
                case .some(let value):
                    result(value)
                    viewController.dismiss(nil)
                case .none:
                    result(FlutterError(code: "Cancel", message: "Operation cancelled.", details: nil))
                    viewController.dismiss(nil)
                }
            }
            flutter.presentAsSheet(vc)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

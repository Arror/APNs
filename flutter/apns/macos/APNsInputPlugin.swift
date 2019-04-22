//
//  APNsInputPlugin.swift
//  APNsFlutter
//
//  Created by Qiang Ma 马强 on 2019/4/2.
//  Copyright © 2019 Arror. All rights reserved.
//

import Cocoa
import FlutterMacOS

public final class APNsInputPlugin: NSObject, FLEPlugin {
    
    public static func register(with registrar: FLEPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.Arror.APNs.Input",
            binaryMessenger: registrar.messenger
        )
        registrar.addMethodCallDelegate(APNsInputPlugin(), channel: channel)
    }
    
    private override init() {
        super.init()
    }
    
    private func loadMainWindow() -> Window {
        guard
            let window = NSApplication.shared.keyWindow as? Window else {
                fatalError("Invalid Flutter.")
        }
        return window
    }
    
    private func loadFlutter() -> FLEViewController {
        guard
            let flutter = self.loadMainWindow().flutter else {
                fatalError("Invalid Flutter.")
        }
        return flutter
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
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
            let vc = APNsInputViewController.makeViewController(title: title, value: value) { viewController, r in
                switch r {
                case .some(let value):
                    result(value.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
                    viewController.dismiss(nil)
                case .none:
                    result(FlutterError(code: "Cancel", message: "Operation cancelled.", details: nil))
                    viewController.dismiss(nil)
                }
            }
            flutter.presentAsSheet(vc)
        case "showLoadCertificateDialog":
            let window = self.loadMainWindow()
            let panel = NSOpenPanel()
            panel.canChooseFiles = true
            panel.canChooseDirectories = false
            panel.allowsMultipleSelection = false
            panel.allowedFileTypes = ["p8"]
            panel.beginSheetModal(for: window) { resp in
                do {
                    let value = try panel.urls.first.map { try String(contentsOf: $0, encoding: .utf8) }
                    result(value ?? "")
                } catch {
                    result(FlutterError(code: "Error", message: error.localizedDescription, details: nil))
                }
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

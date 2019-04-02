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
        guard
            let flutter = self.loadFlutter() else {
                result(FlutterError(code: "", message: nil, details: nil))
                return
        }
        let vc = ProviderInfoEditViewController.makeViewController()
        flutter.presentAsSheet(vc)
    }
}

public class ProviderInfoEditViewController: NSViewController {
    
    
}

extension ProviderInfoEditViewController {
    
    static func makeViewController() -> ProviderInfoEditViewController {
        return NSStoryboard(name: "APNsPlugin", bundle: nil).instantiateInitialController() as! ProviderInfoEditViewController
    }
}

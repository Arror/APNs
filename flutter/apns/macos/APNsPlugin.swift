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
    
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var certificateTextField: NSTextField!
    @IBOutlet weak var teamTextField: NSTextField!
    @IBOutlet weak var keyTextField: NSTextField!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.certificateTextField.addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(chooseCertificate(_:))))
    }
    
    @objc private func chooseCertificate(_ sender: NSClickGestureRecognizer) {
        guard
            let window = NSApplication.shared.keyWindow else {
                return
        }
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedFileTypes = ["p8"]
        panel.beginSheetModal(for: window) { resp in
            guard
                let url = panel.urls.first else {
                    return
            }
            print(url)
        }
    }
    
    @IBAction func confirmButtonTapped(_ sender: NSButton) {
        self.dismiss(nil)
    }
    
    @IBAction func cancelButtonTapped(_ sender: NSButton) {
        self.dismiss(nil)
    }
}

extension ProviderInfoEditViewController {
    
    static func makeViewController() -> ProviderInfoEditViewController {
        return NSStoryboard(name: "APNsPlugin", bundle: nil).instantiateInitialController() as! ProviderInfoEditViewController
    }
}

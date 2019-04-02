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
        let vc = ProviderInfoEditViewController.makeViewController(with: .none) { controller, result in
            switch result {
            case .success(let info):
                print(info)
            case .failure(let error):
                print(error.localizedDescription)
            }
            controller.dismiss(nil)
        }
        flutter.presentAsSheet(vc)
    }
}

public struct ProviderInfo {
    public let name: String
    public let certificateName: String
    public let teamID: String
    public let keyID: String
    public let certificate: String
}

public enum ProviderInfoError: Error {
    case invalidProviderName
    case invalidCertificate
    case invalidTeamID
    case invalidKeyID
    case cancel
}

public class ProviderInfoEditViewController: NSViewController {
    
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var certificateTextField: NSTextField!
    @IBOutlet weak var teamTextField: NSTextField!
    @IBOutlet weak var keyTextField: NSTextField!

    private var certificate: String = ""
    
    private var completion: (ProviderInfoEditViewController, Swift.Result<ProviderInfo, ProviderInfoError>) -> Void = { _, _ in }
    private var info: Optional<ProviderInfo> = .none
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.certificateTextField.addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(chooseCertificate(_:))))
        self.nameTextField.stringValue = info?.name ?? ""
        self.certificateTextField.stringValue = info?.certificateName ?? ""
        self.certificate = info?.certificate ?? ""
        self.teamTextField.stringValue = info?.teamID ?? ""
        self.keyTextField.stringValue = info?.keyID ?? ""
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
            do {
                guard
                    let url = panel.urls.first else {
                        throw NSError(domain: "com.Arror.APNs.Flutter", code: -1, userInfo: nil)
                }
                self.certificateTextField.stringValue = url.lastPathComponent
                self.certificate = try String(contentsOf: url, encoding: .utf8)
            } catch {
                self.certificateTextField.stringValue = ""
                self.certificate = ""
            }
        }
    }
    
    @IBAction func confirmButtonTapped(_ sender: NSButton) {
        do {
            let name = self.nameTextField.stringValue
            let certificateName = self.certificateTextField.stringValue
            let teamID = self.teamTextField.stringValue
            let keyID = self.keyTextField.stringValue
            let certificate = self.certificate
            if name.isEmpty {
                throw ProviderInfoError.invalidProviderName
            }
            if teamID.isEmpty {
                throw ProviderInfoError.invalidTeamID
            }
            if keyID.isEmpty {
                throw ProviderInfoError.invalidKeyID
            }
            if certificate.isEmpty {
                throw ProviderInfoError.invalidCertificate
            }
            self.completion(self, .success(ProviderInfo(name: name, certificateName: certificateName, teamID: teamID, keyID: keyID, certificate: certificate)))
        } catch {
            self.completion(self, .failure(error as! ProviderInfoError))
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: NSButton) {
        self.completion(self, .failure(.cancel))
    }
}

extension ProviderInfoEditViewController {
    
    static func makeViewController(with info: Optional<ProviderInfo>, completion: @escaping (ProviderInfoEditViewController, Swift.Result<ProviderInfo, ProviderInfoError>) -> Void) -> ProviderInfoEditViewController {
        let vc = NSStoryboard(name: "APNsPlugin", bundle: nil).instantiateInitialController() as! ProviderInfoEditViewController
        vc.info = info
        vc.completion = completion
        return vc
    }
}

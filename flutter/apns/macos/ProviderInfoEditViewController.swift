//
//  ProviderInfoEditViewController.swift
//  APNsFlutter
//
//  Created by Arror on 2019/4/3.
//  Copyright © 2019 Arror. All rights reserved.
//

import Cocoa

public struct ProviderInfo: Equatable {
    
    public let name: String
    public let certificateName: String
    public let certificate: String
    public let teamID: String
    public let keyID: String
    
    public static func ==(lhs: ProviderInfo, rhs: ProviderInfo) -> Bool {
        return (lhs.teamID == rhs.teamID) && (lhs.keyID == rhs.keyID) && (lhs.certificate == rhs.certificate)
    }
    
    public init(name: String, certificateName: String, certificate: String, teamID: String, keyID: String) {
        self.name = name
        self.certificateName = certificateName
        self.certificate = certificate
        self.teamID = teamID
        self.keyID = keyID
    }
    
    public init(json: [String: Any]) {
        self.name = json["name"] as? String ?? ""
        self.certificateName = json["certificate_name"] as? String ?? ""
        self.certificate = json["certificate"] as? String ?? ""
        self.teamID = json["team_id"] as? String ?? ""
        self.keyID = json["key_id"] as? String ?? ""
    }
    
    public var json: [String: Any] {
        var dict: [String: Any] = [:]
        dict["name"] = self.name
        dict["certificate_name"] = self.certificateName
        dict["certificate"] = self.certificate
        dict["team_id"] = self.teamID
        dict["key_id"] = self.keyID
        return dict
    }
}

public class ProviderInfoEditViewController: NSViewController {
    
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var certificateTextField: NSTextField!
    @IBOutlet weak var teamTextField: NSTextField!
    @IBOutlet weak var keyTextField: NSTextField!
    
    private var certificate: String = ""
    
    private var completion: (ProviderInfoEditViewController, Optional<ProviderInfo>) -> Void = { _, _ in }
    private var info: Optional<ProviderInfo> = .none
    private var infos: [ProviderInfo] = []
    
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
        guard
            let window = self.view.window else {
                return
        }
        let name = self.nameTextField.stringValue.trimmingCharacters(in: CharacterSet.whitespaces)
        let certificateName = self.certificateTextField.stringValue.trimmingCharacters(in: CharacterSet.whitespaces)
        let teamID = self.teamTextField.stringValue.trimmingCharacters(in: CharacterSet.whitespaces)
        let keyID = self.keyTextField.stringValue.trimmingCharacters(in: CharacterSet.whitespaces)
        let certificate = self.certificate.trimmingCharacters(in: CharacterSet.whitespaces)
        
        let informativeText: String
        
        repeat {
            if name.isEmpty {
                informativeText = "名称不能为空"
                break
            } else if name.count < 4 {
                informativeText = "名称不得少于4个字符"
                break
            } else if name.count >= 20 {
                informativeText = "名称不得多于20个字符"
                break
            }
            if certificate.isEmpty {
                informativeText = "请选择证书"
                break
            }
            if teamID.isEmpty {
                informativeText = "请输入组织 ID"
                break
            } else if teamID.count != 10 {
                informativeText = "请输入合法的组织 ID"
                break
            }
            if keyID.isEmpty {
                informativeText = "请输入钥匙 ID"
                break
            } else if keyID.count != 10 {
                informativeText = "请输入合法的钥匙 ID"
                break
            }
            let new = ProviderInfo(name: name, certificateName: certificateName, certificate: certificate, teamID: teamID, keyID: keyID)
            self.completion(self, new)
            return
        } while true
        
        let alert = NSAlert()
        alert.messageText = "错误"
        alert.informativeText = informativeText
        alert.addButton(withTitle: "确定")
        alert.beginSheetModal(for: window, completionHandler: nil)
    }
    
    @IBAction func cancelButtonTapped(_ sender: NSButton) {
        self.completion(self, .none)
    }
}

extension ProviderInfoEditViewController {
    
    static func makeViewController(info: Optional<ProviderInfo>, completion: @escaping (ProviderInfoEditViewController, Optional<ProviderInfo>) -> Void) -> ProviderInfoEditViewController {
        
        let vc = NSStoryboard(name: "APNsPlugin", bundle: nil).instantiateInitialController() as! ProviderInfoEditViewController
        vc.info = info
        vc.completion = completion
        
        return vc
    }
}

//
//  CertificateView.swift
//  APNs-NG
//
//  Created by 马强 on 2020/3/28.
//  Copyright © 2020 Arror. All rights reserved.
//

import Cocoa
import SwiftyJSON

public enum CertificateType: String, Codable, CaseIterable {
    case cer
    case p12
    case p8
}

public struct APNsCertificate: Codable {
    
    public let certificateType: CertificateType
    public let name: String
    public let data: Data
    public let passphrase: String
    
    public init(certificateType: CertificateType, passphrase: String, name: String, data: Data) {
        self.certificateType = certificateType
        self.passphrase = passphrase
        self.name = name
        self.data = data
    }
}

class CertificateView: NSView {
    
    var passphraseTextField: NSTextField!
    
    @IBOutlet private weak var label: NSTextField!
    
    private var isInDragDropProcess: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.registerForDraggedTypes([.fileURL])
        self.updateLabel()
    }
    
    private func updateLabel() {
        switch AppService.current.certificateObject.value {
        case .some(let certificate):
            self.label.stringValue = self.isInDragDropProcess ? "释放" : certificate.name
        case .none:
            self.label.stringValue = self.isInDragDropProcess ? "释放" : "拖拽证书文件到这里"
        }
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        self.isInDragDropProcess = true
        self.updateLabel()
        return .copy
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        self.isInDragDropProcess = false
        self.updateLabel()
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        self.isInDragDropProcess = false
        self.updateLabel()
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard
            let types = sender.draggingPasteboard.types, types.contains(.fileURL) else {
                return false
        }
        guard
            let fileURLs = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL],
            let fileURL = fileURLs.first else {
            return false
        }
        guard
            let certificateType = CertificateType(rawValue: fileURL.pathExtension),
            let data = try? Data(contentsOf: fileURL) else {
                return false
        }
        let name = fileURL.lastPathComponent
        let passphrase: String
        if certificateType == .p12 {
            let alert = NSAlert()
            alert.messageText = "Input passphrase"
            alert.addButton(withTitle: "OK")
            alert.accessoryView = self.passphraseTextField
            alert.runModal()
            passphrase = self.passphraseTextField.stringValue
            self.passphraseTextField.stringValue = ""
        } else {
            passphrase = ""
        }
        AppService.current.certificateObject.value = APNsCertificate(
            certificateType: certificateType,
            passphrase: passphrase,
            name: name,
            data: data
        )
        return true
    }
}

extension URL {
    
    var isCertificateFileURL: Bool {
        return self.isFileURL && CertificateType.allCases.map({ $0.rawValue }).contains(self.pathExtension)
    }
}

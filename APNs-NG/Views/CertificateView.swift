//
//  CertificateView.swift
//  APNs-NG
//
//  Created by 马强 on 2020/3/28.
//  Copyright © 2020 Arror. All rights reserved.
//

import Cocoa
import SwiftUI
import Combine

struct CertificateView: View, DropDelegate {
        
    @EnvironmentObject var appService: AppService
    
    @State private var certificateUpdating: Bool = false
    @State private var isInDragDropProcessing: Bool = false
    
    var body: some View {
        GroupBox {
            Text(
                self.isInDragDropProcessing ?
                    "释放以设置证书" :
                    (
                        self.certificateUpdating ?
                        "..." :
                        self.appService.apnsCertificate?.name ?? "拖拽证书文件到这里，支持cer、pem、p12、p8类型证书"
                    )
            )
                .frame(maxWidth: .infinity, minHeight: 60.0, idealHeight: 60.0, maxHeight: 60.0)
                .background(Color.textBackgroundColor)
        }
        .onDrop(of: [kUTTypeFileURL as String], delegate: self)
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        let providers = info.itemProviders(for: [kUTTypeFileURL as String])
        return providers.count == 1
    }
    
    func performDrop(info: DropInfo) -> Bool {
        let typeIdentifier = kUTTypeFileURL as String
        let providers = info.itemProviders(for: [typeIdentifier])
        guard providers.count == 1 else {
            return false
        }
        let provider = providers[0]
        provider.loadDataRepresentation(forTypeIdentifier: typeIdentifier) { data, _ in
            guard
                let dataRepresentation = data,
                let fileURL = NSURL(dataRepresentation: dataRepresentation, relativeTo: nil).absoluteURL else {
                    self.certificateUpdating = false
                    return
            }
            guard
                let certificateType = CertificateType(rawValue: fileURL.pathExtension),
                let certificateData = try? Data(contentsOf: fileURL) else {
                    self.certificateUpdating = false
                    return
            }
            self.inputPassphrase(certificateType: certificateType) { passphrase in
                self.appService.apnsCertificate = APNsCertificate(
                    certificateType: certificateType,
                    passphrase: passphrase,
                    name: fileURL.lastPathComponent,
                    data: certificateData
                )
                self.certificateUpdating = false
            }
        }
        self.certificateUpdating = true
        return true
    }
    
    private func inputPassphrase(certificateType: CertificateType, completion: @escaping (String) -> Void) {
        DispatchQueue.main.async {
            switch certificateType {
            case .p12:
                let alert = NSAlert()
                alert.messageText = "输入密码"
                alert.informativeText = "如果未设置密码，请直接点击确定按钮"
                alert.addButton(withTitle: "确定")
                let textField = NSSecureTextField(frame: NSRect(origin: .zero, size: CGSize(width: 300, height: 20)))
                alert.accessoryView = textField
                textField.becomeFirstResponder()
                alert.beginSheetModal(for: AppDelegate.shared.window) { _ in
                    completion(textField.stringValue)
                }
            case .cer, .pem, .p8:
                completion("")
            }
        }
    }
    
    func dropEntered(info: DropInfo) {
        self.isInDragDropProcessing = true
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .copy)
    }
    
    func dropExited(info: DropInfo) {
        self.isInDragDropProcessing = false
    }
}

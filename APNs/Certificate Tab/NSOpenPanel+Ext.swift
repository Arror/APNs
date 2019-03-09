//
//  NSOpenPanel+Ext.swift
//  APNs
//
//  Created by Qiang Ma 马强 on 2019/3/9.
//  Copyright © 2019 Arror. All rights reserved.
//

import AppKit

extension NSOpenPanel {
    
    public static func chooseCertificateFile(type: String, from window: NSWindow, completion: @escaping (Optional<(URL, Data)>) -> Void) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedFileTypes = [type]
        panel.beginSheetModal(for: window) { resp in
            guard
                let url = panel.urls.first, let data = try? Data(contentsOf: url) else {
                    completion(.none)
                    return
            }
            completion((url, data))
        }
    }
}

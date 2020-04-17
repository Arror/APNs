//
//  AppDelegate.swift
//  APNs-NG
//
//  Created by 马强 on 2020/3/27.
//  Copyright © 2020 Arror. All rights reserved.
//

import Cocoa
import SwiftUI
import Combine

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet private weak var tooBar: NSToolbar!
    
    private var cancellables: Set<AnyCancellable> = []
    private let service = AppService()
    
    let window = NSWindow(
        contentRect: .zero,
        styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
        backing: .buffered,
        defer: false
    )
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        let contentView = ContentView().environmentObject(self.service)
        self.window.titleVisibility = .hidden
        self.window.center()
        self.window.setFrameAutosaveName("Main Window")
        self.window.contentView = NSHostingView(rootView: contentView)
        self.window.makeKeyAndOrderFront(nil)
        self.window.toolbar = self.tooBar
        
        self.service.apnsStateSubject
            .sink { state in
                DispatchQueue.main.async {
                    switch state {
                    case .idle, .process:
                        break
                    case .failure(let reason):
                        let alert = NSAlert()
                        alert.alertStyle = .critical
                        alert.messageText = "错误"
                        alert.informativeText = reason
                        alert.beginSheetModal(for: self.window) { _ in }
                    case .success:
                        let alert = NSAlert()
                        alert.alertStyle = .informational
                        alert.messageText = "成功"
                        alert.informativeText = "推送成功"
                        alert.beginSheetModal(for: self.window) { _ in }
                    }
                }
            }
            .store(in: &self.cancellables)
    }

    func applicationWillTerminate(_ aNotification: Notification) {}
    
//    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
//        do {
//            try AppService.current.savePreference()
//        } catch {
//            APNsLog.error(error.localizedDescription)
//        }
//        return true
//    }
}

extension AppDelegate {
    
    static var shared: AppDelegate {
        return NSApplication.shared.delegate as! AppDelegate
    }
}

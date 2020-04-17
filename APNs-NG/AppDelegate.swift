//
//  AppDelegate.swift
//  APNs-NG
//
//  Created by 马强 on 2020/3/27.
//  Copyright © 2020 Arror. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet private weak var tooBar: NSToolbar!
    
    private let service = AppService()
    
    private let window = NSWindow(
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

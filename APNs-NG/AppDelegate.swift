//
//  AppDelegate.swift
//  APNs-NG
//
//  Created by 马强 on 2020/3/27.
//  Copyright © 2020 Arror. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {}

    func applicationWillTerminate(_ aNotification: Notification) {}
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        do {
            try AppService.current.savePreference()
        } catch {
            APNsLog.error(error.localizedDescription)
        }
        return true
    }
}

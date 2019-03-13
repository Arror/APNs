//
//  AppDelegate.swift
//  APNs
//
//  Created by Arror on 2019/3/3.
//  Copyright © 2019 Arror. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag {
            return false
        } else {
            sender.windows.first?.makeKeyAndOrderFront(self)
            return true
        }
    }
}


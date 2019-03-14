//
//  AppDelegate.swift
//  APNsFlutter
//
//  Created by Arror on 2019/3/14.
//  Copyright © 2019 Arror. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}


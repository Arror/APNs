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
    
    private static let keychainService      = "APNs"
    private static let keycahinAccessGroup  = "A8XWAF2UFT.com.Arror.keychain.shared"
    
    private let preferenceKey = CodableStorageKey<APNsPreference>(stringKey: "USER.PREFERENCE")
        
    @IBOutlet private weak var tooBar: NSToolbar!
    
    private var cancellables: Set<AnyCancellable> = []
    
    let window = NSWindow(
        contentRect: .zero,
        styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
        backing: .buffered,
        defer: false
    )
    
    let keychainStorage = KeychainStorage(
        service: AppDelegate.keychainService,
        accessGroup: AppDelegate.keycahinAccessGroup
    )
    
    private var appService: AppService!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        self.migrateAPNsPreferenceIfNeeded()
        
        self.appService = {
            let preference: Optional<APNsPreference>
            do {
                preference = try self.keychainStorage.item(for: self.preferenceKey)
            } catch {
                preference = .none
            }
            return AppService(preference: preference)
        }()
        
        let contentView = ContentView().environmentObject(self.appService)
        self.window.titleVisibility = .hidden
        self.window.center()
        self.window.setFrameAutosaveName("Main Window")
        self.window.contentView = NSHostingView(rootView: contentView)
        self.window.makeKeyAndOrderFront(nil)
        self.window.toolbar = self.tooBar

        appService.apnsStateSubject
            .sink { state in
                DispatchQueue.main.async {
                    switch state {
                    case .idle, .process:
                        break
                    case .failure(let reason):
                        let alert = NSAlert()
                        alert.alertStyle = .critical
                        alert.messageText = String.localizedString(forKey: "Appdelegate.Alert.Failure")
                        alert.informativeText = reason
                        alert.beginSheetModal(for: self.window) { _ in }
                    case .success:
                        let alert = NSAlert()
                        alert.alertStyle = .informational
                        alert.messageText = String.localizedString(forKey: "Appdelegate.Alert.Success")
                        alert.informativeText = String.localizedString(forKey: "Appdelegate.Alert.SuccessMessage")
                        alert.beginSheetModal(for: self.window) { _ in }
                    }
                }
            }
            .store(in: &self.cancellables)
    }

    func applicationWillTerminate(_ aNotification: Notification) {}
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        
        let service: AppService = self.appService
        let preference = APNsPreference(
            teamID: service.teamID,
            keyID: service.keyID,
            bundleID: service.bundleID,
            service: service.apnsService,
            certificate: service.apnsCertificate,
            token: service.token,
            priority: service.priority
        )
        do {
            try self.keychainStorage.set(item: preference, for: self.preferenceKey)
        } catch {
            
        }
        
        return true
    }
}

extension AppDelegate {
    
    private func migrateAPNsPreferenceIfNeeded() {
        guard let data = UserDefaults.standard.data(forKey: self.preferenceKey.stringKey) else {
            return
        }
        do {
            let preference = try JSONDecoder().decode(APNsPreference.self, from: data)
            try self.keychainStorage.set(item: preference, for: self.preferenceKey)
        } catch {
            
        }
        UserDefaults.standard.removeObject(forKey: self.preferenceKey.stringKey)
    }
}

extension AppDelegate {
    
    static var shared: AppDelegate {
        return NSApplication.shared.delegate as! AppDelegate
    }
}

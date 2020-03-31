//
//  APNsViewController.swift
//  APNs-NG
//
//  Created by 马强 on 2020/3/27.
//  Copyright © 2020 Arror. All rights reserved.
//

import Cocoa
import Combine

class APNsViewController: NSViewController {

    @IBOutlet private var passphraseTextField: NSTextField!
    @IBOutlet private weak var certificateView: CertificateView!
    @IBOutlet private weak var deviceOnlyView: NSStackView!
    @IBOutlet private weak var simulatorOnlyView: NSStackView!
    @IBOutlet private weak var priorityView: NSView!
    
    @IBOutlet private weak var teamIDView: TeamIDView!
    @IBOutlet private weak var keyIDView: KeyIDView!
    @IBOutlet private weak var bundleIDView: BundleIDView!
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.certificateView.passphraseTextField = self.passphraseTextField
        let destinationToDevice = AppService.current.destinationObject.$value.map({ $0 == .device })
        self.cancellables.insert(destinationToDevice.map({ !$0 }).assign(to: \APNsViewController.deviceOnlyView.isHidden, on: self))
        self.cancellables.insert(destinationToDevice.assign(to: \APNsViewController.simulatorOnlyView.isHidden, on: self))
        self.cancellables.insert(destinationToDevice.map({ !$0 }).assign(to: \APNsViewController.priorityView.isHidden, on: self))
        self.updateViews(using: AppService.current.certificateObject.value)
        self.cancellables.insert(
            AppService.current.certificateObject.$value.sink { [weak self] certificate in
                guard let self = self else {
                    return
                }
                self.updateViews(using: certificate)
            }
        )
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        guard let toolbar = self.view.window?.toolbar else {
            return
        }
        let removedIdentifier: NSToolbarItem.Identifier = {
            #if COMMUNITY
            return NSToolbarItem.Identifier("APNsTitle")
            #else
            return NSToolbarItem.Identifier("APNsSegment")
            #endif
        }()
        guard let index = toolbar.items.firstIndex(where: { $0.itemIdentifier == removedIdentifier }) else {
            return
        }
        toolbar.removeItem(at: index)
    }
    
    private func updateViews(using certificate: APNsCertificate?) {
        switch certificate {
        case .some(let certificate):
            switch certificate.certificateType {
            case .cer:
                self.teamIDView.isHidden = true
                self.keyIDView.isHidden = true
            case .p12:
                self.teamIDView.isHidden = true
                self.keyIDView.isHidden = true
            case .p8:
                self.teamIDView.isHidden = false
                self.keyIDView.isHidden = false
            }
            self.bundleIDView.isHidden = false
        case .none:
            self.teamIDView.isHidden = true
            self.keyIDView.isHidden = true
            self.bundleIDView.isHidden = true
        }
    }
}

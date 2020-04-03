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

    @IBOutlet private weak var deviceOnlyView: NSStackView!
    @IBOutlet private weak var simulatorOnlyView: NSStackView!
    @IBOutlet private weak var priorityView: NSView!
    @IBOutlet private weak var teamIDView: TeamIDView!
    @IBOutlet private weak var keyIDView: KeyIDView!
    @IBOutlet private weak var bundleIDView: BundleIDView!
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let destinationToDevice = AppService.current.destinationObject.$value.map({ $0 == .device })
        destinationToDevice
            .map({ !$0 })
            .assign(to: \APNsViewController.deviceOnlyView.isHidden, on: self)
            .store(in: &self.cancellables)
        destinationToDevice
            .assign(to: \APNsViewController.simulatorOnlyView.isHidden, on: self)
            .store(in: &self.cancellables)
        destinationToDevice
            .map({ !$0 })
            .assign(to: \APNsViewController.priorityView.isHidden, on: self)
            .store(in: &self.cancellables)
        let certificatePublisher = AppService.current.certificateObject.$value
        certificatePublisher
            .map({ $0?.certificateType != .some(.p8) })
            .assign(to: \.teamIDView.isHidden, on: self)
            .store(in: &self.cancellables)
        certificatePublisher
            .map({ $0?.certificateType != .some(.p8) })
            .assign(to: \.keyIDView.isHidden, on: self)
            .store(in: &self.cancellables)
        certificatePublisher
            .map({ $0?.certificateType == .none })
            .assign(to: \.bundleIDView.isHidden, on: self)
            .store(in: &self.cancellables)
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
}

//
//  APNsWindowViewController.swift
//  APNs-NG
//
//  Created by 马强 on 2020/3/28.
//  Copyright © 2020 Arror. All rights reserved.
//

import Cocoa

public enum APNsDestination: String, Codable {
    case device
    case simulator
}

fileprivate extension APNsDestination {
    
    var segmentIndex: Int {
        switch self {
        case .device:
            return 0
        case .simulator:
            return 1
        }
    }
    
    init?(segmentIndex: Int) {
        switch segmentIndex {
        case 0:
            self = .device
        case 1:
            self = .simulator
        default:
            return nil
        }
    }
}

class APNsWindowViewController: NSWindowController {
    
    @IBOutlet private weak var segmentedControl: NSSegmentedControl!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.segmentedControl.selectedSegment = AppService.current.destinationObject.value.segmentIndex
    }
    
    @IBAction private func segmentedControlVaueChanged(_ sender: NSSegmentedControl) {
        guard let destination = APNsDestination(segmentIndex: sender.selectedSegment) else {
            return
        }
        AppService.current.destinationObject.value = destination
    }
}

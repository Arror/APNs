//
//  SimulatorView.swift
//  APNs-NG
//
//  Created by 马强 on 2020/3/28.
//  Copyright © 2020 Arror. All rights reserved.
//

import Cocoa
import SwiftyJSON
import Combine

public struct APNsDevice {
    
    let name: String
    let udid: String
    let state: String
    let osVersion: String
    
    init(os: OS, device: OS.Device) {
        self.name = device.name
        self.udid = device.udid
        self.state = device.state
        self.osVersion = os.version
    }
    
    private init() {
        self.name = "NONE"
        self.udid = ""
        self.state = ""
        self.osVersion = ""
    }
    
    static let fake = APNsDevice()
}

class SimulatorView: NSView {
    
    private let device: [APNsDevice] = SimulatorController.allDevices()
    
    @IBOutlet private weak var simulatorsPicker: NSPopUpButton!
    
    @objc private func simulatorsPickerValueChanged(_ sender: NSPopUpButton) {
        AppService.current.deviceObject.value = self.device[sender.indexOfSelectedItem]
    }
    
    private var cancellable: AnyCancellable?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.simulatorsPicker.target = self
        self.simulatorsPicker.action = #selector(simulatorsPickerValueChanged)
        self.simulatorsPicker.removeAllItems()
        self.simulatorsPicker.addItems(withTitles: self.device.map({ "\($0.name) (\($0.osVersion))" }))
        if !self.device.isEmpty {
            AppService.current.deviceObject.value = self.device[self.simulatorsPicker.indexOfSelectedItem]
        }
    }
}

class SimulatorController {
    
    static func fetchOS() -> [OS] {
        do {
            let executor = Executor()
            let json = try JSON(data: try executor.execute("xcrun", "simctl", "list", "--json"))
            return json["runtimes"].arrayValue
                .filter({ $0["name"].stringValue.hasPrefix("iOS") })
                .map({ OS(json: $0, deviceMapping: json["devices"].dictionaryValue) })
        } catch {
            return []
        }
    }
    
    static func allDevices() -> [APNsDevice] {
        return self.fetchOS().reduce(into: []) { r, n in
            n.devices.forEach { d in
                r.append(APNsDevice(os: n, device: d))
            }
        }
    }
}

struct OS {
    struct Device {
        let name: String
        let udid: String
        let state: String
        init(json: JSON) {
            self.name = json["name"].stringValue
            self.udid = json["udid"].stringValue
            self.state = json["state"].stringValue
        }
    }
    let name: String
    let version: String
    let devices: [Device]
    init(json: JSON, deviceMapping: [String: JSON]) {
        self.name = json["name"].stringValue
        self.version = json["version"].stringValue
        if let deviceJSONs = deviceMapping[json["identifier"].stringValue] {
            self.devices = deviceJSONs.arrayValue.map(Device.init(json:))
        } else {
            self.devices = []
        }
    }
}

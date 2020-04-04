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

class SimulatorView: NSView {
    
    private let simulators: [SimulatorController.Simulator] = {
        let controller = SimulatorController()
        let all = controller.loadSimulators()
        let iPhones = all.filter({ $0.device.name.hasPrefix("iPhone") })
        let iPads = all.filter({ $0.device.name.hasPrefix("iPad") })
        return iPhones + iPads
    }()
        
    @IBOutlet private weak var simulatorPicker: NSPopUpButton!
    @IBOutlet private weak var applicationPicker: NSPopUpButton!
    
    @objc private func simulatorPickerValueChanged(_ sender: NSPopUpButton) {
        AppService.current.simulatorObject.value = self.simulators[sender.indexOfSelectedItem]
        self.updateApplicationPicker()
    }
    
    @objc private func applicationPickerValueChanged(_ sender: NSPopUpButton) {
        if let simulator = AppService.current.simulatorObject.value {
            AppService.current.applicationObject.value = simulator.applications[sender.indexOfSelectedItem]
        } else {
            AppService.current.applicationObject.value = nil
        }
    }
    
    private var cancellable: AnyCancellable?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.simulatorPicker.target = self
        self.simulatorPicker.action = #selector(simulatorPickerValueChanged)
        self.simulatorPicker.removeAllItems()
        self.simulatorPicker.addItems(withTitles: self.simulators.map { "\($0.device.name) (\($0.runtime.version))" })
        if self.simulators.isEmpty {
            AppService.current.simulatorObject.value = .none
        } else {
            AppService.current.simulatorObject.value = self.simulators[self.simulatorPicker.indexOfSelectedItem]
        }
        self.updateApplicationPicker()
    }
    
    private func updateApplicationPicker() {
        self.applicationPicker.target = self
        self.applicationPicker.action = #selector(applicationPickerValueChanged)
        self.applicationPicker.removeAllItems()
        let applications: [SimulatorController.Simulator.Application]
        if let simulator = AppService.current.simulatorObject.value {
            simulator.loadApplications()
            applications = simulator.applications
            AppService.current.applicationObject.value = simulator.applications.first
        } else {
            applications = []
            AppService.current.applicationObject.value = nil
        }
        self.applicationPicker.addItems(withTitles: applications.map({ $0.bundleIdentifier }))
    }
}

public class SimulatorController {
    
    public class Simulator {
        
        public struct Application: Decodable, Equatable {
            let applicationType: String
            let displayName: String
            let bundleIdentifier: String
            private enum CodingKeys: String, CodingKey {
                case applicationType = "ApplicationType"
                case displayName = "CFBundleDisplayName"
                case bundleIdentifier = "CFBundleIdentifier"
            }
        }
        
        let runtime: SimulatorControl.Runtime
        let device: SimulatorControl.Device
        
        private(set) var applications: [Application] = []
        
        init(runtime: SimulatorControl.Runtime, device: SimulatorControl.Device) {
            self.runtime = runtime
            self.device = device
        }
        
        func loadApplications() {
            do {
                let data = try Executor.execute("xcrun", "simctl", "listapps", self.device.udid, "-j")
                let mapping = try PropertyListDecoder().decode([String: Application].self, from: data)
                self.applications = mapping.compactMap { pair in
                    guard pair.value.applicationType == "User" else {
                        return nil
                    }
                    return pair.value
                }
            } catch {
                self.applications = []
            }
        }
    }
        
    public init() {}
    
    public func loadSimulators() -> [Simulator] {
        do {
            let control = SimulatorControl(json: try JSON(data: try Executor.execute("xcrun", "simctl", "list", "--json")))
            return control.runtimes.flatMap { runtime in
                return runtime.devices.map { device in
                    return Simulator(runtime: runtime, device: device)
                }
            }
        } catch {
            return []
        }
    }
}

struct SimulatorControl {
    
    struct Device {
        let name: String
        let udid: String
    }
    
    struct Runtime {
        let name: String
        let version: String
        let devices: [Device]
    }
    
    let runtimes: [Runtime]
    
    init(json: JSON) {
        self.runtimes = json["runtimes"].arrayValue.compactMap { runtime in
            guard let devicesJSON = json["devices"].dictionaryValue[runtime["identifier"].stringValue] else {
                return nil
            }
            return Runtime(
                name: runtime["name"].stringValue,
                version: runtime["version"].stringValue,
                devices: devicesJSON.arrayValue.map({ device in
                    return Device(name: device["name"].stringValue, udid: device["udid"].stringValue)
                })
            )
        }
    }
}

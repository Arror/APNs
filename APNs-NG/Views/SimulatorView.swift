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
        
    @IBOutlet private weak var simulatorsPicker: NSPopUpButton!
    
    @objc private func simulatorsPickerValueChanged(_ sender: NSPopUpButton) {
        AppService.current.deviceObject.value = self.simulators[sender.indexOfSelectedItem]
    }
    
    private var cancellable: AnyCancellable?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.simulatorsPicker.target = self
        self.simulatorsPicker.action = #selector(simulatorsPickerValueChanged)
        self.simulatorsPicker.removeAllItems()
        let titles = self.simulators.map { simulator in
            return "\(simulator.device.name) (\(simulator.runtime.version))"
        }
        self.simulatorsPicker.addItems(withTitles: titles)
        if self.simulators.isEmpty {
            AppService.current.deviceObject.value = .none
        } else {
            AppService.current.deviceObject.value = self.simulators[self.simulatorsPicker.indexOfSelectedItem]
        }
    }
}

public class SimulatorController {
    
    public class Simulator {
        
        let runtime: SimulatorControl.Runtime
        let device: SimulatorControl.Device
        
        init(runtime: SimulatorControl.Runtime, device: SimulatorControl.Device) {
            self.runtime = runtime
            self.device = device
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

//
//  EnvironmentView.swift
//  APNs-NG
//
//  Created by 马强 on 2020/3/28.
//  Copyright © 2020 Arror. All rights reserved.
//

import Cocoa
import Combine

public enum APNsEnvironment: String, Equatable, Codable {
    case production
    case sandbox
}

public final class APNsEnvironmentObject: ObservableObject {
    
    @Published var environment: APNsEnvironment
    
    public init() {
        self.environment = .sandbox
    }
}

class EnvironmentView: NSView {
    
    @IBOutlet private weak var productionButton: NSButton!
    @IBOutlet private weak var sandboxButton: NSButton!
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.productionButton.state = AppService.current.environmentObject.value == .production ? .on : .off
        self.sandboxButton.state = AppService.current.environmentObject.value == .sandbox ? .on : .off
        AppService.current.environmentObject.$value
            .map { $0 == .production ? .on : .off }
            .assign(to: \.productionButton.state, on: self)
            .store(in: &self.cancellables)
        AppService.current.environmentObject.$value
            .map { $0 == .production ? .off : .on }
            .assign(to: \.sandboxButton.state, on: self)
            .store(in: &self.cancellables)
    }
    
    @IBAction func productionButtonTapped(_ sender: NSButton) {
        AppService.current.environmentObject.value = .production
    }
    
    @IBAction func sandboxButtonTapped(_ sender: NSButton) {
        AppService.current.environmentObject.value = .sandbox
    }
}

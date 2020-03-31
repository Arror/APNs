//
//  EnvironmentView.swift
//  APNs-NG
//
//  Created by 马强 on 2020/3/28.
//  Copyright © 2020 Arror. All rights reserved.
//

import Cocoa
import Combine

public enum APNsEnvironment: String, Codable {
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
        self.updateButtons(environment: AppService.current.environmentObject.value)
        self.cancellables.insert(
            AppService.current.environmentObject.$value.sink(receiveValue: { [weak self] environment in
                guard let self = self else { return }
                self.updateButtons(environment: environment)
            })
        )
    }
    
    private func updateButtons(environment: APNsEnvironment) {
        switch environment {
        case .production:
            self.productionButton.state = .on
            self.sandboxButton.state = .off
        case .sandbox:
            self.productionButton.state = .off
            self.sandboxButton.state = .on
        }
    }
    
    @IBAction func productionButtonTapped(_ sender: NSButton) {
        AppService.current.environmentObject.value = .production
    }
    
    @IBAction func sandboxButtonTapped(_ sender: NSButton) {
        AppService.current.environmentObject.value = .sandbox
    }
}

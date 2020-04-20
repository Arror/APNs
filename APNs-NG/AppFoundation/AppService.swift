//
//  AppService.swift
//  APNs-NG
//
//  Created by 马强 on 2020/3/28.
//  Copyright © 2020 Arror. All rights reserved.
//

import Cocoa
import Combine
import SwiftUI

public final class AppService: ObservableObject {
    
    @Published public var apnsCertificate: Optional<APNsCertificate> = .none
    @Published public var teamID: String = ""
    @Published public var keyID: String = ""
    @Published public var bundleID: String = ""
    @Published public var token: String = ""
    @Published public var apnsService: APNsService = .sandbox
    @Published public var priority: Int = 5
    @Published public var payload: String = """
    {
        "aps": {
            "content-available": 1,
            "alert": {
                "title": "Push Notification",
                "body": "Notification from APNs Provider."
            },
            "badge": 9,
            "sound": "default"
        }
    }
    """
    @Published var isInPushProcessing: Bool = false
    
    public let pushSubject = PassthroughSubject<Void, Never>()
    public let apnsStateSubject = CurrentValueSubject<APNsState, Never>(.idle)
    
    private var cancellables: Set<AnyCancellable> = []
    
    public init() {
        
        let preference = AppService.loadPreference()
        self.apnsCertificate = preference?.certificate
        self.teamID = preference?.teamID ?? ""
        self.keyID = preference?.keyID ?? ""
        self.bundleID = preference?.bundleID ?? ""
        self.token = preference?.token ?? ""
        self.apnsService = preference?.service ?? .sandbox
        self.priority = preference?.priority ?? 5
        
        self.pushSubject.sink { _ in
            self.apnsStateSubject.send(.process)
            do {
                try self.makeRawPushPublsher()
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            self.apnsStateSubject.send(.success)
                            self.apnsStateSubject.send(.idle)
                        case .failure(let error):
                            self.apnsStateSubject.send(.failure(error.localizedDescription))
                            self.apnsStateSubject.send(.idle)
                        }
                    }, receiveValue: { _ in })
                    .store(in: &self.cancellables)
            } catch {
                self.apnsStateSubject.send(.failure(error.localizedDescription))
                self.apnsStateSubject.send(.idle)
            }
        }
        .store(in: &self.cancellables)
        
        self.apnsStateSubject
            .map({ $0 == .idle })
            .map({ !$0 })
            .assign(to: \.isInPushProcessing, on: self)
            .store(in: &self.cancellables)
    }
}

extension String {
    
    static func localizedString(forKey key: String) -> String {
        return NSLocalizedString(key, comment: "Content")
    }
}

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
import SwiftyJSON
import Logging
import LoggerAPI

public struct Preference: Codable {
    public let teamID: String
    public let keyID: String
    public let bundleID: String
    public let service: APNsService
    public let certificate: Optional<APNsCertificate>
    public let token: String
    public let priority: Int
}

public enum CertificateType: String, Equatable, Codable, CaseIterable {
    
    case cer    = "cer"
    case pem    = "pem"
    case p12    = "p12"
    case p8     = "p8"
    
    public static let availableFileExtensions: Set<String> = Set(CertificateType.allCases.map(\.rawValue))
    
    public func loadData(from fileURL: URL) -> Data? {
        switch self {
        case .cer, .p12, .p8:
            return nil
        case .pem:
            return nil
        }
    }
}

public struct APNsCertificate: Codable {
    
    public let certificateType: CertificateType
    public let name: String
    public let data: Data
    public let passphrase: String
    
    public init(certificateType: CertificateType, passphrase: String, name: String, data: Data) {
        self.certificateType = certificateType
        self.passphrase = passphrase
        self.name = name
        self.data = data
    }
}

extension String {
    
    public var trimmed: String {
        return self.trimmingCharacters(in: CharacterSet(charactersIn: "\n "))
    }
}

public enum APNsService: String, Codable, Equatable, CaseIterable {
    
    case sandbox
    case production
    
    var name: String {
        switch self {
        case .sandbox:
            return "Sandbox"
        case .production:
            return "Production"
        }
    }
}

public enum APNsState {
    case idle
    case process
    case success
    case failure(String)
}

public final class AppService: ObservableObject {
    
    private static let preferenceStoreKey = "USER.PREFERENCE"
    
    private static func loadPreference() -> Preference? {
        guard let data = UserDefaults.standard.data(forKey: AppService.preferenceStoreKey) else {
            return nil
        }
        do {
            return try JSONDecoder().decode(Preference.self, from: data)
        } catch {
            return nil
        }
    }

    func savePreference() {
        let preference = Preference(
            teamID: self.teamID,
            keyID: self.keyID,
            bundleID: self.bundleID,
            service: self.apnsService,
            certificate: self.apnsCertificate,
            token: self.token,
            priority: self.priority
        )
        do {
            UserDefaults.standard.set(try JSONEncoder().encode(preference), forKey: AppService.preferenceStoreKey)
        } catch {
            
        }
    }
    
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
    }
}

extension Color {
    
    static let textColor = Color("text_color")
    
    static let textBackgroundColor = Color("text_input_background_color")
}

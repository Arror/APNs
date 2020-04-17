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

//public struct Preference: Codable {
//    public let teamID: String
//    public let keyID: String
//    public let bundleID: String
//    public let environment: APNsEnvironment
//    public let certificate: Optional<APNsCertificate>
//    public let token: String
//    public let priority: Int
//}

//public class AppService {
//
//    private static let preferenceStoreKey = "USER.PREFERENCE"
//
//    private static func loadPreference() -> Preference? {
//        guard let data = UserDefaults.standard.data(forKey: AppService.preferenceStoreKey) else {
//            return nil
//        }
//        do {
//            return try JSONDecoder().decode(Preference.self, from: data)
//        } catch {
//            return nil
//        }
//    }
//
//    func savePreference() throws {
//        let preference = Preference(
//            teamID: self.teamIDObject.value,
//            keyID: self.keyIDObject.value,
//            bundleID: self.bundleIDObject.value,
//            environment: self.environmentObject.value,
//            certificate: self.certificateObject.value,
//            token: self.tokenObject.value,
//            priority: self.priorityObject.value
//        )
//        UserDefaults.standard.set(try JSONEncoder().encode(preference), forKey: AppService.preferenceStoreKey)
//    }
//
//    public static let current = AppService()
//
//    private var cancellables: Set<AnyCancellable> = []
//
//    private init() {
//        LoggingSystem.bootstrap(APNsLogHandler.apnsLog)
//        LoggerAPI.Log.swiftLogger = Logging.Logger(label: "com.Arror.APNs")
//
//        let preference = AppService.loadPreference()
//        self.bundleIDObject     = ObservableWrapper<String>(preference?.bundleID ?? "")
//        self.certificateObject  = ObservableWrapper<Optional<APNsCertificate>>(preference?.certificate)
//        self.tokenObject        = ObservableWrapper<String>(preference?.token ?? "")
//        self.priorityObject     = ObservableWrapper<Int>(preference?.priority ?? 5)
//        self.teamIDObject       = ObservableWrapper<String>(preference?.teamID ?? "")
//        self.keyIDObject        = ObservableWrapper<String>(preference?.keyID ?? "")
//        self.environmentObject  = ObservableWrapper<APNsEnvironment>(preference?.environment ?? .sandbox)
//
//        let triggerToken = self.pushTrigger.sink { [unowned self] _ in
//            do {
//                let provider = try APNsProviderFactory.provider(forCurrentService: self)
//                self.indicatorSubject.send(true)
//                APNsLog.info("正在发送。。。")
//                provider.send(payload: self.payloadObject.value.trimmed, token: self.tokenObject.value.trimmed, priorty: self.priorityObject.value) { result in
//                    self.indicatorSubject.send(false)
//                    switch result {
//                    case .success:
//                        APNsLog.info("发送成功")
//                    case .failure(let error):
//                        APNsLog.error(error.localizedDescription)
//                    }
//                }
//            } catch {
//                APNsLog.error(error.localizedDescription)
//            }
//        }
//        self.cancellables.insert(triggerToken)
//    }
//
//    public let bundleIDObject:      ObservableWrapper<String>
//    public let certificateObject:   ObservableWrapper<Optional<APNsCertificate>>
//    public let tokenObject:         ObservableWrapper<String>
//    public let priorityObject:      ObservableWrapper<Int>
//    public let teamIDObject:        ObservableWrapper<String>
//    public let keyIDObject:         ObservableWrapper<String>
//    public let environmentObject:   ObservableWrapper<APNsEnvironment>
//
//    public let simulatorObject      = ObservableWrapper<Optional<SimulatorController.Simulator>>(.none)
//    public let applicationObject    = ObservableWrapper<Optional<SimulatorController.Simulator.Application>>(.none)
//    public let payloadObject        = ObservableWrapper<String>(
//        """
//        {
//            "aps": {
//                "content-available": 1,
//                "alert": {
//                    "title": "Title",
//                    "body": "Your message here."
//                },
//                "badge": 9,
//                "sound": "default"
//            }
//        }
//        """
//    )
//    public let logObject    = ObservableWrapper<String>("")
//    public let pushTrigger  = PassthroughSubject<Void, Never>()
//
//    public let indicatorSubject = CurrentValueSubject<Bool, Never>(false)
//}
//
//public final class ObservableWrapper<Value>: ObservableObject {
//
//    @Published public var value: Value
//
//    public init(_ value: Value) {
//        self.value = value
//    }
//}

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

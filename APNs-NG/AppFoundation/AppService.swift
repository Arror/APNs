//
//  AppService.swift
//  APNs-NG
//
//  Created by 马强 on 2020/3/28.
//  Copyright © 2020 Arror. All rights reserved.
//

import Foundation
import Combine
import SwiftyJSON
import Logging
import LoggerAPI

public struct Preference: Codable {
    public let teamID: String
    public let keyID: String
    public let bundleID: String
    public let environment: APNsEnvironment
    public let certificate: Optional<APNsCertificate>
    public let token: String
    public let priority: Int
}

public class AppService {
    
    private static func loadPreference() -> Preference? {
        guard let data = UserDefaults.standard.data(forKey: "User.Preference") else {
            return nil
        }
        do {
            return try JSONDecoder().decode(Preference.self, from: data)
        } catch {
            return nil
        }
    }
    
    func savePreference() throws {
        let preference = Preference(
            teamID: self.teamIDObject.value,
            keyID: self.keyIDObject.value,
            bundleID: self.bundleIDObject.value,
            environment: self.environmentObject.value,
            certificate: self.certificateObject.value,
            token: self.tokenObject.value,
            priority: self.priorityObject.value
        )
        UserDefaults.standard.set(try JSONEncoder().encode(preference), forKey: "USER.PREFERENCE")
    }
    
    public static let current = AppService()
    
    private var cancellables: Set<AnyCancellable> = []
    
    private init() {
        LoggingSystem.bootstrap(APNsLogHandler.apnsLog)
        LoggerAPI.Log.swiftLogger = Logging.Logger(label: "com.Arror.APNs")
        
        let preference = AppService.loadPreference()
        self.bundleIDObject     = ObservableWrapper<String>(preference?.bundleID ?? "")
        self.certificateObject  = ObservableWrapper<Optional<APNsCertificate>>(preference?.certificate)
        self.tokenObject        = ObservableWrapper<String>(preference?.token ?? "")
        self.priorityObject     = ObservableWrapper<Int>(preference?.priority ?? 5)
        self.teamIDObject       = ObservableWrapper<String>(preference?.teamID ?? "")
        self.keyIDObject        = ObservableWrapper<String>(preference?.keyID ?? "")
        self.environmentObject  = ObservableWrapper<APNsEnvironment>(preference?.environment ?? .sandbox)
        
        let triggerToken = self.pushTrigger.sink { [unowned self] _ in
            do {
                let provider = try APNsProviderFactory.provider(forCurrentService: self)
                self.indicatorSubject.send(true)
                APNsLog.info("正在发送。。。")
                provider.send(payload: self.payloadObject.value, token: self.tokenObject.value, priorty: self.priorityObject.value) { result in
                    self.indicatorSubject.send(false)
                    switch result {
                    case .success:
                        APNsLog.info("发送成功")
                    case .failure(let error):
                        APNsLog.error(error.localizedDescription)
                    }
                }
            } catch {
                APNsLog.error(error.localizedDescription)
            }
        }
        self.cancellables.insert(triggerToken)
    }
    
    public let bundleIDObject:      ObservableWrapper<String>
    public let certificateObject:   ObservableWrapper<Optional<APNsCertificate>>
    public let tokenObject:         ObservableWrapper<String>
    public let priorityObject:      ObservableWrapper<Int>
    public let teamIDObject:        ObservableWrapper<String>
    public let keyIDObject:         ObservableWrapper<String>
    public let environmentObject:   ObservableWrapper<APNsEnvironment>
    
    public let destinationObject    = ObservableWrapper<APNsDestination>(.device)
    public let deviceObject         = ObservableWrapper<APNsDevice>(APNsDevice.fake)
    public let payloadObject        = ObservableWrapper<String>(
        """
        {
            "aps": {
                "content-available": 1,
                "alert": {
                    "title": "Title",
                    "body": "Your message here."
                },
                "badge": 9,
                "sound": "default"
            }
        }
        """
    )
    public let logObject    = ObservableWrapper<String>("")
    public let pushTrigger  = PassthroughSubject<Void, Never>()
    
    public let indicatorSubject = CurrentValueSubject<Bool, Never>(false)
}

public final class ObservableWrapper<Value>: ObservableObject {
    
    @Published public var value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
}

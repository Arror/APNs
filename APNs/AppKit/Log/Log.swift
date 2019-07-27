//
//  Log.swift
//  APNs
//
//  Created by Qiang Ma 马强 on 2019/3/9.
//  Copyright © 2019 Arror. All rights reserved.
//

import Foundation

public enum Level: String {
    case verbose = "Verbose"
    case info    = "Info"
    case debug   = "Debug"
    case error   = "Error"
    case fault   = "Fault"
}

open class LogDestination: Hashable {
    
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
    
    open func write(level: Level, format: String, args: [CVarArg]) {}
    
    public final func write(level: Level, message: String) {
        self.write(level: level, format: message, args: [])
    }
    
    public static func ==(lhs: LogDestination, rhs: LogDestination) -> Bool {
        return lhs.name == rhs.name
    }
    
    public final func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
    }
}

public final class ConsoleLogDestination: LogDestination {
    
    public override init(name: String) {
        super.init(name: name)
    }
    
    public override func write(level: Level, format: String, args: [CVarArg]) {
        NSLog("\(level.rawValue): \(format)", args)
    }
}

public final class StringDestination: LogDestination {
    
    public private(set) var log: String
    
    private let format: DateFormatter
    
    public var logUpdate: (StringDestination) -> Void = { _ in }
    
    public override init(name: String) {
        self.log = ""
        self.format = DateFormatter()
        super.init(name: name)
        self.format.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    public override func write(level: Level, format: String, args: [CVarArg]) {
        let date = self.format.string(from: Date(timeIntervalSinceNow: 0))
        self.log.append("[\(date)] [\(level.rawValue)]: \(String(format: format, args))\n")
        DispatchQueue.main.async {
            self.logUpdate(self)
        }
    }
}

public class Logger {
    
    public private(set) var destinations: Set<LogDestination>
    
    private let queue = DispatchQueue(label: "com.APNs.Log")
    
    public init(destinations: [LogDestination] = []) {
        self.destinations = Set(destinations)
    }
    
    public func add(destination: LogDestination) {
        self.queue.async {
            self.destinations.insert(destination)
        }
    }
    
    public func remove(destination: LogDestination) {
        self.queue.async {
            self.destinations.remove(destination)
        }
    }
    
    public func log(level: Level, message: String) {
        self.queue.async {
            self.log(level: level, format: message, args: [])
        }
    }
    
    public func log(level: Level, format: String, args: [CVarArg]) {
        self.queue.async {
            self.destinations.forEach { $0.write(level: level, format: format, args: args) }
        }
    }
}

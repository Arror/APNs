import Foundation

public struct CodableStorageKey<Value: Codable> {
    
    public let stringKey: String
    public let valueType: Value.Type
    
    public init(stringKey: String, valueType: Value.Type = Value.self) {
        self.stringKey = stringKey
        self.valueType = valueType
    }
}

public protocol CodableItemStorage {
    
    func set<Item>(item: Optional<Item>, for key: CodableStorageKey<Item>) throws
    
    func item<Item>(for key: CodableStorageKey<Item>) throws -> Optional<Item>
}

extension CodableItemStorage {
    
    public subscript<Item>(storageKey key: CodableStorageKey<Item>) -> Optional<Item> {
        set {
            do {
                try self.set(item: newValue, for: key)
            } catch {
                
            }
        }
        get {
            do {
                return try self.item(for: key)
            } catch {
                return .none
            }
        }
    }
}

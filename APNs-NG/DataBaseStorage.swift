import Foundation

open class DataBaseStorage: CodableItemStorage {
    
    public struct PropertyListBox<Wrapped: Codable>: Codable {
        
        public let wrapped: Wrapped
        
        public init(wrapped: Wrapped) {
            self.wrapped = wrapped
        }
    }
    
    public init() {}
    
    open func set(data: Optional<Data>, forKey key: String) throws {
        fatalError()
    }
    
    open func data(forKey key: String) throws -> Optional<Data> {
        fatalError()
    }
    
    open func set<Item>(item: Optional<Item>, for key: CodableStorageKey<Item>) throws {
        let data: Optional<Data>
        switch item {
        case .some(let value):
            if value.self is Data.Type {
                data = value as? Data
            } else {
                let wrapped = PropertyListBox(wrapped: value)
                let encoder = PropertyListEncoder()
                encoder.outputFormat = .binary
                data = try encoder.encode(wrapped)
            }
        case .none:
            data = .none
        }
        try self.set(data: data, forKey: key.stringKey)
    }
    
    open func item<Item>(for key: CodableStorageKey<Item>) throws -> Optional<Item> {
        guard let data = try self.data(forKey: key.stringKey) else {
            return .none
        }
        if Item.self is Data.Type {
            return data as? Item
        } else {
            let topLevel = try PropertyListDecoder().decode(PropertyListBox<Item>.self, from: data)
            return topLevel.wrapped
        }
    }
}

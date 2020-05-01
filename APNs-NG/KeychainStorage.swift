import Foundation

public final class KeychainStorage: DataBaseStorage, CodableItemStorage {
    
    public let service: String
    public let accessGroup: Optional<String>
    
    public init(service: String, accessGroup: Optional<String> = .none) {
        self.service = service
        self.accessGroup = accessGroup
        super.init()
    }
    
    struct PropertyListWrapper<Wrapped: Codable>: Codable {
        let wrapped: Wrapped
    }
    
    public override func set(data: Optional<Data>, forKey key: String) throws {
        let item = KeychainDataItem(service: self.service, account: key, accessGroup: self.accessGroup)
        if let data = data {
            try item.saveData(data)
        } else {
            _ = try item.deleteItem()
        }
    }
    
    public override func data(forKey key: String) throws -> Optional<Data> {
        let item = KeychainDataItem(service: self.service, account: key, accessGroup: self.accessGroup)
        do {
            return try item.readData()
        } catch KeychainDataItem.KeychainError.noData {
            return nil
        } catch {
            throw error
        }
    }
    
    public func set<Item>(item: Optional<Item>, for key: CodableStorageKey<Item>) throws {
        let data: Optional<Data>
        switch item {
        case .some(let value):
            if value.self is Data.Type {
                data = value as? Data
            } else {
                let wrapped = PropertyListWrapper(wrapped: value)
                let encoder = PropertyListEncoder()
                encoder.outputFormat = .binary
                data = try encoder.encode(wrapped)
            }
        case .none:
            data = .none
        }
        try self.set(data: data, forKey: key.stringKey)
    }
    
    public func item<Item>(for key: CodableStorageKey<Item>) throws -> Optional<Item> {
        guard let data = try self.data(forKey: key.stringKey) else {
            return .none
        }
        if Item.self is Data.Type {
            return data as? Item
        } else {
            let topLevel = try PropertyListDecoder().decode(PropertyListWrapper<Item>.self, from: data)
            return topLevel.wrapped
        }
    }
}

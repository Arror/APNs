import Foundation

public final class KeychainStorage: DataBaseStorage {
    
    public let service: String
    public let accessGroup: Optional<String>
    
    public init(service: String, accessGroup: Optional<String> = .none) {
        self.service = service
        self.accessGroup = accessGroup
        super.init()
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
}

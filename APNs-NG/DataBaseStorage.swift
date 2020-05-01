import Foundation

open class DataBaseStorage {
    
    public init() {}
    
    open func set(data: Optional<Data>, forKey key: String) throws {
        fatalError()
    }
    
    open func data(forKey key: String) throws -> Optional<Data> {
        fatalError()
    }
}

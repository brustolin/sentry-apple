import Foundation

public protocol Serializable {
    func serialize() -> [String: Any]
}

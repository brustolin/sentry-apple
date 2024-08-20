import Foundation

extension Dictionary {
    mutating func addNonNil(_ key: Key, value: Value?) {
        if let value = value {
            self[key] = value
        }
    }
}

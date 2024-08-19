import Foundation

public protocol Serializable : BinaryOutputStreamable {
    func serialize() -> [String: Any]
}

extension Serializable {
    public func stream(to target:inout any BinaryOutputStream) throws {
        try SentrySerialization.stream(object: serialize(), to: &target)
    }
}


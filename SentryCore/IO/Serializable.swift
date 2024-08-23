import Foundation

protocol Serializable : BinaryOutputStreamable {
    func serialize() -> [String: Any]
}

extension Serializable {
    func stream<Target>(to target: inout Target) throws where Target : BinaryOutputStream {
        try SentrySerialization.stream(object: serialize(), to: &target)
    }
}


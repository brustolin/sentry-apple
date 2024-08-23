import Foundation

public protocol BinaryOutputStream {
    mutating func stream(_ data: any DataProtocol) throws
}

protocol BinaryOutputStreamable {
    func stream<Target>(to target: inout Target) throws where Target : BinaryOutputStream
}

extension Data : BinaryOutputStreamable {
    func stream<Target>(to target: inout Target) throws where Target : BinaryOutputStream {
        try target.stream(self)
    }
}

extension String : BinaryOutputStreamable {
    func stream<Target>(to target: inout Target) throws where Target: BinaryOutputStream {
        guard let data = self.data(using: .utf8) else {
            throw SentryError("Failed to convert string to UTF-8 data")
        }
        try target.stream(data)
    }
}

extension FileHandle : BinaryOutputStream {
    public func stream(_ data: any DataProtocol) throws {
        self.write(Data(data))
    }
}

extension Data : BinaryOutputStream {
    public mutating func stream(_ data: any DataProtocol) throws {
        self.append(contentsOf: data)
    }
}

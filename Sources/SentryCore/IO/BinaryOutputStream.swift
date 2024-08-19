import Foundation

public protocol BinaryOutputStream {
    mutating func stream(_ data: any DataProtocol) throws
}

public protocol BinaryOutputStreamable {
    func stream(to target: inout any BinaryOutputStream) throws
}

extension Data : BinaryOutputStreamable {
    public func stream(to target: inout any BinaryOutputStream) throws {
        try target.stream(self)
    }
}

extension String : BinaryOutputStreamable {
  public func stream(to target: inout any BinaryOutputStream) throws {
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

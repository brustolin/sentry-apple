import Foundation

protocol BinaryInputStream {
    func readStream() throws -> Data
}

extension FileHandle : BinaryInputStream {
    func readStream() throws -> Data {
        self.readDataToEndOfFile()
    }
}

extension Data : BinaryInputStream {
    func readStream() throws -> Data {
        self
    }
}

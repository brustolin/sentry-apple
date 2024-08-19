import Foundation

class SentryEnvelopeItem {
    /**
     * The envelope item header.
     */
    let header: SentryEnvelopeItemHeader

    /**
     * The envelope payload.
     */
    let data: Data
    
    init(header: SentryEnvelopeItemHeader, data: Data) {
        self.header = header
        self.data = data
    }
}

extension SentryEnvelopeItem : BinaryOutputStreamable {
    func stream(to target: inout any BinaryOutputStream) throws {
        try header.stream(to: &target)
        try String.newLine.stream(to: &target)
        try data.stream(to: &target)
    }
}

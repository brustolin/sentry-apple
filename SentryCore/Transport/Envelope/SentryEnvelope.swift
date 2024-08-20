import Foundation

class SentryEnvelope {
    
    /**
     * The envelope header.
     */
    let header: SentryEnvelopeHeader

    /**
     * The envelope items.
     */
    let items: [SentryEnvelopeItem]
    
    init(header: SentryEnvelopeHeader, items: [SentryEnvelopeItem]) {
        self.header = header
        self.items = items
    }
}

extension SentryEnvelope : BinaryOutputStreamable {
    func stream(to target: inout any BinaryOutputStream) throws {
        try header.stream(to: &target)
        
        try items.forEach {
            try String.newLine.stream(to: &target)
            try $0.stream(to: &target)
        }
    }
}

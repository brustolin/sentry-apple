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
    
    /**
     * This is the preferred initializer to avoid incorrect types and data length in the header.
     */
    convenience init(type: SentryEnvelopeItemType, data: Data, filename: String? = nil, contentType: String? = nil) {
        self.init(header: 
                    SentryEnvelopeItemHeader(type: type.rawValue, 
                                             length: UInt(data.count),
                                             filename: filename,
                                             contentType: contentType),
                  data: data)
    }
}

extension SentryEnvelopeItem : BinaryOutputStreamable {
    func stream<Target>(to target: inout Target) throws where Target : BinaryOutputStream {
        try header.stream(to: &target)
        try String.newLine.stream(to: &target)
        try data.stream(to: &target)
    }
}

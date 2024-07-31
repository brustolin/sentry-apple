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

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

import Foundation

class SentryHttpTransport : SentryTransport {
    func send(envelope: SentryEnvelope) {
            
    }
    
    func recordLostEvent(category: SentryDataCategory, reason: SentryDiscardReason) {
        
    }
    
    func recordLostEvent(category: SentryDataCategory, reason: SentryDiscardReason, quantity: UInt) {
        
    }
    
    func flush(timeout: TimeInterval) -> FlushResult {
        
    }
}

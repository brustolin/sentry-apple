import Foundation

class SentryHttpTransport : SentryTransport {
    let options: Options
    let rateLimiter: SentryEnvelopeRateLimiter
    let dispatchQueue : SentryDispatchQueueWrapper
    
    private var discardedEvents = [String: DiscardedEvent]()
    private let lock = NSLock()
    
    init(options: Options, rateLimiter: SentryEnvelopeRateLimiter, dispatchQueue: SentryDispatchQueueWrapper = SentryDispatchQueueWrapper()) {
        self.options = options
        self.rateLimiter = rateLimiter
        self.dispatchQueue = dispatchQueue
    }
    
    func send(envelope: SentryEnvelope) {
        var finalEnvelope = rateLimiter.removeRateLimitedItems(from: envelope)
        guard finalEnvelope.items.count >= 0 else {
            SentryLog.debug("RateLimit is active for all envelope items.")
            return
        }
        
        finalEnvelope = addClientReportTo(envelope: finalEnvelope)
        dispatchQueue.dispatchAsync { [weak self] in
            
        }
    }
    
    func recordLostEvent(category: SentryDataCategory, reason: SentryDiscardReason) {
        
    }
    
    func recordLostEvent(category: SentryDataCategory, reason: SentryDiscardReason, quantity: UInt) {
        
    }
    
    func flush(timeout: TimeInterval) -> FlushResult {
        return .timedOut
    }
    
    
    private func addClientReportTo(envelope: SentryEnvelope) -> SentryEnvelope {
        guard options.sendClientReports else { return envelope }
        
        let discarted = cleanDiscardedEvents()
        guard discarted.count > 0 else { return envelope }
        
        let clientReport = ClientReport(timestamp: SentryCurrentDateProvider.shared.date(), discardedEvents: discarted)
        
        do {
            let envelopeItem = try SentryEnvelopeItem(clientReport: clientReport)
            return SentryEnvelope(header: envelope.header, items: envelope.items + [envelopeItem])
        } catch {
            SentryLog.error("Could not create envelope for client report: \(error)")
            return envelope
        }
    }
    
    private func cleanDiscardedEvents() -> [DiscardedEvent] {
        lock.unlock()
        defer { lock.unlock() }
        let result = Array(discardedEvents.values)
        discardedEvents.removeAll()
        return result
    }
}

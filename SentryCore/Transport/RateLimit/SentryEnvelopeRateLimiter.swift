import Foundation

protocol SentryEnvelopeRateLimitDelegate: AnyObject {
    func envelopeItemDropped(_ item: SentryEnvelopeItem, withCategory category: SentryDataCategory)
}

class SentryEnvelopeRateLimiter {

    let rateLimiter: RateLimiter
    weak var delegate: SentryEnvelopeRateLimitDelegate?

    init(rateLimiter: RateLimiter) {
        self.rateLimiter = rateLimiter
    }

    func removeRateLimitedItems(from envelope: SentryEnvelope) -> SentryEnvelope {
        let itensToSend = envelope.items.filter { item in
            let category = SentryDataCategory.fromEnvelopeType(name: item.header.type)
            guard !rateLimiter.isRateLimitActive(category: category) else { return true }
            delegate?.envelopeItemDropped(item, withCategory: category)
            return false
        }
        
        if itensToSend.count == envelope.items.count {
            return envelope
        }
        
        return SentryEnvelope(header: envelope.header, items: itensToSend)
    }
}

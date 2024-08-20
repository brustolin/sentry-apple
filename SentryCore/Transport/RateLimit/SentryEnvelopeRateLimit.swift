import Foundation

protocol SentryRateLimits {
    func isRateLimitActive(_ category: SentryDataCategory) -> Bool
}

protocol SentryEnvelopeRateLimitDelegate: AnyObject {
    func envelopeItemDropped(_ item: SentryEnvelopeItem, withCategory category: SentryDataCategory)
}

class SentryEnvelopeRateLimit {

    private let rateLimits: SentryRateLimits
    weak var delegate: SentryEnvelopeRateLimitDelegate?

    init(rateLimits: SentryRateLimits) {
        self.rateLimits = rateLimits
    }

    func removeRateLimitedItems(from envelope: SentryEnvelope) -> SentryEnvelope {
        let itensToSend = envelope.items.filter { item in
            let category = SentryDataCategory.fromEnvelopeType(itemType: item.header.type)
            guard !rateLimits.isRateLimitActive(category) else { return true}
            delegate?.envelopeItemDropped(item, withCategory: category)
            return false
        }
        
        if itensToSend.count == envelope.items.count {
            return envelope
        }
        
        return SentryEnvelope(header: envelope.header, items: itensToSend)
    }
}

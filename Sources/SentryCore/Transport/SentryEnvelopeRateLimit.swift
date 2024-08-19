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

    func removeRateLimitedItems(from envelope: SentryEnvelope?) -> SentryEnvelope? {
        guard let envelope = envelope else {
            return envelope
        }

        let itemsToDrop = getEnvelopeItemsToDrop(envelope.items)

        if !itemsToDrop.isEmpty {
            let itemsToSend = getItemsToSend(from: envelope.items, excluding: itemsToDrop)
            return SentryEnvelope(header: envelope.header, items: itemsToSend)
        }

        return envelope
    }

    private func getEnvelopeItemsToDrop(_ items: [SentryEnvelopeItem]) -> [SentryEnvelopeItem] {
        var itemsToDrop = [SentryEnvelopeItem]()

        for item in items {
            let rateLimitCategory = sentryDataCategory(for: item.header.type)
            if rateLimits.isRateLimitActive(rateLimitCategory) {
                itemsToDrop.append(item)
                delegate?.envelopeItemDropped(item, withCategory: rateLimitCategory)
            }
        }

        return itemsToDrop
    }

    private func getItemsToSend(from allItems: [SentryEnvelopeItem], excluding itemsToDrop: [SentryEnvelopeItem]) -> [SentryEnvelopeItem] {
        return allItems.filter { !itemsToDrop.contains(where: $0) }
    }
}

import Foundation

struct DiscardedEvent {
    let reason: SentryDiscardReason
    let category: SentryDataCategory
    let quantity: UInt
}

extension DiscardedEvent : Serializable {
    func serialize() -> [String : Any] {
        [
            Keys.reason: reason.name().rawValue,
            Keys.category: category.name().rawValue,
            Keys.quantity: quantity
        ]
    }
    
    private enum Keys {
        static let reason = "reason"
        static let category = "category"
        static let quantity = "quantity"
    }
}

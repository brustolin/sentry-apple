import Foundation

struct ClientReport {
    let timestamp: Date
    let discardedEvents: [DiscardedEvent]
}

extension ClientReport : Serializable {
    func serialize() -> [String : Any] {
        [
            Keys.timestamp: timestamp.timeIntervalSince1970,
            Keys.discardedEvents: discardedEvents.map({ $0.serialize() })
        ]
    }
    
    private enum Keys {
        static let timestamp = "timestamp"
        static let discardedEvents = "discarded_events"
    }
}

// Sentry Envelope from Client Report
extension ClientReport {
    func toSentryEnvelopeItem() throws -> SentryEnvelopeItem {
        let data = try SentrySerialization.dataWithJsonObject(self.serialize())
        return SentryEnvelopeItem(type: .clientReport, data: data)
    }
}

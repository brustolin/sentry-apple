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
extension SentryEnvelopeItem {
    convenience init(clientReport: ClientReport) throws {
        let data = try SentrySerialization.dataWithJsonObject(clientReport.serialize())
        self.init(header: SentryEnvelopeItemHeader(itemType: .clientReport, length: UInt(data.count)), data: data)
    }
}

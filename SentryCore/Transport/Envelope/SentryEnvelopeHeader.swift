import Foundation

class SentryEnvelopeHeader {
    /**
     * The event identifier, if available.
     * An event id exist if the envelope contains an event of items within it are related. i.e
     * Attachments
     */
    let eventId: SentryId?
    let sdkInfo: SDKInfo?
    let traceContext: TraceContext?
    
    /**
     * The timestamp when the event was sent from the SDK as string in RFC 3339 format. Used
     * for clock drift correction of the event timestamp. The time zone must be UTC.
     *
     * The timestamp should be generated as close as possible to the transmision of the event,
     * so that the delay between sending the envelope and receiving it on the server-side is
     * minimized.
     */
    var sentAt: Date?
    
    init(eventId: SentryId? = nil, sdkInfo: SDKInfo? = nil, traceContext: TraceContext? = nil, sentAt: Date? = nil) {
        self.eventId = eventId
        self.sdkInfo = sdkInfo
        self.traceContext = traceContext
        self.sentAt = sentAt
    }
}

extension SentryEnvelopeHeader : Serializable {
    func serialize() -> [String: Any] {
        var result = [String:Any]()
        
        result.addNonNil(Keys.eventId, value: eventId?.sentryIdString)
        result.addNonNil(Keys.trace, value: traceContext?.serialize)
        
        if let sentAt {
            result[Keys.sentAt] = SentryDateUtils.dateToIso8601String(sentAt)
        }
        
        if let sdkInfo {
            result.merge(sdkInfo.serialize()) { _, new in new }
        }
        
        return result
    }
    
    private enum Keys {
        static let eventId = "event_id"
        static let trace = "trace"
        static let sentAt = "sent_at"
    }
}

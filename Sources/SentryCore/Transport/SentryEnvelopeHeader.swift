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
    let sentAt: Date?
    
    init(eventId: SentryId? = nil, sdkInfo: SDKInfo? = nil, traceContext: TraceContext? = nil, sentAt: Date? = nil) {
        self.eventId = eventId
        self.sdkInfo = sdkInfo
        self.traceContext = traceContext
        self.sentAt = sentAt
    }
}

extension SentryEnvelopeHeader : BinaryOutputStreamable {
    func stream<Target>(to target: inout Target) where Target : BinaryOutputStream {
        
    }
}

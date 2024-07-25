import Foundation

@objcMembers
public class SentryEnvelopeHeader : NSObject {
    /**
     * The event identifier, if available.
     * An event id exist if the envelope contains an event of items within it are related. i.e
     * Attachments
     */
    let eventId: SentryId?
    let sdkInfo: SentrySDKInfo?
    //let traceContext: SentryTraceContext?

    /**
     * The timestamp when the event was sent from the SDK as string in RFC 3339 format. Used
     * for clock drift correction of the event timestamp. The time zone must be UTC.
     *
     * The timestamp should be generated as close as possible to the transmision of the event,
     * so that the delay between sending the envelope and receiving it on the server-side is
     * minimized.
     */
    let sentAt: Date?
}

@objcMembers
public class SentryEnvelopeItemHeader {
    
}

@objcMembers
public class SentryEnvelopeItem : NSObject {
    /**
     * The envelope item header.
     */
    let header: SentryEnvelopeItemHeader

    /**
     * The envelope payload.
     */
    let data: Data
    
    init(header: SentryEnvelopeItemHeader, data: Data) {
        self.header = header
        self.data = data
    }
}

@objcMembers
public class SentryEnvelope : NSObject {
    
    /**
     * The envelope header.
     */
    let header: SentryEnvelopeHeader

    /**
     * The envelope items.
     */
    let items: [SentryEnvelopeItem]
    
    init(header: SentryEnvelopeHeader, items: [SentryEnvelopeItem]) {
        self.header = header
        self.items = items
    }
}

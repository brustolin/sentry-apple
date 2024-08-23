import XCTest
@testable import SentryCore

class SentryEnvelopeTests: XCTestCase {
    
    func testSentryEnvelopeInitialization() {
        let header = SentryEnvelopeHeader(eventId: SentryId(uuidString: "12c2d058-d584-4270-9aa2-eca08bf20986"), sentAt: Date())
        let itemHeader = SentryEnvelopeItemHeader(type: "event", length: 5)
        let mockData = "test".data(using: .utf8)!
        let item = SentryEnvelopeItem(header: itemHeader, data: mockData)
        let envelope = SentryEnvelope(header: header, items: [item])
        
        XCTAssertEqual(envelope.header.eventId?.sentryIdString, "12c2d058d58442709aa2eca08bf20986")
        XCTAssertEqual(envelope.items.count, 1)
        XCTAssertEqual(envelope.items.first?.header.type, "event")
        XCTAssertEqual(envelope.items.first?.data, mockData)
    }
    
    func testSentryEnvelopeStreaming() throws {
        let header = SentryEnvelopeHeader(eventId: SentryId(uuidString: "12c2d058d58442709aa2eca08bf20986"), sdkInfo: nil, traceContext: nil, sentAt: Date())
        let itemHeader = SentryEnvelopeItemHeader(type: "event", length: 5)
        let mockData = "test".data(using: .utf8)!
        let item = SentryEnvelopeItem(header: itemHeader, data: mockData)
        let envelope = SentryEnvelope(header: header, items: [item])
        var outputStream = Data()

        try envelope.stream(to: &outputStream)
        
        let outputEnvelope = try SentryEnvelope(from: outputStream)
        
        XCTAssertNotNil(outputEnvelope)
        XCTAssertEqual(outputEnvelope?.header.eventId?.sentryIdString, "12c2d058d58442709aa2eca08bf20986")
        XCTAssertEqual(outputEnvelope?.items.count, 1)
        XCTAssertEqual(outputEnvelope?.items.first?.header.type, "event")
        XCTAssertEqual(outputEnvelope?.items.first?.data, mockData)
    }
}

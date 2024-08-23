import XCTest
@testable import SentryCore

class TraceContextTests: XCTestCase {

    // Helper function to create a TraceContext instance for testing
    private func getSut() -> TraceContext {
        return TraceContext(
            traceId: SentryId(uuidString: "12c2d058d58442709aa2eca08bf20986"),
            publicKey: "public_key_123",
            releaseName: "package@1.0.0+build",
            environment: "production",
            transaction: "transaction_name",
            sampleRate: "0.5",
            sampled: "true",
            replayId: "replay_123"
        )
    }

    func testTraceContextInitialization() {
        let traceContext = getSut()
        
        XCTAssertNotNil(traceContext)
        XCTAssertEqual(traceContext.traceId.sentryIdString, "12c2d058d58442709aa2eca08bf20986")
        XCTAssertEqual(traceContext.publicKey, "public_key_123")
        XCTAssertEqual(traceContext.releaseName, "package@1.0.0+build")
        XCTAssertEqual(traceContext.environment, "production")
        XCTAssertEqual(traceContext.transaction, "transaction_name")
        XCTAssertEqual(traceContext.sampleRate, "0.5")
        XCTAssertEqual(traceContext.sampled, "true")
        XCTAssertEqual(traceContext.replayId, "replay_123")
    }
    
    func testTraceContextSerialization() {
        let traceContext = getSut()
        let serialized = traceContext.serialize()
        
        XCTAssertEqual(serialized["trace_id"] as? String, "12c2d058d58442709aa2eca08bf20986")
        XCTAssertEqual(serialized["public_id"] as? String, "public_key_123")
        XCTAssertEqual(serialized["release"] as? String, "package@1.0.0+build")
        XCTAssertEqual(serialized["environment"] as? String, "production")
        XCTAssertEqual(serialized["transaction"] as? String, "transaction_name")
        XCTAssertEqual(serialized["sample_rate"] as? String, "0.5")
        XCTAssertEqual(serialized["sampled"] as? String, "true")
        XCTAssertEqual(serialized["replay_id"] as? String, "replay_123")
    }

    func testTraceContextDeserialization() {
        let dictionary: [String: Any] = [
            "trace_id": "12c2d058d58442709aa2eca08bf20986",
            "public_id": "public_key_123",
            "release": "package@1.0.0+build",
            "environment": "production",
            "transaction": "transaction_name",
            "sample_rate": "0.5",
            "sampled": "true",
            "replay_id": "replay_123"
        ]
        
        let traceContext = TraceContext(dictionary: dictionary)
        
        XCTAssertNotNil(traceContext)
        XCTAssertEqual(traceContext?.traceId.sentryIdString, "12c2d058d58442709aa2eca08bf20986")
        XCTAssertEqual(traceContext?.publicKey, "public_key_123")
        XCTAssertEqual(traceContext?.releaseName, "package@1.0.0+build")
        XCTAssertEqual(traceContext?.environment, "production")
        XCTAssertEqual(traceContext?.transaction, "transaction_name")
        XCTAssertEqual(traceContext?.sampleRate, "0.5")
        XCTAssertEqual(traceContext?.sampled, "true")
        XCTAssertEqual(traceContext?.replayId, "replay_123")
    }
    
    func testToBaggageHeader() {
        let traceContext = getSut()
        let baggageHeader = traceContext.toBaggageHeader(original: nil)
        let expectedBaggageHeader = "sentry-environment=production,sentry-public_id=public_key_123,sentry-release=package%401.0.0%2Bbuild,sentry-replay_id=replay_123,sentry-sample_rate=0.5,sentry-sampled=true,sentry-trace_id=12c2d058d58442709aa2eca08bf20986,sentry-transaction=transaction_name"
               
        let sortedExpectedBaggageHeader = expectedBaggageHeader
            .split(separator: ",")
            .sorted()
            .joined(separator: ",")
        
        XCTAssertEqual(baggageHeader, sortedExpectedBaggageHeader)
    }
}

import XCTest
import SentryPerformance

class SentryPerformanceOptionsTest: XCTestCase {
    func testOptions() throws {
        let options = Options()
        //By importing SentryPerformance, `options.experiment` must have `replayOptions` property
        options.performanceOptions.tracesSampleRate = 0.5
        XCTAssertEqual(options.performanceOptions.tracesSampleRate, 0.5)
        XCTAssertEqual(options.tracesSampleRate, 0.5)
    }
    
    func testUpdateWithFlatDictionary() {
        let options = SentryPerformanceOptions()
        let dictionary: [String: Any] = [
            "idleTimeout": 5.0,
            "enableTracing": true,
            "tracesSampleRate": 0.5,
            "tracesSampler": { return Float(0.75) }
        ]
        
        options.update(dictionary: dictionary)
        
        XCTAssertEqual(options.idleTimeout, 5.0)
        XCTAssertEqual(options.enableTracing, true)
        XCTAssertEqual(options.tracesSampleRate, 0.5)
        XCTAssertNotNil(options.tracesSampler)
        XCTAssertEqual(options.tracesSampler?(), 0.75)
    }
    
    func testUpdateWithNestedDictionary() {
        let options = SentryPerformanceOptions()
        let nestedDictionary: [String: Any] = [
            "performanceOptions": [
                "idleTimeout": 10.0,
                "enableTracing": false,
                "tracesSampleRate": 1,
                "tracesSampler": { return Float(0.9) }
            ]
        ]
        
        options.update(dictionary: nestedDictionary)
        
        XCTAssertEqual(options.idleTimeout, 10.0)
        XCTAssertEqual(options.enableTracing, false)
        XCTAssertEqual(options.tracesSampleRate, 1)
        XCTAssertNotNil(options.tracesSampler)
        XCTAssertEqual(options.tracesSampler?(), 0.9)
    }
    
    func testUpdateWithEmptyDictionary() {
        let options = SentryPerformanceOptions()
        let defaultOptions = SentryPerformanceOptions()
        let dictionary: [String: Any] = [:]
        
        options.update(dictionary: dictionary)
        
        XCTAssertEqual(options.idleTimeout, defaultOptions.idleTimeout)
        XCTAssertEqual(options.enableTracing, defaultOptions.enableTracing)
        XCTAssertEqual(options.tracesSampleRate, defaultOptions.tracesSampleRate)
        XCTAssertNil(options.tracesSampler)
    }
    
}

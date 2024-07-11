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

}

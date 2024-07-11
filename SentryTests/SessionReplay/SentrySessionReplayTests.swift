import XCTest
import SentrySessionReplay

class SentrySessionReplayTests: XCTestCase {

    func testOptions() throws {
        let options = Options()
        //By importing SentrySessionReplay, `options.experiment` must have `replayOptions` property
        options.experimental.replayOptions.quality = .high
        XCTAssertEqual(options.experimental.replayOptions.quality, .high)
    }

}

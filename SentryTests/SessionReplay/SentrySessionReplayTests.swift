import XCTest
import SentrySessionReplay

class SentrySessionReplayTests: XCTestCase {
    
    func testOptions() throws {
        let options = Options()
        //By importing SentrySessionReplay, `options.experiment` must have `replayOptions` property
        options.experimental.replayOptions.quality = .high
        XCTAssertEqual(options.experimental.replayOptions.quality, .high)
    }
    
    func testUpdateWithValidDictionary() {
        let replayOptions = SentryReplayOptions()
        let dictionary: [String: Any] = [
            "replayOptions": [
                "sessionSampleRate": 0.5,
                "errorSampleRate": 0.7,
                "redactAllText": false,
                "redactAllImages": false,
                "quality": 1
            ]
        ]
        
        replayOptions.update(dictionary: dictionary)
        
        XCTAssertEqual(replayOptions.sessionSampleRate, 0.5)
        XCTAssertEqual(replayOptions.errorSampleRate, 0.7)
        XCTAssertFalse(replayOptions.redactAllText)
        XCTAssertFalse(replayOptions.redactAllImages)
        XCTAssertEqual(replayOptions.quality, .medium)
    }
    
    func testUpdateWithInvalidQuality() {
        let replayOptions = SentryReplayOptions()
        let dictionary: [String: Any] = [
            "replayOptions": [
                "quality": 5
            ]
        ]
        
        replayOptions.update(dictionary: dictionary)
        XCTAssertEqual(replayOptions.quality, .low)
    }
    
    func testUpdateKeepDefaultValue() {
        let replayOptions = SentryReplayOptions()
        let defaultOptions = SentryReplayOptions()
        let dictionary: [String: Any] = [:]
        
        replayOptions.update(dictionary: dictionary)
        
        XCTAssertEqual(replayOptions.sessionSampleRate, defaultOptions.sessionSampleRate)
        XCTAssertEqual(replayOptions.errorSampleRate, defaultOptions.errorSampleRate) // unchanged
        XCTAssertEqual(replayOptions.redactAllText, defaultOptions.redactAllText)
        XCTAssertEqual(replayOptions.redactAllImages, defaultOptions.redactAllImages) // unchanged
    }
    
}

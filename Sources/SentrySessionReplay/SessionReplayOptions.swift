import Foundation

@objcMembers
public class SentryReplayOptions : NSObject, IntegrationOption {
    
    /**
     * Enum to define the quality of the session replay.
     */
    public enum SentryReplayQuality: Int {
        /**
         * Video Scale: 80%
         * Bit Rate: 20.000
         */
        case low
        
        /**
         * Video Scale: 100%
         * Bit Rate: 40.000
         */
        case medium
        
        /**
         * Video Scale: 100%
         * Bit Rate: 60.000
         */
        case high
    }
    
    /**
     * Indicates the percentage in which the replay for the session will be created.
     * - Specifying @c 0 means never, @c 1.0 means always.
     * - note: The value needs to be >= 0.0 and \<= 1.0. When setting a value out of range the SDK sets it
     * to the default.
     * - note:  The default is 0.
     */
    public var sessionSampleRate: Float

    /**
     * Indicates the percentage in which a 30 seconds replay will be send with error events.
     * - Specifying 0 means never, 1.0 means always.
     * - note: The value needs to be >= 0.0 and \<= 1.0. When setting a value out of range the SDK sets it
     * to the default.
     * - note: The default is 0.
     */
    public var errorSampleRate: Float
    
    /**
     * Indicates whether session replay should redact all text in the app
     * by drawing a black rectangle over it.
     *
     * - note: The default is true
     */
    public var redactAllText = true
    
    /**
     * Indicates whether session replay should redact all non-bundled image
     * in the app by drawing a black rectangle over it.
     *
     * - note: The default is true
     */
    public var redactAllImages = true
    
    /**
     * Indicates the quality of the replay.
     * The higher the quality, the higher the CPU and bandwidth usage.
     */
    public var quality = SentryReplayQuality.low
    
    /**
     * Defines the quality of the session replay.
     * Higher bit rates better quality, but also bigger files to transfer.
     */
    var replayBitRate: Int {
        quality.rawValue * 20_000 + 20_000
    }
    
    /**
     * The scale related to the window size at which the replay will be created
     */
    var sizeScale: Float {
        quality == .low ? 0.8 : 1.0
    }
   
    /**
     * Number of frames per second of the replay.
     * The more the havier the process is.
     */
    let frameRate = 1
        
    /**
     * The maximum duration of replays for error events.
     */
    let errorReplayDuration = TimeInterval(30)
    
    /**
     * The maximum duration of the segment of a session replay.
     */
    let sessionSegmentDuration = TimeInterval(5)
    
    /**
     * The maximum duration of a replay session.
     */
    let maximumDuration = TimeInterval(3_600)
    
    /**
     * Inittialize session replay options disabled
     */
    public override init() {
        self.sessionSampleRate = 0
        self.errorSampleRate = 0
    }
    
}

public extension ExperimentalOptions {
    var replayOptions : SentryReplayOptions {
        get {
            if let existingOption = self[SentryReplayOptions.self] {
                return existingOption
            } else {
                let newOption = SentryReplayOptions()
                self[SentryReplayOptions.self] = newOption
                return newOption
            }
        }
    }
}

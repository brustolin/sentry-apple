import Foundation

@objcMembers
public class SentryPerformanceOptions : NSObject, IntegrationOption {
    public var idleTimeout : TimeInterval = 30
    public var enableTracing : Bool = false
    public var tracesSampleRate : Float = 0
    public var tracesSampler : (()->Float)? = nil
}

public extension Options {
    var performanceOptions : SentryPerformanceOptions {
        get {
            if let existingOption = self[SentryPerformanceOptions.self] {
                return existingOption
            } else {
                let newOption = SentryPerformanceOptions()
                self[SentryPerformanceOptions.self] = newOption
                return newOption
            }
        }
    }
    
    @available(*, deprecated, message: "use performanceOptions.idleTimeout instead")
    var idleTimeout : TimeInterval {
        get { performanceOptions.idleTimeout }
        set { performanceOptions.idleTimeout = newValue }
    }
    
    @available(*, deprecated, message: "use performanceOptions.enableTracing instead")
    var enableTracing : Bool {
        get { performanceOptions.enableTracing }
        set { performanceOptions.enableTracing = newValue }
    }
    
    @available(*, deprecated, message: "use performanceOptions.tracesSampleRate instead")
    var tracesSampleRate : Float {
        get { performanceOptions.tracesSampleRate }
        set { performanceOptions.tracesSampleRate = newValue }
    }
    
    @available(*, deprecated, message: "use performanceOptions.tracesSampler instead")
    var tracesSampler : (()->Float)? {
        get { performanceOptions.tracesSampler }
        set { performanceOptions.tracesSampler = newValue }
    }
}

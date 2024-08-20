import Foundation

class SentryCurrentDateProvider {
    static private(set) var shared = SentryCurrentDateProvider()
    
    func date() -> Date {
        return Date()
    }
    
    func timezoneOffset() -> Int {
        return TimeZone.current.secondsFromGMT()
    }
    
    func systemTime() -> UInt64 {
        if #available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
            return clock_gettime_nsec_np(CLOCK_UPTIME_RAW)
        } else {
            return mach_absolute_time()
        }
    }
    
    func systemUptime() -> TimeInterval {
        ProcessInfo.processInfo.systemUptime
    }
    
    #if TEST || TESTCI
    // The only reason we have a wrapper around system time functions is to enable testing.
    // Using a stateless singleton that can be modified during tests removes the necessity
    // of passing an instance of SentryCurrentDateProvider around or instantiating multiple copies of it.
    static func setShared(_ shared: SentryCurrentDateProvider) {
        self.shared = shared
    }
    #endif
}

import Foundation

class SentryDateUtils {
    private static let iso8601Formatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return formatter
    }()
        
    /**
     * The NSDateFormatter only works with milliseconds resolution, even though NSDate has a higher
     * precision. For more information checkout
     * https://stackoverflow.com/questions/23684727/nsdateformatter-milliseconds-bug/23685280#23685280.
     * The SDK can either send timestamps to Sentry a string as defined in RFC 3339 or a numeric
     * (integer or float) value representing the number of seconds that have elapsed since the Unix
     * epoch, see https://develop.sentry.dev/sdk/event-payloads/. Instead of appending micro and
     * nanoseconds to the output of NSDateFormatter please use a numeric float instead, which can be
     * retrieved with timeIntervalSince1970.
     */
    private static let iso8601FormatterWithMillisecondPrecision: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter
    }()
    
    static func dateFromIso8601String(_ string: String) -> Date? {
        // Fallback to low precision formatter for backward compatible
        return iso8601FormatterWithMillisecondPrecision.date(from: string) ?? iso8601Formatter.date(from: string)
    }

    /**
     * Only works with milliseconds precision. For more details see
     * getIso8601FormatterWithMillisecondPrecision.
     */
    static func dateToIso8601String(_ date: Date) -> String {
        return iso8601FormatterWithMillisecondPrecision.string(from: date)
    }
}

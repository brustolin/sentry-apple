import Foundation

@objc
public enum SentryDataCategory: UInt {
    case all = 0
    case `default` = 1
    case error = 2
    case session = 3
    case transaction = 4
    case attachment = 5
    case userFeedback = 6
    case profile = 7
    case metricBucket = 8
    case replay = 9
    case profileChunk = 10
    case span = 11
    case unknown = 12
}

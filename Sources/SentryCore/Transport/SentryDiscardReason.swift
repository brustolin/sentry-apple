enum SentryDiscardReason: UInt {
    case beforeSend = 0
    case eventProcessor = 1
    case sampleRate = 2
    case networkError = 3
    case queueOverflow = 4
    case cacheOverflow = 5
    case rateLimitBackoff = 6
    case insufficientData = 7
}

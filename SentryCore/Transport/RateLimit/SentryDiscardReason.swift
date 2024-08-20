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

enum SentryDiscardReasonName: String {
    case beforeSend = "before_send"
    case eventProcessor = "event_processor"
    case sampleRate = "sample_rate"
    case networkError = "network_error"
    case queueOverflow = "queue_overflow"
    case cacheOverflow = "cache_overflow"
    case rateLimitBackoff = "ratelimit_backoff"
    case insufficientData = "insufficient_data"
}

extension SentryDiscardReason {
    func name() -> SentryDiscardReasonName {
        switch self {
            case .beforeSend: return .beforeSend
            case .eventProcessor: return .eventProcessor
            case .sampleRate: return .sampleRate
            case .networkError: return .networkError
            case .queueOverflow: return .queueOverflow
            case .cacheOverflow: return .cacheOverflow
            case .rateLimitBackoff: return .rateLimitBackoff
            case .insufficientData: return .insufficientData
        }
    }
}

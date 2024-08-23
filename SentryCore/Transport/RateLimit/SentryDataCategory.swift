import Foundation

enum SentryDataCategory: UInt {
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

enum SentryDataCategoryName: String {
    case all
    case `default`
    case error
    case session
    case transaction
    case attachment
    case userFeedback = "user_report"
    case profile
    case metricBucket = "metric_bucket"
    case replay
    case profileChunk = "profile_chunk"
    case span
    case unknown
}

extension SentryDataCategory {
    static func fromEnvelopeType(name: String) -> SentryDataCategory {
        guard let type = SentryEnvelopeItemType(rawValue: name) else { return .default }
        return fromEnvelopeType(type)
    }

    static func fromEnvelopeType(_ type: SentryEnvelopeItemType) -> SentryDataCategory {
        switch type {
            case .session: return .session
            case .event: return .error
            case .transaction: return .transaction
            case .attachment: return .attachment
            case .profile: return .profile
            case .replayVideo: return .replay
            case .statsd: return .metricBucket
            case .profileChunk: return .profileChunk
            default: return .default
        }
    }
    
    static func fromString(_ value: String) -> SentryDataCategory? {
        guard let categoryName = SentryDataCategoryName(rawValue: value) else { return nil }
        switch categoryName {
            case .all: return .all
            case .default: return .default
            case .error: return .error
            case .session: return .session
            case .transaction: return .transaction
            case .attachment: return .attachment
            case .userFeedback: return .userFeedback
            case .profile: return .profile
            case .metricBucket: return .metricBucket
            case .replay: return .replay
            case .profileChunk: return .profileChunk
            case .span: return .span
            case .unknown: return .unknown
        }
    }
    
    func name() -> SentryDataCategoryName {
        switch self {
        case .all: return .all            
        case .default: return .default            
        case .error: return .error            
        case .session: return .session            
        case .transaction: return .transaction            
        case .attachment: return .attachment            
        case .userFeedback: return .userFeedback            
        case .profile: return .profile            
        case .metricBucket: return .metricBucket            
        case .replay: return .replay            
        case .profileChunk: return .profileChunk            
        case .span: return .span            
        case .unknown: return .unknown            
        }
    }
}

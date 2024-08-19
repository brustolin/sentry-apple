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


extension SentryDataCategory {
    
    func toString() -> String {
        switch self {
        case .all: return "all"
        case .default: return "default"
        case .error: return "error"
        case .session: return "session"
        case .transaction: return "transaction"
        case .attachment: return "attachment"
        case .userFeedback: return "user_report"
        case .profile: return "profile"
        case .metricBucket: return "metric_bucket"
        case .replay: return "replay"
        case .profileChunk: return "profile_chuck"
        case .span: return "span"
        case .unknown: return "unknown"
        }
    }
    
    static func fromEnvelopeType(itemType: String) -> SentryDataCategory {
        
    }
}

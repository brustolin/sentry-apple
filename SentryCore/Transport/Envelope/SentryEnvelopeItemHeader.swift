import Foundation

class SentryEnvelopeItemHeader {
    let type: String
    let length: UInt
    let filename: String?
    let contentType: String?
    
    init(type: String, length: UInt, filename: String? = nil, contentType: String? = nil) {
        self.type = type
        self.length = length
        self.filename = filename
        self.contentType = contentType
    }
}

extension SentryEnvelopeItemHeader : Serializable {
    func serialize() -> [String: Any] {
        var result : [String:Any] = [Keys.type: type, Keys.length: length ]
        
        result.addNonNil(Keys.filename, value: filename)
        result.addNonNil(Keys.contentType, value: contentType)
        
        return result
    }
    
    private enum Keys {
        static let filename = "filename"
        static let contentType = "content_type"
        static let type = "type"
        static let length = "length"
    }
}

enum SentryEnvelopeItemType: String {
    case event = "event"
    case session = "session"
    case userFeedback = "user_report"
    case transaction = "transaction"
    case attachment = "attachment"
    case clientReport = "client_report"
    case profile = "profile"
    case replayVideo = "replay_video"
    case statsd = "statsd"
    case profileChunk = "profile_chunk"
}

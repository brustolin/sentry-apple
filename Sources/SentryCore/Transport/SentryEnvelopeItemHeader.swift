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

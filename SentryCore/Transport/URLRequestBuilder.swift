import Foundation

class URLRequestBuilder {
    
    static private(set) var shared = URLRequestBuilder()
    
    func createEnvelopeRequest(envelope: SentryEnvelope, dsn: SentryDSN) throws -> URLRequest {
        var data = Data()
        try envelope.stream(to: &data)
       
        return URLRequest(envelopeRequestWithDsn: dsn, data: data)
    }
    
    func createEnvelopeRequest(envelope: SentryEnvelope, url: URL) throws -> URLRequest {
        var data = Data()
        try envelope.stream(to: &data)
       
        return URLRequest(envelopeRequestWithURL: url, data: data, authHeader: nil)
    }
}

import Foundation

private let SentryServerVersionString = "7"
private let SentryRequestTimeout: TimeInterval = 15

extension URLRequest {

    init(storeRequestWithDsn dsn: SentryDSN, event: Event) throws {
        let serialized = event.serialize()
        let jsonData = try SentrySerialization.dataWithJsonObject(serialized)
       
        SentryLog.debug("""
Sending JSON -------------------------------
\(String(data: jsonData, encoding: .utf8) ?? "")
--------------------------------------------
""")
        self.init(storeRequestWithDsn: dsn, data: jsonData)
    }
    
    init(storeRequestWithDsn dsn: SentryDSN, data: Data) {
        self.init(url: dsn.storeEndpoint, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: SentryRequestTimeout)
        let authHeader = newAuthHeader(url: dsn.url)
        
        self.httpMethod = "POST"
        self.setValue(authHeader, forHTTPHeaderField: "X-Sentry-Auth")
        self.setValue("application/json", forHTTPHeaderField: "Content-Type")
        self.setValue("\(SentryMeta.sdkName)/\(SentryMeta.versionString)", forHTTPHeaderField: "User-Agent")
        
        if let compressed = SentryDataUtils.gzipped(data: data) {
            self.setValue("gzip", forHTTPHeaderField: "Content-Encoding")
            self.httpBody = compressed
        } else {
            self.httpBody = data
        }
    }
    
    init(envelopeRequestWithDsn dsn: SentryDSN, data: Data) {
        let apiURL = dsn.envelopeEndpoint
        let authHeader = newAuthHeader(url: dsn.url)
        self.init(envelopeRequestWithURL: apiURL, data: data, authHeader: authHeader)
    }
    
    init(envelopeRequestWithURL url: URL, data: Data, authHeader: String?) {
        self.init(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: SentryRequestTimeout)
        
        self.httpMethod = "POST"
        
        if let authHeader = authHeader {
            self.setValue(authHeader, forHTTPHeaderField: "X-Sentry-Auth")
        }
        self.setValue("application/x-sentry-envelope", forHTTPHeaderField: "Content-Type")
        self.setValue("\(SentryMeta.sdkName)/\(SentryMeta.versionString)", forHTTPHeaderField: "User-Agent")
        self.setValue("gzip", forHTTPHeaderField: "Content-Encoding")
        
        if let compressed = SentryDataUtils.gzipped(data: data) {
            self.setValue("gzip", forHTTPHeaderField: "Content-Encoding")
            self.httpBody = compressed
        } else {
            self.httpBody = data
        }
    }
}

private func newHeaderPart(key: String, value: Any) -> String {
    return "\(key)=\(value)"
}

private func newAuthHeader(url: URL) -> String {
    var string = "Sentry "
    string += "\(newHeaderPart(key: "sentry_version", value: SentryServerVersionString)),"
    string += "\(newHeaderPart(key: "sentry_client", value: "\(SentryMeta.sdkName)/\(SentryMeta.versionString)")),"
    string += newHeaderPart(key: "sentry_key", value: url.user ?? "")
    
    if let password = url.password {
        string += ",\(newHeaderPart(key: "sentry_secret", value: password))"
    }
    return string
}


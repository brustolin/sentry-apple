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
        let authHeader = Self.newAuthHeader(url: dsn.url)
        
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
    
    init(storeRequestWithDsn dsn: SentryDSN, filePath: String) throws {
           self.init(url: dsn.storeEndpoint, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: SentryRequestTimeout)
           let authHeader = Self.newAuthHeader(url: dsn.url)
           
           self.httpMethod = "POST"
           self.setValue(authHeader, forHTTPHeaderField: "X-Sentry-Auth")
           self.setValue("application/json", forHTTPHeaderField: "Content-Type")
           self.setValue("\(SentryMeta.sdkName)/\(SentryMeta.versionString)", forHTTPHeaderField: "User-Agent")
           
           let fileURL = URL(fileURLWithPath: filePath)
           
           // Setup InputStream for file
           // This could be improved with a compressable stream
           let fileStream = InputStream(url: fileURL)
           fileStream?.open()
           
           // Create a stream body for the URLRequest
           self.httpBodyStream = fileStream
       }
    
    init(envelopeRequestWithDsn dsn: SentryDSN, data: Data) {
        let apiURL = dsn.envelopeEndpoint
        let authHeader = Self.newAuthHeader(url: dsn.url)
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
        
        if let compressed = SentryDataUtils.gzipped(data: data) {
            self.setValue("gzip", forHTTPHeaderField: "Content-Encoding")
            self.httpBody = compressed
        } else {
            self.httpBody = data
        }
    }
    
    private static func newAuthHeader(url: URL) -> String {
        var string = "Sentry "
        string += "sentry_version=\(SentryServerVersionString),"
        string += "sentry_client=\(SentryMeta.sdkName)/\(SentryMeta.versionString))),"
        string += "sentry_key=\(url.user ?? "")"
        
        if let password = url.password {
            string += ",sentry_secret=\(password)"
        }
        return string
    }
}

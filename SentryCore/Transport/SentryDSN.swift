import Foundation
import CommonCrypto

class SentryDSN {
    let url: URL
    let storeEndpoint: URL
    let envelopeEndpoint: URL
    
    init(dsnString: String) throws {
        let url = try Self.convertDsnString(dsnString: dsnString)
        self.url = url
        
         let baseEndPoint = try Self.getBaseEndpoint(for: url)
         self.storeEndpoint = baseEndPoint.appendingPathComponent("store/")
         self.envelopeEndpoint = baseEndPoint.appendingPathComponent("envelope/")
    }
    
    func getHash() -> String {
        guard let data = url.absoluteString.data(using: .utf8) else { return "" }
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        }
        return digest.map { String(format: "%02x", $0) }.joined()
    }
       
    private static func getBaseEndpoint(for url: URL) throws -> URL {
        let projectId = url.lastPathComponent
        var paths = url.pathComponents.dropFirst().dropLast() // Drop leading '/' and projectId
        var path = paths.count == 0 ? "" : "/\(paths.joined(separator: "/"))"

        var components = URLComponents()
        components.scheme = url.scheme
        components.host = url.host
        components.port = url.port
        components.path = "\(path)/api/\(projectId)/"
        
        guard let result = components.url else { throw SentryError("Could not parse DSN base Endpoint") }
        return result
    }
    
    private static func convertDsnString(dsnString: String) throws -> URL {
        let trimmedDsnString = dsnString.trimmingCharacters(in: .whitespacesAndNewlines)
        let allowedSchemes: Set<String> = ["http", "https"]
        
        guard let url = URL(string: trimmedDsnString) else { throw SentryError("Invalid DSN string: \(trimmedDsnString)") }
        
        guard let scheme = url.scheme, allowedSchemes.contains(scheme) else { throw SentryError("Invalid URL schemefor DSN: \(trimmedDsnString)") }
        
        guard let host = url.host, !host.isEmpty else { throw SentryError("Host component missing for DSN: \(trimmedDsnString)") }
        
        guard url.user != nil else { throw SentryError("User component missing for DSN: \(trimmedDsnString)") }
        
        guard url.pathComponents.count >= 2 else { throw SentryError("Project ID path component missing for DSN: \(trimmedDsnString)") }
        
        return url
    }
}

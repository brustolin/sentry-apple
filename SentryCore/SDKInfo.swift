import Foundation

public class SDKInfo {
    // TODO: Check if its possible to add the package manager
    
    /**
     * The name of the SDK. Examples: sentry.cocoa, sentry.cocoa.vapor, ...
     */
    public let name: String

    /**
     * The version of the SDK. It should have the Semantic Versioning format MAJOR.MINOR.PATCH, without
     * any prefix (no v or anything else in front of the major version number). Examples:
     * 0.1.0, 1.0.0, 2.0.0-beta0
     */
    public let version: String
    
    public init(name: String, version: String) {
        self.name = name
        self.version = version
    }
}

extension SDKInfo : Serializable {
    public func serialize() -> [String: Any] {
        return [
            Keys.name: name,
            Keys.version: version
        ]
    }
    
    convenience init?(dictionary: [String: Any]) {
        guard let name = dictionary[Keys.name] as? String,
              let version = dictionary[Keys.name] as? String
        else { return nil }
        self.init(name: name, version: version)
    }
    
    private enum Keys {
        static let name = "name"
        static let version = "version"
    }
}

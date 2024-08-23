import Foundation

@objc(SentryOptions)
@objcMembers
public class Options : OptionsBase {

    private(set) var parsedDSN: SentryDSN?
    
    public var dsn: String? {
        get { parsedDSN?.url.absoluteString }
        set {
            if let newValue {
                do {
                    parsedDSN = try SentryDSN(dsnString: newValue)
                } catch {
                    SentryLog.error("Could not parse the DSN (\(newValue)): \(error)")
                }
            }
            else { parsedDSN = nil }
        }
    }
    
    /**
     * Whether to send client reports, which contain statistics about discarded events.
     * @note The default is @c YES.
     * @see <https://develop.sentry.dev/sdk/client-reports/>
     */
    public var sendClientReports: Bool = true
    
    /**
     * The path to store SDK data, like events, transactions, profiles, raw crash data, etc. We
     recommend only changing this when the default, e.g., in security environments, can't be accessed.
     *
     * @note The default is `NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask,
     YES)`.
     */
    public var cacheDirectoryPath: String
        
    public let experimental = ExperimentalOptions()
    
    public override init() {
        self.cacheDirectoryPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first ?? ""
        super.init()
    }
}

@objc(SentryExperimentalOptions)
public class ExperimentalOptions : OptionsBase {
}

@objc(SentryOptionsBase)
@objcMembers
public class OptionsBase : NSObject {
    
    private let initializedDictionary : [String: Any]
    
    public override init() {
        initializedDictionary = [:]
    }
    
    init(dictionary : [String:Any]) {
        initializedDictionary = dictionary
    }
    
    //Mechanism to allow integrations to add new options to the SDK
    //This is meant to be used by other integrations and not users
    //see "SentryTests/SessionReplay/SentrySessionReplayTests.swift" or
    //"SentryTests/Performance/SentryPerformanceOptionsTests.swift"
    private var integrations: [ObjectIdentifier: IntegrationOption] = [:]
    
    public subscript<T: IntegrationOption>(type: T.Type) -> T? {
        get {
            let key = ObjectIdentifier(type)
            return integrations[key] as? T
        }
        set {
            let key = ObjectIdentifier(type)
            newValue?.update(dictionary: initializedDictionary)
            integrations[key] = newValue
        }
    }
}

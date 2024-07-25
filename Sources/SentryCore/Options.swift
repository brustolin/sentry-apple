import Foundation

@objc(SentryOptions)
@objcMembers
public class Options : OptionsBase {
    public var dsn : String?
    public let experimental = ExperimentalOptions()
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

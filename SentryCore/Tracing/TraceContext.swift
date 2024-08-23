/// Context: https://develop.sentry.dev/sdk/telemetry/traces/dynamic-sampling-context/

import Foundation

public class TraceContext {
    
    /// UUID V4 encoded as a hexadecimal sequence with no dashes.
    let traceId: SentryId
    
    /// Public key from the DSN used by the SDK.
    let publicKey: String
    
    /// The release name as specified in client options, usually: package@x.y.z+build.
    let releaseName: String?
    
    /// The environment name as specified in client options, for example staging.
    let environment: String?
    
    /// The transaction name set on the scope.
    let transaction: String?
    
    /// Sample rate used for this trace.
    let sampleRate: String?
    
    /// Value indicating whether the trace was sampled.
    let sampled: String?
    
    /// Id of the current session replay.
    let replayId: String?
    
    /// Initializes a SentryTraceContext with given properties.
    init(traceId: SentryId, publicKey: String, releaseName: String? = nil, environment: String? = nil, transaction: String? = nil, sampleRate: String? = nil, sampled: String? = nil, replayId: String? = nil) {
        self.traceId = traceId
        self.publicKey = publicKey
        self.releaseName = releaseName
        self.environment = environment
        self.transaction = transaction
        self.sampleRate = sampleRate
        self.sampled = sampled
        self.replayId = replayId
    }
}

extension TraceContext : Serializable {
    
    static let BAGGAGE_HEADER = "baggage"
    
    public func serialize() -> [String : Any] {
        var information = [Keys.traceId: traceId.sentryIdString,
                           Keys.publicKey: publicKey]
        
        information.addNonNil(Keys.release, value: releaseName)
        information.addNonNil(Keys.environment, value: environment)
        information.addNonNil(Keys.transaction, value: transaction)
        information.addNonNil(Keys.sampleRate, value: sampleRate)
        information.addNonNil(Keys.sampled, value: sampled)
        information.addNonNil(Keys.replayId, value: replayId)
        
        return information
    }

    convenience init?(dictionary: [String:Any]) {
        guard let traceId = dictionary[Keys.traceId] as? String,
              let publicKey = dictionary[Keys.publicKey] as? String
        else { return nil }
        
        self.init(traceId: SentryId(uuidString: traceId),
                  publicKey: publicKey,
                  releaseName: dictionary[Keys.release] as? String,
                  environment: dictionary[Keys.environment] as? String,
                  transaction: dictionary[Keys.transaction] as? String,
                  sampleRate: dictionary[Keys.sampleRate] as? String,
                  sampled: dictionary[Keys.sampled] as? String,
                  replayId: dictionary[Keys.replayId] as? String
        )
    }
    
    /// Create a SentryBaggage with the information of this SentryTraceContext.
    func toBaggageHeader(original: [String:String]?) -> String {
        var result = original ?? [:]
        serialize().forEach { result["sentry-\($0)"] = "\($1)" }
        return BaggageSerialization.encodeDictionary(result)
    }
    
    private enum Keys {
        static let traceId = "trace_id"
        static let publicKey = "public_id"
        static let release = "release"
        static let environment = "environment"
        static let transaction = "transaction"
        static let userSegment = "user_segment"
        static let sampleRate = "sample_rate"
        static let sampled = "sampled"
        static let replayId = "replay_id"
    }
}

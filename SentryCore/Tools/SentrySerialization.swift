import Foundation

class SentrySerialization {
    static func dataWithJsonObject(_ object: Any) throws -> Data {
        // When the object is not valid to serialized, trying to serialized it
        // will cause a crash that cannot be capture, that why why first check
        // and in negative cause we throw a Swift exception
        guard JSONSerialization.isValidJSONObject(object) else {
            throw SentryError("Object is not JSON valid: \(object)")
        }
        
        return try JSONSerialization.data(withJSONObject: object)
    }
    
    static func jsonWithData(_ data: Data) throws -> Any {
        try JSONSerialization.jsonObject(with: data)
    }
    
    static func stream<Target>(object: Any, to target: inout Target) throws where Target : BinaryOutputStream {
        let data = try dataWithJsonObject(object)
        try target.stream(data)
    }
    
    private init(){
    }
}

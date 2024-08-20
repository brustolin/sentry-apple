import Foundation

/// Event is a generic name. I believe we should use SentryEvent for Swift too
class Event : Serializable {
    func serialize() -> [String : Any] {
        [:]
    }
}

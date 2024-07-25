import Foundation

@objc
public enum SentryFlushResult: Int {
    case success = 0
    case timedOut
    case alreadyFlushing
}

@objc(SentryTransport)
public protocol Transport:  NSObjectProtocol {
    func send(envelope: SentryEnvelope)
    func recordLostEvent(category: SentryDataCategory, reason: SentryDiscardReason)
    func recordLostEvent(category: SentryDataCategory, reason: SentryDiscardReason, quantity: UInt)
    func flush(timeout: TimeInterval) -> SentryFlushResult
}

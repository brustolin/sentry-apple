import Foundation

enum FlushResult: Int {
    case success = 0
    case timedOut
    case alreadyFlushing
}

protocol SentryTransport {
    func send(envelope: SentryEnvelope)
    func recordLostEvent(category: SentryDataCategory, reason: SentryDiscardReason)
    func recordLostEvent(category: SentryDataCategory, reason: SentryDiscardReason, quantity: UInt)
    func flush(timeout: TimeInterval) -> FlushResult
}

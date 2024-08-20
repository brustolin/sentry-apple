import Foundation

protocol RateLimiter {
    func isRateLimitActive(category: SentryDataCategory) -> Bool
    func update(with response: HTTPURLResponse)
}

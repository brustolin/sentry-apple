/// Documentation: https://develop.sentry.dev/sdk/rate-limiting/

import Foundation

class DefaultRateLimiter : RateLimiter {
    
    private static let DEFAULT_DELAY = 60.0
    private static let RATE_LIMIT_HEADER = "X-Sentry-Rate-Limits"
    private static let RETRY_AFTER_HEADER = "Retry-After"
    private static let CUSTOM_NAMESPACE = "custom"
    
    private var rateLimits = [SentryDataCategory: Date]()

    func isRateLimitActive(category: SentryDataCategory) -> Bool {
        let now = SentryCurrentDateProvider.shared.date()
        
        if let categoryRate = rateLimits[category], categoryRate > now {
            return true
        }
        
        if let allRate = rateLimits[.all], allRate > now {
            return true
        }
        
        return false
    }
    
    func update(with response: HTTPURLResponse) {
        if let rateLimitHeader = response.allHeaderFields[DefaultRateLimiter.RATE_LIMIT_HEADER] as? String {
            processRateLimits(rateLimitHeader)
        } else if let retryAfterHeader = response.allHeaderFields[DefaultRateLimiter.RETRY_AFTER_HEADER] as? String, response.statusCode == 429 {
            processRetryAfter(retryAfterHeader)
        }
    }
        
    private func processRateLimits(_ header: String) {
        guard !header.isEmpty else { return }

        // Each quotaLimit exists of retryAfter:categories:scope.
        // The scope is ignored here as it can be ignored by SDKs.
        // Remove any white space between quotas.
        let quotas = header.split(separator: .comma).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        for quota in quotas {
            let parameters = quota.split(separator: .colon)
            guard parameters.count >= 2, let rateLimitInSeconds = Double(parameters[0]), rateLimitInSeconds > 0 else { continue }
            
            let categories = parseCategories(parameters[1])
            for category in categories {
                if category == .metricBucket && parameters.count > 4 {
                    let namespacesAsString = parameters[4]
                    let namespaces = namespacesAsString.split(separator: .semicolon)
                    if namespacesAsString.isEmpty || namespaces.contains(DefaultRateLimiter.CUSTOM_NAMESPACE[...]) {
                        rateLimits[category] = getLongerRateLimit(rateLimits[category],
                                                                  newRateLimitInSeconds: rateLimitInSeconds)
                    }
                } else {
                    rateLimits[category] = getLongerRateLimit(rateLimits[category],
                                                              newRateLimitInSeconds: rateLimitInSeconds)
                }
            }
        }
    }
    
    private func processRetryAfter(_ header: String) {
        let seconds = Double(header) ?? DefaultRateLimiter.DEFAULT_DELAY
        rateLimits[.all] = getLongerRateLimit(rateLimits[.all], newRateLimitInSeconds: seconds)
    }
    
    private func parseCategories(_ categoriesAsString: any StringProtocol) -> [SentryDataCategory] {
        // The categories are a semicolon-separated list. If this parameter is empty, it stands for all categories.
        guard categoriesAsString.count > 0 else { return [.all] }
        let categories = categoriesAsString.split(separator: .semicolon)
        
        return categories.compactMap {
            guard let result = SentryDataCategory.fromString(String($0)), result != .userFeedback && result != .unknown else { return SentryDataCategory?.none }
            return result
        }
    }

    private func getLongerRateLimit(_ existingRateLimit: Date?, newRateLimitInSeconds: Double) -> Date {
        let newDate = SentryCurrentDateProvider.shared.date().addingTimeInterval(newRateLimitInSeconds)
        guard let existingRateLimit else { return newDate }
        return existingRateLimit > newDate ? existingRateLimit : newDate
    }
}

import Foundation

class SentryHttpTransport : SentryTransport, SentryEnvelopeManagerDelegate, SentryEnvelopeRateLimitDelegate {
        
    private let options: Options
    private let envelopeRateLimiter: SentryEnvelopeRateLimiter
    private let envelopeManager: SentryEnvelopeManager
    private let dispatchQueue: SentryDispatchQueueWrapper
    private var discardedEvents = [String: DiscardedEvent]()
    private let lock = NSLock()
    private let discardLock = NSLock()
    
    private let requestManager: SentryRequestManager
    private let requestBuilder: URLRequestBuilder
    private var cachedEnvelopeSendDelay: TimeInterval
    private var dispatchGroup: DispatchGroup

    private var isFlushing = false
    private var isSending = false
    
    init(options: Options, rateLimiter: SentryEnvelopeRateLimiter, envelopeManager: SentryEnvelopeManager, requestManager: SentryRequestManager, requestBuilder: URLRequestBuilder, cachedEnvelopeSendDelay: TimeInterval = 0.1, dispatchQueue: SentryDispatchQueueWrapper = SentryDispatchQueueWrapper()) {
        self.options = options
        self.envelopeRateLimiter = rateLimiter
        self.dispatchQueue = dispatchQueue
        self.envelopeManager = envelopeManager
        self.requestManager = requestManager
        self.cachedEnvelopeSendDelay = cachedEnvelopeSendDelay
        self.requestBuilder = requestBuilder
        self.dispatchGroup = DispatchGroup()
        
        envelopeManager.delegate = self
        rateLimiter.delegate = self
    }
    
    func send(envelope: SentryEnvelope) {
        var finalEnvelope = envelopeRateLimiter.removeRateLimitedItems(from: envelope)
        guard finalEnvelope.items.count >= 0 else {
            SentryLog.debug("RateLimit is active for all envelope items.")
            return
        }
        
        finalEnvelope = addClientReportTo(envelope: finalEnvelope)
        dispatchQueue.dispatchAsync { [weak self] in
            guard let self else { return }
            do {
                try self.envelopeManager.storeEnvelope(finalEnvelope)
                self.sendAllCachedEnvelopes()
            } catch {
                SentryLog.error("Could not save envelope: \(error)")
            }
        }
    }
    
    func recordLostEvent(category: SentryDataCategory, reason: SentryDiscardReason) {
        self.recordLostEvent(category: category, reason: reason, quantity: 1)
    }
    
    func recordLostEvent(category: SentryDataCategory, reason: SentryDiscardReason, quantity: UInt) {
        guard options.sendClientReports else { return }
        
        let key = "\(category.name()):\(reason.name())"
        
        defer { discardLock.unlock() }
        discardLock.lock()
        
        let discardedQuantity = (discardedEvents[key]?.quantity ?? 0) + quantity
        
        discardedEvents[key] = DiscardedEvent(reason: reason, category: category, quantity: discardedQuantity)
    }
    
    func flush(timeout: TimeInterval) -> FlushResult {
        
        // Calculate the dispatch time of the flush duration as early as possible to guarantee an exact
        // flush duration. Any code up to the dispatch_group_wait can take a couple of ms, adding up to
        // the flush duration.
        let delta = timeout * Double(NSEC_PER_SEC)
        let dispatchTimeout = DispatchTime.now() + delta
        
        lock.lock()
        if isFlushing {
            SentryLog.debug("Already flushing")
            lock.unlock()
            return .alreadyFlushing
        }
        isFlushing = true
        dispatchGroup.enter()
        lock.unlock()
        
        dispatchQueue.dispatchAsync { self.sendAllCachedEnvelopes() }
        
        let result = dispatchGroup.wait(timeout: dispatchTimeout)
        
        if result == .success {
            SentryLog.debug("Finished flushing.")
            return .success
        } else {
            return .timedOut
        }
    }
   
    
    // MARK: - SentryEnvelopeRateLimitDelegate
    func envelopeItemDropped(_ item: SentryEnvelopeItem, withCategory category: SentryDataCategory) {
        recordLostEvent(category: category, reason: .rateLimitBackoff)
        recordLostSpans(from: item, reason: .rateLimitBackoff)
    }
        
    // MARK: - SentryEnvelopeManagerDelegate
    
    func envelopeItemDeleted(_ item: SentryEnvelopeItem, category: SentryDataCategory) {
        recordLostEvent(category: category, reason: .cacheOverflow)
        recordLostSpans(from: item, reason: .cacheOverflow)
    }
    
    // MARK: - Private functions
   
    private func recordLostEnvelopeItems(_ items: [SentryEnvelopeItem]) {
        for item in items {
            // We don't want to record a lost event when it's a client report.
            // It's fine to drop it silently.
            guard let itemType = SentryEnvelopeItemType(rawValue: item.header.type), itemType != .clientReport else { continue }
            let category = SentryDataCategory.fromEnvelopeType(itemType)
            recordLostEvent(category: category, reason: .networkError)
            recordLostSpans(from: item, reason: .networkError)
        }
    }
    
    private func recordLostSpans(from item: SentryEnvelopeItem, reason: SentryDiscardReason) {
        guard item.header.type == SentryEnvelopeItemType.transaction.rawValue else { return }
        do {
            guard let json = try SentrySerialization.jsonWithData(item.data) as? [String: Any] else { 
                SentryLog.error("Could not record lost span: Invalid data format")
                return
            }
            
            let numberOfSpans = UInt((json["spans"] as? [Any])?.count ?? 0)
            
            // +1 because the transaction itself is a span
            recordLostEvent(category: .span, reason: reason, quantity: numberOfSpans + 1)
        } catch {
            SentryLog.error("Could not record lost span: \(error)")
        }
    }
    
    private func sendAllCachedEnvelopes() {
        SentryLog.debug("sendAllCachedEnvelopes start")
        
        guard let dsn = options.parsedDSN else {
            SentryLog.debug("Cannot send envelopes. Invalid DSN")
            return
        }
        
        lock.lock()
        if isSending || !requestManager.ready {
            SentryLog.debug("Already Sending")
            lock.unlock()
            return
        }
        self.isSending = true
        lock.unlock()
        
        guard let oldestEnvelopeFile = envelopeManager.popOldestEnvelopeFile()
        else {
            SentryLog.debug("No envelopes left to send.")
            return
        }
        
        guard var envelope: SentryEnvelope = oldestEnvelopeFile.readEnvelope() else {
            deleteAndSendNext(oldestEnvelopeFile.url)
            return
        }
        
        envelope = envelopeRateLimiter.removeRateLimitedItems(from: envelope)
        envelope.header.sentAt = SentryCurrentDateProvider.shared.date()
        do {
            let request = try requestBuilder.createEnvelopeRequest(envelope: envelope, dsn: dsn)
            send(envelope: envelope, from: oldestEnvelopeFile, request: request)
        } catch {
            SentryLog.error("Failed to build request: \(error)")
            recordLostEnvelopeItems(envelope.items)
            deleteAndSendNext(oldestEnvelopeFile.url)
        }
    }
    
    private func send(envelope:SentryEnvelope, from:EnvelopeFile, request:URLRequest) {
        requestManager.addRequest(request) { [weak self] response, error in
            guard let self else {
                SentryLog.debug("Self is nil. Not doing anything.")
                return
            }
            
            if let error, response?.statusCode == 429 {
                SentryLog.debug("Request error other than rate limit: \(error)")
                self.recordLostEnvelopeItems(envelope.items)
            }
            
            if let response {
                SentryLog.debug("Envelope sent successfully!")
                self.envelopeRateLimiter.rateLimiter.update(with: response)
                self.deleteAndSendNext(from.url)
            } else {
                SentryLog.debug("No internet connection.")
                // Envelope was not send, returning it to the cache list
                envelopeManager.insertEnvelopeFile(from)
                finishedSending()
            }
        }
    }
    
    private func finishedSending() {
        defer { lock.unlock() }
        lock.lock()
        isSending = false
        if isFlushing {
            SentryLog.debug("Stop flushing")
            isFlushing = false
            dispatchGroup.leave()
        }
    }
    
    private func deleteAndSendNext(_ pathToEnvelope: URL) {
        SentryLog.debug("Deleting envelope and sending next.")
        defer { lock.unlock() }
        lock.lock()
        
        isSending = false
        
        dispatchQueue.dispatchAfter(interval: self.cachedEnvelopeSendDelay) { [weak self] in
            self?.sendAllCachedEnvelopes()
        }
    }
    
    private func addClientReportTo(envelope: SentryEnvelope) -> SentryEnvelope {
        guard options.sendClientReports else { return envelope }
       
        let discarted = cleanDiscardedEvents()
        guard discarted.count > 0 else { return envelope }
        
        let clientReport = ClientReport(timestamp: SentryCurrentDateProvider.shared.date(), discardedEvents: discarted)
        
        do {
            let envelopeItem = try clientReport.toSentryEnvelopeItem()
            return SentryEnvelope(header: envelope.header, items: envelope.items + [envelopeItem])
        } catch {
            SentryLog.error("Could not create envelope for client report: \(error)")
            return envelope
        }
    }
    
    private func cleanDiscardedEvents() -> [DiscardedEvent] {
        defer { discardLock.unlock() }
        discardLock.lock()
        
        let result = Array(discardedEvents.values)
        discardedEvents.removeAll()
        return result
    }
}

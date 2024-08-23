import Foundation
class Session {
    private let lock = NSLock()
    
    private(set) var sessionId: UUID
    private(set) var started: Date
    private(set) var status: SessionStatus
    private(set) var sequence: UInt
    private(set) var errors: UInt
    private(set) var distinctId: String
    private(set) var timestamp: Date?
    private(set) var duration: Double?
    private(set) var releaseName: String?
    private(set) var environment: String?
    private var initFlag: Bool?
    
    // Default private constructor
    init(distinctId: String) {
        self.sessionId = UUID()
        self.started = SentryCurrentDateProvider.shared.date()
        self.status = .ok
        self.sequence = 1
        self.errors = 0
        self.distinctId = distinctId
    }
    
    init(releaseName: String, distinctId: String) {
        self.sessionId = UUID()
        self.started = SentryCurrentDateProvider.shared.date()
        self.status = .ok
        self.sequence = 1
        self.errors = 0
        self.distinctId = distinctId
        self.releaseName = releaseName
    }
    
    init?(jsonObject: [String: Any]) {
        guard let sid = jsonObject["sid"] as? String, let sessionId = UUID(uuidString: sid) else {
            return nil
        }
        self.sessionId = sessionId
        
        guard let startedStr = jsonObject["started"] as? String, let startedDate = SentryDateUtils.dateFromIso8601String(startedStr) else {
            return nil
        }
        self.started = startedDate
        
        guard let statusStr = jsonObject["status"] as? String, let statusName = SessionStatusNames(rawValue: statusStr) else {
            return nil
        }
        self.status = statusName.toStatus()
        
        guard let seq = jsonObject["seq"] as? NSNumber else {
            return nil
        }
        self.sequence = seq.uintValue
        
        guard let errors = jsonObject["errors"] as? NSNumber else {
            return nil
        }
        self.errors = errors.uintValue
        
        guard let did = jsonObject["did"] as? String else {
            return nil
        }
        self.distinctId = did
        
        self.initFlag = jsonObject["init"] as? Bool
        
        if let attrs = jsonObject["attrs"] as? [String: Any] {
            if let releaseName = attrs["release"] as? String {
                self.releaseName = releaseName
            }
            if let environment = attrs["environment"] as? String {
                self.environment = environment
            }
        }
        
        if let timestampStr = jsonObject["timestamp"] as? String {
            self.timestamp = SentryDateUtils.dateFromIso8601String(timestampStr)
        }
        
        self.duration = jsonObject["duration"] as? Double
    }
    
    func setFlagInit() {
        self.initFlag = true
    }
    
    func endSessionExited(withTimestamp timestamp: Date) {
        defer { lock.unlock() }
        lock.lock()
        self.changed()
        self.status = .exited
        self.endSession(withTimestamp: timestamp)
    }
    
    func endSessionCrashed(withTimestamp timestamp: Date) {
        defer { lock.unlock() }
        lock.lock()
        self.changed()
        self.status = .crashed
        self.endSession(withTimestamp: timestamp)
        
    }
    
    func endSessionAbnormal(withTimestamp timestamp: Date) {
        defer { lock.unlock() }
        lock.lock()
        self.changed()
        self.status = .abnormal
        self.endSession(withTimestamp: timestamp)
    }
    
    private func endSession(withTimestamp timestamp: Date) {
        defer { lock.unlock() }
        lock.lock()
        self.timestamp = timestamp
        self.duration = timestamp.timeIntervalSince(self.started)
    }
    
    private func changed() {
        self.initFlag = nil
        self.sequence += 1
    }
    
    func incrementErrors() {
        defer { lock.unlock() }
        lock.lock()
        self.changed()
        self.errors += 1
    }
    
    func serialize() -> [String: Any] {
        defer { lock.unlock() }
        lock.lock()
        
        var serializedData: [String: Any] = [
            "sid": self.sessionId.uuidString,
            "errors": self.errors,
            "started": SentryDateUtils.dateToIso8601String(self.started)
        ]
        
        if let initFlag = self.initFlag {
            serializedData["init"] = initFlag
        }
        
        serializedData["status"] = self.status.name().rawValue
        
        let timestamp = self.timestamp ?? SentryCurrentDateProvider.shared.date()
        serializedData["timestamp"] = SentryDateUtils.dateToIso8601String(timestamp)
        
        if let duration = self.duration {
            serializedData["duration"] = duration
        } else if self.initFlag == nil {
            let secondsBetween = (self.timestamp ?? Date()).timeIntervalSince(self.started)
            serializedData["duration"] = NSNumber(value: secondsBetween)
        }
        
        serializedData["seq"] = self.sequence
        
        if self.releaseName != nil || self.environment != nil {
            var attrs: [String: Any] = [:]
            if let releaseName = self.releaseName {
                attrs["release"] = releaseName
            }
            if let environment = self.environment {
                attrs["environment"] = environment
            }
            serializedData["attrs"] = attrs
        }
        
        serializedData["did"] = self.distinctId
        
        return serializedData
    }
    
    func copy() -> Session {
        let copy = Session(distinctId: self.distinctId)
        copy.sessionId = self.sessionId
        copy.started = self.started
        copy.status = self.status
        copy.errors = self.errors
        copy.sequence = self.sequence
        copy.timestamp = self.timestamp
        copy.duration = self.duration
        copy.releaseName = self.releaseName
        copy.environment = self.environment
        copy.initFlag = self.initFlag
        return copy
    }
}

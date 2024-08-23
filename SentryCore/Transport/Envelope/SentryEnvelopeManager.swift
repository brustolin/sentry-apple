import Foundation

protocol SentryEnvelopeManagerDelegate: AnyObject {
    func envelopeItemDeleted(_ item: SentryEnvelopeItem, category: SentryDataCategory)
}

struct EnvelopeFile {
    let createdAt: Date
    let url: URL
    
    func readEnvelope() -> SentryEnvelope? {
        do {
            let file = try FileHandle(forReadingFrom: url)
            return try SentryEnvelope(from: file)
        }
        catch {
            SentryLog.debug("Could not read envelope: \(error)")
            return nil
        }
    }
}

class SentryEnvelopeManager {
    private static let ENVELOPE_PATH_COMPONENT = "envelopes"
    
    let envelopesPath: URL
    let fileManager: SentryFileManager
    let maxEnvelopes: Int
    weak var delegate: SentryEnvelopeManagerDelegate? = nil
    
    // We used to use the file system to control the cache.
    // Now we keep a cache refence in memory and we could event expand it
    // To Keep more information about the envelope so we dont need to
    // open and parse it every time we need some information.
    private var pendingEnvelopes: [EnvelopeFile]
    private let lock = NSLock()
    
    init(fileManager: SentryFileManager, maxEnvelopes: Int = 10) {
        self.fileManager = fileManager
        self.maxEnvelopes = maxEnvelopes
        self.envelopesPath = fileManager.sentryPath.appendingPathComponent(Self.ENVELOPE_PATH_COMPONENT)

        pendingEnvelopes = Self.getPendingEnvelopes(from: self.envelopesPath, fileManager: fileManager)
    }
    
    func storeEnvelope(_ envelope: SentryEnvelope) throws {
        let destination = envelopesPath.appendingPathComponent(fileManager.uniqueAscendingJsonName())
        try fileManager.writeStreamable(envelope, at: destination)
        handleEnvelopesLimit()
    }
    
    func popOldestEnvelopeFile() -> EnvelopeFile? {
        defer { lock.unlock() }
        lock.lock()
        
        guard pendingEnvelopes.count > 0 else { return nil }
        return pendingEnvelopes.removeFirst()
    }
    
    func insertEnvelopeFile(_ file: EnvelopeFile) {
        defer { lock.unlock() }
        lock.lock()
        
        for i in 0..<pendingEnvelopes.count {
            if file.createdAt < pendingEnvelopes[i].createdAt {
                pendingEnvelopes.insert(file, at: i)
                return
            }
        }
        
        pendingEnvelopes.append(file)
    }
    
    private func handleEnvelopesLimit() {
        let envelopesToRemove : [EnvelopeFile] = {
            defer { lock.unlock() }
            lock.lock()
            
            let amountToRemove = pendingEnvelopes.count - maxEnvelopes;
            guard amountToRemove > 0 else { return [] }
            
            let envelopesToRemove = Array(pendingEnvelopes.prefix(amountToRemove))
            pendingEnvelopes.removeSubrange(0..<amountToRemove)
            
            return envelopesToRemove
        }()
        
        for file in envelopesToRemove {
            do {
                try fileManager.removeItem(at: file.url)
            } catch {
                SentryLog.error("Error deleting envelope \(file.url.lastPathComponent): \(error)")
            }
        }
    }
    
    private static func getPendingEnvelopes(from url: URL, fileManager: SentryFileManager) -> [EnvelopeFile] {
        let allFiles = fileManager.allFilesInFolder(url)
        
        return allFiles.compactMap { name in
            guard let endOFTime = name.firstIndex(of: "-"),
                  let time = Double(name.prefix(upTo: endOFTime))
            else { return nil }
            
            return EnvelopeFile(createdAt: Date(timeIntervalSince1970: time), url: url.appendingPathComponent(name))
        }
    }
}

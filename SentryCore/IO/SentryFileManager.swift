import Foundation



class SentryFileManager {
    private var currentFileCounter: UInt = 0
    
    let basePath: URL
    let sentryPath: URL
    
    init(options: Options)
    {
        let cacheURL = URL(fileURLWithPath: options.cacheDirectoryPath)
        SentryLog.debug("CachePath: \(cacheURL)")
        
        self.basePath = cacheURL.appendingPathComponent("io.sentry")
        self.sentryPath = self.basePath.appendingPathComponent(options.parsedDSN?.getHash() ?? "default")
    }
    
    func createDirectoryIfNotExists(path: String) throws -> Bool {
        var isDir = ObjCBool(false)
        if !FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
            return true
        }
        return isDir.boolValue
    }
    
    func writeStreamable(_ source: any BinaryOutputStreamable, at destination: URL, atomic: Bool = true) throws {
        if FileManager.default.fileExists(atPath: destination.path) {
            try FileManager.default.removeItem(at: destination)
        }
        let tempFile = atomic ? getTemporaryFilePath() : destination
        
        var fileHandle = try FileHandle(forWritingTo: tempFile)
        try source.stream(to: &fileHandle)
        try fileHandle.close()
        
        if atomic {
            try FileManager.default.moveItem(at: tempFile, to: destination)
        }
    }
    
    func getTemporaryFilePath() -> URL {
        let tempDirectoryURL = FileManager.default.temporaryDirectory
        let fileName = UUID().uuidString
        return tempDirectoryURL.appendingPathComponent(fileName)
    }
    
    func uniqueAscendingJsonName() -> String {
        // For example 978307200.000000-00001-3FE8C3AE-EB9C-4BEB-868C-14B8D47C33DD.json
        let timestamp = Int(SentryCurrentDateProvider.shared.date().timeIntervalSince1970 * 1000)
        let counter = String(format: "%05lu", currentFileCounter)
        let uuid = UUID().uuidString
        
        currentFileCounter += 1
        
        return "\(timestamp)-\(counter)-\(uuid).json"
    }
    
    func removeItem(at url: URL) throws {
        try FileManager.default.removeItem(at: url)
    }
    
    func removeItem(atPath path: String) throws {
        try FileManager.default.removeItem(atPath: path)
    }
    
    func allFilesInFolder(_ folder: URL) -> [String] {
        var isDir = ObjCBool(false)
        if FileManager.default.fileExists(atPath: folder.path, isDirectory: &isDir) && isDir.boolValue {
            SentryLog.info("Returning empty files list, as folder doesn't exist at path: \(folder)")
            return []
        }
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: folder.path)
            return files.sorted(by: { $0.caseInsensitiveCompare($1) == .orderedAscending })
        } catch {
            SentryLog.error("Couldn't load files in folder \(folder): \(error)")
            return []
        }
    }
}

import Foundation

struct SentryError : Error {
    let file: String
    let line: Int
    let message: String
    
    init(_ message: String, file: String = #file, line: Int = #line) {
        if let lastSlash = file.lastIndex(of: "/"){
            self.file = String(file[file.index(after: lastSlash)...])
        } else {
            self.file = file
        }
        self.line = line
        self.message = message
    }
}

extension SentryError: CustomStringConvertible {
    var description: String {
        return "[\(file):\(line)] \(message)"
    }
}

extension SentryError: LocalizedError {
    var errorDescription: String? {
        return NSLocalizedString("[\(file):\(line)] \(message)", comment: "Sentry Error")
    }
}

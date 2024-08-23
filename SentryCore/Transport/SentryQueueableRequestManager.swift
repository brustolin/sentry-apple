import Foundation

class SentryQueueableRequestManager : SentryRequestManager {
  
    private var requestsInProgress = 0
    private let session: URLSession
    
    /// Initializes a `SentryQueueableRequestManager` with the provided session.
    /// - Parameter session: The `URLSession` to be used for network requests.
    init(session: URLSession) {
        self.session = session
    }
    
    /// Checks if the manager is ready to accept new requests.
    /// - Returns: A Boolean indicating if the queue has one or no operations.
    var ready: Bool {
        return requestsInProgress <= 1
    }
    
    /// Adds a request to the operation queue.
    /// - Parameters:
    ///   - request: The `URLRequest` to be added to the queue.
    ///   - completionHandler: A closure to be called when the request finishes.
    func addRequest(_ request: URLRequest, completionHandler: RequestOperationFinished?) {
        let newSession = session.dataTask(with: request) { data, response, error in
            self.requestsInProgress -= 1
            guard let httpResponse = response as? HTTPURLResponse else {
                completionHandler?(nil, SentryError("Cannot convert response to HTTPURLResponse"))
                return
            }
            SentryLog.debug("Request status: \(httpResponse.statusCode)")
            
            if let data, let content = String(data: data, encoding: .utf8) {
                SentryLog.debug("Request response: \(content)")
            }
            if let error {
                SentryLog.error("Request failed: \(error)")
            }
            
            completionHandler?(httpResponse, error)
        }
        
        self.requestsInProgress += 1
        newSession.resume()
    }
}


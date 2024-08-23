import Foundation

typealias RequestOperationFinished = (HTTPURLResponse?, Error?) -> Void

protocol SentryRequestManager {
    var ready : Bool { get }
    func addRequest(_ request: URLRequest, completionHandler: RequestOperationFinished?)
}

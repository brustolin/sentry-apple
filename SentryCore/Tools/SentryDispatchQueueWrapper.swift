import Foundation

class SentryDispatchQueueWrapper {
    private let queue: DispatchQueue

    init() {
        self.queue = DispatchQueue(label: "sentry-default", qos: .default, attributes: [])
    }

    init(name: String, attributes: DispatchQueue.Attributes? = nil) {
        self.queue = DispatchQueue(label: name, attributes: attributes ?? [])
    }

    func dispatchAsync(block: @escaping () -> Void) {
        queue.async {
            block()
        }
    }

    func dispatchSync(block: () -> Void) {
        queue.sync {
            block()
        }
    }
    
    func dispatchAfter(interval: TimeInterval, block: @escaping () -> Void) {
        let when = DispatchTime.now() + interval
        queue.asyncAfter(deadline: when) {
            block()
        }
    }

}

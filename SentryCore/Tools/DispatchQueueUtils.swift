import Foundation


class DispatchQueueUtils {
    static private(set) var shared = DispatchQueueUtils()
    
    func dispatchAsyncOnMainQueue(block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async {
                autoreleasepool {
                    block()
                }
            }
        }
    }
    
    func dispatchSyncOnMainQueue(block: () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.sync {
                block()
            }
        }
    }

    @discardableResult
    func dispatchSyncOnMainQueue(timeout: TimeInterval, block: @escaping () -> Void) -> Bool {
        if Thread.isMainThread {
            block()
        } else {
            let semaphore = DispatchSemaphore(value: 0)

            DispatchQueue.main.async {
                block()
                semaphore.signal()
            }

            let timeoutTime = DispatchTime.now() + timeout
            return semaphore.wait(timeout: timeoutTime) == .success
        }
        return true
    }

    func dispatchCancel(block: DispatchWorkItem) {
        block.cancel()
    }

    func createDispatchBlock(block: @escaping () -> Void) -> DispatchWorkItem {
        return DispatchWorkItem(block: block)
    }
    
#if TEST || TESTCI
    // The only reason we have a wrapper around system time functions is to enable testing.
    // Using a stateless singleton that can be modified during tests removes the necessity
    // of passing an instance of SentryCurrentDateProvider around or instantiating multiple copies of it.
    static func setShared(_ shared: DispatchQueueUtils?) {
        self.shared = shared ?? DispatchQueueUtils()
    }
#endif
}

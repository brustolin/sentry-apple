import Foundation

func unwrap<T,C,R>(_ object: T?,with: (C) throws -> R?) rethrows -> R? {
    if let object = object as? C {
        return try with(object)
    }
    return nil
}

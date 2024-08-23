import Foundation

enum SessionStatus {
    case ok
    case exited
    case crashed
    case abnormal
}

enum SessionStatusNames : String {
    case ok
    case exited
    case crashed
    case abnormal
}


extension SessionStatus {
    func name() -> SessionStatusNames {
        switch self {
            case .ok: .ok
            case .exited: .exited
            case .crashed: .crashed
            case .abnormal: .abnormal
        }
    }
}

extension SessionStatusNames {
    func toStatus() -> SessionStatus {
        switch self {
        case .ok: .ok
        case .exited: .exited
        case .crashed: .crashed
        case .abnormal: .abnormal
        }
    }
}

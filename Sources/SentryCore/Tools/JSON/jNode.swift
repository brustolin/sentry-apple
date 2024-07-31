import Foundation

protocol jNode {
    func writeAsJson(to target:inout any TextOutputStream)
}

extension String: jNode {
    func writeAsJson(to target:inout any TextOutputStream) {
        target.write("\"\(self)\"")
    }
}

extension Double: jNode {
    func writeAsJson(to target: inout any TextOutputStream) {
        self.write(to: &target)
    }
}

extension Bool: jNode {
    func writeAsJson(to target: inout any TextOutputStream) {
        target.write(self ? "true" : "false" )
    }
}

extension Array: jNode where Element == any jNode {
    func writeAsJson(to target: inout any TextOutputStream) {
        "[".write(to: &target)
        for item in self {
            item.writeAsJson(to: &target)
        }
        "]".write(to: &target)
    }
}

extension Dictionary: jNode where Key == String, Value == any jNode {
    func writeAsJson(to target: inout any TextOutputStream) {
        "{".write(to: &target)
        for pair in self {
            pair.value.writeAsJson(to: &target)
            ":".write(to: &target)
            pair.value.writeAsJson(to: &target)
        }
        "}".write(to: &target)
    }
}

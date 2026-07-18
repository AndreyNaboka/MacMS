import Foundation

struct SystemLoad {
    let cpu: Double
    let memory: Double
}

struct ProcessLoad {
    let pid: Int32
    let name: String
    let cpu: Double
    let memoryBytes: UInt64
}

enum ProcessSortColumn: String {
    case process
    case cpu
    case memory
}

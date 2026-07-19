import Foundation

struct SystemLoad {
    let cpu: Double
    let memory: Double
    let memoryUsedBytes: UInt64
    let memoryTotalBytes: UInt64
    let memoryCachedBytes: UInt64
    let memoryCompressedBytes: UInt64
    let swapUsedBytes: UInt64
    let memoryPressure: MemoryPressureLevel
}

enum MemoryPressureLevel {
    case normal
    case warning
    case critical
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

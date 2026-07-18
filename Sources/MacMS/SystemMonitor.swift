import Darwin
import Foundation

final class SystemMonitor {
    private struct CPUTicks {
        let user: UInt64
        let system: UInt64
        let idle: UInt64
        let nice: UInt64

        var total: UInt64 { user + system + idle + nice }
        var busy: UInt64 { user + system + nice }
    }

    private var previousCPUTicks: CPUTicks?
    private var previousProcessTimes: [Int32: UInt64] = [:]
    private var previousProcessSampleTime = DispatchTime.now().uptimeNanoseconds
    private let processorCount = max(1, ProcessInfo.processInfo.processorCount)

    func sampleSystemLoad() -> SystemLoad {
        SystemLoad(cpu: sampleCPU(), memory: sampleMemory())
    }

    func sampleProcesses() -> [ProcessLoad] {
        let now = DispatchTime.now().uptimeNanoseconds
        let elapsed = max(1, now - previousProcessSampleTime)
        var newTimes: [Int32: UInt64] = [:]
        var result: [ProcessLoad] = []

        for pid in allProcessIDs() {
            var info = proc_taskinfo()
            let infoSize = Int32(MemoryLayout<proc_taskinfo>.stride)
            let read = withUnsafeMutablePointer(to: &info) { pointer in
                proc_pidinfo(pid, PROC_PIDTASKINFO, 0, pointer, infoSize)
            }
            guard read == infoSize else { continue }

            let totalTime = info.pti_total_user &+ info.pti_total_system
            newTimes[pid] = totalTime

            let cpu: Double
            if let previous = previousProcessTimes[pid], totalTime >= previous {
                // libproc reports cumulative CPU time in nanoseconds. A value of
                // 100% means one logical core is fully occupied, like Activity Monitor.
                cpu = min(Double(processorCount * 100), Double(totalTime - previous) / Double(elapsed) * 100)
            } else {
                cpu = 0
            }

            result.append(ProcessLoad(
                pid: pid,
                name: processName(pid: pid),
                cpu: cpu,
                memoryBytes: info.pti_resident_size
            ))
        }

        previousProcessTimes = newTimes
        previousProcessSampleTime = now
        return result
    }

    private func sampleCPU() -> Double {
        var cpuInfo: processor_info_array_t?
        var cpuInfoCount: mach_msg_type_number_t = 0
        var cpuCount: natural_t = 0

        let status = host_processor_info(
            mach_host_self(),
            PROCESSOR_CPU_LOAD_INFO,
            &cpuCount,
            &cpuInfo,
            &cpuInfoCount
        )
        guard status == KERN_SUCCESS, let cpuInfo else { return 0 }
        defer {
            vm_deallocate(
                mach_task_self_,
                vm_address_t(UInt(bitPattern: cpuInfo)),
                vm_size_t(cpuInfoCount) * vm_size_t(MemoryLayout<integer_t>.stride)
            )
        }

        var ticks = CPUTicks(user: 0, system: 0, idle: 0, nice: 0)
        for cpu in 0..<Int(cpuCount) {
            let offset = cpu * Int(CPU_STATE_MAX)
            ticks = CPUTicks(
                user: ticks.user + UInt64(cpuInfo[offset + Int(CPU_STATE_USER)]),
                system: ticks.system + UInt64(cpuInfo[offset + Int(CPU_STATE_SYSTEM)]),
                idle: ticks.idle + UInt64(cpuInfo[offset + Int(CPU_STATE_IDLE)]),
                nice: ticks.nice + UInt64(cpuInfo[offset + Int(CPU_STATE_NICE)])
            )
        }

        defer { previousCPUTicks = ticks }
        guard let previous = previousCPUTicks,
              ticks.total >= previous.total,
              ticks.busy >= previous.busy else { return 0 }
        let totalDelta = ticks.total - previous.total
        guard totalDelta > 0 else { return 0 }
        return min(1, max(0, Double(ticks.busy - previous.busy) / Double(totalDelta)))
    }

    private func sampleMemory() -> Double {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(
            MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size
        )
        let status = withUnsafeMutablePointer(to: &stats) { pointer in
            pointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        guard status == KERN_SUCCESS else { return 0 }

        let pageSize = UInt64(vm_kernel_page_size)
        let usedPages = UInt64(stats.active_count)
            + UInt64(stats.inactive_count)
            + UInt64(stats.wire_count)
            + UInt64(stats.compressor_page_count)
            - min(UInt64(stats.purgeable_count), UInt64(stats.inactive_count))
        let usedBytes = usedPages * pageSize
        let totalBytes = ProcessInfo.processInfo.physicalMemory
        guard totalBytes > 0 else { return 0 }
        return min(1, max(0, Double(usedBytes) / Double(totalBytes)))
    }

    private func allProcessIDs() -> [Int32] {
        let capacity = max(1024, Int(proc_listallpids(nil, 0)) + 128)
        var pids = [pid_t](repeating: 0, count: capacity)
        let processCount = proc_listallpids(&pids, Int32(capacity * MemoryLayout<pid_t>.stride))
        guard processCount > 0 else { return [] }
        let count = min(capacity, Int(processCount))
        return pids.prefix(count).filter { $0 > 0 }
    }

    private func processName(pid: pid_t) -> String {
        var buffer = [CChar](repeating: 0, count: Int(MAXPATHLEN))
        let length = proc_name(pid, &buffer, UInt32(buffer.count))
        if length > 0 {
            return String(cString: buffer)
        }
        return "Процесс \(pid)"
    }
}

import AppKit

final class StatusController: NSObject, NSPopoverDelegate {
    private let monitor = SystemMonitor()
    private let statusItem = NSStatusBar.system.statusItem(withLength: 128)
    private let graphView = StatusGraphView(frame: NSRect(x: 1, y: 0, width: 126, height: 22))
    private let popover = NSPopover()
    private let processController: ProcessListViewController
    private var timer: Timer?

    override init() {
        processController = ProcessListViewController(monitor: monitor)
        super.init()

        if let button = statusItem.button {
            button.image = nil
            button.title = ""
            graphView.autoresizingMask = [.width, .height]
            button.addSubview(graphView)
            button.target = self
            button.action = #selector(togglePopover)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        popover.contentViewController = processController
        popover.contentSize = NSSize(width: 540, height: 500)
        popover.behavior = .transient
        popover.delegate = self

        updateSystemLoad()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateSystemLoad()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func stop() {
        timer?.invalidate()
        processController.stopUpdating()
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            processController.startUpdating()
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    private func updateSystemLoad() {
        let load = monitor.sampleSystemLoad()
        graphView.append(cpu: load.cpu, memory: load.memory)
        processController.updateSummary(load)
    }

    func popoverDidClose(_ notification: Notification) {
        processController.stopUpdating()
    }
}

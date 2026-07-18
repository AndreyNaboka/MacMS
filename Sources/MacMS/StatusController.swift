import AppKit

final class StatusController: NSObject, NSWindowDelegate {
    private let monitor = SystemMonitor()
    private let statusItem = NSStatusBar.system.statusItem(withLength: 128)
    private let graphView = StatusGraphView(frame: NSRect(x: 1, y: 0, width: 126, height: 22))
    private let processController: ProcessListViewController
    private let processWindow: NSWindow
    private var timer: Timer?

    override init() {
        processController = ProcessListViewController(monitor: monitor)
        processWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 620, height: 520),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        super.init()

        if let button = statusItem.button {
            button.image = nil
            button.title = ""
            graphView.autoresizingMask = [.width, .height]
            button.addSubview(graphView)
            button.target = self
            button.action = #selector(toggleWindow)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        processWindow.title = L10n.windowTitle
        processWindow.contentViewController = processController
        processWindow.minSize = NSSize(width: 480, height: 320)
        processWindow.isReleasedWhenClosed = false
        processWindow.delegate = self
        processWindow.collectionBehavior = [.fullScreenPrimary]

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

    @objc private func toggleWindow() {
        guard let button = statusItem.button else { return }
        if processWindow.isVisible {
            processWindow.orderOut(nil)
            processController.stopUpdating()
        } else {
            positionWindow(below: button)
            processController.startUpdating()
            NSApp.activate(ignoringOtherApps: true)
            processWindow.makeKeyAndOrderFront(nil)
        }
    }

    private func positionWindow(below button: NSStatusBarButton) {
        guard let statusWindow = button.window else {
            processWindow.center()
            return
        }

        let buttonRect = statusWindow.convertToScreen(button.convert(button.bounds, to: nil))
        let screenFrame = (statusWindow.screen ?? NSScreen.main)?.visibleFrame ?? .zero
        let windowSize = processWindow.frame.size
        let preferredX = buttonRect.midX - windowSize.width / 2
        let x = min(max(screenFrame.minX, preferredX), screenFrame.maxX - windowSize.width)
        let y = max(screenFrame.minY, buttonRect.minY - windowSize.height - 6)
        processWindow.setFrameOrigin(NSPoint(x: x, y: y))
    }

    private func updateSystemLoad() {
        let load = monitor.sampleSystemLoad()
        graphView.append(
            cpu: load.cpu,
            memory: load.memory,
            memoryUsedBytes: load.memoryUsedBytes,
            memoryTotalBytes: load.memoryTotalBytes
        )
        processController.updateSummary(load)
    }

    func windowWillClose(_ notification: Notification) {
        processController.stopUpdating()
    }
}

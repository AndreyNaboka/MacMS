import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusController: StatusController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusController = StatusController()
        DispatchQueue.main.async {
            LaunchAtLoginPrompt.showIfNeeded()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        statusController?.stop()
    }
}

import AppKit
import ServiceManagement

enum LaunchAtLoginPrompt {
    private static let hasAskedKey = "hasAskedToLaunchAtLogin"

    static func showIfNeeded() {
        // `swift run` creates a plain executable rather than an application
        // bundle. Only packaged .app builds can be registered as a login item.
        guard Bundle.main.bundleURL.pathExtension == "app" else { return }

        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: hasAskedKey) else { return }

        let service = SMAppService.mainApp
        if service.status == .enabled {
            defaults.set(true, forKey: hasAskedKey)
            return
        }

        // Persist before displaying the alert so a crash or registration error
        // can never cause the first-launch question to repeat.
        defaults.set(true, forKey: hasAskedKey)

        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = L10n.launchAtLoginTitle
        alert.informativeText = L10n.launchAtLoginMessage
        alert.addButton(withTitle: L10n.enable)
        alert.addButton(withTitle: L10n.notNow)

        NSApp.activate(ignoringOtherApps: true)
        guard alert.runModal() == .alertFirstButtonReturn else { return }

        do {
            if service.status == .notRegistered || service.status == .notFound {
                try service.register()
            }

            if service.status == .requiresApproval {
                showApprovalRequired()
            }
        } catch {
            showRegistrationError(error)
        }
    }

    private static func showApprovalRequired() {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = L10n.loginApprovalTitle
        alert.informativeText = L10n.loginApprovalMessage
        alert.addButton(withTitle: L10n.openSettings)
        alert.addButton(withTitle: L10n.notNow)
        if alert.runModal() == .alertFirstButtonReturn {
            SMAppService.openSystemSettingsLoginItems()
        }
    }

    private static func showRegistrationError(_ error: Error) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = L10n.loginErrorTitle
        alert.informativeText = "\(L10n.loginErrorMessage)\n\n\(error.localizedDescription)"
        alert.addButton(withTitle: L10n.ok)
        alert.runModal()
    }
}

import Foundation

enum L10n {
    static let isRussian: Bool = {
        let language = Locale.preferredLanguages.first?.lowercased() ?? "en"
        return language == "ru" || language.hasPrefix("ru-") || language.hasPrefix("ru_")
    }()

    static var locale: Locale { Locale(identifier: isRussian ? "ru_RU" : "en_US") }

    static var windowTitle: String { text(russian: "MacMS — процессы", english: "MacMS — Processes") }
    static var monitorTitle: String { text(russian: "Мониторинг системы", english: "System Monitor") }
    static var quit: String { text(russian: "Завершить MacMS", english: "Quit MacMS") }
    static var process: String { text(russian: "Процесс", english: "Process") }
    static var memoryUsed: String { text(russian: "занято", english: "used") }
    static var memorySeparator: String { text(russian: "из", english: "of") }
    static var launchAtLoginTitle: String {
        text(russian: "Запускать MacMS при входе?", english: "Open MacMS at login?")
    }
    static var launchAtLoginMessage: String {
        text(
            russian: "MacMS будет автоматически запускаться после входа в macOS и показывать графики CPU и RAM в строке меню.",
            english: "MacMS will open automatically after you log in to macOS and show CPU and RAM graphs in the menu bar."
        )
    }
    static var enable: String { text(russian: "Добавить", english: "Add") }
    static var notNow: String { text(russian: "Не сейчас", english: "Not Now") }
    static var loginApprovalTitle: String {
        text(russian: "Требуется разрешение macOS", english: "macOS Approval Required")
    }
    static var loginApprovalMessage: String {
        text(
            russian: "MacMS зарегистрирован для автозапуска, но его необходимо разрешить в разделе «Объекты входа» системных настроек.",
            english: "MacMS is registered to open at login, but it must be allowed in Login Items in System Settings."
        )
    }
    static var loginErrorTitle: String {
        text(russian: "Не удалось добавить в автозагрузку", english: "Couldn’t Enable Open at Login")
    }
    static var loginErrorMessage: String {
        text(
            russian: "Добавьте MacMS вручную в разделе «Основные» → «Объекты входа и расширения» системных настроек.",
            english: "Add MacMS manually in System Settings under General → Login Items & Extensions."
        )
    }
    static var openSettings: String { text(russian: "Открыть настройки", english: "Open Settings") }
    static var ok: String { text(russian: "OK", english: "OK") }

    static func processFallback(pid: Int32) -> String {
        "\(process) \(pid)"
    }

    static func text(russian: String, english: String) -> String {
        isRussian ? russian : english
    }

    static func number(_ value: Double, decimals: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = decimals
        formatter.maximumFractionDigits = decimals
        formatter.usesGroupingSeparator = false
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.*f", decimals, value)
    }

    static func bytes(_ bytes: UInt64) -> String {
        let units: [(size: Double, russian: String, english: String)] = [
            (1_099_511_627_776, "ТБ", "TB"),
            (1_073_741_824, "ГБ", "GB"),
            (1_048_576, "МБ", "MB"),
            (1_024, "КБ", "KB")
        ]

        for unit in units where Double(bytes) >= unit.size {
            let suffix = isRussian ? unit.russian : unit.english
            return "\(number(Double(bytes) / unit.size, decimals: 1)) \(suffix)"
        }
        return "\(bytes) \(isRussian ? "Б" : "B")"
    }
}

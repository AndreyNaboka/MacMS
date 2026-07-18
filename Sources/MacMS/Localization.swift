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

import AppKit

final class ProcessListViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    private let monitor: SystemMonitor
    private let tableView = NSTableView()
    private let summaryLabel = NSTextField(labelWithString: "")
    private var rows: [ProcessLoad] = []
    private var updateTimer: Timer?
    private var latestLoad = SystemLoad(cpu: 0, memory: 0)

    init(monitor: SystemMonitor) {
        self.monitor = monitor
        super.init(nibName: nil, bundle: nil)
        preferredContentSize = NSSize(width: 540, height: 500)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 540, height: 500))

        let title = NSTextField(labelWithString: "Мониторинг системы")
        title.font = .systemFont(ofSize: 16, weight: .semibold)
        title.translatesAutoresizingMaskIntoConstraints = false
        summaryLabel.font = .monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        summaryLabel.textColor = .secondaryLabelColor
        summaryLabel.translatesAutoresizingMaskIntoConstraints = false

        let quitButton = NSButton(title: "Завершить MacMS", target: NSApplication.shared, action: #selector(NSApplication.terminate(_:)))
        quitButton.bezelStyle = .inline
        quitButton.controlSize = .small
        quitButton.translatesAutoresizingMaskIntoConstraints = false

        let processColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(ProcessSortColumn.process.rawValue))
        processColumn.title = "Процесс"
        processColumn.width = 290
        processColumn.minWidth = 160
        processColumn.sortDescriptorPrototype = NSSortDescriptor(key: ProcessSortColumn.process.rawValue, ascending: true)

        let cpuColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(ProcessSortColumn.cpu.rawValue))
        cpuColumn.title = "CPU"
        cpuColumn.width = 95
        cpuColumn.minWidth = 70
        cpuColumn.sortDescriptorPrototype = NSSortDescriptor(key: ProcessSortColumn.cpu.rawValue, ascending: false)

        let memoryColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(ProcessSortColumn.memory.rawValue))
        memoryColumn.title = "RAM"
        memoryColumn.width = 115
        memoryColumn.minWidth = 85
        memoryColumn.sortDescriptorPrototype = NSSortDescriptor(key: ProcessSortColumn.memory.rawValue, ascending: false)

        tableView.addTableColumn(processColumn)
        tableView.addTableColumn(cpuColumn)
        tableView.addTableColumn(memoryColumn)
        tableView.headerView = NSTableHeaderView()
        tableView.usesAlternatingRowBackgroundColors = true
        tableView.rowHeight = 24
        tableView.columnAutoresizingStyle = .lastColumnOnlyAutoresizingStyle
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsEmptySelection = true
        tableView.target = self

        let scrollView = NSScrollView()
        scrollView.documentView = tableView
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(title)
        view.addSubview(summaryLabel)
        view.addSubview(quitButton)
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            title.topAnchor.constraint(equalTo: view.topAnchor, constant: 14),
            summaryLabel.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            summaryLabel.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 3),
            quitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            quitButton.centerYAnchor.constraint(equalTo: title.centerYAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 10),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func startUpdating() {
        guard updateTimer == nil else { return }
        refreshProcesses()
        updateTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            self?.refreshProcesses()
        }
        RunLoop.main.add(updateTimer!, forMode: .common)
    }

    func stopUpdating() {
        updateTimer?.invalidate()
        updateTimer = nil
    }

    func updateSummary(_ load: SystemLoad) {
        latestLoad = load
        guard isViewLoaded else { return }
        summaryLabel.stringValue = String(format: "CPU: %.1f%%    RAM: %.1f%%", load.cpu * 100, load.memory * 100)
    }

    private func refreshProcesses() {
        rows = monitor.sampleProcesses()
        sortRows()
        tableView.reloadData()
        updateSummary(latestLoad)
    }

    private func sortRows() {
        let descriptor = tableView.sortDescriptors.first
            ?? NSSortDescriptor(key: ProcessSortColumn.cpu.rawValue, ascending: false)
        let ascending = descriptor.ascending
        switch ProcessSortColumn(rawValue: descriptor.key ?? "cpu") ?? .cpu {
        case .process:
            rows.sort { ascending ? $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                                  : $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending }
        case .cpu:
            rows.sort { ascending ? $0.cpu < $1.cpu : $0.cpu > $1.cpu }
        case .memory:
            rows.sort { ascending ? $0.memoryBytes < $1.memoryBytes : $0.memoryBytes > $1.memoryBytes }
        }
    }

    func numberOfRows(in tableView: NSTableView) -> Int { rows.count }

    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        sortRows()
        tableView.reloadData()
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let tableColumn, rows.indices.contains(row) else { return nil }
        let identifier = tableColumn.identifier
        let cell = (tableView.makeView(withIdentifier: identifier, owner: self) as? NSTableCellView) ?? makeCell(identifier: identifier)
        let process = rows[row]

        switch ProcessSortColumn(rawValue: identifier.rawValue) {
        case .process:
            cell.textField?.stringValue = "\(process.name)  (\(process.pid))"
            cell.textField?.alignment = .left
        case .cpu:
            cell.textField?.stringValue = String(format: "%.1f%%", process.cpu)
            cell.textField?.alignment = .right
        case .memory:
            cell.textField?.stringValue = ByteCountFormatter.string(fromByteCount: Int64(process.memoryBytes), countStyle: .memory)
            cell.textField?.alignment = .right
        case nil:
            break
        }
        return cell
    }

    private func makeCell(identifier: NSUserInterfaceItemIdentifier) -> NSTableCellView {
        let cell = NSTableCellView()
        cell.identifier = identifier
        let textField = NSTextField(labelWithString: "")
        textField.lineBreakMode = .byTruncatingTail
        textField.translatesAutoresizingMaskIntoConstraints = false
        cell.textField = textField
        cell.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 7),
            textField.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -7),
            textField.centerYAnchor.constraint(equalTo: cell.centerYAnchor)
        ])
        return cell
    }
}

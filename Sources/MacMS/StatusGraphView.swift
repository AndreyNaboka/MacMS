import AppKit

final class StatusGraphView: NSView {
    private let maximumSamples = 34
    private var cpuSamples: [Double] = []
    private var memorySamples: [Double] = []
    private var cpuValue = 0.0
    private var memoryValue = 0.0

    override var intrinsicContentSize: NSSize { NSSize(width: 126, height: 22) }
    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    func append(cpu: Double, memory: Double, memoryUsedBytes: UInt64, memoryTotalBytes: UInt64) {
        cpuValue = cpu
        memoryValue = memory
        cpuSamples.append(cpu)
        memorySamples.append(memory)
        if cpuSamples.count > maximumSamples { cpuSamples.removeFirst() }
        if memorySamples.count > maximumSamples { memorySamples.removeFirst() }
        let used = ByteCountFormatter.string(fromByteCount: Int64(memoryUsedBytes), countStyle: .memory)
        let total = ByteCountFormatter.string(fromByteCount: Int64(memoryTotalBytes), countStyle: .memory)
        toolTip = String(format: "CPU %.0f%%  •  RAM занято: %@ из %@ (%.0f%%)", cpu * 100, used, total, memory * 100)
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        drawPanel(
            in: NSRect(x: 1, y: 1, width: 61, height: bounds.height - 2),
            title: "CPU",
            value: cpuValue,
            samples: cpuSamples,
            color: .systemGreen
        )
        drawPanel(
            in: NSRect(x: 64, y: 1, width: 61, height: bounds.height - 2),
            title: "RAM",
            value: memoryValue,
            samples: memorySamples,
            color: .systemBlue
        )
    }

    private func drawPanel(in rect: NSRect, title: String, value: Double, samples: [Double], color: NSColor) {
        let graphRect = NSRect(x: rect.minX, y: rect.minY, width: 29, height: rect.height)
        let line = NSBezierPath()
        guard !samples.isEmpty else { return }
        for (index, sample) in samples.enumerated() {
            let x = graphRect.maxX - CGFloat(samples.count - 1 - index) * graphRect.width / CGFloat(maximumSamples - 1)
            let y = graphRect.minY + 1 + CGFloat(sample) * (graphRect.height - 3)
            index == 0 ? line.move(to: NSPoint(x: x, y: y)) : line.line(to: NSPoint(x: x, y: y))
        }
        color.setStroke()
        line.lineWidth = 1.35
        line.stroke()

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .right
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedDigitSystemFont(ofSize: 8, weight: .medium),
            .foregroundColor: NSColor.labelColor,
            .paragraphStyle: paragraph
        ]
        let label = String(format: "%@\n%2.0f%%", title, value * 100)
        label.draw(in: NSRect(x: graphRect.maxX + 1, y: rect.minY + 1, width: 31, height: 19), withAttributes: attributes)
    }
}

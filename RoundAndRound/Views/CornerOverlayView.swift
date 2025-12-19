import AppKit

class CornerOverlayView: NSView {
    var corner: Corner
    var radius: Double
    var color: NSColor

    init(corner: Corner, radius: Double, color: NSColor) {
        self.corner = corner
        self.radius = radius
        self.color = color
        super.init(frame: .zero)
        self.wantsLayer = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }

        context.clear(bounds)

        let path = createCornerWedgePath()
        context.addPath(path)
        context.setFillColor(color.cgColor)
        context.fillPath()
    }

    private func createCornerWedgePath() -> CGPath {
        let path = CGMutablePath()
        let r = CGFloat(radius)

        switch corner {
        case .topLeft:
            // Start at top-left corner of the view (the actual screen corner)
            path.move(to: CGPoint(x: 0, y: r))
            // Draw arc from left edge to top edge
            path.addArc(
                center: CGPoint(x: r, y: 0),
                radius: r,
                startAngle: .pi,
                endAngle: .pi / 2,
                clockwise: true
            )
            // Line to top-left corner
            path.addLine(to: CGPoint(x: 0, y: r))
            path.closeSubpath()

        case .topRight:
            // Start at top-right corner
            path.move(to: CGPoint(x: r, y: r))
            // Draw arc from top edge to right edge
            path.addArc(
                center: CGPoint(x: 0, y: 0),
                radius: r,
                startAngle: .pi / 2,
                endAngle: 0,
                clockwise: true
            )
            // Line to top-right corner
            path.addLine(to: CGPoint(x: r, y: r))
            path.closeSubpath()

        case .bottomLeft:
            // Start at bottom-left corner
            path.move(to: CGPoint(x: 0, y: 0))
            // Draw arc from bottom edge to left edge
            path.addArc(
                center: CGPoint(x: r, y: r),
                radius: r,
                startAngle: .pi * 1.5,
                endAngle: .pi,
                clockwise: true
            )
            // Line to bottom-left corner
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.closeSubpath()

        case .bottomRight:
            // Start at bottom-right corner
            path.move(to: CGPoint(x: r, y: 0))
            // Draw arc from right edge to bottom edge
            path.addArc(
                center: CGPoint(x: 0, y: r),
                radius: r,
                startAngle: 0,
                endAngle: -.pi / 2,
                clockwise: true
            )
            // Line to bottom-right corner
            path.addLine(to: CGPoint(x: r, y: 0))
            path.closeSubpath()
        }

        return path
    }
}

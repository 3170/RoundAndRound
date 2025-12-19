import AppKit

@MainActor
class OverlayWindowController: NSWindowController {
    private let screen: NSScreen
    private let corner: Corner
    private let settings: AppSettings
    private var overlayView: CornerOverlayView?

    init(screen: NSScreen, corner: Corner, settings: AppSettings) {
        self.screen = screen
        self.corner = corner
        self.settings = settings

        let radius = settings.cornerRadius
        let windowFrame = Self.calculateFrame(for: corner, screen: screen, radius: radius)

        let window = NSWindow(
            contentRect: windowFrame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )

        window.level = .screenSaver
        window.ignoresMouseEvents = true
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        window.isReleasedWhenClosed = false

        super.init(window: window)

        let view = CornerOverlayView(corner: corner, radius: radius, color: settings.overlayNSColor)
        view.frame = NSRect(origin: .zero, size: windowFrame.size)
        window.contentView = view
        self.overlayView = view
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateOverlay() {
        guard let window = self.window else { return }

        let radius = settings.cornerRadius
        let newFrame = Self.calculateFrame(for: corner, screen: screen, radius: radius)

        window.setFrame(newFrame, display: false)

        overlayView?.radius = radius
        overlayView?.color = settings.overlayNSColor
        overlayView?.frame = NSRect(origin: .zero, size: newFrame.size)
        overlayView?.needsDisplay = true
    }

    private static func calculateFrame(for corner: Corner, screen: NSScreen, radius: Double) -> NSRect {
        let screenFrame = screen.frame
        let size = NSSize(width: radius, height: radius)

        let origin: NSPoint
        switch corner {
        case .topLeft:
            origin = NSPoint(
                x: screenFrame.minX,
                y: screenFrame.maxY - radius
            )
        case .topRight:
            origin = NSPoint(
                x: screenFrame.maxX - radius,
                y: screenFrame.maxY - radius
            )
        case .bottomLeft:
            origin = NSPoint(
                x: screenFrame.minX,
                y: screenFrame.minY
            )
        case .bottomRight:
            origin = NSPoint(
                x: screenFrame.maxX - radius,
                y: screenFrame.minY
            )
        }

        return NSRect(origin: origin, size: size)
    }
}

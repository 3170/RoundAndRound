import SwiftUI
import AppKit

@main
struct RoundAndRoundApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    let settings = AppSettings()
    var screenManager: ScreenManager?
    var statusItem: NSStatusItem?
    var popover: NSPopover?

    func applicationDidFinishLaunching(_ notification: Notification) {
        screenManager = ScreenManager(settings: settings)
        screenManager?.setupOverlays()

        setupMenuBar()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenParametersDidChange),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }

    func applicationWillTerminate(_ notification: Notification) {
        screenManager?.removeAllOverlays()
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "circle.circle", accessibilityDescription: "RoundAndRound")
            button.action = #selector(togglePopover)
            button.target = self
        }

        popover = NSPopover()
        popover?.behavior = .transient
        popover?.animates = true
        popover?.contentViewController = NSHostingController(
            rootView: MenuBarSettingsView(settings: settings)
                .padding(12)
        )
    }

    @objc func togglePopover() {
        guard let button = statusItem?.button, let popover = popover else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    @objc func screenParametersDidChange(_ notification: Notification) {
        screenManager?.rebuildOverlays()
    }
}

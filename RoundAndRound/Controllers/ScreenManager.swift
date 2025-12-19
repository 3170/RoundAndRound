import AppKit
import Combine

enum Corner: CaseIterable {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}

@MainActor
class ScreenManager {
    private let settings: AppSettings
    private var overlayControllers: [OverlayWindowController] = []
    private var cancellables = Set<AnyCancellable>()

    init(settings: AppSettings) {
        self.settings = settings

        settings.settingsChanged
            .debounce(for: .milliseconds(50), scheduler: RunLoop.main)
            .sink { [weak self] in
                self?.updateAllOverlays()
            }
            .store(in: &cancellables)
    }

    func setupOverlays() {
        removeAllOverlays()

        guard settings.overlayEnabled else { return }

        for screen in NSScreen.screens {
            for corner in Corner.allCases {
                let controller = OverlayWindowController(
                    screen: screen,
                    corner: corner,
                    settings: settings
                )
                overlayControllers.append(controller)
                controller.showWindow(nil)
            }
        }
    }

    func rebuildOverlays() {
        setupOverlays()
    }

    func removeAllOverlays() {
        for controller in overlayControllers {
            controller.close()
        }
        overlayControllers.removeAll()
    }

    func updateAllOverlays() {
        if settings.overlayEnabled {
            if overlayControllers.isEmpty {
                setupOverlays()
            } else {
                for controller in overlayControllers {
                    controller.updateOverlay()
                }
            }
        } else {
            removeAllOverlays()
        }
    }
}

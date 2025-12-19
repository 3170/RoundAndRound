import Foundation
import SwiftUI
import Combine

@MainActor
class AppSettings: ObservableObject {
    @AppStorage("cornerRadius") var cornerRadius: Double = 24 {
        didSet {
            settingsChanged.send()
        }
    }

    @AppStorage("overlayEnabled") var overlayEnabled: Bool = true {
        didSet {
            settingsChanged.send()
        }
    }

    @AppStorage("launchAtLogin") var launchAtLogin: Bool = false {
        didSet {
            LaunchAtLogin.setEnabled(launchAtLogin)
        }
    }

    let settingsChanged = PassthroughSubject<Void, Never>()

    var overlayNSColor: NSColor {
        .black
    }

    static let minRadius: Double = 4
    static let maxRadius: Double = 32
}

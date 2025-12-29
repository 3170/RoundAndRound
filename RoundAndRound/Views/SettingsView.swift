import SwiftUI

struct MenuBarSettingsView: View {
    @ObservedObject var settings: AppSettings
    @State private var launchAtLogin: Bool = LaunchAtLogin.isEnabled

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection

            Divider()

            mainControlsSection

            Divider()

            footerSection
        }
        .frame(width: 280)
    }

    private var headerSection: some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: "circle.circle")
                .font(.system(size: 24))
                .foregroundColor(.secondary.opacity(0.5))

            VStack(alignment: .leading, spacing: 2) {
                Text("RoundAndRound")
                    .font(.headline)

                Text("Screen corner rounding")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.bottom, 8)
    }

    private var mainControlsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Enable toggle
            HStack {
                Image(systemName: settings.overlayEnabled ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(settings.overlayEnabled ? .primary : .secondary)
                Text("Round Corners")
                Spacer()
                Toggle("", isOn: $settings.overlayEnabled)
                    .toggleStyle(.switch)
                    .labelsHidden()
                    .focusable(false)
            }

            if settings.overlayEnabled {
                Divider()
                    .padding(.vertical, 4)

                // Corner Radius
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Radius")
                            .font(.subheadline)
                        Spacer()
                        Text("\(Int(settings.cornerRadius)) px")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .monospacedDigit()
                    }
                    Slider(
                        value: $settings.cornerRadius,
                        in: AppSettings.minRadius...AppSettings.maxRadius,
                        step: 1
                    )
                    .controlSize(.regular)
                }
            }
        }
        .padding(.vertical, 10)
    }

    private var footerSection: some View {
        HStack {
            Button(action: { NSApp.terminate(nil) }) {
                HStack(spacing: 4) {
                    Image(systemName: "power")
                    Text("Quit")
                }
            }
            .buttonStyle(.plain)
            .focusable(false)

            Spacer()

            Button(action: {
                if launchAtLogin {
                    LaunchAtLogin.setEnabled(false)
                    launchAtLogin = false
                } else {
                    LaunchAtLogin.setEnabled(true)
                    launchAtLogin = true
                }
            }) {
                HStack(spacing: 4) {
                    Text("Launch at Login")
                        .font(.caption)
                    Image(systemName: launchAtLogin ? "checkmark.square" : "square")
                        .font(.system(size: 14))
                }
                .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .focusable(false)
        }
        .padding(.top, 10)
    }
}

#Preview {
    MenuBarSettingsView(settings: AppSettings())
}

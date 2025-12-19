import SwiftUI

struct MenuBarSettingsView: View {
    @ObservedObject var settings: AppSettings

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            Divider()

            VStack(spacing: 16) {
                enableToggleSection
                radiusSection
                launchSection
            }
            .padding(16)

            Divider()

            footerSection
        }
        .frame(width: 320)
    }

    private var headerSection: some View {
        HStack(spacing: 12) {
            Image(systemName: "rainbow")
                .font(.system(size: 24))
                .foregroundStyle(.primary)

            VStack(alignment: .leading, spacing: 2) {
                Text("RoundAndRound")
                    .font(.headline)

                Text("Screen corner rounding")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(16)
    }

    private var enableToggleSection: some View {
        HStack {
            Label("Enabled", systemImage: "checkmark.circle.fill")

            Spacer()

            Toggle("", isOn: $settings.overlayEnabled)
                .toggleStyle(.switch)
                .labelsHidden()
        }
    }

    private var radiusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Corner Radius", systemImage: "circle.dashed")

                Spacer()

                Text("\(Int(settings.cornerRadius)) px")
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(.secondary)
            }

            Slider(
                value: $settings.cornerRadius,
                in: AppSettings.minRadius...AppSettings.maxRadius,
                step: 1
            )
            .disabled(!settings.overlayEnabled)
        }
    }

    private var launchSection: some View {
        HStack {
            Label("Launch at Login", systemImage: "power.circle.fill")

            Spacer()

            Toggle("", isOn: $settings.launchAtLogin)
                .toggleStyle(.switch)
                .labelsHidden()
        }
    }

    private var footerSection: some View {
        HStack {
            Text("\(NSScreen.screens.count) display\(NSScreen.screens.count == 1 ? "" : "s")")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            Button("Quit") {
                NSApp.terminate(nil)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
        }
        .padding(16)
    }
}

#Preview {
    MenuBarSettingsView(settings: AppSettings())
}

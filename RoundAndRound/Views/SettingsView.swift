import SwiftUI

struct MenuBarSettingsView: View {
    @ObservedObject var settings: AppSettings
    @ObservedObject var licenseManager = LicenseManager.shared
    @State private var launchAtLogin: Bool = LaunchAtLogin.isEnabled
    @State private var showingLicenseSheet = false
    @State private var showLicensedBadge = true

    private var shouldShowLicenseSection: Bool {
        switch licenseManager.status {
        case .trial, .expired:
            return true
        case .licensed:
            return showLicensedBadge
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection

            Divider()

            mainControlsSection

            if shouldShowLicenseSection {
                Divider()

                licenseStatusSection
            }

            Divider()

            footerSection
        }
        .frame(width: 280)
        .sheet(isPresented: $showingLicenseSheet) {
            LicenseInputSheet(isPresented: $showingLicenseSheet)
        }
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

    @ViewBuilder
    private var licenseStatusSection: some View {
        switch licenseManager.status {
        case .trial(let daysRemaining):
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.orange)
                Text("Trial: \(daysRemaining) day\(daysRemaining == 1 ? "" : "s") remaining")
                    .font(.subheadline)
                Spacer()
                Button("Activate") {
                    showingLicenseSheet = true
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .focusable(false)
            }
            .padding(.vertical, 10)

        case .licensed(let email):
            if showLicensedBadge {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Licensed")
                            .font(.subheadline)
                        Text(email)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    Spacer()
                }
                .padding(.vertical, 10)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        withAnimation(.easeOut(duration: 0.3)) {
                            showLicensedBadge = false
                        }
                    }
                }
            }

        case .expired:
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Trial Expired")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                }
                HStack {
                    Button("Enter License") {
                        showingLicenseSheet = true
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .focusable(false)

                    Button("Purchase") {
                        NSWorkspace.shared.open(LicenseManager.purchaseURL)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .focusable(false)
                }
            }
            .padding(.vertical, 10)
        }
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

// MARK: - License Input Sheet

struct LicenseInputSheet: View {
    @Binding var isPresented: Bool
    @ObservedObject var licenseManager = LicenseManager.shared
    @State private var licenseKey: String = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "key.fill")
                    .font(.title2)
                    .foregroundColor(.accentColor)
                Text("Activate License")
                    .font(.headline)
                Spacer()
            }

            // License key input
            VStack(alignment: .leading, spacing: 4) {
                Text("License Key")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                TextField("XXXXXXXX-XXXXXXXX-XXXXXXXX-XXXXXXXX", text: $licenseKey)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))
                    .focused($isTextFieldFocused)
                    .disabled(licenseManager.isValidating)
            }

            // Error message
            if let error = licenseManager.validationError {
                HStack {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                    Spacer()
                }
            }

            Divider()

            // Buttons
            HStack {
                Button("Purchase License") {
                    NSWorkspace.shared.open(LicenseManager.purchaseURL)
                }
                .buttonStyle(.link)
                .focusable(false)

                Spacer()

                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.escape)
                .focusable(false)

                Button("Activate") {
                    Task {
                        let success = await licenseManager.validateLicenseKey(licenseKey.trimmingCharacters(in: .whitespacesAndNewlines))
                        if success {
                            isPresented = false
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(licenseKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || licenseManager.isValidating)
                .keyboardShortcut(.return)
            }
        }
        .padding(20)
        .frame(width: 380)
        .onAppear {
            isTextFieldFocused = true
        }
    }
}

#Preview {
    MenuBarSettingsView(settings: AppSettings())
}

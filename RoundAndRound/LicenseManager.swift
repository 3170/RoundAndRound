import Foundation
import Security

// MARK: - License Status

enum LicenseStatus: Equatable {
    case trial(daysRemaining: Int)
    case licensed(email: String)
    case expired

    var isValid: Bool {
        switch self {
        case .trial, .licensed:
            return true
        case .expired:
            return false
        }
    }
}

// MARK: - Gumroad API Response

struct GumroadLicenseResponse: Codable {
    let success: Bool
    let uses: Int?
    let purchase: GumroadPurchase?
    let message: String?
}

struct GumroadPurchase: Codable {
    let email: String?
    let sellerID: String?
    let productID: String?
    let productName: String?
    let refunded: Bool?
    let disputed: Bool?
    let chargebacked: Bool?

    enum CodingKeys: String, CodingKey {
        case email
        case sellerID = "seller_id"
        case productID = "product_id"
        case productName = "product_name"
        case refunded
        case disputed
        case chargebacked
    }
}

// MARK: - License Manager

@MainActor
class LicenseManager: ObservableObject {
    static let shared = LicenseManager()

    // MARK: - Configuration
    private static let productId = "mH1FOV-lWaCCIoHAdZGotQ=="
    static let purchaseURL = URL(string: "https://eilert-janssen.gumroad.com/l/roundandround")!

    private let trialDurationDays = 14

    // Keychain keys
    private let keychainService = "com.roundandround.license"
    private let trialStartDateKey = "trialStartDate"
    private let licenseKeyKey = "licenseKey"
    private let licensedEmailKey = "licensedEmail"

    // MARK: - Published State
    @Published var status: LicenseStatus = .expired
    @Published var isValidating: Bool = false
    @Published var validationError: String?

    // MARK: - Initialization

    private init() {
        checkLicenseStatus()
    }

    // MARK: - Public Methods

    /// Check and update the current license status
    func checkLicenseStatus() {
        // First check for existing license
        if let email = loadFromKeychain(key: licensedEmailKey),
           let _ = loadFromKeychain(key: licenseKeyKey) {
            status = .licensed(email: email)
            return
        }

        // Check trial status
        if let trialStartString = loadFromKeychain(key: trialStartDateKey),
           let trialStartDate = ISO8601DateFormatter().date(from: trialStartString) {
            let daysRemaining = calculateDaysRemaining(from: trialStartDate)
            if daysRemaining > 0 {
                status = .trial(daysRemaining: daysRemaining)
            } else {
                status = .expired
            }
        } else {
            // First launch - start trial
            startTrial()
        }
    }

    /// Start a new trial period
    func startTrial() {
        let now = Date()
        let dateString = ISO8601DateFormatter().string(from: now)
        _ = saveToKeychain(key: trialStartDateKey, value: dateString)
        status = .trial(daysRemaining: trialDurationDays)
    }

    /// Validate a license key with Gumroad API
    func validateLicenseKey(_ licenseKey: String) async -> Bool {
        isValidating = true
        validationError = nil

        defer { isValidating = false }

        do {
            let result = try await verifyWithGumroad(licenseKey: licenseKey, productId: Self.productId)

            if result.success, let purchase = result.purchase {
                // Check for refund/dispute/chargeback
                if purchase.refunded == true || purchase.disputed == true || purchase.chargebacked == true {
                    validationError = "This license has been refunded or disputed."
                    return false
                }

                // Save license info
                let email = purchase.email ?? "Licensed User"
                _ = saveToKeychain(key: licenseKeyKey, value: licenseKey)
                _ = saveToKeychain(key: licensedEmailKey, value: email)

                status = .licensed(email: email)
                return true
            } else {
                validationError = result.message ?? "Invalid license key."
                return false
            }
        } catch {
            validationError = "Network error. Please check your connection."
            return false
        }
    }

    /// Remove stored license (for testing or deactivation)
    func removeLicense() {
        _ = deleteFromKeychain(key: licenseKeyKey)
        _ = deleteFromKeychain(key: licensedEmailKey)
        checkLicenseStatus()
    }

    /// Reset trial (for testing only)
    func resetTrial() {
        _ = deleteFromKeychain(key: trialStartDateKey)
        _ = deleteFromKeychain(key: licenseKeyKey)
        _ = deleteFromKeychain(key: licensedEmailKey)
        startTrial()
    }

    // MARK: - Private Methods

    private func calculateDaysRemaining(from startDate: Date) -> Int {
        let calendar = Calendar.current
        let now = Date()
        let endDate = calendar.date(byAdding: .day, value: trialDurationDays, to: startDate)!
        let components = calendar.dateComponents([.day], from: now, to: endDate)
        return max(0, components.day ?? 0)
    }

    nonisolated private func verifyWithGumroad(licenseKey: String, productId: String) async throws -> GumroadLicenseResponse {
        guard let url = URL(string: "https://api.gumroad.com/v2/licenses/verify") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let bodyString = "product_id=\(productId)&license_key=\(licenseKey)&increment_uses_count=false"
        request.httpBody = bodyString.data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        // Gumroad returns 404 for invalid keys with JSON body
        if httpResponse.statusCode == 404 {
            return GumroadLicenseResponse(success: false, uses: nil, purchase: nil, message: "Invalid license key.")
        }

        let decoder = JSONDecoder()
        return try decoder.decode(GumroadLicenseResponse.self, from: data)
    }

    // MARK: - Keychain Helpers

    private func saveToKeychain(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        // Delete existing item first
        _ = deleteFromKeychain(key: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    private func loadFromKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }

        return value
    }

    private func deleteFromKeychain(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}

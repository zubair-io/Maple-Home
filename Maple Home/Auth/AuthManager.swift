import Foundation

// MARK: - AuthManager

@Observable
final class AuthManager {
    static let shared = AuthManager()

    private(set) var serverURL: URL?
    private(set) var token: String?
    private(set) var refreshTokenValue: String?

    /// The callback path HA redirects to after login
    static let callbackPath = "/auth/external/callback"

    private init() {
        // Load saved credentials
        if let urlString = KeychainStore.load(key: KeychainStore.Keys.serverURL),
           let url = URL(string: urlString) {
            self.serverURL = url
        }
        self.token = KeychainStore.load(key: KeychainStore.Keys.accessToken)
        self.refreshTokenValue = KeychainStore.load(key: KeychainStore.Keys.refreshToken)
    }

    var isAuthenticated: Bool {
        token != nil && serverURL != nil
    }

    // MARK: - OAuth Helpers

    /// Build the OAuth authorize URL for a given server
    func oauthURL(for serverURL: URL) -> URL? {
        let clientId = serverURL.absoluteString
        let redirectURI = serverURL.absoluteString + Self.callbackPath

        var components = URLComponents(string: serverURL.absoluteString + "/auth/authorize")
        components?.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectURI)
        ]
        return components?.url
    }

    /// Exchange the auth code for tokens after OAuth callback
    func exchangeCode(_ code: String, serverURL: URL) async throws {
        let clientId = serverURL.absoluteString
        let restClient = HARestClient(serverURL: serverURL)
        let tokenResponse = try await restClient.exchangeAuthCode(code, clientId: clientId)

        // Store credentials
        self.serverURL = serverURL
        self.token = tokenResponse.accessToken
        self.refreshTokenValue = tokenResponse.refreshToken

        try KeychainStore.save(serverURL.absoluteString, for: KeychainStore.Keys.serverURL)
        try KeychainStore.save(tokenResponse.accessToken, for: KeychainStore.Keys.accessToken)
        if let refresh = tokenResponse.refreshToken {
            try KeychainStore.save(refresh, for: KeychainStore.Keys.refreshToken)
        }
    }

    /// Save a long-lived access token directly (for manual token entry)
    func saveToken(_ token: String, serverURL: URL) throws {
        print("[Maple] saveToken — serverURL: \(serverURL.absoluteString), token: \(token.prefix(8))...")
        self.serverURL = serverURL
        self.token = token

        try KeychainStore.save(serverURL.absoluteString, for: KeychainStore.Keys.serverURL)
        try KeychainStore.save(token, for: KeychainStore.Keys.accessToken)
        print("[Maple] Token saved to keychain successfully")
    }

    /// Attempt a silent token refresh
    func refreshTokenIfNeeded() async throws {
        guard let serverURL,
              let refresh = refreshTokenValue else {
            throw AuthError.tokenExchangeFailed
        }

        let clientId = serverURL.absoluteString
        let restClient = HARestClient(serverURL: serverURL)
        let tokenResponse = try await restClient.refreshToken(refresh, clientId: clientId)

        self.token = tokenResponse.accessToken
        if let newRefresh = tokenResponse.refreshToken {
            self.refreshTokenValue = newRefresh
            try KeychainStore.save(newRefresh, for: KeychainStore.Keys.refreshToken)
        }
        try KeychainStore.save(tokenResponse.accessToken, for: KeychainStore.Keys.accessToken)
    }

    /// Sign out and clear all credentials
    func signOut() {
        token = nil
        refreshTokenValue = nil
        serverURL = nil
        KeychainStore.clearAll()
    }
}

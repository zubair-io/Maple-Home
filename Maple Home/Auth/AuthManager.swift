import Foundation
import AuthenticationServices

// MARK: - AuthManager

@Observable
final class AuthManager {
    static let shared = AuthManager()

    private(set) var serverURL: URL?
    private(set) var token: String?
    private(set) var refreshTokenValue: String?

    static let clientId = "https://casita.maple.app"
    static let callbackScheme = "casita"

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

    // MARK: - Authentication Flow

    /// Full authentication flow: validate URL, OAuth2, token exchange
    func authenticate(serverURL: URL) async throws {
        // 1. Validate the URL
        let restClient = HARestClient(serverURL: serverURL)
        let _ = try await restClient.validateInstance()

        // 2. Build OAuth2 URL
        let authURL = serverURL.appendingPathComponent("auth/authorize")
        var components = URLComponents(url: authURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: Self.clientId),
            URLQueryItem(name: "redirect_uri", value: "\(Self.callbackScheme)://auth-callback")
        ]

        guard let oauthURL = components.url else {
            throw AuthError.invalidURL
        }

        // 3. Present ASWebAuthenticationSession
        let callbackURL = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<URL, Error>) in
            let session = ASWebAuthenticationSession(
                url: oauthURL,
                callbackURLScheme: Self.callbackScheme
            ) { callbackURL, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let callbackURL {
                    continuation.resume(returning: callbackURL)
                } else {
                    continuation.resume(throwing: AuthError.authCancelled)
                }
            }
            session.prefersEphemeralWebBrowserSession = false

            // Run on main thread for presentation
            DispatchQueue.main.async {
                session.start()
            }
        }

        // 4. Extract auth code from callback
        guard let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            throw AuthError.tokenExchangeFailed
        }

        // 5. Exchange code for token
        let tokenResponse = try await restClient.exchangeAuthCode(code, clientId: Self.clientId)

        // 6. Store credentials
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
        self.serverURL = serverURL
        self.token = token

        try KeychainStore.save(serverURL.absoluteString, for: KeychainStore.Keys.serverURL)
        try KeychainStore.save(token, for: KeychainStore.Keys.accessToken)
    }

    /// Attempt a silent token refresh
    func refreshTokenIfNeeded() async throws {
        guard let serverURL,
              let refresh = refreshTokenValue else {
            throw AuthError.tokenExchangeFailed
        }

        let restClient = HARestClient(serverURL: serverURL)
        let tokenResponse = try await restClient.refreshToken(refresh, clientId: Self.clientId)

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

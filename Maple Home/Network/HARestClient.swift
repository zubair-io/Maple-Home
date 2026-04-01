import Foundation

// MARK: - HARestClient

struct HARestClient {
    let serverURL: URL
    let session: URLSession

    init(serverURL: URL, session: URLSession = .shared) {
        self.serverURL = serverURL
        self.session = session
    }

    /// Validate that a URL points to a Home Assistant instance
    func validateInstance() async throws -> HAInstanceInfo {
        var url = serverURL
        url.appendPathComponent("api/")

        print("[Maple] Validating HA instance at: \(url.absoluteString)")
        var request = URLRequest(url: url)
        request.timeoutInterval = 10

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            print("[Maple] Network error reaching \(url.absoluteString): \(error)")
            throw AuthError.unreachable
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            print("[Maple] Response is not HTTPURLResponse")
            throw AuthError.unreachable
        }

        print("[Maple] Validation response: HTTP \(httpResponse.statusCode)")

        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                // This is still a HA instance, just needs auth
                print("[Maple] Got 401 — valid HA instance, needs auth")
                return HAInstanceInfo(version: "unknown", baseURL: serverURL)
            }
            print("[Maple] Unexpected status code: \(httpResponse.statusCode)")
            throw AuthError.notHAInstance
        }

        // Try to parse the response for version info
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let message = json["message"] as? String,
           message.contains("API running") {
            let version = json["version"] as? String ?? "unknown"
            print("[Maple] Valid HA instance, version: \(version)")
            return HAInstanceInfo(version: version, baseURL: serverURL)
        }

        print("[Maple] Response didn't contain expected 'API running' message")
        if let body = String(data: data, encoding: .utf8) {
            print("[Maple] Response body: \(body.prefix(500))")
        }
        throw AuthError.notHAInstance
    }

    /// Exchange an auth code for tokens
    func exchangeAuthCode(_ code: String, clientId: String) async throws -> HATokenResponse {
        var url = serverURL
        url.appendPathComponent("auth/token")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = "grant_type=authorization_code&code=\(code)&client_id=\(clientId)"
        request.httpBody = body.data(using: .utf8)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AuthError.tokenExchangeFailed
        }

        return try JSONDecoder().decode(HATokenResponse.self, from: data)
    }

    /// Refresh an expired token
    func refreshToken(_ refreshToken: String, clientId: String) async throws -> HATokenResponse {
        var url = serverURL
        url.appendPathComponent("auth/token")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = "grant_type=refresh_token&refresh_token=\(refreshToken)&client_id=\(clientId)"
        request.httpBody = body.data(using: .utf8)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AuthError.tokenExchangeFailed
        }

        return try JSONDecoder().decode(HATokenResponse.self, from: data)
    }
}

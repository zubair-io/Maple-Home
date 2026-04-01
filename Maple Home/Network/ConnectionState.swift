import Foundation

// MARK: - Connection State

enum ConnectionState: Equatable {
    case disconnected
    case connecting
    case authenticating
    case connected(haVersion: String)
    case error(ConnectionError)
    case reconnecting(attempt: Int)

    var isConnected: Bool {
        if case .connected = self { return true }
        return false
    }
}

// MARK: - Connection Error

enum ConnectionError: Equatable, LocalizedError {
    case unreachable
    case authFailed
    case tokenExpired
    case timeout
    case unknown(String)

    var userMessage: String {
        switch self {
        case .unreachable:
            return "Connection lost \u{2014} retrying..."
        case .authFailed:
            return "Authentication failed. Please try again."
        case .tokenExpired:
            return "Session expired. Please sign in again."
        case .timeout:
            return "Connection timed out."
        case .unknown(let msg):
            return msg
        }
    }
}

// MARK: - Auth Error

enum AuthError: Error {
    case unreachable
    case notHAInstance
    case authCancelled
    case tokenExchangeFailed
    case invalidURL
}

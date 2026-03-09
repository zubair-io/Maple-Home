import Foundation

// MARK: - HAWebSocketClient

actor HAWebSocketClient {
    private var webSocketTask: URLSessionWebSocketTask?
    private var session: URLSession
    private var messageIdCounter: Int = 0
    private var pendingRequests: [Int: CheckedContinuation<HAIncomingMessage, Error>] = [:]
    private var stateChangeContinuation: AsyncStream<StateChangedEvent>.Continuation?
    private var exposedEntityIds: Set<String> = []
    private var serverURL: URL?
    private var token: String?
    private var isReceiving = false

    init() {
        self.session = URLSession(configuration: .default)
    }

    // MARK: - Public API

    /// Connect to HA WebSocket and authenticate
    func connect(to url: URL, token: String) async throws -> String {
        self.serverURL = url
        self.token = token

        let wsScheme = url.scheme == "https" ? "wss" : "ws"
        guard let wsURL = URL(string: "\(wsScheme)://\(url.host ?? "localhost"):\(url.port ?? (url.scheme == "https" ? 443 : 8123))/api/websocket") else {
            throw ConnectionError.unreachable
        }

        let task = session.webSocketTask(with: wsURL)
        self.webSocketTask = task
        task.resume()

        // Wait for auth_required
        let authRequired = try await receiveMessage()
        guard authRequired.type == "auth_required" else {
            throw ConnectionError.authFailed
        }

        // Send auth
        let authMsg = HAAuthMessage(accessToken: token)
        try await sendRaw(authMsg)

        // Wait for auth_ok
        let authResult = try await receiveMessage()
        guard authResult.type == "auth_ok" else {
            throw ConnectionError.authFailed
        }

        // Start receive loop
        isReceiving = true
        Task { await receiveLoop() }

        return authResult.haVersion ?? "unknown"
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        isReceiving = false
        stateChangeContinuation?.finish()
        stateChangeContinuation = nil

        // Cancel all pending requests
        for (_, continuation) in pendingRequests {
            continuation.resume(throwing: ConnectionError.unreachable)
        }
        pendingRequests.removeAll()
    }

    func setExposedEntityIds(_ ids: Set<String>) {
        self.exposedEntityIds = ids
    }

    // MARK: - Message Sending

    /// Send a typed command and await the result
    func sendCommand(type: String) async throws -> HAIncomingMessage {
        let id = nextMessageId()
        let msg = HACommandMessage(id: id, type: type)
        return try await sendAndWait(id: id, message: msg)
    }

    /// Subscribe to state_changed events
    func subscribeStateChanges() async throws {
        let id = nextMessageId()
        let msg = HASubscribeEventsMessage(id: id, eventType: "state_changed")
        let _ = try await sendAndWait(id: id, message: msg)
    }

    /// Call a service
    func callService(domain: String, service: String, serviceData: [String: Any]) async throws {
        let id = nextMessageId()
        let codableData = serviceData.mapValues { AnyCodable($0) }
        let msg = HACallServiceMessage(id: id, domain: domain, service: service, serviceData: codableData)
        let _ = try await sendAndWait(id: id, message: msg)
    }

    /// Get exposed entity list using homeassistant/expose_entity/list
    func getExposedEntityList() async throws -> HAIncomingMessage {
        return try await sendCommand(type: "homeassistant/expose_entity/list")
    }

    // MARK: - State Change Stream

    var stateChanges: AsyncStream<StateChangedEvent> {
        AsyncStream { continuation in
            self.stateChangeContinuation = continuation
        }
    }

    // MARK: - Private

    private func nextMessageId() -> Int {
        messageIdCounter += 1
        return messageIdCounter
    }

    private func sendRaw<T: Encodable>(_ message: T) async throws {
        let data = try JSONEncoder().encode(message)
        guard let string = String(data: data, encoding: .utf8) else {
            throw ConnectionError.unknown("Failed to encode message")
        }
        try await webSocketTask?.send(.string(string))
    }

    private func sendAndWait<T: Encodable>(id: Int, message: T) async throws -> HAIncomingMessage {
        return try await withCheckedThrowingContinuation { continuation in
            pendingRequests[id] = continuation
            Task {
                do {
                    try await sendRaw(message)
                } catch {
                    pendingRequests.removeValue(forKey: id)
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func receiveMessage() async throws -> HAIncomingMessage {
        guard let task = webSocketTask else {
            throw ConnectionError.unreachable
        }
        let message = try await task.receive()
        switch message {
        case .string(let text):
            let data = Data(text.utf8)
            return try JSONDecoder().decode(HAIncomingMessage.self, from: data)
        case .data(let data):
            return try JSONDecoder().decode(HAIncomingMessage.self, from: data)
        @unknown default:
            throw ConnectionError.unknown("Unknown message format")
        }
    }

    private func receiveLoop() async {
        guard let task = webSocketTask else { return }

        while isReceiving {
            do {
                let message = try await task.receive()
                let incoming: HAIncomingMessage
                switch message {
                case .string(let text):
                    incoming = try JSONDecoder().decode(HAIncomingMessage.self, from: Data(text.utf8))
                case .data(let data):
                    incoming = try JSONDecoder().decode(HAIncomingMessage.self, from: data)
                @unknown default:
                    continue
                }

                // Handle response to pending request
                if let id = incoming.id, let continuation = pendingRequests.removeValue(forKey: id) {
                    continuation.resume(returning: incoming)
                }

                // Handle state_changed events
                if incoming.type == "event",
                   let event = incoming.event,
                   event.eventType == "state_changed",
                   let data = event.data,
                   let entityId = data.entityId,
                   let newState = data.newState {
                    // Filter to exposed entities only
                    if exposedEntityIds.isEmpty || exposedEntityIds.contains(entityId) {
                        let stateEvent = StateChangedEvent(
                            entityId: entityId,
                            newState: newState.state,
                            attributes: HAAttributes(raw: newState.attributes)
                        )
                        stateChangeContinuation?.yield(stateEvent)
                    }
                }
            } catch {
                if isReceiving {
                    // Connection lost
                    isReceiving = false
                    stateChangeContinuation?.finish()
                    // Cancel pending requests
                    for (_, continuation) in pendingRequests {
                        continuation.resume(throwing: ConnectionError.unreachable)
                    }
                    pendingRequests.removeAll()
                }
                break
            }
        }
    }
}

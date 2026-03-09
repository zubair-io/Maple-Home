import SwiftUI
import Foundation

// MARK: - Command Error

enum CommandError: Equatable {
    case commandFailed(entity: String)
    case connectionLost

    var message: String {
        switch self {
        case .commandFailed(let entity):
            return "Command failed for \(entity)"
        case .connectionLost:
            return "Connection lost"
        }
    }
}

// MARK: - DashboardViewModel

@Observable
final class DashboardViewModel {
    // Connection
    var connectionState: ConnectionState = .disconnected
    var haVersion: String = ""

    // Data
    var areas: [HAArea] = []
    var entities: [String: HAEntity] = [:]  // keyed by entity_id
    var exposedEntityIds: Set<String> = []

    // Error
    var commandError: CommandError?
    var showCommandError: Bool = false

    // Collapse state — tracked by @Observable so sections recompute
    var collapsedAreaIds: Set<String> = Set(UserDefaults.standard.stringArray(forKey: "collapsedAreas") ?? [])

    // MARK: - Derived

    var sections: [DashboardSection] {
        let exposed = entities.values.filter { $0.isExposed }

        // Group by entity category (Control, Sensor, Input, Automation, Presence)
        return EntityCategory.allCases.compactMap { category in
            let categoryEntities = exposed.filter { $0.domain.category == category }
            guard !categoryEntities.isEmpty else { return nil }
            let sorted = sortEntities(categoryEntities)
            return DashboardSection(
                id: category.rawValue,
                category: category,
                entities: sorted,
                isCollapsed: collapsedAreaIds.contains(category.rawValue)
            )
        }
    }

    var activeCount: Int {
        entities.values.filter { $0.isExposed && $0.isAvailable && $0.state == "on" }.count
    }

    // MARK: - Init

    let client: HAWebSocketClient

    init(client: HAWebSocketClient) {
        self.client = client
    }

    // MARK: - Connection

    func connect() async {
        // Don't connect if already connected or in the process of connecting
        if connectionState.isConnected || connectionState == .connecting || connectionState == .authenticating {
            print("[Maple] connect() — skipping, already \(connectionState)")
            return
        }

        guard let serverURL = AuthManager.shared.serverURL,
              let token = AuthManager.shared.token else {
            print("[Maple] connect() — no serverURL or token found")
            connectionState = .disconnected
            return
        }

        print("[Maple] connect() — serverURL: \(serverURL.absoluteString), token: \(token.prefix(8))...")
        connectionState = .connecting

        do {
            connectionState = .authenticating
            print("[Maple] Authenticating via WebSocket...")
            let version = try await client.connect(to: serverURL, token: token)
            haVersion = version
            connectionState = .connected(haVersion: version)
            print("[Maple] Connected! HA version: \(version)")

            // Load data
            print("[Maple] Loading entity registry...")
            try await loadEntityRegistry()
            print("[Maple] Loading exposed entities...")
            try await loadExposedEntities()
            print("[Maple] Loading area registry...")
            try await loadAreaRegistry()
            print("[Maple] Loading current states...")
            try await loadCurrentStates()
            print("[Maple] Subscribing to state changes...")
            try await subscribeToStateChanges()
            print("[Maple] All data loaded, \(entities.count) entities, \(areas.count) areas")
        } catch let error as ConnectionError where error == .authFailed {
            print("[Maple] Auth invalid — signing out")
            AuthManager.shared.signOut()
            connectionState = .disconnected
        } catch {
            print("[Maple] Connection failed: \(error)")
            connectionState = .error(.unreachable)
            // Start reconnection
            Task { await reconnect() }
        }
    }

    func disconnect() {
        Task { await client.disconnect() }
        connectionState = .disconnected
    }

    func reload() async {
        guard case .connected = connectionState else {
            await connect()
            return
        }

        do {
            try await loadCurrentStates()
        } catch {
            // Reconnect if reload fails
            await connect()
        }
    }

    // MARK: - Collapse

    func setCollapsed(_ collapsed: Bool, for sectionId: String) {
        if collapsed {
            collapsedAreaIds.insert(sectionId)
        } else {
            collapsedAreaIds.remove(sectionId)
        }
        UserDefaults.standard.set(Array(collapsedAreaIds), forKey: "collapsedAreas")
    }

    // MARK: - Data Loading

    private func loadEntityRegistry() async throws {
        let response = try await client.sendCommand(type: "config/entity_registry/list")

        guard let result = response.result,
              let entries = result.value as? [[String: Any]] else { return }

        for entry in entries {
            guard let entityId = entry["entity_id"] as? String else { continue }

            let name = entry["name"] as? String
                ?? (entry["original_name"] as? String)
                ?? entityId.components(separatedBy: ".").last?.replacingOccurrences(of: "_", with: " ").capitalized
                ?? entityId
            let areaId = entry["area_id"] as? String
            let disabledBy = entry["disabled_by"] as? String
            let hiddenBy = entry["hidden_by"] as? String

            // Skip disabled/hidden
            guard disabledBy == nil, hiddenBy == nil else { continue }

            let domain = DomainType(entityId: entityId)

            if entities[entityId] == nil {
                entities[entityId] = HAEntity(
                    id: entityId,
                    name: name,
                    domain: domain,
                    areaId: areaId,
                    state: "unknown",
                    attributes: HAAttributes(),
                    isExposed: false  // Will be updated by loadExposedEntities
                )
            }
        }
    }

    private func loadExposedEntities() async throws {
        // Use homeassistant/expose_entity/list to get exposed entities
        let response = try await client.getExposedEntityList()

        guard let result = response.result else {
            print("[Maple] loadExposedEntities — no result in response, success=\(response.success ?? false)")
            // If the command isn't supported, fall back to showing all entities
            exposedEntityIds = Set(entities.keys)
            for entityId in entities.keys {
                entities[entityId]?.isExposed = true
            }
            await client.setExposedEntityIds(exposedEntityIds)
            return
        }

        var exposed = Set<String>()

        // The response contains exposed_entities keyed by entity_id
        if let dict = result.value as? [String: Any] {
            print("[Maple] loadExposedEntities — got dict with \(dict.count) keys: \(Array(dict.keys).prefix(5))")

            // Try parsing as a dict of entity_id -> assistant exposure info
            if let exposedEntities = dict["exposed_entities"] as? [String: Any] {
                print("[Maple] Found exposed_entities key with \(exposedEntities.count) entries")
                // Log a sample entry
                if let sample = exposedEntities.first {
                    print("[Maple] Sample entry: \(sample.key) -> \(sample.value)")
                }
                for (entityId, info) in exposedEntities {
                    if let infoDict = info as? [String: Any] {
                        // Check any assistant has should_expose = true
                        for (_, assistantInfo) in infoDict {
                            if let aInfo = assistantInfo as? [String: Any],
                               let shouldExpose = aInfo["should_expose"] as? Bool,
                               shouldExpose {
                                exposed.insert(entityId)
                                break
                            }
                        }
                    }
                }
            } else {
                print("[Maple] No exposed_entities key, trying flat dict parse")
                // Log first entry for debugging
                if let sample = dict.first {
                    print("[Maple] Sample key: \(sample.key) -> \(type(of: sample.value)): \(sample.value)")
                }
                // Fallback: try as flat dict
                for (entityId, value) in dict {
                    if let valueDict = value as? [String: Any] {
                        for (_, assistantInfo) in valueDict {
                            if let aInfo = assistantInfo as? [String: Any],
                               let shouldExpose = aInfo["should_expose"] as? Bool,
                               shouldExpose {
                                exposed.insert(entityId)
                                break
                            }
                        }
                    }
                }
            }
        } else {
            print("[Maple] loadExposedEntities — result is not a dict, type: \(type(of: result.value))")
            if let arr = result.value as? [Any] {
                print("[Maple] Result is array with \(arr.count) items")
                if let sample = arr.first {
                    print("[Maple] Sample: \(sample)")
                }
            }
        }

        print("[Maple] Exposed entities from expose_entity/list: \(exposed.count)")

        // If the expose_entity/list didn't give results, fall back to entity registry
        if exposed.isEmpty {
            print("[Maple] Falling back to entity registry options...")
            let registryResponse = try await client.sendCommand(type: "config/entity_registry/list")
            if let entries = registryResponse.result?.value as? [[String: Any]] {
                for entry in entries {
                    guard let entityId = entry["entity_id"] as? String else { continue }
                    if let options = entry["options"] as? [String: Any],
                       let conversation = options["conversation"] as? [String: Any],
                       let shouldExpose = conversation["should_expose"] as? Bool,
                       shouldExpose {
                        exposed.insert(entityId)
                    }
                }
            }
            print("[Maple] Exposed entities from registry fallback: \(exposed.count)")
        }

        // If still empty, show all non-disabled entities
        if exposed.isEmpty {
            print("[Maple] No exposed entities found via any method — showing all \(entities.count) entities")
            exposed = Set(entities.keys)
        }

        print("[Maple] Final exposed entity count: \(exposed.count)")
        exposedEntityIds = exposed
        await client.setExposedEntityIds(exposed)

        // Update entity exposed flags
        for entityId in entities.keys {
            entities[entityId] = HAEntity(
                id: entities[entityId]!.id,
                name: entities[entityId]!.name,
                domain: entities[entityId]!.domain,
                areaId: entities[entityId]!.areaId,
                state: entities[entityId]!.state,
                attributes: entities[entityId]!.attributes,
                isExposed: exposed.contains(entityId)
            )
        }
    }

    private func loadAreaRegistry() async throws {
        let response = try await client.sendCommand(type: "config/area_registry/list")

        guard let result = response.result,
              let entries = result.value as? [[String: Any]] else { return }

        areas = entries.compactMap { entry in
            guard let areaId = entry["area_id"] as? String,
                  let name = entry["name"] as? String else { return nil }
            return HAArea(id: areaId, name: name)
        }
    }

    private func loadCurrentStates() async throws {
        let response = try await client.sendCommand(type: "get_states")

        guard let result = response.result,
              let states = result.value as? [[String: Any]] else { return }

        for stateDict in states {
            guard let entityId = stateDict["entity_id"] as? String else { continue }

            let state = stateDict["state"] as? String ?? "unknown"
            let attrs = stateDict["attributes"] as? [String: Any] ?? [:]
            let haAttrs = HAAttributes(raw: attrs.mapValues { AnyCodable($0) })

            let friendlyName = attrs["friendly_name"] as? String

            if var entity = entities[entityId] {
                entity.state = state
                entity.attributes = haAttrs
                entities[entityId] = entity
            } else if exposedEntityIds.contains(entityId) {
                // Entity not in registry but has state - create it
                let domain = DomainType(entityId: entityId)
                let name = friendlyName
                    ?? entityId.components(separatedBy: ".").last?.replacingOccurrences(of: "_", with: " ").capitalized
                    ?? entityId

                entities[entityId] = HAEntity(
                    id: entityId,
                    name: name,
                    domain: domain,
                    areaId: nil,
                    state: state,
                    attributes: haAttrs,
                    isExposed: true
                )
            }
        }
    }

    private func subscribeToStateChanges() async throws {
        try await client.subscribeStateChanges()

        // Listen for state changes in a separate task
        Task {
            for await event in await client.stateChanges {
                await MainActor.run {
                    handleStateChange(event)
                }
            }
        }
    }

    private func handleStateChange(_ event: StateChangedEvent) {
        guard exposedEntityIds.contains(event.entityId) else { return }
        entities[event.entityId]?.state = event.newState
        entities[event.entityId]?.attributes = event.attributes
    }

    // MARK: - Reconnection

    private func reconnect() async {
        let delays: [UInt64] = [1, 2, 4, 8, 30]
        for (attempt, delay) in delays.enumerated() {
            connectionState = .reconnecting(attempt: attempt + 1)
            try? await Task.sleep(nanoseconds: delay * 1_000_000_000)
            do {
                guard let serverURL = AuthManager.shared.serverURL,
                      let token = AuthManager.shared.token else { return }
                let version = try await client.connect(to: serverURL, token: token)
                haVersion = version
                connectionState = .connected(haVersion: version)
                try await loadCurrentStates()
                try await subscribeToStateChanges()
                return
            } catch {
                continue
            }
        }
        connectionState = .error(.unreachable)
    }

    // MARK: - Entity Controls

    func toggle(_ entity: HAEntity) async {
        let previousState = entities[entity.id]?.state
        entities[entity.id]?.state = previousState == "on" ? "off" : "on"

        do {
            let domain = entity.domain.serviceDomain
            let service = previousState == "on" ? "turn_off" : "turn_on"
            try await client.callService(
                domain: domain,
                service: service,
                serviceData: ["entity_id": entity.id]
            )
        } catch {
            entities[entity.id]?.state = previousState ?? "off"
            showError(.commandFailed(entity: entity.name))
        }
    }

    func setBrightness(_ entity: HAEntity, brightness: Int) async {
        let clamped = max(0, min(255, brightness))
        do {
            try await client.callService(
                domain: "light",
                service: "turn_on",
                serviceData: ["entity_id": entity.id, "brightness": clamped]
            )
        } catch {
            showError(.commandFailed(entity: entity.name))
        }
    }

    func setColorTemp(_ entity: HAEntity, kelvin: Int) async {
        do {
            try await client.callService(
                domain: "light",
                service: "turn_on",
                serviceData: ["entity_id": entity.id, "color_temp_kelvin": kelvin]
            )
        } catch {
            showError(.commandFailed(entity: entity.name))
        }
    }

    func setTemperature(_ entity: HAEntity, temperature: Double) async {
        do {
            try await client.callService(
                domain: "climate",
                service: "set_temperature",
                serviceData: ["entity_id": entity.id, "temperature": temperature]
            )
        } catch {
            showError(.commandFailed(entity: entity.name))
        }
    }

    func setHvacMode(_ entity: HAEntity, mode: String) async {
        do {
            try await client.callService(
                domain: "climate",
                service: "set_hvac_mode",
                serviceData: ["entity_id": entity.id, "hvac_mode": mode]
            )
        } catch {
            showError(.commandFailed(entity: entity.name))
        }
    }

    func setCoverPosition(_ entity: HAEntity, position: Int) async {
        do {
            try await client.callService(
                domain: "cover",
                service: "set_cover_position",
                serviceData: ["entity_id": entity.id, "position": position]
            )
        } catch {
            showError(.commandFailed(entity: entity.name))
        }
    }

    func openCover(_ entity: HAEntity) async {
        do {
            try await client.callService(
                domain: "cover",
                service: "open_cover",
                serviceData: ["entity_id": entity.id]
            )
        } catch {
            showError(.commandFailed(entity: entity.name))
        }
    }

    func closeCover(_ entity: HAEntity) async {
        do {
            try await client.callService(
                domain: "cover",
                service: "close_cover",
                serviceData: ["entity_id": entity.id]
            )
        } catch {
            showError(.commandFailed(entity: entity.name))
        }
    }

    func stopCover(_ entity: HAEntity) async {
        do {
            try await client.callService(
                domain: "cover",
                service: "stop_cover",
                serviceData: ["entity_id": entity.id]
            )
        } catch {
            showError(.commandFailed(entity: entity.name))
        }
    }

    func setVolume(_ entity: HAEntity, level: Double) async {
        do {
            try await client.callService(
                domain: "media_player",
                service: "volume_set",
                serviceData: ["entity_id": entity.id, "volume_level": level]
            )
        } catch {
            showError(.commandFailed(entity: entity.name))
        }
    }

    func mediaPlayPause(_ entity: HAEntity) async {
        do {
            try await client.callService(
                domain: "media_player",
                service: "media_play_pause",
                serviceData: ["entity_id": entity.id]
            )
        } catch {
            showError(.commandFailed(entity: entity.name))
        }
    }

    func selectOption(_ entity: HAEntity, option: String) async {
        do {
            let domain = entity.domain.serviceDomain
            try await client.callService(
                domain: domain,
                service: "select_option",
                serviceData: ["entity_id": entity.id, "option": option]
            )
        } catch {
            showError(.commandFailed(entity: entity.name))
        }
    }

    func activateScene(_ entity: HAEntity) async {
        do {
            try await client.callService(
                domain: "scene",
                service: "turn_on",
                serviceData: ["entity_id": entity.id]
            )
        } catch {
            showError(.commandFailed(entity: entity.name))
        }
    }

    func triggerButton(_ entity: HAEntity) async {
        do {
            let domain = entity.domain.serviceDomain
            try await client.callService(
                domain: domain,
                service: "press",
                serviceData: ["entity_id": entity.id]
            )
        } catch {
            showError(.commandFailed(entity: entity.name))
        }
    }

    // MARK: - Error Handling

    private func showError(_ error: CommandError) {
        commandError = error
        showCommandError = true
        // Auto-dismiss after 2.5s
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            showCommandError = false
        }
    }

    // MARK: - Sorting

    private func sortEntities(_ entities: [HAEntity]) -> [HAEntity] {
        let domainOrder: [DomainType: Int] = [
            .light: 0, .switch: 1, .fan: 2, .inputBoolean: 3,
            .climate: 4, .cover: 5, .mediaPlayer: 6,
            .sensor: 7, .binarySensor: 8,
            .automation: 9, .scene: 10, .script: 11,
        ]

        return entities.sorted { a, b in
            let orderA = domainOrder[a.domain] ?? 20
            let orderB = domainOrder[b.domain] ?? 20
            if orderA != orderB { return orderA < orderB }
            return a.name < b.name
        }
    }
}

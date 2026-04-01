import Foundation

// MARK: - Room

struct Room: Identifiable {
    let id: String                    // area_id from HA
    let name: String
    let floorId: String?              // from HA area registry
    let floorName: String?            // resolved from floor registry

    /// Short display name for hex tile (max ~10 chars)
    var shortName: String {
        // Use first two words max, abbreviate long names
        let words = name.split(separator: " ")
        if name.count <= 10 { return name }
        if words.count >= 2 {
            return words.prefix(2).joined(separator: "\n")
        }
        return name
    }

    // Linked HA entity IDs (resolved from area)
    var temperatureSensorId: String?
    var humiditySensorId: String?
    var occupancySensorIds: [String] = []
    var lightEntityIds: [String] = []
    var climateEntityId: String?
    var deviceEntityIds: [String] = []

    // Derived real-time state
    var currentTemp: Double?
    var targetTemp: Double?
    var humidity: Double?
    var isOccupied: Bool = false
    var isLit: Bool = false
    var lightBrightness: Double?      // 0–100
    var lightsOnCount: Int = 0
    var totalLightCount: Int = 0
}

// MARK: - HexPosition (used by HexGeometry for grid layout)

struct HexPosition {
    let col: Int
    let row: Int
}

// MARK: - Floor Section (for grouping rooms in hex grid)

struct FloorSection: Identifiable {
    let id: String          // floor_id or "_unassigned"
    let name: String
    let level: Int          // for sorting (lower = lower floor)
    var rooms: [Room]
}

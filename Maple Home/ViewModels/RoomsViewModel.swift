import SwiftUI
import Foundation

// MARK: - RoomsViewModel

@Observable
final class RoomsViewModel {
    // Source of truth
    private let dashboardVM: DashboardViewModel

    // Room state
    var floorSections: [FloorSection] = []
    var selectedRoomId: String?

    // Summary stats
    var occupiedCount: Int {
        floorSections.flatMap(\.rooms).filter(\.isOccupied).count
    }
    var lightsOnCount: Int {
        floorSections.flatMap(\.rooms).filter(\.isLit).count
    }
    var averageTemp: Double? {
        let temps = floorSections.flatMap(\.rooms).compactMap(\.currentTemp)
        guard !temps.isEmpty else { return nil }
        return temps.reduce(0, +) / Double(temps.count)
    }

    var allRooms: [Room] {
        floorSections.flatMap(\.rooms)
    }

    var selectedRoom: Room? {
        guard let id = selectedRoomId else { return nil }
        return allRooms.first { $0.id == id }
    }

    // MARK: - Init

    init(dashboardVM: DashboardViewModel) {
        self.dashboardVM = dashboardVM
    }

    // MARK: - Build Rooms

    /// Builds Room objects from all HA areas + entities, grouped by floor.
    func buildRooms() {
        let floorMap = Dictionary(uniqueKeysWithValues: dashboardVM.floors.map { ($0.id, $0) })

        // Build a Room for every area
        var roomsByFloor: [String: [Room]] = [:]  // floorId -> rooms

        for area in dashboardVM.areas {
            let areaEntities = dashboardVM.entities.values.filter { $0.areaId == area.id }

            let floorName = area.floorId.flatMap { floorMap[$0]?.name }

            var room = Room(
                id: area.id,
                name: area.name,
                floorId: area.floorId,
                floorName: floorName
            )

            // Resolve entity links
            for entity in areaEntities {
                switch entity.domain {
                case .sensor:
                    if entity.attributes.deviceClass == "temperature" && room.temperatureSensorId == nil {
                        room.temperatureSensorId = entity.id
                    } else if entity.attributes.deviceClass == "humidity" && room.humiditySensorId == nil {
                        room.humiditySensorId = entity.id
                    }
                case .binarySensor:
                    let dc = entity.attributes.deviceClass
                    if dc == "occupancy" || dc == "motion" || dc == "presence" {
                        room.occupancySensorIds.append(entity.id)
                    }
                case .light:
                    room.lightEntityIds.append(entity.id)
                case .climate:
                    if room.climateEntityId == nil {
                        room.climateEntityId = entity.id
                    }
                default:
                    break
                }
                room.deviceEntityIds.append(entity.id)
            }

            // Derive real-time state
            updateRoomState(&room)

            let key = area.floorId ?? "_unassigned"
            roomsByFloor[key, default: []].append(room)
        }

        // Build floor sections sorted by level
        var sections: [FloorSection] = []

        // Floors with known level, sorted ascending (lower floors first)
        let sortedFloors = dashboardVM.floors.sorted { ($0.level ?? 0) < ($1.level ?? 0) }

        for floor in sortedFloors {
            if let rooms = roomsByFloor.removeValue(forKey: floor.id), !rooms.isEmpty {
                sections.append(FloorSection(
                    id: floor.id,
                    name: floor.name,
                    level: floor.level ?? 0,
                    rooms: rooms
                ))
            }
        }

        // Any remaining rooms not assigned to a known floor
        for (floorId, rooms) in roomsByFloor where !rooms.isEmpty {
            if floorId == "_unassigned" {
                sections.append(FloorSection(
                    id: "_unassigned",
                    name: "Other",
                    level: 999,
                    rooms: rooms
                ))
            } else {
                // Floor ID exists on area but floor not in registry
                sections.append(FloorSection(
                    id: floorId,
                    name: floorId.replacingOccurrences(of: "_", with: " ").capitalized,
                    level: 500,
                    rooms: rooms
                ))
            }
        }

        floorSections = sections
    }

    /// Updates a single room's derived state from current entity data.
    private func updateRoomState(_ room: inout Room) {
        let entities = dashboardVM.entities

        // Temperature
        if let sensorId = room.temperatureSensorId,
           let sensor = entities[sensorId] {
            room.currentTemp = Double(sensor.state)
        } else if let climateId = room.climateEntityId,
                  let climate = entities[climateId] {
            room.currentTemp = climate.attributes.currentTemperature
        }

        // Target temp
        if let climateId = room.climateEntityId,
           let climate = entities[climateId] {
            room.targetTemp = climate.attributes.targetTemperature
        }

        // Humidity
        if let humidId = room.humiditySensorId,
           let sensor = entities[humidId] {
            room.humidity = Double(sensor.state)
        }

        // Occupancy
        room.isOccupied = room.occupancySensorIds.contains { sensorId in
            entities[sensorId]?.state == "on"
        }

        // Lights
        let lightEntities = room.lightEntityIds.compactMap { entities[$0] }
        let onLights = lightEntities.filter(\.isOn)
        room.totalLightCount = lightEntities.count
        room.lightsOnCount = onLights.count
        room.isLit = !onLights.isEmpty

        // Average brightness of on lights
        if !onLights.isEmpty {
            let brightnesses = onLights.compactMap { $0.attributes.brightness }
            if !brightnesses.isEmpty {
                let avgRaw = Double(brightnesses.reduce(0, +)) / Double(brightnesses.count)
                room.lightBrightness = (avgRaw / 255.0) * 100.0
            }
        } else {
            room.lightBrightness = nil
        }
    }

    // MARK: - Refresh

    /// Call whenever entity state changes to update derived room state.
    func refreshRoomStates() {
        for sIdx in floorSections.indices {
            for rIdx in floorSections[sIdx].rooms.indices {
                updateRoomState(&floorSections[sIdx].rooms[rIdx])
            }
        }
    }

    // MARK: - Selection

    func selectRoom(_ roomId: String) {
        if selectedRoomId == roomId {
            selectedRoomId = nil
        } else {
            selectedRoomId = roomId
        }
    }

    func deselectRoom() {
        selectedRoomId = nil
    }
}

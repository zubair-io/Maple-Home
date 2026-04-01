import Foundation

struct HAArea: Identifiable, Equatable, Codable {
    let id: String      // area_id
    let name: String
    var floorId: String? // floor_id from HA area registry

    enum CodingKeys: String, CodingKey {
        case id = "area_id"
        case name
        case floorId = "floor_id"
    }
}

struct HAFloor: Identifiable, Equatable, Codable {
    let id: String      // floor_id
    let name: String
    let level: Int?     // sorting order (lower number = lower floor)

    enum CodingKeys: String, CodingKey {
        case id = "floor_id"
        case name
        case level
    }
}

// MARK: - Dashboard Section (Area-Based)

struct DashboardSection: Identifiable {
    let id: String
    let areaName: String
    let entities: [HAEntity]
    var isCollapsed: Bool

    var entityCount: Int { entities.count }
}

import Foundation

struct HAArea: Identifiable, Equatable, Codable {
    let id: String      // area_id
    let name: String

    enum CodingKeys: String, CodingKey {
        case id = "area_id"
        case name
    }
}

// MARK: - Dashboard Section

struct DashboardSection: Identifiable {
    let id: String
    let category: EntityCategory
    let entities: [HAEntity]
    var isCollapsed: Bool

    var entityCount: Int { entities.count }
}

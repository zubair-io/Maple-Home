import SwiftUI

struct ToggleCardView: View {
    let entity: HAEntity
    @Environment(DashboardViewModel.self) private var vm

    private var isOn: Bool { entity.isOn }
    private var areaName: String? { vm.areaName(for: entity) }

    var body: some View {
        MapleCard(category: entity.domain.category, isActive: isOn) {
            MapleCardHeader(
                entityType: entity.domain.rawValue,
                name: entity.name,
                area: areaName,
                trailing: AnyView(
                    MapleToggle(isOn: .init(
                        get: { isOn },
                        set: { _ in Task { await vm.toggle(entity) } }
                    ))
                )
            )
            MapleBadge(text: isOn ? "ON" : "OFF", style: isOn ? .on : .off)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: entity.state)
    }
}

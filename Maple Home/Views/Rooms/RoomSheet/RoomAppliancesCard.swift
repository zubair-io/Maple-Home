import SwiftUI

struct RoomAppliancesCard: View {
    let room: Room
    @Environment(DashboardViewModel.self) private var vm

    private var applianceEntities: [HAEntity] {
        room.deviceEntityIds
            .compactMap { vm.entities[$0] }
            .filter { $0.domain == .switch || $0.domain == .inputBoolean }
            .sorted { $0.name < $1.name }
    }

    var body: some View {
        if !applianceEntities.isEmpty {
            EntityCardWrapper(railColor: .catControl) {
                Text("APPLIANCES")
                    .font(MapleFont.label)
                    .kerning(1.4)
                    .foregroundColor(.mapleT4)
                    .padding(.bottom, MapleSpacing.s2)

                FlowLayout(spacing: 6) {
                    ForEach(applianceEntities) { entity in
                        DeviceChip(entity: entity)
                    }
                }
            }
        }
    }
}

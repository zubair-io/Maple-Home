import SwiftUI

struct RoomDevicesCard: View {
    let room: Room
    @Environment(DashboardViewModel.self) private var vm

    /// Entities not already shown in dedicated cards
    private var otherEntities: [HAEntity] {
        let dedicatedIds = Set(
            room.lightEntityIds
            + room.occupancySensorIds
            + [room.climateEntityId, room.temperatureSensorId, room.humiditySensorId].compactMap { $0 }
        )
        // Also exclude domains handled by their own cards
        let handledDomains: Set<DomainType> = [.light, .climate, .mediaPlayer, .cover, .switch, .inputBoolean]
        return room.deviceEntityIds
            .compactMap { vm.entities[$0] }
            .filter { !dedicatedIds.contains($0.id) && !handledDomains.contains($0.domain) }
            .sorted { $0.name < $1.name }
    }

    var body: some View {
        if !otherEntities.isEmpty {
            EntityCardWrapper(railColor: .mapleT3) {
                Text("DEVICES")
                    .font(MapleFont.label)
                    .kerning(1.4)
                    .foregroundColor(.mapleT4)
                    .padding(.bottom, MapleSpacing.s2)

                FlowLayout(spacing: 6) {
                    ForEach(otherEntities) { entity in
                        DeviceChip(entity: entity)
                    }
                }
            }
        }
    }
}

// MARK: - Device Chip

struct DeviceChip: View {
    let entity: HAEntity

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(entity.isOn ? Color.mapleSuccess : Color.mapleT4)
                .frame(width: 5, height: 5)

            Text(entity.name)
                .font(MapleFont.bodyRegular(11))
                .foregroundColor(.mapleT2)
                .lineLimit(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.mapleSurface2)
        .clipShape(Capsule())
    }
}

import SwiftUI

struct RoomPresenceCard: View {
    let room: Room
    @Environment(DashboardViewModel.self) private var vm

    private var occupancyEntities: [HAEntity] {
        room.occupancySensorIds.compactMap { vm.entities[$0] }
    }

    private var isOccupied: Bool {
        occupancyEntities.contains { $0.state == "on" }
    }

    private var iconName: String {
        if isOccupied {
            return occupancyEntities.contains(where: { $0.attributes.deviceClass == "motion" })
                ? "figure.walk" : "person.fill"
        }
        return "person.fill"
    }

    var body: some View {
        EntityCardWrapper(railColor: .mapleSuccess) {
            HStack(spacing: MapleSpacing.s4) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                        .fill(isOccupied ? Color.mapleSuccessDim : Color.mapleSurface2)
                        .frame(width: 44, height: 44)
                    Image(systemName: iconName)
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(isOccupied ? .mapleSuccess : .mapleT4)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(isOccupied ? "Occupied" : "Clear")
                        .font(MapleFont.displayBold(15))
                        .foregroundColor(isOccupied ? .mapleT1 : .mapleT3)
                    Text(isOccupied ? "Motion detected" : "No recent activity")
                        .font(MapleFont.bodyLight(11))
                        .foregroundColor(.mapleT3)
                }

                Spacer()

                MapleBadge(
                    text: isOccupied ? "Active" : "Clear",
                    style: isOccupied ? .ok : .off
                )
            }
        }
    }
}

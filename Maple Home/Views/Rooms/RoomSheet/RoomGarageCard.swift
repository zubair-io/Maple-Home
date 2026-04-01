import SwiftUI

struct RoomGarageCard: View {
    let room: Room
    @Environment(DashboardViewModel.self) private var vm

    private var coverEntity: HAEntity? {
        room.deviceEntityIds
            .compactMap { vm.entities[$0] }
            .first { $0.domain == .cover }
    }

    var body: some View {
        if let entity = coverEntity {
            EntityCardWrapper(railColor: .mapleT2) {
                Text(entity.name.uppercased())
                    .font(MapleFont.label)
                    .kerning(1.4)
                    .foregroundColor(.mapleT4)
                    .padding(.bottom, MapleSpacing.s2)

                CoverVisual(position: Double(entity.attributes.currentPosition ?? (entity.state == "open" ? 100 : 0)))

                HStack(spacing: MapleSpacing.s3) {
                    MapleActionButton(label: "Open", icon: "arrow.up", style: .dark) {
                        Task { await vm.openCover(entity) }
                    }
                    MapleActionButton(label: "Close", icon: "arrow.down", style: .ghost) {
                        Task { await vm.closeCover(entity) }
                    }
                }
                .padding(.top, MapleSpacing.s3)
            }
        }
    }
}

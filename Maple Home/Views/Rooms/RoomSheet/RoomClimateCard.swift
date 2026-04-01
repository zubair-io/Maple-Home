import SwiftUI

struct RoomClimateCard: View {
    let room: Room
    @Environment(DashboardViewModel.self) private var vm

    private var climateEntity: HAEntity? {
        room.climateEntityId.flatMap { vm.entities[$0] }
    }

    private var tempColor: Color {
        guard let temp = room.currentTemp else { return .mapleT3 }
        switch temp {
        case ..<66:  return .tempCold
        case ..<69:  return .tempCool
        case ..<74:  return .tempNorm
        default:     return .tempWarm
        }
    }

    private var arcValue: Double {
        guard let current = room.currentTemp else { return 0 }
        // Normalize 50–90°F to 0–1
        return max(0, min(1, (current - 50) / 40))
    }

    @State private var targetTemp: Double = 72
    @State private var hvacMode: String = "auto"

    var body: some View {
        EntityCardWrapper(railColor: .entityHeat) {
            HStack {
                Text("CLIMATE")
                    .font(MapleFont.label)
                    .kerning(1.4)
                    .foregroundColor(.mapleT4)
                Spacer()
                if let entity = climateEntity {
                    MapleBadge(
                        text: entity.attributes.hvacAction?.capitalized ?? entity.state.capitalized,
                        style: entity.state == "off" ? .off : .on
                    )
                }
            }

            HStack(spacing: MapleSpacing.s5) {
                MapleArc(
                    value: arcValue,
                    label: room.currentTemp.map { "\(Int($0))°" } ?? "–",
                    sublabel: "Current",
                    size: 84,
                    strokeWidth: 5,
                    color: tempColor
                )

                VStack(spacing: MapleSpacing.s3) {
                    Text("TARGET")
                        .font(MapleFont.label)
                        .kerning(1.0)
                        .foregroundColor(.mapleT3)

                    MapleNumberStepper(
                        value: $targetTemp,
                        range: 60...85,
                        format: { "\(Int($0))°" }
                    )
                    .onChange(of: targetTemp) { _, newValue in
                        guard let entity = climateEntity else { return }
                        Task { await vm.setTemperature(entity, temperature: newValue) }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.top, MapleSpacing.s3)

            if let modes = climateEntity?.attributes.hvacModes, !modes.isEmpty {
                ModePills(options: modes, selected: $hvacMode)
                    .padding(.top, MapleSpacing.s3)
                    .onChange(of: hvacMode) { _, newValue in
                        guard let entity = climateEntity else { return }
                        Task { await vm.setHvacMode(entity, mode: newValue) }
                    }
            }
        }
        .onAppear { syncState() }
        .onChange(of: vm.entities) { _, _ in syncState() }
    }

    private func syncState() {
        if let entity = climateEntity {
            targetTemp = entity.attributes.targetTemperature ?? 72
            hvacMode = entity.state
        }
    }
}

import SwiftUI

struct FanCardView: View {
    let entity: HAEntity
    @Environment(DashboardViewModel.self) private var vm

    @State private var fanRotation: Double = 0

    private var isOn: Bool { entity.isOn }
    private var areaName: String? { vm.areaName(for: entity) }

    private var speedLabel: String {
        entity.attributes.raw["percentage"]?.intValue.map { "\($0)%" } ?? entity.state.capitalized
    }

    var body: some View {
        MapleCard(category: .control, isActive: isOn) {
            MapleCardHeader(
                entityType: "fan",
                name: entity.name,
                area: areaName,
                trailing: AnyView(
                    MapleToggle(isOn: .init(
                        get: { isOn },
                        set: { _ in Task { await vm.toggle(entity) } }
                    ))
                )
            )

            HStack(spacing: MapleSpacing.s5) {
                ZStack {
                    Circle()
                        .fill(Color.mapleSurface2)
                        .frame(width: 64, height: 64)
                    Image(systemName: "fan.fill")
                        .font(.system(size: 28, weight: .light))
                        .foregroundColor(.mapleT2)
                        .rotationEffect(.degrees(fanRotation))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(isOn ? speedLabel : "Off")
                        .font(MapleFont.displayBold(22))
                        .foregroundColor(.mapleT1)
                }
            }
            .padding(.vertical, MapleSpacing.s2)

            MapleBadge(text: isOn ? "ON" : "OFF", style: isOn ? .on : .off)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: entity.state)
        .onAppear { if isOn { startSpinning() } }
        .onChange(of: entity.state) { _, _ in
            if isOn { startSpinning() }
        }
    }

    private func startSpinning() {
        withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
            fanRotation += 360
        }
    }
}

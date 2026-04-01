import SwiftUI

struct TimerCardView: View {
    let entity: HAEntity
    @Environment(DashboardViewModel.self) private var vm

    private var timerState: String { entity.state }

    private var badgeStyle: MapleBadgeStyle {
        switch timerState {
        case "active": return .info
        case "paused": return .warn
        default: return .off
        }
    }

    private var formattedTime: String {
        if let remaining = entity.attributes.raw["remaining"]?.stringValue {
            return remaining
        }
        if let duration = entity.attributes.raw["duration"]?.stringValue {
            return timerState == "idle" ? duration : "00:00:00"
        }
        return "00:00:00"
    }

    var body: some View {
        MapleCard(category: .automation) {
            MapleCardHeader(
                entityType: "timer",
                name: entity.name,
                area: vm.areaName(for: entity),
                badgeStyle: badgeStyle,
                badgeText: timerState.uppercased()
            )

            Text(formattedTime)
                .font(MapleFont.displayHero(36))
                .foregroundColor(.mapleT1)
                .monospacedDigit()
                .padding(.vertical, MapleSpacing.s2)

            HStack(spacing: MapleSpacing.s2) {
                if timerState == "active" {
                    timerButton("Pause", primary: true) {
                        Task { try? await vm.client.callService(domain: "timer", service: "pause", serviceData: ["entity_id": entity.id]) }
                    }
                    timerButton("Cancel", primary: false) {
                        Task { try? await vm.client.callService(domain: "timer", service: "cancel", serviceData: ["entity_id": entity.id]) }
                    }
                } else if timerState == "paused" {
                    timerButton("Resume", primary: true) {
                        Task { try? await vm.client.callService(domain: "timer", service: "start", serviceData: ["entity_id": entity.id]) }
                    }
                    timerButton("Cancel", primary: false) {
                        Task { try? await vm.client.callService(domain: "timer", service: "cancel", serviceData: ["entity_id": entity.id]) }
                    }
                } else {
                    timerButton("Start", primary: true) {
                        Task { try? await vm.client.callService(domain: "timer", service: "start", serviceData: ["entity_id": entity.id]) }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func timerButton(_ label: String, primary: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(MapleFont.bodyBold(12))
                .kerning(0.3)
                .foregroundColor(primary ? .white : .mapleT2)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(primary ? Color.mapleAccent : Color.mapleSurface2)
                .cornerRadius(MapleRadius.sm)
        }
    }
}

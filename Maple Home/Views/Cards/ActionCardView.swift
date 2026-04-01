import SwiftUI

struct ActionCardView: View {
    let entity: HAEntity
    @Environment(DashboardViewModel.self) private var vm

    @State private var triggered = false

    var body: some View {
        MapleCard(category: entity.domain.category) {
            MapleCardHeader(
                entityType: entity.domain.rawValue,
                name: entity.name,
                area: vm.areaName(for: entity)
            )

            MapleActionButton(
                label: triggered ? "Triggered" : actionLabel,
                icon: triggered ? "checkmark" : actionIcon,
                style: triggered ? .accent : .dark
            ) {
                withAnimation(.spring(response: 0.2)) { triggered = true }
                Task {
                    switch entity.domain {
                    case .scene:
                        await vm.activateScene(entity)
                    case .script:
                        await vm.toggle(entity)
                    case .button, .inputButton:
                        await vm.triggerButton(entity)
                    default:
                        await vm.toggle(entity)
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation { triggered = false }
                }
            }
        }
    }

    private var actionLabel: String {
        switch entity.domain {
        case .scene: return "Activate"
        case .script: return "Run"
        case .button, .inputButton: return "Press"
        default: return "Execute"
        }
    }

    private var actionIcon: String {
        switch entity.domain {
        case .scene: return "sparkles"
        case .script: return "play.fill"
        case .button, .inputButton: return "hand.tap.fill"
        default: return "bolt.fill"
        }
    }
}

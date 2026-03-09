import SwiftUI

// MARK: - Entity Card View (Router)

struct EntityCardView: View {
    let entity: HAEntity
    @Environment(DashboardViewModel.self) private var viewModel
    @State private var showDetailSheet = false

    var body: some View {
        cardContent
            .overlay(alignment: .leading) {
                // Category accent rail on left edge
                UnevenRoundedRectangle(
                    topLeadingRadius: Radius.lg,
                    bottomLeadingRadius: Radius.lg
                )
                .fill(entity.domain.category.color)
                .frame(width: 3)
            }
            .opacity(entity.isAvailable ? 1.0 : 0.45)
            .onLongPressGesture(minimumDuration: 0.4) {
                showDetailSheet = true
            }
            .sheet(isPresented: $showDetailSheet) {
                EntityDetailSheet(entity: entity)
            }
    }

    @ViewBuilder
    private var cardContent: some View {
        switch entity.domain.controlStyle {
        case .toggle:
            ToggleCardView(entity: entity)
        case .light:
            LightCardView(entity: entity)
        case .slider:
            SliderCardView(entity: entity)
        case .climate:
            ClimateCardView(entity: entity)
        case .mediaPlayer:
            MediaPlayerCardView(entity: entity)
        case .cover:
            CoverCardView(entity: entity)
        case .readOnly:
            SensorTileView(entity: entity)
        case .select:
            SelectCardView(entity: entity)
        case .action:
            ActionCardView(entity: entity)
        case .timer:
            TimerCardView(entity: entity)
        }
    }
}


#Preview {
    EntityCardView(entity: HAEntity(
        id: "light.desk_lamp",
        name: "Desk Lamp",
        domain: .light,
        areaId: nil,
        state: "on",
        attributes: HAAttributes(),
        isExposed: true
    ))
}

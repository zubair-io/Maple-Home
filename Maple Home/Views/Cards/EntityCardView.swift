import SwiftUI

struct EntityCardView: View {
    let entity: HAEntity
    @Environment(DashboardViewModel.self) private var viewModel
    @State private var showDetailSheet = false

    var body: some View {
        cardContent
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
        case .fan:
            FanCardView(entity: entity)
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

import SwiftUI

// MARK: - Entity Card View (Router)

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

// MARK: - Entity Detail Sheet (Placeholder)

struct EntityDetailSheet: View {
    let entity: HAEntity
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Entity") {
                    LabeledContent("ID", value: entity.id)
                    LabeledContent("State", value: entity.state)
                    LabeledContent("Domain", value: entity.domain.rawValue)
                }

                Section("Attributes") {
                    ForEach(entity.attributes.rawKeyValues, id: \.key) { pair in
                        LabeledContent(pair.key, value: pair.value)
                            .font(.bodySM)
                    }
                }
            }
            .navigationTitle(entity.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.lato(size: 14, weight: .bold))
                }
            }
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

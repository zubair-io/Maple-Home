import SwiftUI

// MARK: - Cover Card View

struct CoverCardView: View {
    let entity: HAEntity
    @Environment(DashboardViewModel.self) private var viewModel

    @State private var positionValue: Double = 0
    @State private var isDragging = false
    @State private var debounceTask: Task<Void, Never>?

    private var position: Int { entity.attributes.currentPosition ?? 0 }
    private var displayPosition: Int {
        isDragging ? Int(positionValue) : position
    }

    private var iconName: String {
        entity.isOn ? entity.domain.activeSymbol : entity.domain.inactiveSymbol
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sp3) {
            // Header
            HStack(spacing: Spacing.sp3) {
                Image(systemName: iconName)
                    .font(.system(size: 24))
                    .foregroundStyle(entity.isOn ? entity.domain.accentColor : .entityInactive)
                    .frame(width: 32, alignment: .center)

                VStack(alignment: .leading, spacing: 2) {
                    Text(entity.name)
                        .font(.bodySMBold)
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)

                    Text("\(displayPosition)%")
                        .font(.caption)
                        .foregroundStyle(Color.textMuted)
                }

                Spacer()
            }

            // Position slider
            Slider(
                value: $positionValue,
                in: 0...100,
                step: 1
            ) {
                EmptyView()
            } onEditingChanged: { editing in
                isDragging = editing
                if !editing {
                    debouncePosition()
                }
            }
            .tint(entity.domain.accentColor)

            // Control buttons
            HStack(spacing: Spacing.sp3) {
                Button("Open") {
                    Task { await viewModel.openCover(entity) }
                }
                .buttonStyle(MapleButtonStyle(variant: .ghost, isFullWidth: false))

                Button("Stop") {
                    Task { await viewModel.stopCover(entity) }
                }
                .buttonStyle(MapleButtonStyle(variant: .ghost, isFullWidth: false))

                Button("Close") {
                    Task { await viewModel.closeCover(entity) }
                }
                .buttonStyle(MapleButtonStyle(variant: .ghost, isFullWidth: false))

                Spacer()
            }
        }
        .padding(Spacing.sp4)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .mapleShadow(.sm)
        .onAppear { positionValue = Double(position) }
        .onChange(of: entity.attributes.currentPosition) { _, newValue in
            if !isDragging {
                positionValue = Double(newValue ?? 0)
            }
        }
    }

    private func debouncePosition() {
        debounceTask?.cancel()
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await viewModel.setCoverPosition(entity, position: Int(positionValue))
        }
    }
}

#Preview {
    CoverCardView(entity: HAEntity(
        id: "cover.living_room_blinds",
        name: "Living Room Blinds",
        domain: .cover,
        areaId: nil,
        state: "open",
        attributes: HAAttributes(raw: [
            "current_position": AnyCodable(75)
        ]),
        isExposed: true
    ))
    .padding()
    .background(Color.base)
}

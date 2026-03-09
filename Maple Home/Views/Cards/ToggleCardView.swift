import SwiftUI

// MARK: - Toggle Card View

struct ToggleCardView: View {
    let entity: HAEntity
    @Environment(DashboardViewModel.self) private var viewModel

    private var isOn: Bool { entity.isOn }

    private var iconName: String {
        isOn ? entity.domain.activeSymbol : entity.domain.inactiveSymbol
    }

    private var iconColor: Color {
        isOn ? entity.domain.accentColor : .entityInactive
    }

    private var subtitle: String {
        entity.state.capitalized
    }

    var body: some View {
        HStack(spacing: Spacing.sp3) {
            // Icon
            Image(systemName: iconName)
                .font(.system(size: 24))
                .foregroundStyle(iconColor)
                .frame(width: 32, alignment: .center)

            // Label + Subtitle
            VStack(alignment: .leading, spacing: 2) {
                Text(entity.name)
                    .font(.bodySMBold)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color.textMuted)
                    .lineLimit(1)
            }

            Spacer()

            // Toggle
            Toggle(isOn: Binding(
                get: { isOn },
                set: { _, _ in
                    Task { await viewModel.toggle(entity) }
                }
            )) {
                EmptyView()
            }
            .labelsHidden()
            .tint(entity.domain.accentColor)
        }
        .padding(.horizontal, Spacing.sp4)
        .padding(.vertical, Spacing.sp3)
        .background(isOn ? entity.domain.fillColor : Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .mapleShadow(.sm)
        .animation(.easeInOut(duration: 0.2), value: entity.state)
    }
}

#Preview {
    VStack(spacing: Spacing.sp3) {
        ToggleCardView(entity: HAEntity(
            id: "light.desk_lamp",
            name: "Desk Lamp",
            domain: .light,
            areaId: nil,
            state: "on",
            attributes: HAAttributes(),
            isExposed: true
        ))

        ToggleCardView(entity: HAEntity(
            id: "switch.fan",
            name: "Ceiling Fan",
            domain: .fan,
            areaId: nil,
            state: "off",
            attributes: HAAttributes(),
            isExposed: true
        ))
    }
    .padding()
    .background(Color.base)
}

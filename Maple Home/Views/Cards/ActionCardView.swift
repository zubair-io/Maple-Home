import SwiftUI

// MARK: - Action Card View

struct ActionCardView: View {
    let entity: HAEntity
    @Environment(DashboardViewModel.self) private var viewModel

    @State private var isPressed = false

    private var iconName: String {
        switch entity.domain {
        case .scene: return "sparkles"
        case .script: return entity.domain.activeSymbol
        default: return entity.domain.inactiveSymbol
        }
    }

    private var lastRun: String? {
        // state often holds the last triggered timestamp for scripts/automations
        if entity.domain == .scene { return nil }
        let state = entity.state
        if state == "unknown" || state == "unavailable" { return nil }
        return state
    }

    var body: some View {
        VStack(spacing: Spacing.sp3) {
            Spacer()

            // Icon
            Image(systemName: iconName)
                .font(.system(size: 32))
                .foregroundStyle(entity.domain.accentColor)

            // Name
            Text(entity.name)
                .font(.bodySMBold)
                .foregroundStyle(Color.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.center)

            // Last run
            if let lastRun {
                Text(lastRun)
                    .font(.caption)
                    .foregroundStyle(Color.textMuted)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(Spacing.sp4)
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .mapleShadow(.sm)
        .scaleEffect(isPressed ? 0.94 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onTapGesture {
            withAnimation {
                isPressed = true
            }

            Task {
                switch entity.domain {
                case .scene:
                    await viewModel.activateScene(entity)
                case .button, .inputButton:
                    await viewModel.triggerButton(entity)
                default:
                    await viewModel.toggle(entity)
                }

                // Reset press state after a short delay
                try? await Task.sleep(nanoseconds: 200_000_000)
                await MainActor.run {
                    withAnimation {
                        isPressed = false
                    }
                }
            }
        }
    }
}

#Preview {
    HStack(spacing: Spacing.sp3) {
        ActionCardView(entity: HAEntity(
            id: "scene.movie_night",
            name: "Movie Night",
            domain: .scene,
            areaId: nil,
            state: "unknown",
            attributes: HAAttributes(),
            isExposed: true
        ))

        ActionCardView(entity: HAEntity(
            id: "script.goodnight",
            name: "Goodnight",
            domain: .script,
            areaId: nil,
            state: "off",
            attributes: HAAttributes(),
            isExposed: true
        ))
    }
    .padding()
    .background(Color.base)
}

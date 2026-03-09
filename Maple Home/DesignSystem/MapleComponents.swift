import SwiftUI

// MARK: - Card Modifier

struct MapleCard: ViewModifier {
    var isActive: Bool = false
    var fillColor: Color = .fillSwitch

    func body(content: Content) -> some View {
        content
            .background(isActive ? fillColor : Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 2)
    }
}

extension View {
    func mapleCard(isActive: Bool = false, fillColor: Color = .fillSwitch) -> some View {
        modifier(MapleCard(isActive: isActive, fillColor: fillColor))
    }
}

// MARK: - Primary Button Style

struct MapleButtonStyle: ButtonStyle {
    enum Variant {
        case primary
        case ghost
    }

    let variant: Variant
    var isFullWidth: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        switch variant {
        case .primary:
            configuration.label
                .font(.lato(size: 14, weight: .bold))
                .foregroundStyle(Color.textInverse)
                .padding(.horizontal, Spacing.sp6)
                .padding(.vertical, Spacing.sp3)
                .frame(maxWidth: isFullWidth ? .infinity : nil)
                .background(Color.accent)
                .clipShape(RoundedRectangle(cornerRadius: Radius.pill))
                .opacity(configuration.isPressed ? 0.85 : 1.0)
                .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
                .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)

        case .ghost:
            configuration.label
                .font(.lato(size: 12, weight: .bold))
                .foregroundStyle(Color.textPrimary)
                .padding(.horizontal, Spacing.sp4)
                .padding(.vertical, Spacing.sp2)
                .background(Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: Radius.pill))
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.pill)
                        .stroke(Color.borderStrong, lineWidth: 1)
                )
                .opacity(configuration.isPressed ? 0.7 : 1.0)
                .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
                .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
        }
    }
}

// MARK: - Pill Badge

struct PillBadge: View {
    let text: String
    var foregroundColor: Color = .textInverse
    var backgroundColor: Color = .accent

    var body: some View {
        Text(text.uppercased())
            .font(.lato(size: 10, weight: .bold))
            .tracking(0.5)
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, Spacing.sp2)
            .padding(.vertical, 3)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: Radius.pill))
    }
}

// MARK: - Connection Banner

struct ConnectionBannerView: View {
    let state: ConnectionState

    var body: some View {
        switch state {
        case .connecting, .authenticating:
            bannerContent(
                icon: nil,
                message: "Connecting...",
                showProgress: true
            )
        case .reconnecting(let attempt):
            bannerContent(
                icon: "exclamationmark.circle.fill",
                message: "Reconnecting (attempt \(attempt))...",
                showProgress: true
            )
        case .error(let error):
            bannerContent(
                icon: "exclamationmark.circle.fill",
                message: error.userMessage,
                showProgress: false
            )
        default:
            EmptyView()
        }
    }

    private func bannerContent(icon: String?, message: String, showProgress: Bool) -> some View {
        HStack(spacing: Spacing.sp3) {
            if let icon {
                Image(systemName: icon)
                    .foregroundStyle(Color.error)
            }
            Text(message)
                .font(.lato(size: 13, weight: .bold))
                .foregroundStyle(Color.textPrimary)
            Spacer()
            if showProgress {
                ProgressView()
                    .controlSize(.small)
            }
        }
        .padding(Spacing.sp4)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .shadow(color: .black.opacity(0.12), radius: 32, x: 0, y: 8)
    }
}

// MARK: - Empty State View

struct EmptyExposedEntitiesView: View {
    var body: some View {
        VStack(spacing: Spacing.sp4) {
            Image(systemName: "house.circle")
                .font(.system(size: 48))
                .foregroundStyle(Color.textFaint)

            Text("No exposed entities found.")
                .font(.lato(size: 14))
                .foregroundStyle(Color.textMuted)

            Text("In Home Assistant, mark entities as exposed in Settings \u{2192} Voice Assistants \u{2192} Expose.")
                .font(.lato(size: 13))
                .foregroundStyle(Color.textMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.sp10)
    }
}

// MARK: - HVAC Mode Pill

struct HvacModePill: View {
    let mode: String

    private var accentColor: Color {
        switch mode {
        case "cool", "fan_only": return .entityCool
        case "heat", "heat_cool": return .entityHeat
        case "auto": return .accent
        default: return .textMuted
        }
    }

    private var dimColor: Color {
        switch mode {
        case "cool", "fan_only": return .fillCool
        case "heat", "heat_cool": return .fillHeat
        case "auto": return .accentDim
        default: return .clear
        }
    }

    var body: some View {
        Text(mode.uppercased())
            .font(.lato(size: 10, weight: .bold))
            .tracking(0.5)
            .foregroundStyle(accentColor)
            .padding(.horizontal, Spacing.sp2)
            .padding(.vertical, 3)
            .background(dimColor)
            .clipShape(RoundedRectangle(cornerRadius: Radius.pill))
    }
}

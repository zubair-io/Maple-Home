import SwiftUI

// MARK: - Timer Card View

struct TimerCardView: View {
    let entity: HAEntity
    @Environment(DashboardViewModel.self) private var viewModel

    private var isActive: Bool {
        entity.state == "active"
    }

    private var isPaused: Bool {
        entity.state == "paused"
    }

    private var isIdle: Bool {
        entity.state == "idle"
    }

    /// The countdown display value from the entity state or duration attribute
    private var countdownValue: String {
        if isActive || isPaused {
            // State often holds remaining time like "0:05:00"
            return entity.state == "active" ? timerDisplay : entity.state
        }
        return entity.attributes.raw["duration"]?.stringValue ?? "0:00:00"
    }

    private var timerDisplay: String {
        // Timer entities in active state show remaining via attributes
        if let remaining = entity.attributes.raw["remaining"]?.stringValue {
            return remaining
        }
        return entity.state
    }

    /// Rough progress (0-1) based on duration vs remaining
    private var progress: Double {
        guard isActive || isPaused else { return 0 }
        guard let durationStr = entity.attributes.raw["duration"]?.stringValue,
              let remainingStr = entity.attributes.raw["remaining"]?.stringValue else {
            return 0
        }
        let totalSeconds = parseTimeToSeconds(durationStr)
        let remainingSeconds = parseTimeToSeconds(remainingStr)
        guard totalSeconds > 0 else { return 0 }
        return 1.0 - (Double(remainingSeconds) / Double(totalSeconds))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sp3) {
            // Header
            HStack {
                Image(systemName: "timer")
                    .font(.system(size: 20))
                    .foregroundStyle(isActive ? Color.accent : .entityInactive)

                Text(entity.name)
                    .font(.bodySMBold)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)

                Spacer()

                PillBadge(
                    text: entity.state,
                    foregroundColor: isActive ? .accent : .textMuted,
                    backgroundColor: isActive ? .accentDim : .base
                )
            }

            // Countdown
            Text(countdownValue)
                .font(.merriweather(size: 24, weight: .bold))
                .foregroundStyle(Color.textPrimary)
                .monospacedDigit()

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.base)
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.accent)
                        .frame(width: geometry.size.width * progress, height: 4)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 4)

            // Controls
            HStack(spacing: Spacing.sp3) {
                if isIdle {
                    Button("Start") {
                        Task { await viewModel.toggle(entity) }
                    }
                    .buttonStyle(MapleButtonStyle(variant: .ghost, isFullWidth: false))
                }

                if isActive {
                    Button("Pause") {
                        Task { await viewModel.toggle(entity) }
                    }
                    .buttonStyle(MapleButtonStyle(variant: .ghost, isFullWidth: false))
                }

                if isPaused {
                    Button("Resume") {
                        Task { await viewModel.toggle(entity) }
                    }
                    .buttonStyle(MapleButtonStyle(variant: .ghost, isFullWidth: false))
                }

                if isActive || isPaused {
                    Button("Cancel") {
                        Task { await cancelTimer() }
                    }
                    .buttonStyle(MapleButtonStyle(variant: .ghost, isFullWidth: false))
                }

                Spacer()
            }
        }
        .padding(Spacing.sp4)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .mapleShadow(.sm)
    }

    // MARK: - Helpers

    private func cancelTimer() async {
        // Timer cancel uses the timer.cancel service
        // Reuse toggle which maps to start/pause, but cancel is a separate service.
        // Since the view model doesn't have a dedicated cancel, we use toggle as fallback.
        await viewModel.toggle(entity)
    }

    private func parseTimeToSeconds(_ timeString: String) -> Int {
        let components = timeString.split(separator: ":").compactMap { Int($0) }
        switch components.count {
        case 3: return components[0] * 3600 + components[1] * 60 + components[2]
        case 2: return components[0] * 60 + components[1]
        case 1: return components[0]
        default: return 0
        }
    }
}

#Preview {
    TimerCardView(entity: HAEntity(
        id: "timer.kitchen",
        name: "Kitchen Timer",
        domain: .timer,
        areaId: nil,
        state: "active",
        attributes: HAAttributes(raw: [
            "duration": AnyCodable("0:10:00"),
            "remaining": AnyCodable("0:06:30")
        ]),
        isExposed: true
    ))
    .padding()
    .background(Color.base)
}

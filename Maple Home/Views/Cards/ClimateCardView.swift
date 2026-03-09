import SwiftUI

// MARK: - Climate Card View

struct ClimateCardView: View {
    let entity: HAEntity
    @Environment(DashboardViewModel.self) private var viewModel

    private var currentTemp: Double? { entity.attributes.currentTemperature }
    private var targetTemp: Double? { entity.attributes.targetTemperature }
    private var hvacModes: [String] { entity.attributes.hvacModes ?? [] }
    private var currentMode: String { entity.state }

    private var backgroundFill: Color {
        switch currentMode {
        case "cool", "fan_only":
            return .fillCool
        case "heat":
            return .fillHeat
        case "heat_cool", "auto":
            return .accentDim
        default:
            return Color.surface
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sp4) {
            // Header
            HStack {
                Text(entity.name)
                    .font(.bodySMBold)
                    .foregroundStyle(Color.textPrimary)

                Spacer()

                HvacModePill(mode: currentMode)
            }

            // Temperature display
            HStack(alignment: .firstTextBaseline, spacing: Spacing.sp4) {
                // Current temperature
                if let current = currentTemp {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(formatTemp(current))
                            .font(.merriweather(size: 32, weight: .bold))
                            .foregroundStyle(Color.textPrimary)

                        Text("Current")
                            .font(.caption)
                            .foregroundStyle(Color.textMuted)
                    }
                }

                Spacer()

                // Target temperature stepper
                if let target = targetTemp, currentMode != "off" {
                    HStack(spacing: Spacing.sp3) {
                        Button {
                            Task {
                                await viewModel.setTemperature(entity, temperature: target - 0.5)
                            }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(Color.textMuted)
                        }
                        .buttonStyle(.plain)

                        VStack(spacing: 2) {
                            Text(formatTemp(target))
                                .font(.merriweather(size: 20, weight: .bold))
                                .foregroundStyle(Color.textPrimary)

                            Text("Target")
                                .font(.caption)
                                .foregroundStyle(Color.textMuted)
                        }
                        .frame(minWidth: 56)

                        Button {
                            Task {
                                await viewModel.setTemperature(entity, temperature: target + 0.5)
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(Color.textMuted)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Mode picker
            if !hvacModes.isEmpty {
                HvacModePickerView(
                    modes: hvacModes,
                    activeMode: currentMode,
                    accentColor: entity.domain.accentColor
                ) { mode in
                    Task { await viewModel.setHvacMode(entity, mode: mode) }
                }
            }
        }
        .padding(Spacing.sp4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundFill)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .mapleShadow(.sm)
        .animation(.easeInOut(duration: 0.25), value: currentMode)
    }

    private func formatTemp(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(value))\u{00B0}"
        }
        return String(format: "%.1f\u{00B0}", value)
    }
}

#Preview {
    ClimateCardView(entity: HAEntity(
        id: "climate.living_room",
        name: "Living Room Thermostat",
        domain: .climate,
        areaId: nil,
        state: "heat",
        attributes: HAAttributes(raw: [
            "current_temperature": AnyCodable(21.5),
            "temperature": AnyCodable(23.0),
            "hvac_modes": AnyCodable(["off", "heat", "cool", "auto"])
        ]),
        isExposed: true
    ))
    .padding()
    .background(Color.base)
}

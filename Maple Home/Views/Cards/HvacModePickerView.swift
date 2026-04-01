import SwiftUI

// MARK: - HVAC Mode Picker View

struct HvacModePickerView: View {
    let modes: [String]
    let activeMode: String
    let accentColor: Color
    let onSelect: (String) -> Void

    var body: some View {
        HStack(spacing: Spacing.sp2) {
            ForEach(modes, id: \.self) { mode in
                Button {
                    onSelect(mode)
                } label: {
                    HStack(spacing: Spacing.sp1) {
                        Image(systemName: iconForMode(mode))
                            .font(.system(size: 12))

                        Text(labelForMode(mode))
                            .font(.lato(size: 11, weight: .bold))
                    }
                    .foregroundStyle(mode == activeMode ? modeAccent(mode) : Color.textMuted)
                    .padding(.horizontal, Spacing.sp3)
                    .padding(.vertical, Spacing.sp2)
                    .background(mode == activeMode ? modeFill(mode) : Color.base)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.pill))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Mode Helpers

    private func iconForMode(_ mode: String) -> String {
        switch mode {
        case "cool", "fan_only": return "snowflake"
        case "heat": return "flame"
        case "heat_cool", "auto": return "arrow.left.arrow.right"
        case "dry": return "drop.degreesign"
        case "off": return "power"
        default: return "thermometer.medium"
        }
    }

    private func labelForMode(_ mode: String) -> String {
        switch mode {
        case "heat_cool": return "Auto"
        case "fan_only": return "Fan"
        default: return mode.capitalized
        }
    }

    private func modeAccent(_ mode: String) -> Color {
        switch mode {
        case "cool", "fan_only": return .entityCool
        case "heat": return .entityHeat
        case "heat_cool", "auto": return .accent
        case "off": return .textMuted
        default: return accentColor
        }
    }

    private func modeFill(_ mode: String) -> Color {
        switch mode {
        case "cool", "fan_only": return .fillCool
        case "heat": return .fillHeat
        case "heat_cool", "auto": return .accentDim
        case "off": return .base
        default: return accentColor.opacity(0.08)
        }
    }
}

#Preview {
    VStack(spacing: Spacing.sp4) {
        HvacModePickerView(
            modes: ["off", "heat", "cool", "auto"],
            activeMode: "heat",
            accentColor: .entityHeat
        ) { mode in
            print("Selected: \(mode)")
        }

        HvacModePickerView(
            modes: ["off", "cool", "heat", "auto", "fan_only"],
            activeMode: "cool",
            accentColor: .entityCool
        ) { mode in
            print("Selected: \(mode)")
        }
    }
    .padding()
    .background(Color.surface)
}

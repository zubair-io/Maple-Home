import SwiftUI
import Combine

// MARK: - Slider Card View

struct SliderCardView: View {
    let entity: HAEntity
    @Environment(DashboardViewModel.self) private var viewModel

    @State private var sliderValue: Double = 0
    @State private var isDragging = false
    @State private var debounceTask: Task<Void, Never>?

    private var isLight: Bool { entity.domain == .light }

    private var brightnessPercent: Int {
        if let brightness = entity.attributes.brightness {
            return Int(round(Double(brightness) / 255.0 * 100))
        }
        return 0
    }

    private var displayPercent: Int {
        if isDragging {
            return isLight ? Int(round(sliderValue / 255.0 * 100)) : Int(round(sliderValue))
        }
        return isLight ? brightnessPercent : Int(round(Double(entity.state) ?? 0))
    }

    private var iconName: String {
        entity.isOn ? entity.domain.activeSymbol : entity.domain.inactiveSymbol
    }

    private var iconColor: Color {
        entity.isOn ? entity.domain.accentColor : .entityInactive
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sp3) {
            // Header row
            HStack(spacing: Spacing.sp3) {
                Image(systemName: iconName)
                    .font(.system(size: 24))
                    .foregroundStyle(iconColor)
                    .frame(width: 32, alignment: .center)

                VStack(alignment: .leading, spacing: 2) {
                    Text(entity.name)
                        .font(.bodySMBold)
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)

                    Text("\(displayPercent)%")
                        .font(.caption)
                        .foregroundStyle(Color.textMuted)
                }

                Spacer()
            }

            // Slider
            Slider(
                value: $sliderValue,
                in: isLight ? 0...255 : 0...100,
                step: isLight ? 1 : 1
            ) {
                EmptyView()
            } onEditingChanged: { editing in
                isDragging = editing
                if !editing {
                    debounceSend()
                }
            }
            .tint(entity.domain.accentColor)
        }
        .padding(.horizontal, Spacing.sp4)
        .padding(.vertical, Spacing.sp3)
        .background(entity.isOn ? entity.domain.fillColor : Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .mapleShadow(.sm)
        .onAppear { syncSlider() }
        .onChange(of: entity.state) { _, _ in
            if !isDragging { syncSlider() }
        }
        .onChange(of: entity.attributes.brightness) { _, _ in
            if !isDragging { syncSlider() }
        }
    }

    // MARK: - Helpers

    private func syncSlider() {
        if isLight {
            sliderValue = Double(entity.attributes.brightness ?? 0)
        } else {
            sliderValue = Double(entity.state) ?? 0
        }
    }

    private func debounceSend() {
        debounceTask?.cancel()
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            if isLight {
                await viewModel.setBrightness(entity, brightness: Int(sliderValue))
            } else {
                // For input_number / number entities, use the toggle (turn_on) as a proxy
                // or handle via a dedicated service if added later
                await viewModel.setBrightness(entity, brightness: Int(sliderValue))
            }
        }
    }
}

#Preview {
    SliderCardView(entity: HAEntity(
        id: "light.living_room",
        name: "Living Room",
        domain: .light,
        areaId: nil,
        state: "on",
        attributes: HAAttributes(raw: [
            "brightness": AnyCodable(180)
        ]),
        isExposed: true
    ))
    .padding()
    .background(Color.base)
}

import SwiftUI

// MARK: - Light Card View

struct LightCardView: View {
    let entity: HAEntity
    @Environment(DashboardViewModel.self) private var viewModel

    @State private var brightnessValue: Double = 0
    @State private var colorTempValue: Double = 0
    @State private var isDraggingBrightness = false
    @State private var isDraggingColorTemp = false
    @State private var debounceTask: Task<Void, Never>?

    private var isOn: Bool { entity.isOn }

    private var brightnessPercent: Int {
        if isDraggingBrightness {
            return Int(round(brightnessValue / 255.0 * 100))
        }
        if let brightness = entity.attributes.brightness {
            return Int(round(Double(brightness) / 255.0 * 100))
        }
        return 0
    }

    private var hasBrightness: Bool {
        entity.attributes.brightness != nil || isOn
    }

    private var hasColorTemp: Bool {
        entity.attributes.colorTempKelvin != nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sp3) {
            // Header row
            HStack(spacing: Spacing.sp3) {
                Image(systemName: isOn ? "lightbulb.fill" : "lightbulb")
                    .font(.system(size: 24))
                    .foregroundStyle(isOn ? Color.entityLight : .entityInactive)
                    .frame(width: 32, alignment: .center)

                VStack(alignment: .leading, spacing: 2) {
                    Text(entity.name)
                        .font(.bodySMBold)
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)

                    Text(isOn ? "\(brightnessPercent)%" : "Off")
                        .font(.caption)
                        .foregroundStyle(Color.textMuted)
                }

                Spacer()

                Toggle(isOn: Binding(
                    get: { isOn },
                    set: { _, _ in
                        Task { await viewModel.toggle(entity) }
                    }
                )) {
                    EmptyView()
                }
                .labelsHidden()
                .tint(Color.entityLight)
            }

            // Brightness slider
            if hasBrightness {
                VStack(alignment: .leading, spacing: Spacing.sp1) {
                    Text("Brightness")
                        .font(.caption)
                        .foregroundStyle(Color.textMuted)

                    Slider(
                        value: $brightnessValue,
                        in: 0...255,
                        step: 1
                    ) {
                        EmptyView()
                    } onEditingChanged: { editing in
                        isDraggingBrightness = editing
                        if !editing {
                            debounceBrightness()
                        }
                    }
                    .tint(Color.entityLight)
                }
            }

            // Color temperature slider
            if hasColorTemp {
                VStack(alignment: .leading, spacing: Spacing.sp1) {
                    Text("Color Temp")
                        .font(.caption)
                        .foregroundStyle(Color.textMuted)

                    Slider(
                        value: $colorTempValue,
                        in: 2000...6500,
                        step: 50
                    ) {
                        EmptyView()
                    } onEditingChanged: { editing in
                        isDraggingColorTemp = editing
                        if !editing {
                            debounceColorTemp()
                        }
                    }
                    .tint(
                        LinearGradient(
                            colors: [Color.orange, Color.white, Color.blue.opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                }
            }
        }
        .padding(Spacing.sp4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isOn ? Color.fillLight : Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .mapleShadow(.sm)
        .animation(.easeInOut(duration: 0.2), value: entity.state)
        .onAppear { syncValues() }
        .onChange(of: entity.attributes.brightness) { _, _ in
            if !isDraggingBrightness { syncValues() }
        }
        .onChange(of: entity.attributes.colorTempKelvin) { _, _ in
            if !isDraggingColorTemp { syncValues() }
        }
    }

    // MARK: - Helpers

    private func syncValues() {
        brightnessValue = Double(entity.attributes.brightness ?? 0)
        colorTempValue = Double(entity.attributes.colorTempKelvin ?? 4000)
    }

    private func debounceBrightness() {
        debounceTask?.cancel()
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await viewModel.setBrightness(entity, brightness: Int(brightnessValue))
        }
    }

    private func debounceColorTemp() {
        debounceTask?.cancel()
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await viewModel.setColorTemp(entity, kelvin: Int(colorTempValue))
        }
    }
}

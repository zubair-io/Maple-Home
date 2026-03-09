import SwiftUI

struct LightCardView: View {
    let entity: HAEntity
    @Environment(DashboardViewModel.self) private var vm

    @State private var brightnessValue: Double = 0
    @State private var colorTempValue: Double = 4000
    @State private var debounceTask: Task<Void, Never>?

    private var isOn: Bool { entity.isOn }
    private var areaName: String? { vm.areaName(for: entity) }

    private var brightnessPercent: Int {
        Int(round(brightnessValue / 255.0 * 100))
    }

    private var hasColorTemp: Bool {
        entity.attributes.colorTempKelvin != nil
    }

    var body: some View {
        MapleCard(category: .control, isActive: isOn) {
            MapleCardHeader(
                entityType: "light",
                name: entity.name,
                area: areaName,
                trailing: AnyView(
                    MapleToggle(isOn: .init(
                        get: { isOn },
                        set: { _ in Task { await vm.toggle(entity) } }
                    ))
                )
            )
            MapleBadge(text: isOn ? "ON · \(brightnessPercent)%" : "OFF", style: isOn ? .on : .off)
                .padding(.bottom, MapleSpacing.s4)

            if isOn {
                MapleSlider(
                    value: $brightnessValue,
                    range: 0...255,
                    label: "Brightness",
                    valueFormat: { "\(Int(round($0 / 255.0 * 100)))%" }
                )
                .onChange(of: brightnessValue) { _, _ in debounceBrightness() }
                .padding(.bottom, hasColorTemp ? MapleSpacing.s4 : 0)

                if hasColorTemp {
                    ColorTempSlider(kelvin: $colorTempValue)
                        .onChange(of: colorTempValue) { _, _ in debounceColorTemp() }
                }
            } else {
                MapleSlider(
                    value: .constant(0),
                    range: 0...255,
                    label: "Brightness",
                    valueFormat: { _ in "0%" }
                )
                .opacity(0.35)
                .disabled(true)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isOn)
        .onAppear { syncValues() }
        .onChange(of: entity.attributes.brightness) { _, _ in syncValues() }
        .onChange(of: entity.attributes.colorTempKelvin) { _, _ in syncValues() }
    }

    private func syncValues() {
        brightnessValue = Double(entity.attributes.brightness ?? 0)
        colorTempValue = Double(entity.attributes.colorTempKelvin ?? 4000)
    }

    private func debounceBrightness() {
        debounceTask?.cancel()
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await vm.setBrightness(entity, brightness: Int(brightnessValue))
        }
    }

    private func debounceColorTemp() {
        debounceTask?.cancel()
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await vm.setColorTemp(entity, kelvin: Int(colorTempValue))
        }
    }
}

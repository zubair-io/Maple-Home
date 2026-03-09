import SwiftUI

struct ClimateCardView: View {
    let entity: HAEntity
    @Environment(DashboardViewModel.self) private var vm

    @State private var targetTemp: Double = 20
    @State private var selectedHvacMode: String = ""
    @State private var debounceTask: Task<Void, Never>?

    private var areaName: String? { vm.areaName(for: entity) }
    private var currentTemp: Double { entity.attributes.currentTemperature ?? 0 }
    private var hvacModes: [String] { entity.attributes.hvacModes ?? ["off", "heat", "cool", "auto"] }

    private var arcColor: Color {
        switch entity.state {
        case "heat": return .mapleAccent
        case "cool": return .mapleInfo
        case "auto", "heat_cool": return .mapleSuccess
        default: return .mapleT3
        }
    }

    var body: some View {
        MapleCard(category: .control) {
            MapleCardHeader(
                entityType: "climate",
                name: entity.name,
                area: areaName,
                badgeStyle: entity.state == "off" ? .off : .info,
                badgeText: entity.state.uppercased()
            )

            HStack(spacing: MapleSpacing.s6) {
                MapleArc(
                    value: currentTemp > 0 ? (currentTemp - 16) / 14 : 0,
                    label: "\(Int(currentTemp))°",
                    sublabel: "current",
                    size: 96,
                    color: arcColor
                )

                VStack(alignment: .leading, spacing: MapleSpacing.s2) {
                    Text("TARGET TEMP")
                        .font(MapleFont.label)
                        .kerning(1.0)
                        .foregroundColor(.mapleT3)
                    MapleNumberStepper(
                        value: $targetTemp,
                        step: 0.5,
                        range: 16...30,
                        format: { String(format: "%.1f°C", $0) }
                    )
                    .onChange(of: targetTemp) { _, newVal in debounceTemp(newVal) }
                }
            }
            .padding(.vertical, MapleSpacing.s2)

            VStack(alignment: .leading, spacing: MapleSpacing.s2) {
                Text("HVAC MODE")
                    .font(MapleFont.label)
                    .kerning(1.0)
                    .foregroundColor(.mapleT3)
                ModePills(options: hvacModes, selected: $selectedHvacMode, accentStyle: true)
                    .onChange(of: selectedHvacMode) { _, newMode in
                        Task { await vm.setHvacMode(entity, mode: newMode) }
                    }
            }
            .padding(.vertical, MapleSpacing.s3)
        }
        .onAppear { syncValues() }
        .onChange(of: entity.attributes.targetTemperature) { _, _ in syncValues() }
        .onChange(of: entity.state) { _, _ in syncValues() }
    }

    private func syncValues() {
        targetTemp = entity.attributes.targetTemperature ?? 20
        selectedHvacMode = entity.state
    }

    private func debounceTemp(_ temp: Double) {
        debounceTask?.cancel()
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }
            await vm.setTemperature(entity, temperature: temp)
        }
    }
}

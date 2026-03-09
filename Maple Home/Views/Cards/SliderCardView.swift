import SwiftUI

struct SliderCardView: View {
    let entity: HAEntity
    @Environment(DashboardViewModel.self) private var vm

    @State private var value: Double = 0
    @State private var debounceTask: Task<Void, Never>?

    private var unit: String { entity.attributes.unitOfMeasurement ?? "" }
    private var step: Double { entity.attributes.raw["step"]?.doubleValue ?? 1 }
    private var minVal: Double { entity.attributes.raw["min"]?.doubleValue ?? 0 }
    private var maxVal: Double { entity.attributes.raw["max"]?.doubleValue ?? 100 }

    var body: some View {
        MapleCard(category: entity.domain.category) {
            MapleCardHeader(
                entityType: entity.domain.rawValue,
                name: entity.name,
                area: vm.areaName(for: entity)
            )

            MapleNumberStepper(
                value: $value,
                step: step,
                range: minVal...maxVal,
                format: {
                    if step < 1 { return String(format: "%.1f%@", $0, unit) }
                    return "\(Int($0))\(unit)"
                }
            )
            .onChange(of: value) { _, _ in debounceValue() }
            .padding(.bottom, MapleSpacing.s4)

            MapleSlider(
                value: $value,
                range: minVal...maxVal,
                valueFormat: { _ in "" },
                accentColor: .catInput
            )
            .onChange(of: value) { _, _ in debounceValue() }
        }
        .onAppear { value = Double(entity.state) ?? 0 }
        .onChange(of: entity.state) { _, newVal in
            value = Double(newVal) ?? value
        }
    }

    private func debounceValue() {
        debounceTask?.cancel()
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }
            let domain = entity.domain.serviceDomain
            try? await vm.client.callService(
                domain: domain,
                service: "set_value",
                serviceData: ["entity_id": entity.id, "value": value]
            )
        }
    }
}

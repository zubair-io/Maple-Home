import SwiftUI

struct SensorTileView: View {
    let entity: HAEntity
    @Environment(DashboardViewModel.self) private var vm

    private var areaName: String? { vm.areaName(for: entity) }

    private var displayValue: String {
        if let doubleVal = Double(entity.state) {
            if doubleVal.truncatingRemainder(dividingBy: 1) == 0 {
                return "\(Int(doubleVal))"
            }
            return String(format: "%.1f", doubleVal)
        }
        return entity.state.capitalized
    }

    private var unit: String { entity.attributes.unitOfMeasurement ?? "" }

    var body: some View {
        MapleCard(category: .sensor) {
            MapleCardHeader(
                entityType: entity.domain.rawValue,
                name: entity.name,
                area: areaName
            )

            if !unit.isEmpty {
                SensorValueDisplay(value: displayValue, unit: unit, valueSize: 36)
            } else {
                Text(displayValue)
                    .font(MapleFont.displayBold(24))
                    .foregroundColor(.mapleT1)
            }
        }
    }
}

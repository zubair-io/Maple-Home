import SwiftUI

// MARK: - Sensor Tile View

struct SensorTileView: View {
    let entity: HAEntity

    private var displayValue: String {
        let state = entity.state
        // Try to format numeric values nicely
        if let doubleVal = Double(state) {
            if doubleVal.truncatingRemainder(dividingBy: 1) == 0 {
                return "\(Int(doubleVal))"
            }
            return String(format: "%.1f", doubleVal)
        }
        return state.capitalized
    }

    private var unit: String? {
        entity.attributes.unitOfMeasurement
    }

    private var iconName: String {
        sensorIcon(for: entity)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sp2) {
            // Icon
            Image(systemName: iconName)
                .font(.system(size: 20))
                .foregroundStyle(entity.domain.accentColor)

            Spacer()

            // Value
            Text(displayValue)
                .font(.merriweather(size: 28, weight: .bold))
                .foregroundStyle(Color.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            // Unit
            if let unit {
                Text(unit)
                    .font(.caption)
                    .foregroundStyle(Color.textMuted)
            }

            // Label
            Text(entity.name)
                .font(.caption)
                .foregroundStyle(Color.textMuted)
                .lineLimit(2)
        }
        .padding(Spacing.sp4)
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .mapleShadow(.sm)
    }

    // MARK: - Sensor Icon Helper

    private func sensorIcon(for entity: HAEntity) -> String {
        if let deviceClass = entity.attributes.deviceClass {
            switch deviceClass {
            case "temperature": return "thermometer.medium"
            case "humidity": return "humidity"
            case "pressure": return "gauge.with.dots.needle.bottom.50percent"
            case "battery": return "battery.75percent"
            case "power", "energy": return "bolt.fill"
            case "illuminance": return "sun.max"
            case "motion", "occupancy": return "figure.walk"
            case "door": return "door.left.hand.closed"
            case "window": return "window.vertical.closed"
            case "moisture": return "drop"
            case "gas", "carbon_dioxide", "carbon_monoxide": return "aqi.medium"
            default: break
            }
        }
        return entity.domain.inactiveSymbol
    }
}

#Preview {
    HStack(spacing: Spacing.sp3) {
        SensorTileView(entity: HAEntity(
            id: "sensor.temperature",
            name: "Temperature",
            domain: .sensor,
            areaId: nil,
            state: "22.5",
            attributes: HAAttributes(raw: [
                "unit_of_measurement": AnyCodable("\u{00B0}C"),
                "device_class": AnyCodable("temperature")
            ]),
            isExposed: true
        ))

        SensorTileView(entity: HAEntity(
            id: "sensor.humidity",
            name: "Humidity",
            domain: .sensor,
            areaId: nil,
            state: "45",
            attributes: HAAttributes(raw: [
                "unit_of_measurement": AnyCodable("%"),
                "device_class": AnyCodable("humidity")
            ]),
            isExposed: true
        ))
    }
    .padding()
    .background(Color.base)
}

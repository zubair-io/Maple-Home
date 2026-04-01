import SwiftUI

struct RoomHumidityCard: View {
    let room: Room

    var body: some View {
        EntityCardWrapper(railColor: .mapleInfo) {
            Text("HUMIDITY")
                .font(MapleFont.label)
                .kerning(1.4)
                .foregroundColor(.mapleT4)
                .padding(.bottom, MapleSpacing.s2)

            SensorValueDisplay(
                value: room.humidity.map { "\(Int($0))" } ?? "–",
                unit: "%",
                valueSize: 42
            )
        }
    }
}

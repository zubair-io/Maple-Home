import SwiftUI

struct RoomLightingCard: View {
    let room: Room
    @Environment(DashboardViewModel.self) private var vm

    private var lightEntities: [HAEntity] {
        room.lightEntityIds.compactMap { vm.entities[$0] }
    }

    private var onLights: [HAEntity] {
        lightEntities.filter(\.isOn)
    }

    private var allOn: Bool { !onLights.isEmpty }

    private var avgBrightness: Double {
        guard !onLights.isEmpty else { return 0 }
        let values = onLights.compactMap { $0.attributes.brightness }
        guard !values.isEmpty else { return 50 }
        return Double(values.reduce(0, +)) / Double(values.count) / 255.0 * 100.0
    }

    private var avgColorTemp: Double {
        let temps = onLights.compactMap { $0.attributes.colorTempKelvin }
        guard !temps.isEmpty else { return 4000 }
        return Double(temps.reduce(0, +)) / Double(temps.count)
    }

    private var supportsColorTemp: Bool {
        lightEntities.contains { entity in
            entity.attributes.supportedColorModes?.contains(where: { $0.contains("color_temp") }) ?? false
        }
    }

    @State private var brightness: Double = 50
    @State private var colorTemp: Double = 4000
    @State private var isOn: Bool = false

    var body: some View {
        EntityCardWrapper(railColor: .entityLight) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("LIGHTING")
                        .font(MapleFont.label)
                        .kerning(1.4)
                        .foregroundColor(.mapleT4)
                    Text("\(room.lightsOnCount) of \(room.totalLightCount) lights on")
                        .font(MapleFont.bodyRegular(12))
                        .foregroundColor(.mapleT2)
                }

                Spacer()

                MapleBadge(
                    text: allOn ? "ON" : "OFF",
                    style: allOn ? .on : .off
                )

                MapleToggle(isOn: $isOn) { newValue in
                    Task { await toggleAllLights(newValue) }
                }
            }

            // Brightness slider
            if allOn {
                MapleSlider(
                    value: $brightness,
                    label: "Brightness",
                    accentColor: .entityLight
                )
                .padding(.top, MapleSpacing.s3)
                .onChange(of: brightness) { _, newValue in
                    Task { await setAllBrightness(newValue) }
                }

                // Color temp slider
                if supportsColorTemp {
                    ColorTempSlider(kelvin: $colorTemp)
                        .padding(.top, MapleSpacing.s3)
                        .onChange(of: colorTemp) { _, newValue in
                            Task { await setAllColorTemp(newValue) }
                        }
                }

                // Color swatches
                colorSwatches
                    .padding(.top, MapleSpacing.s3)
            }
        }
        .onAppear { syncState() }
        .onChange(of: vm.entities) { _, _ in syncState() }
    }

    private var colorSwatches: some View {
        HStack(spacing: MapleSpacing.s2) {
            ForEach(presetColors, id: \.self) { color in
                Circle()
                    .fill(color)
                    .frame(width: 22, height: 22)
                    .overlay(Circle().stroke(Color.mapleBorder, lineWidth: 1))
            }
            Spacer()
        }
    }

    private var presetColors: [Color] {
        [
            Color(hex: "#FFD27F"),
            Color(hex: "#FFEBC2"),
            Color(hex: "#FFFAF0"),
            Color(hex: "#E8F0FF"),
            Color(hex: "#C8E8FF"),
            Color(hex: "#FF8C66"),
        ]
    }

    private func syncState() {
        isOn = allOn
        if allOn {
            brightness = avgBrightness
            colorTemp = avgColorTemp
        }
    }

    private func toggleAllLights(_ on: Bool) async {
        for entity in lightEntities {
            if on && !entity.isOn {
                await vm.toggle(entity)
            } else if !on && entity.isOn {
                await vm.toggle(entity)
            }
        }
    }

    private func setAllBrightness(_ pct: Double) async {
        let raw = Int(pct / 100.0 * 255.0)
        for entity in onLights {
            await vm.setBrightness(entity, brightness: raw)
        }
    }

    private func setAllColorTemp(_ kelvin: Double) async {
        for entity in onLights {
            await vm.setColorTemp(entity, kelvin: Int(kelvin))
        }
    }
}

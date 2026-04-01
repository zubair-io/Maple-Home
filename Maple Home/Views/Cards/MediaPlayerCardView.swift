import SwiftUI

struct MediaPlayerCardView: View {
    let entity: HAEntity
    @Environment(DashboardViewModel.self) private var vm

    @State private var volume: Double = 50
    @State private var debounceTask: Task<Void, Never>?

    private var areaName: String? { vm.areaName(for: entity) }
    private var isPlaying: Bool { entity.state == "playing" }
    private var title: String { entity.attributes.mediaTitle ?? "No media" }
    private var artist: String { entity.attributes.mediaArtist ?? "" }

    var body: some View {
        MapleCard(category: .control) {
            MapleCardHeader(
                entityType: "media_player",
                name: entity.name,
                area: areaName,
                badgeStyle: isPlaying ? .on : .off,
                badgeText: entity.state.uppercased()
            )

            // Album art placeholder
            ZStack {
                RoundedRectangle(cornerRadius: MapleRadius.md, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#1a1a2e"), Color(hex: "#16213e"), Color(hex: "#0f3460")],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 120)
                Image(systemName: "music.note")
                    .font(.system(size: 32, weight: .ultraLight))
                    .foregroundColor(.white.opacity(0.15))
            }
            .padding(.bottom, MapleSpacing.s3)

            // Track info
            Text(title)
                .font(MapleFont.displayBold(15))
                .foregroundColor(.mapleT1)
            if !artist.isEmpty {
                Text(artist)
                    .font(MapleFont.bodyLight(12))
                    .foregroundColor(.mapleT3)
                    .padding(.top, 2)
            }

            // Controls
            HStack(spacing: MapleSpacing.s2) {
                MapleIconButton(systemImage: "backward.end.fill")
                MapleIconButton(
                    systemImage: isPlaying ? "pause.fill" : "play.fill",
                    accent: true,
                    action: { Task { await vm.mediaPlayPause(entity) } }
                )
                MapleIconButton(systemImage: "forward.end.fill")
                Spacer()
            }
            .padding(.vertical, MapleSpacing.s3)

            // Volume
            HStack(spacing: MapleSpacing.s2) {
                Image(systemName: "speaker.fill")
                    .font(.system(size: 12)).foregroundColor(.mapleT3)
                MapleSlider(
                    value: $volume,
                    range: 0...100,
                    valueFormat: { "\(Int($0))%" }
                )
                .onChange(of: volume) { _, _ in debounceVolume() }
                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: 12)).foregroundColor(.mapleT3)
            }
        }
        .onAppear { syncValues() }
        .onChange(of: entity.attributes.volumeLevel) { _, _ in syncValues() }
    }

    private func syncValues() {
        volume = (entity.attributes.volumeLevel ?? 0.5) * 100
    }

    private func debounceVolume() {
        debounceTask?.cancel()
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await vm.setVolume(entity, level: volume / 100)
        }
    }
}

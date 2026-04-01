import SwiftUI

struct RoomMediaCard: View {
    let room: Room
    @Environment(DashboardViewModel.self) private var vm

    private var mediaEntities: [HAEntity] {
        room.deviceEntityIds
            .compactMap { vm.entities[$0] }
            .filter { $0.domain == .mediaPlayer }
    }

    private var activeMedia: HAEntity? {
        mediaEntities.first { $0.state == "playing" || $0.state == "paused" }
            ?? mediaEntities.first
    }

    @State private var volume: Double = 50

    var body: some View {
        if let entity = activeMedia {
            EntityCardWrapper(railColor: .entityMedia) {
                Text("MEDIA")
                    .font(MapleFont.label)
                    .kerning(1.4)
                    .foregroundColor(.mapleT4)

                // Album art placeholder
                RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.entityMedia.opacity(0.3), Color.entityMedia.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 80)
                    .overlay(
                        Image(systemName: "music.note")
                            .font(.system(size: 28, weight: .light))
                            .foregroundColor(.entityMedia.opacity(0.5))
                    )
                    .padding(.top, MapleSpacing.s2)

                // Track info
                VStack(alignment: .leading, spacing: 2) {
                    Text(entity.attributes.mediaTitle ?? "No media")
                        .font(MapleFont.bodyBold(13))
                        .foregroundColor(.mapleT1)
                        .lineLimit(1)
                    Text(entity.attributes.mediaArtist ?? "")
                        .font(MapleFont.bodyLight(11))
                        .foregroundColor(.mapleT3)
                        .lineLimit(1)
                }
                .padding(.top, MapleSpacing.s2)

                // Transport controls
                HStack(spacing: MapleSpacing.s4) {
                    Spacer()
                    MapleIconButton(systemImage: "backward.fill") {
                        Task {
                            try? await vm.client.callService(
                                domain: "media_player",
                                service: "media_previous_track",
                                serviceData: ["entity_id": entity.id]
                            )
                        }
                    }
                    MapleIconButton(
                        systemImage: entity.state == "playing" ? "pause.fill" : "play.fill",
                        size: 40,
                        accent: true
                    ) {
                        Task { await vm.mediaPlayPause(entity) }
                    }
                    MapleIconButton(systemImage: "forward.fill") {
                        Task {
                            try? await vm.client.callService(
                                domain: "media_player",
                                service: "media_next_track",
                                serviceData: ["entity_id": entity.id]
                            )
                        }
                    }
                    Spacer()
                }
                .padding(.top, MapleSpacing.s3)

                // Volume
                MapleSlider(
                    value: $volume,
                    label: "Volume",
                    accentColor: .entityMedia
                )
                .padding(.top, MapleSpacing.s3)
                .onChange(of: volume) { _, newValue in
                    Task { await vm.setVolume(entity, level: newValue / 100.0) }
                }
            }
            .onAppear {
                volume = (activeMedia?.attributes.volumeLevel ?? 0.5) * 100.0
            }
        }
    }
}

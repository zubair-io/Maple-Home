import SwiftUI

// MARK: - Media Player Card View

struct MediaPlayerCardView: View {
    let entity: HAEntity
    @Environment(DashboardViewModel.self) private var viewModel

    @State private var volumeValue: Double = 0
    @State private var isDraggingVolume = false
    @State private var debounceTask: Task<Void, Never>?

    private var isPlaying: Bool { entity.state == "playing" }
    private var title: String? { entity.attributes.mediaTitle }
    private var artist: String? { entity.attributes.mediaArtist }
    private var volume: Double { entity.attributes.volumeLevel ?? 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sp4) {
            // Media info row
            HStack(spacing: Spacing.sp3) {
                // Album art placeholder
                RoundedRectangle(cornerRadius: Radius.sm)
                    .fill(Color.entityMedia.opacity(0.15))
                    .frame(width: 48, height: 48)
                    .overlay {
                        Image(systemName: "music.note")
                            .font(.system(size: 20))
                            .foregroundStyle(Color.entityMedia)
                    }

                // Title & artist
                VStack(alignment: .leading, spacing: 2) {
                    Text(title ?? entity.name)
                        .font(.bodySMBold)
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)

                    Text(artist ?? entity.state.capitalized)
                        .font(.caption)
                        .foregroundStyle(Color.textMuted)
                        .lineLimit(1)
                }

                Spacer()
            }

            // Transport controls
            HStack(spacing: Spacing.sp5) {
                Spacer()

                // Previous
                Button {
                    // Previous track — could add a dedicated method
                } label: {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.textPrimary)
                }
                .buttonStyle(.plain)

                // Play/Pause
                Button {
                    Task { await viewModel.mediaPlayPause(entity) }
                } label: {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(Color.textPrimary)
                }
                .buttonStyle(.plain)

                // Next
                Button {
                    // Next track — could add a dedicated method
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.textPrimary)
                }
                .buttonStyle(.plain)

                Spacer()
            }

            // Volume slider
            HStack(spacing: Spacing.sp3) {
                Image(systemName: "speaker.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.textMuted)

                Slider(
                    value: $volumeValue,
                    in: 0...1,
                    step: 0.01
                ) {
                    EmptyView()
                } onEditingChanged: { editing in
                    isDraggingVolume = editing
                    if !editing {
                        debounceVolume()
                    }
                }
                .tint(Color.entityMedia)

                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.textMuted)
            }
        }
        .padding(Spacing.sp4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isPlaying ? Color.fillMedia : Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .mapleShadow(.sm)
        .onAppear { volumeValue = volume }
        .onChange(of: entity.attributes.volumeLevel) { _, newValue in
            if !isDraggingVolume {
                volumeValue = newValue ?? 0
            }
        }
    }

    private func debounceVolume() {
        debounceTask?.cancel()
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await viewModel.setVolume(entity, level: volumeValue)
        }
    }
}

#Preview {
    MediaPlayerCardView(entity: HAEntity(
        id: "media_player.living_room",
        name: "Living Room Speaker",
        domain: .mediaPlayer,
        areaId: nil,
        state: "playing",
        attributes: HAAttributes(raw: [
            "media_title": AnyCodable("Bohemian Rhapsody"),
            "media_artist": AnyCodable("Queen"),
            "volume_level": AnyCodable(0.45)
        ]),
        isExposed: true
    ))
    .padding()
    .background(Color.base)
}

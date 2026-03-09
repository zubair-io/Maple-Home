import SwiftUI

struct CoverCardView: View {
    let entity: HAEntity
    @Environment(DashboardViewModel.self) private var vm

    @State private var position: Double = 0
    @State private var debounceTask: Task<Void, Never>?

    private var areaName: String? { vm.areaName(for: entity) }

    private var badgeText: String {
        position > 95 ? "OPEN" : position < 5 ? "CLOSED" : "PARTIAL"
    }
    private var badgeStyle: MapleBadgeStyle {
        position > 95 ? .ok : position < 5 ? .off : .info
    }

    var body: some View {
        MapleCard(category: .control) {
            MapleCardHeader(
                entityType: "cover",
                name: entity.name,
                area: areaName,
                badgeStyle: badgeStyle,
                badgeText: badgeText
            )

            CoverVisual(position: position)
                .padding(.vertical, MapleSpacing.s3)

            MapleSlider(
                value: $position,
                range: 0...100,
                label: "Position",
                valueFormat: { "\(Int($0))%" }
            )
            .onChange(of: position) { _, _ in debouncePosition() }
            .padding(.bottom, MapleSpacing.s4)

            HStack(spacing: MapleSpacing.s2) {
                Button {
                    Task { await vm.openCover(entity) }
                } label: {
                    Label("Open", systemImage: "chevron.up")
                        .font(MapleFont.bodyBold(12))
                        .foregroundColor(.mapleT2)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.mapleSurface2)
                        .cornerRadius(MapleRadius.sm)
                }

                Button {
                    Task { await vm.stopCover(entity) }
                } label: {
                    Label("Stop", systemImage: "minus")
                        .font(MapleFont.bodyBold(12))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.mapleT1)
                        .cornerRadius(MapleRadius.sm)
                }

                Button {
                    Task { await vm.closeCover(entity) }
                } label: {
                    Label("Close", systemImage: "chevron.down")
                        .font(MapleFont.bodyBold(12))
                        .foregroundColor(.mapleT2)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.mapleSurface2)
                        .cornerRadius(MapleRadius.sm)
                }
            }
        }
        .onAppear { position = Double(entity.attributes.currentPosition ?? 0) }
        .onChange(of: entity.attributes.currentPosition) { _, newVal in
            position = Double(newVal ?? 0)
        }
    }

    private func debouncePosition() {
        debounceTask?.cancel()
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }
            await vm.setCoverPosition(entity, position: Int(position))
        }
    }
}

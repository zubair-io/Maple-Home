import SwiftUI

struct AreaSectionView: View {
    @Environment(DashboardViewModel.self) private var vm
    let section: DashboardSection

    // MARK: - Adaptive Columns

    private var columns: [GridItem] {
        #if os(macOS)
        return Array(repeating: GridItem(.flexible(), spacing: Spacing.sp3), count: 4)
        #else
        let baseColumns: [GridItem] = {
            if UIDevice.current.userInterfaceIdiom == .pad {
                return Array(repeating: GridItem(.flexible(), spacing: Spacing.sp3), count: 3)
            } else {
                return Array(repeating: GridItem(.flexible(), spacing: Spacing.sp3), count: 2)
            }
        }()
        return baseColumns
        #endif
    }

    private var fullWidthColumns: [GridItem] {
        [GridItem(.flexible())]
    }

    /// Whether an entity should span full width (climate, media_player).
    private func isFullWidth(_ entity: HAEntity) -> Bool {
        entity.domain == .climate || entity.domain == .mediaPlayer
    }

    // MARK: - Body

    var body: some View {
        Section {
            if !section.isCollapsed {
                let standardEntities = section.entities.filter { !isFullWidth($0) }
                let wideEntities = section.entities.filter { isFullWidth($0) }

                // Standard 2/3/4-column grid
                if !standardEntities.isEmpty {
                    LazyVGrid(columns: columns, spacing: Spacing.sp3) {
                        ForEach(standardEntities) { entity in
                            EntityCardView(entity: entity)
                        }
                    }
                    .padding(.horizontal, Spacing.sp4)
                }

                // Full-width cards for climate / media player
                if !wideEntities.isEmpty {
                    LazyVGrid(columns: fullWidthColumns, spacing: Spacing.sp3) {
                        ForEach(wideEntities) { entity in
                            EntityCardView(entity: entity)
                        }
                    }
                    .padding(.horizontal, Spacing.sp4)
                }
            }
        } header: {
            sectionHeader
        }
    }

    // MARK: - Section Header

    private var sectionHeader: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                vm.setCollapsed(!section.isCollapsed, for: section.id)
            }
        } label: {
            HStack(spacing: Spacing.sp2) {
                Text(section.areaName.uppercased())
                    .font(.label)
                    .tracking(1.2)
                    .foregroundStyle(Color.textMuted)

                Text("\(section.entityCount)")
                    .font(.lato(size: 10, weight: .bold))
                    .foregroundStyle(Color.textFaint)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.border)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.pill))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.textFaint)
                    .rotationEffect(.degrees(section.isCollapsed ? 0 : 90))
                    .animation(.easeInOut(duration: 0.25), value: section.isCollapsed)
            }
            .padding(.horizontal, Spacing.sp4)
            .padding(.vertical, Spacing.sp3)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let section = DashboardSection(
        id: "living_room",
        areaName: "Living Room",
        entities: [],
        isCollapsed: false
    )
    AreaSectionView(section: section)
        .background(Color.base)
}

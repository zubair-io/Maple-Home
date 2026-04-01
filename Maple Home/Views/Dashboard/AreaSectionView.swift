import SwiftUI

struct AreaSectionView: View {
    @Environment(DashboardViewModel.self) private var vm
    let section: DashboardSection

    // MARK: - Body

    var body: some View {
        Section {
            if !section.isCollapsed {
                let standardEntities = section.entities.filter { !$0.domain.controlStyle.isFullWidth }
                let fullWidthEntities = section.entities.filter { $0.domain.controlStyle.isFullWidth }

                // Standard-width cards in grid
                if !standardEntities.isEmpty {
                    LazyVGrid(columns: columns, spacing: MapleSpacing.s3) {
                        ForEach(standardEntities) { entity in
                            EntityCardView(entity: entity)
                        }
                    }
                    .padding(.horizontal, MapleSpacing.s6)
                }

                // Full-width cards
                if !fullWidthEntities.isEmpty {
                    VStack(spacing: MapleSpacing.s3) {
                        ForEach(fullWidthEntities) { entity in
                            EntityCardView(entity: entity)
                        }
                    }
                    .padding(.horizontal, MapleSpacing.s6)
                }
            }
        } header: {
            sectionHeader
        }
    }

    // MARK: - Adaptive Columns

    private var columns: [GridItem] {
        #if os(macOS)
        return Array(repeating: GridItem(.flexible(), spacing: MapleSpacing.s3), count: 4)
        #else
        if UIDevice.current.userInterfaceIdiom == .pad {
            return Array(repeating: GridItem(.flexible(), spacing: MapleSpacing.s3), count: 3)
        } else {
            return Array(repeating: GridItem(.flexible(), spacing: MapleSpacing.s3), count: 2)
        }
        #endif
    }

    // MARK: - Room Section Header

    private var sectionHeader: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                vm.setCollapsed(!section.isCollapsed, for: section.id)
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .lastTextBaseline, spacing: MapleSpacing.s4) {
                    Text(section.areaName)
                        .font(MapleFont.displayBold(22))
                        .foregroundStyle(Color.mapleT1)

                    Text("\(section.entityCount)")
                        .font(MapleFont.bodyLight(12))
                        .foregroundColor(.mapleT3)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.mapleT4)
                        .rotationEffect(.degrees(section.isCollapsed ? 0 : 90))
                        .animation(.easeInOut(duration: 0.25), value: section.isCollapsed)
                }
                .padding(.bottom, MapleSpacing.s3)

                // Accent underline
                Rectangle()
                    .fill(Color.mapleBorderStrong)
                    .frame(height: 1)
            }
            .padding(.horizontal, MapleSpacing.s6)
            .padding(.top, MapleSpacing.s7)
            .padding(.bottom, MapleSpacing.s3)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

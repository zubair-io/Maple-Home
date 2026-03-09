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

    private var wideColumns: [GridItem] {
        #if os(macOS)
        return Array(repeating: GridItem(.flexible(), spacing: Spacing.sp3), count: 2)
        #else
        if UIDevice.current.userInterfaceIdiom == .pad {
            return Array(repeating: GridItem(.flexible(), spacing: Spacing.sp3), count: 2)
        } else {
            return [GridItem(.flexible())]
        }
        #endif
    }

    // MARK: - Body

    var body: some View {
        Section {
            if !section.isCollapsed {
                // Section gradient rail
                sectionRail

                let halfEntities = section.entities.filter { !$0.domain.controlStyle.isFullWidth }
                let fullEntities = section.entities.filter { $0.domain.controlStyle.isFullWidth }

                // Standard-width grid (toggles, sensors, actions, selects, sliders, timers)
                if !halfEntities.isEmpty {
                    LazyVGrid(columns: columns, spacing: Spacing.sp3) {
                        ForEach(halfEntities) { entity in
                            EntityCardView(entity: entity)
                                .frame(height: CardSize.standard)
                        }
                    }
                    .padding(.horizontal, Spacing.sp4)
                }

                // Full-width cards (climate, media, cover, light)
                if !fullEntities.isEmpty {
                    LazyVGrid(columns: wideColumns, spacing: Spacing.sp3) {
                        ForEach(fullEntities) { entity in
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

    // MARK: - Section Header (numbered, styled like mockup)

    private var sectionHeader: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                vm.setCollapsed(!section.isCollapsed, for: section.id)
            }
        } label: {
            VStack(alignment: .leading, spacing: Spacing.sp3) {
                HStack(alignment: .firstTextBaseline, spacing: Spacing.sp3) {
                    // Section number
                    Text(section.category.sectionNumber)
                        .font(.merriweather(size: 11, weight: .bold))
                        .tracking(0.6)
                        .foregroundStyle(section.category.color)

                    // Section title
                    Text(section.category.title)
                        .font(.merriweather(size: 24, weight: .black))
                        .foregroundStyle(Color.textPrimary)

                    Spacer()

                    // Collapse chevron
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.textFaint)
                        .rotationEffect(.degrees(section.isCollapsed ? 0 : 90))
                        .animation(.easeInOut(duration: 0.25), value: section.isCollapsed)
                }

                // Subtitle (entity types)
                Text(section.category.subtitle)
                    .font(.lato(size: 12, weight: .light))
                    .foregroundStyle(Color.textMuted)

                // Bottom border
                Divider()
            }
            .padding(.horizontal, Spacing.sp4)
            .padding(.top, Spacing.sp6)
            .padding(.bottom, Spacing.sp2)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Gradient Rail

    private var sectionRail: some View {
        RoundedRectangle(cornerRadius: 1.5)
            .fill(
                LinearGradient(
                    colors: [section.category.color, section.category.color.opacity(0.08)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 3)
            .padding(.horizontal, Spacing.sp4)
            .padding(.bottom, Spacing.sp6)
    }
}

// MARK: - Card Size Constants

enum CardSize {
    /// Standard height for half-width cards
    static let standard: CGFloat = 160
}

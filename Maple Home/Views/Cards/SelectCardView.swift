import SwiftUI

struct SelectCardView: View {
    let entity: HAEntity
    @Environment(DashboardViewModel.self) private var vm

    @State private var selected: String = ""

    private var options: [String] { entity.attributes.options ?? [] }

    var body: some View {
        MapleCard(category: entity.domain.category) {
            MapleCardHeader(
                entityType: entity.domain.rawValue,
                name: entity.name,
                area: vm.areaName(for: entity)
            )

            if options.count <= 5 {
                ModePills(options: options, selected: $selected)
                    .onChange(of: selected) { _, newVal in
                        Task { await vm.selectOption(entity, option: newVal) }
                    }
            } else {
                Picker("", selection: $selected) {
                    ForEach(options, id: \.self) { Text($0).tag($0) }
                }
                .pickerStyle(.menu)
                .font(MapleFont.bodyRegular(14))
                .foregroundColor(.mapleT1)
                .padding(.horizontal, MapleSpacing.s3)
                .padding(.vertical, MapleSpacing.s2)
                .background(Color.mapleSurface2)
                .cornerRadius(MapleRadius.sm)
                .onChange(of: selected) { _, newVal in
                    Task { await vm.selectOption(entity, option: newVal) }
                }
            }
        }
        .onAppear { selected = entity.state }
        .onChange(of: entity.state) { _, newVal in selected = newVal }
    }
}

import SwiftUI

// MARK: - Select Card View

struct SelectCardView: View {
    let entity: HAEntity
    @Environment(DashboardViewModel.self) private var viewModel

    private var options: [String] { entity.attributes.options ?? [] }
    private var currentValue: String { entity.state }

    private var iconName: String {
        entity.domain.activeSymbol
    }

    var body: some View {
        HStack(spacing: Spacing.sp3) {
            // Icon
            Image(systemName: iconName)
                .font(.system(size: 24))
                .foregroundStyle(entity.domain.accentColor)
                .frame(width: 32, alignment: .center)

            // Label + current value
            VStack(alignment: .leading, spacing: 2) {
                Text(entity.name)
                    .font(.bodySMBold)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)

                Text(currentValue.capitalized)
                    .font(.caption)
                    .foregroundStyle(Color.textMuted)
                    .lineLimit(1)
            }

            Spacer()

            // Menu picker
            Menu {
                ForEach(options, id: \.self) { option in
                    Button {
                        Task { await viewModel.selectOption(entity, option: option) }
                    } label: {
                        HStack {
                            Text(option.capitalized)
                            if option == currentValue {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: Spacing.sp1) {
                    Text(currentValue.capitalized)
                        .font(.bodySM)
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.textMuted)
                }
                .padding(.horizontal, Spacing.sp3)
                .padding(.vertical, Spacing.sp2)
                .background(Color.base)
                .clipShape(RoundedRectangle(cornerRadius: Radius.pill))
            }
        }
        .padding(.horizontal, Spacing.sp4)
        .padding(.vertical, Spacing.sp3)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .mapleShadow(.sm)
    }
}

#Preview {
    SelectCardView(entity: HAEntity(
        id: "input_select.theme",
        name: "House Theme",
        domain: .inputSelect,
        areaId: nil,
        state: "cozy",
        attributes: HAAttributes(raw: [
            "options": AnyCodable(["cozy", "bright", "movie", "party"])
        ]),
        isExposed: true
    ))
    .padding()
    .background(Color.base)
}

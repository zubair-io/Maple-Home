import SwiftUI

struct DashboardHeaderView: View {
    let activeCount: Int

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Top bar with branding and category legend
            HStack(alignment: .center) {
                // Logo
                HStack(spacing: Spacing.sp4) {
                    HStack(spacing: 0) {
                        Text("Maple")
                            .font(.merriweather(size: 17, weight: .black))
                            .foregroundStyle(Color.textPrimary)
                        Text(".")
                            .font(.merriweather(size: 17, weight: .black))
                            .foregroundStyle(Color.accent)
                    }

                    Text("ENTITY LIBRARY")
                        .font(.lato(size: 11, weight: .bold))
                        .tracking(1.0)
                        .foregroundStyle(Color.textMuted)
                }

                Spacer()

                // Category legend (compact on iPhone)
                categoryLegend
            }
            .padding(.horizontal, Spacing.sp4)
            .padding(.vertical, Spacing.sp3)
            .background(Color.surface)
            .overlay(alignment: .bottom) {
                Divider()
            }

            // Greeting row
            VStack(alignment: .leading, spacing: Spacing.sp1) {
                Text(greeting)
                    .font(.merriweather(size: 28, weight: .black))
                    .foregroundStyle(Color.textPrimary)

                Text(subtitle)
                    .font(.lato(size: 14, weight: .regular))
                    .foregroundStyle(Color.textMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Spacing.sp4)
            .padding(.top, Spacing.sp4)
            .padding(.bottom, Spacing.sp2)
        }
    }

    // MARK: - Category Legend

    private var categoryLegend: some View {
        HStack(spacing: Spacing.sp3) {
            ForEach(EntityCategory.allCases) { category in
                HStack(spacing: 4) {
                    Circle()
                        .fill(category.color)
                        .frame(width: 8, height: 8)
                    Text(category.sidebarHeader.uppercased())
                        .font(.lato(size: 9, weight: .bold))
                        .tracking(0.6)
                        .foregroundStyle(Color.textMuted)
                }
            }
        }
    }

    // MARK: - Greeting

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return "Good morning."
        case 12..<17:
            return "Good afternoon."
        default:
            return "Good evening."
        }
    }

    private var subtitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        let dateString = formatter.string(from: Date())
        if activeCount > 0 {
            let noun = activeCount == 1 ? "device" : "devices"
            return "\(dateString) \u{00B7} \(activeCount) \(noun) active"
        }
        return dateString
    }
}

#Preview {
    DashboardHeaderView(activeCount: 5)
        .background(Color.base)
}

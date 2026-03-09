import SwiftUI

struct DashboardHeaderView: View {
    let activeCount: Int

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

    // MARK: - Body

    var body: some View {
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

#Preview {
    DashboardHeaderView(activeCount: 5)
        .background(Color.base)
}

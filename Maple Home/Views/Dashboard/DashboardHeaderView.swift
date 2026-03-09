import SwiftUI

struct DashboardHeaderView: View {
    let activeCount: Int

    var body: some View {
        VStack(spacing: 0) {
            // Top bar with branding and category legend
            HStack(alignment: .center) {
                HStack(spacing: MapleSpacing.s4) {
                    HStack(spacing: 0) {
                        Text("Maple")
                            .font(MapleFont.displayBold(17))
                            .foregroundStyle(Color.mapleT1)
                        Text(".")
                            .font(MapleFont.displayBold(17))
                            .foregroundStyle(Color.mapleAccent)
                    }
                    Text("HOME")
                        .font(MapleFont.bodyBold(11))
                        .tracking(1.0)
                        .foregroundStyle(Color.mapleT3)
                }

                Spacer()

                // Category legend
                HStack(spacing: MapleSpacing.s3) {
                    ForEach(HACategory.allCases) { category in
                        HStack(spacing: 4) {
                            Circle()
                                .fill(category.color)
                                .frame(width: 8, height: 8)
                            Text(category.label.uppercased())
                                .font(MapleFont.bodyBold(9))
                                .tracking(0.6)
                                .foregroundStyle(Color.mapleT3)
                        }
                    }
                }
            }
            .padding(.horizontal, MapleSpacing.s6)
            .padding(.vertical, MapleSpacing.s3)
            .background(Color.mapleSurface)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color.mapleBorderStrong)
                    .frame(height: 1)
            }

            // Greeting row
            VStack(alignment: .leading, spacing: MapleSpacing.s1) {
                Text(greeting)
                    .font(MapleFont.displayHero(28))
                    .foregroundStyle(Color.mapleT1)
                Text(subtitle)
                    .font(MapleFont.bodyRegular(14))
                    .foregroundStyle(Color.mapleT3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, MapleSpacing.s6)
            .padding(.top, MapleSpacing.s4)
            .padding(.bottom, MapleSpacing.s2)
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:  return "Good morning."
        case 12..<17: return "Good afternoon."
        default:      return "Good evening."
        }
    }

    private var subtitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        let dateString = formatter.string(from: Date())
        if activeCount > 0 {
            let noun = activeCount == 1 ? "device" : "devices"
            return "\(dateString) · \(activeCount) \(noun) active"
        }
        return dateString
    }
}

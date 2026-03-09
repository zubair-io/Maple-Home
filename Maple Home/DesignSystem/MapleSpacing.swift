import SwiftUI

// MARK: - Spacing Scale (4pt base unit)

enum Spacing {
    static let sp1: CGFloat = 4
    static let sp2: CGFloat = 8
    static let sp3: CGFloat = 12
    static let sp4: CGFloat = 16
    static let sp5: CGFloat = 20
    static let sp6: CGFloat = 24
    static let sp7: CGFloat = 32
    static let sp8: CGFloat = 40
    static let sp9: CGFloat = 56
    static let sp10: CGFloat = 80
}

// MARK: - Corner Radii

enum Radius {
    static let xs: CGFloat = 6
    static let sm: CGFloat = 10
    static let md: CGFloat = 16
    static let lg: CGFloat = 22
    static let xl: CGFloat = 32
    static let pill: CGFloat = 100
}

// MARK: - Shadow Modifiers

struct MapleShadow: ViewModifier {
    enum Level {
        case xs, sm, md, lg
    }

    let level: Level

    func body(content: Content) -> some View {
        switch level {
        case .xs:
            content.shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 1)
        case .sm:
            content.shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 2)
        case .md:
            content.shadow(color: .black.opacity(0.09), radius: 16, x: 0, y: 4)
        case .lg:
            content.shadow(color: .black.opacity(0.12), radius: 32, x: 0, y: 8)
        }
    }
}

extension View {
    func mapleShadow(_ level: MapleShadow.Level) -> some View {
        modifier(MapleShadow(level: level))
    }
}

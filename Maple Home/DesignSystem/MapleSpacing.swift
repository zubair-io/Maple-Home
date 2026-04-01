import SwiftUI

// MARK: - Spacing Scale

struct MapleSpacing {
    static let s1: CGFloat = 4
    static let s2: CGFloat = 8
    static let s3: CGFloat = 12
    static let s4: CGFloat = 16
    static let s5: CGFloat = 20
    static let s6: CGFloat = 24
    static let s7: CGFloat = 32
    static let s8: CGFloat = 40
    static let s9: CGFloat = 56
    static let s10: CGFloat = 80
}

// MARK: - Corner Radii

struct MapleRadius {
    static let xs: CGFloat   = 6
    static let sm: CGFloat   = 10
    static let md: CGFloat   = 16
    static let lg: CGFloat   = 22
    static let xl: CGFloat   = 32
    static let pill: CGFloat = 100
}

// MARK: - Shadow

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

struct MapleShadow {
    static let xs = Shadow(color: .black.opacity(0.06), radius: 3,  x: 0, y: 1)
    static let sm = Shadow(color: .black.opacity(0.07), radius: 8,  x: 0, y: 2)
    static let md = Shadow(color: .black.opacity(0.10), radius: 16, x: 0, y: 4)
    static let lg = Shadow(color: .black.opacity(0.13), radius: 32, x: 0, y: 8)

    // Backward compat
    enum Level { case xs, sm, md, lg }
}

extension View {
    func mapleShadowSm() -> some View {
        self.shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 2)
    }
    func mapleShadowMd() -> some View {
        self.shadow(color: .black.opacity(0.10), radius: 16, x: 0, y: 4)
    }
    func mapleShadow(_ level: MapleShadow.Level) -> some View {
        switch level {
        case .xs: return AnyView(self.shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 1))
        case .sm: return AnyView(self.shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 2))
        case .md: return AnyView(self.shadow(color: .black.opacity(0.09), radius: 16, x: 0, y: 4))
        case .lg: return AnyView(self.shadow(color: .black.opacity(0.12), radius: 32, x: 0, y: 8))
        }
    }
}

// MARK: - Backward Compatibility

enum Spacing {
    static let sp1: CGFloat = MapleSpacing.s1
    static let sp2: CGFloat = MapleSpacing.s2
    static let sp3: CGFloat = MapleSpacing.s3
    static let sp4: CGFloat = MapleSpacing.s4
    static let sp5: CGFloat = MapleSpacing.s5
    static let sp6: CGFloat = MapleSpacing.s6
    static let sp7: CGFloat = MapleSpacing.s7
    static let sp8: CGFloat = MapleSpacing.s8
    static let sp9: CGFloat = MapleSpacing.s9
    static let sp10: CGFloat = MapleSpacing.s10
}

enum Radius {
    static let xs: CGFloat   = MapleRadius.xs
    static let sm: CGFloat   = MapleRadius.sm
    static let md: CGFloat   = MapleRadius.md
    static let lg: CGFloat   = MapleRadius.lg
    static let xl: CGFloat   = MapleRadius.xl
    static let pill: CGFloat = MapleRadius.pill
}

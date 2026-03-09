import SwiftUI

// MARK: - MapleFont (Design System Typography)

struct MapleFont {
    // Display — Merriweather
    static func displayHero(_ size: CGFloat = 48) -> Font {
        Font.custom("Merriweather-Black", size: size)
    }
    static func displayBold(_ size: CGFloat = 28) -> Font {
        Font.custom("Merriweather-Bold", size: size)
    }
    static func displayLight(_ size: CGFloat = 28) -> Font {
        Font.custom("Merriweather-LightItalic", size: size)
    }
    static func displayRegular(_ size: CGFloat = 16) -> Font {
        Font.custom("Merriweather-Regular", size: size)
    }

    // Body — Lato
    static func bodyHeavy(_ size: CGFloat = 14) -> Font {
        Font.custom("Lato-Black", size: size)
    }
    static func bodyBold(_ size: CGFloat = 14) -> Font {
        Font.custom("Lato-Bold", size: size)
    }
    static func bodyRegular(_ size: CGFloat = 14) -> Font {
        Font.custom("Lato-Regular", size: size)
    }
    static func bodyLight(_ size: CGFloat = 14) -> Font {
        Font.custom("Lato-Light", size: size)
    }

    // Convenience labels
    static var label: Font { bodyBold(11) }
    static var caption: Font { bodyLight(12) }
    static var mono: Font { Font.system(size: 12, design: .monospaced) }
}

// MARK: - Backward Compatibility (Font Extensions)

extension Font {
    static func merriweather(size: CGFloat, weight: Font.Weight = .regular, italic: Bool = false) -> Font {
        switch weight {
        case .black: return MapleFont.displayHero(size)
        case .bold:  return MapleFont.displayBold(size)
        default:     return italic ? MapleFont.displayLight(size) : MapleFont.displayRegular(size)
        }
    }

    static func lato(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch weight {
        case .black: return MapleFont.bodyHeavy(size)
        case .bold:  return MapleFont.bodyBold(size)
        case .light: return MapleFont.bodyLight(size)
        default:     return MapleFont.bodyRegular(size)
        }
    }

    static let displayLG   = MapleFont.displayHero(28)
    static let displayMD   = MapleFont.displayBold(20)
    static let label       = MapleFont.label
    static let bodySMBold  = MapleFont.bodyBold(13)
    static let bodyMDBold  = MapleFont.bodyHeavy(15)
    static let caption     = MapleFont.caption
    static let button      = MapleFont.bodyBold(14)
    static let bodySM      = MapleFont.bodyRegular(13)
    static let mono        = MapleFont.mono
}

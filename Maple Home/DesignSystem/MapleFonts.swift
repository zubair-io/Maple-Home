import SwiftUI

// MARK: - Font Extensions

extension Font {
    /// Merriweather font for editorial display text
    static func merriweather(size: CGFloat, weight: Font.Weight = .regular, italic: Bool = false) -> Font {
        // Use system serif as fallback since custom fonts need to be bundled
        // When Merriweather font files are added to the bundle, switch to .custom()
        let design: Font.Design = .serif
        var font = Font.system(size: size, weight: weight, design: design)
        if italic {
            font = Font.system(size: size, weight: weight, design: design).italic()
        }
        return font
    }

    /// Lato font for UI body text
    static func lato(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        // Use system default as fallback since Lato needs to be bundled
        // When Lato font files are added, switch to .custom()
        return Font.system(size: size, weight: weight, design: .default)
    }
}

// MARK: - Typography Roles

extension Font {
    /// Dashboard greeting / section hero — Merriweather 900 28pt
    static let displayLG = Font.merriweather(size: 28, weight: .black)

    /// Card title / entity name (detail) — Merriweather 700 20pt
    static let displayMD = Font.merriweather(size: 20, weight: .bold)

    /// Area / section header — Lato 700 11pt UC
    static let label = Font.lato(size: 11, weight: .bold)

    /// Card label (entity name) — Lato 700 13pt
    static let bodySMBold = Font.lato(size: 13, weight: .bold)

    /// Card value (state readout) — Lato 900 15pt
    static let bodyMDBold = Font.lato(size: 15, weight: .black)

    /// Unit / secondary — Lato 300 12pt
    static let caption = Font.lato(size: 12, weight: .light)

    /// Button — Lato 700 14pt
    static let button = Font.lato(size: 14, weight: .bold)

    /// Attribute key/value — Lato 400 13pt
    static let bodySM = Font.lato(size: 13, weight: .regular)

    /// Mono (entity IDs, hex) — Courier New 11pt
    static let mono = Font.system(size: 11, design: .monospaced)
}

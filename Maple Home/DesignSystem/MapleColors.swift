import SwiftUI

// MARK: - Maple Base Tokens (adaptive light/dark)

extension Color {
    // Surfaces
    static let base = Color("mapleBase", bundle: nil)
    static let surface = Color("mapleSurface", bundle: nil)
    static let surfaceRaised = Color("mapleSurfaceRaised", bundle: nil)
    static let overlay = Color.black.opacity(0.8)

    // Text
    static let textPrimary = Color("mapleTextPrimary", bundle: nil)
    static let textSecondary = Color("mapleTextSecondary", bundle: nil)
    static let textMuted = Color("mapleTextMuted", bundle: nil)
    static let textFaint = Color("mapleTextFaint", bundle: nil)
    static let textInverse = Color("mapleTextInverse", bundle: nil)

    // Accent (Maple orange)
    static let accent = Color(red: 232/255, green: 84/255, blue: 10/255)
    static let accentHover = Color(red: 201/255, green: 70/255, blue: 8/255)
    static let accentDim = Color(red: 232/255, green: 84/255, blue: 10/255).opacity(0.10)

    // Borders
    static let border = Color("mapleBorder", bundle: nil)
    static let borderStrong = Color("mapleBorderStrong", bundle: nil)

    // Semantic
    static let success = Color(red: 45/255, green: 138/255, blue: 78/255)
    static let successDim = Color(red: 45/255, green: 138/255, blue: 78/255).opacity(0.10)
    static let warning = Color(red: 176/255, green: 125/255, blue: 16/255)
    static let warningDim = Color(red: 176/255, green: 125/255, blue: 16/255).opacity(0.10)
    static let error = Color(red: 192/255, green: 57/255, blue: 43/255)
    static let errorDim = Color(red: 192/255, green: 57/255, blue: 43/255).opacity(0.10)
    static let info = Color(red: 40/255, green: 116/255, blue: 166/255)
    static let infoDim = Color(red: 40/255, green: 116/255, blue: 166/255).opacity(0.10)
}

// MARK: - HA Semantic Layer (Entity State Colors)

extension Color {
    // Entity State Accents
    static let entityLight = Color(red: 245/255, green: 158/255, blue: 11/255)
    static let entityCool = Color(red: 13/255, green: 148/255, blue: 136/255)
    static let entityHeat = Color(red: 234/255, green: 88/255, blue: 12/255)
    static let entityAlert = Color(red: 220/255, green: 38/255, blue: 38/255)
    static let entityMedia = Color(red: 124/255, green: 58/255, blue: 237/255)
    static let entitySwitch = Color(red: 37/255, green: 99/255, blue: 235/255)
    static let entityInactive = Color(red: 138/255, green: 138/255, blue: 138/255)

    // Category Line Colors (transit-map palette)
    static let categoryControl = Color(red: 232/255, green: 84/255, blue: 10/255)
    static let categorySensor = Color(red: 29/255, green: 111/255, blue: 164/255)
    static let categoryInput = Color(red: 45/255, green: 138/255, blue: 78/255)
    static let categoryAutomation = Color(red: 176/255, green: 125/255, blue: 16/255)
    static let categoryPresence = Color(red: 114/255, green: 82/255, blue: 160/255)

    // Entity State Fills (low-opacity tints)
    static let fillLight = Color(red: 245/255, green: 158/255, blue: 11/255).opacity(0.08)
    static let fillCool = Color(red: 13/255, green: 148/255, blue: 136/255).opacity(0.08)
    static let fillHeat = Color(red: 234/255, green: 88/255, blue: 12/255).opacity(0.08)
    static let fillAlert = Color(red: 220/255, green: 38/255, blue: 38/255).opacity(0.08)
    static let fillMedia = Color(red: 124/255, green: 58/255, blue: 237/255).opacity(0.08)
    static let fillSwitch = Color(red: 37/255, green: 99/255, blue: 235/255).opacity(0.08)
}

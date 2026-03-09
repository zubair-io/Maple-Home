import SwiftUI

// MARK: - Color Tokens (Maple Design System)

extension Color {
    // Brand
    static let mapleAccent       = Color(hex: "#E8540A")
    static let mapleAccentHover  = Color(hex: "#C94608")
    static let mapleAccentDim    = Color(hex: "#E8540A").opacity(0.10)
    static let mapleAccentGlow   = Color(hex: "#E8540A").opacity(0.25)

    // Surfaces
    static let mapleBase         = Color(hex: "#F0EFED")
    static let mapleSurface      = Color.white
    static let mapleSurface2     = Color(hex: "#F7F6F4")
    static let mapleBorder       = Color.black.opacity(0.08)
    static let mapleBorderStrong = Color.black.opacity(0.15)

    // Text
    static let mapleT1           = Color(hex: "#111111")
    static let mapleT2           = Color(hex: "#3A3A38")
    static let mapleT3           = Color(hex: "#7A7A78")
    static let mapleT4           = Color(hex: "#C0C0BC")

    // Semantic
    static let mapleSuccess      = Color(hex: "#2D8A4E")
    static let mapleSuccessDim   = Color(hex: "#2D8A4E").opacity(0.12)
    static let mapleWarning      = Color(hex: "#B07D10")
    static let mapleWarningDim   = Color(hex: "#B07D10").opacity(0.12)
    static let mapleError        = Color(hex: "#C0392B")
    static let mapleErrorDim     = Color(hex: "#C0392B").opacity(0.12)
    static let mapleInfo         = Color(hex: "#2874A6")
    static let mapleInfoDim      = Color(hex: "#2874A6").opacity(0.12)

    // Category (transit-map)
    static let catControl        = Color(hex: "#E8540A")
    static let catSensor         = Color(hex: "#2874A6")
    static let catInput          = Color(hex: "#2D8A4E")
    static let catAutomation     = Color(hex: "#7B3FA0")
    static let catCamera         = Color(hex: "#B07D10")

    // Hex initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6: (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default: (r, g, b) = (1, 1, 1)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }
}

// MARK: - Entity State Colors

extension Color {
    static let entityLight    = Color(red: 245/255, green: 158/255, blue: 11/255)
    static let entityCool     = Color(red: 13/255, green: 148/255, blue: 136/255)
    static let entityHeat     = Color(red: 234/255, green: 88/255, blue: 12/255)
    static let entityAlert    = Color(red: 220/255, green: 38/255, blue: 38/255)
    static let entityMedia    = Color(red: 124/255, green: 58/255, blue: 237/255)
    static let entitySwitch   = Color(red: 37/255, green: 99/255, blue: 235/255)
    static let entityInactive = Color(red: 138/255, green: 138/255, blue: 138/255)

    static let fillLight  = Color(red: 245/255, green: 158/255, blue: 11/255).opacity(0.08)
    static let fillCool   = Color(red: 13/255, green: 148/255, blue: 136/255).opacity(0.08)
    static let fillHeat   = Color(red: 234/255, green: 88/255, blue: 12/255).opacity(0.08)
    static let fillAlert  = Color(red: 220/255, green: 38/255, blue: 38/255).opacity(0.08)
    static let fillMedia  = Color(red: 124/255, green: 58/255, blue: 237/255).opacity(0.08)
    static let fillSwitch = Color(red: 37/255, green: 99/255, blue: 235/255).opacity(0.08)
}

// MARK: - Backward Compatibility Aliases

extension Color {
    static let accent        = mapleAccent
    static let accentHover   = mapleAccentHover
    static let accentDim     = mapleAccentDim
    static let base          = mapleBase
    static let surface       = mapleSurface
    static let surfaceRaised = mapleSurface2
    static let overlay       = Color.black.opacity(0.8)
    static let textPrimary   = mapleT1
    static let textSecondary = mapleT2
    static let textMuted     = mapleT3
    static let textFaint     = mapleT4
    static let textInverse   = Color.white
    static let border        = mapleBorder
    static let borderStrong  = mapleBorderStrong
    static let success       = mapleSuccess
    static let successDim    = mapleSuccessDim
    static let warning       = mapleWarning
    static let warningDim    = mapleWarningDim
    static let error         = mapleError
    static let errorDim      = mapleErrorDim
    static let info          = mapleInfo
    static let infoDim       = mapleInfoDim
    static let categoryControl    = catControl
    static let categorySensor     = catSensor
    static let categoryInput      = catInput
    static let categoryAutomation = catAutomation
    static let categoryPresence   = catCamera
}

// MARK: - Entity Category

enum HACategory: String, CaseIterable, Identifiable {
    case control, sensor, input, automation, camera

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .control:    return .catControl
        case .sensor:     return .catSensor
        case .input:      return .catInput
        case .automation: return .catAutomation
        case .camera:     return .catCamera
        }
    }

    var label: String {
        switch self {
        case .control:    return "Control"
        case .sensor:     return "Sensor"
        case .input:      return "Input"
        case .automation: return "Automation"
        case .camera:     return "Camera"
        }
    }
}

// MARK: - State Badge Style

enum MapleBadgeStyle {
    case on, off, ok, warn, error, info

    var bgColor: Color {
        switch self {
        case .on:    return .mapleAccentDim
        case .off:   return .mapleSurface2
        case .ok:    return .mapleSuccessDim
        case .warn:  return .mapleWarningDim
        case .error: return .mapleErrorDim
        case .info:  return .mapleInfoDim
        }
    }

    var fgColor: Color {
        switch self {
        case .on:    return .mapleAccent
        case .off:   return .mapleT3
        case .ok:    return .mapleSuccess
        case .warn:  return .mapleWarning
        case .error: return .mapleError
        case .info:  return .mapleInfo
        }
    }
}

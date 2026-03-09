import SwiftUI

// MARK: - Entity Control Style

enum EntityControlStyle {
    case toggle
    case slider
    case climate
    case mediaPlayer
    case cover
    case readOnly
    case select
    case action
    case timer
}

// MARK: - Domain Type

enum DomainType: String, Codable, Equatable {
    case light
    case `switch` = "switch"
    case fan
    case cover
    case climate
    case mediaPlayer = "media_player"
    case sensor
    case binarySensor = "binary_sensor"
    case inputBoolean = "input_boolean"
    case inputSelect = "input_select"
    case select
    case number
    case inputNumber = "input_number"
    case person
    case deviceTracker = "device_tracker"
    case automation
    case script
    case scene
    case button
    case inputButton = "input_button"
    case timer
    case update
    case camera
    case image
    case unknown

    init(entityId: String) {
        let prefix = entityId.components(separatedBy: ".").first ?? ""
        self = DomainType(rawValue: prefix) ?? .unknown
    }

    var controlStyle: EntityControlStyle {
        switch self {
        case .light, .switch, .fan, .inputBoolean:
            return .toggle
        case .cover:
            return .cover
        case .climate:
            return .climate
        case .mediaPlayer:
            return .mediaPlayer
        case .sensor, .binarySensor, .person, .deviceTracker:
            return .readOnly
        case .inputSelect, .select:
            return .select
        case .number, .inputNumber:
            return .slider
        case .scene, .script, .button, .inputButton:
            return .action
        case .timer:
            return .timer
        case .automation:
            return .toggle
        case .update:
            return .readOnly
        default:
            return .readOnly
        }
    }

    /// The raw domain string for service calls
    var serviceDomain: String {
        return rawValue
    }

    // MARK: - Icon Mapping

    var inactiveSymbol: String {
        switch self {
        case .light: return "lightbulb"
        case .switch: return "powerplug"
        case .inputBoolean: return "switch.2"
        case .fan: return "fan"
        case .cover: return "blinds.horizontal.closed"
        case .climate: return "thermometer.medium"
        case .mediaPlayer: return "play.rectangle"
        case .sensor: return "gauge.with.dots.needle.bottom.50percent"
        case .binarySensor: return "sensor"
        case .person, .deviceTracker: return "person.circle"
        case .automation: return "gearshape.2"
        case .script: return "scroll"
        case .scene: return "sparkles"
        case .button, .inputButton: return "button.programmable"
        case .timer: return "timer"
        case .update: return "arrow.up.circle"
        case .camera: return "camera"
        case .image: return "photo"
        case .inputSelect, .select: return "list.bullet"
        case .number, .inputNumber: return "slider.horizontal.3"
        default: return "questionmark.circle"
        }
    }

    var activeSymbol: String {
        switch self {
        case .light: return "lightbulb.fill"
        case .switch: return "powerplug.fill"
        case .inputBoolean: return "switch.2"
        case .fan: return "fan.fill"
        case .cover: return "blinds.horizontal.open"
        case .climate: return "thermometer.medium"
        case .mediaPlayer: return "play.rectangle.fill"
        case .sensor: return "gauge.with.dots.needle.bottom.50percent"
        case .binarySensor: return "sensor.fill"
        case .person, .deviceTracker: return "person.circle.fill"
        case .automation: return "gearshape.2.fill"
        case .script: return "scroll.fill"
        case .scene: return "sparkles"
        case .button, .inputButton: return "button.programmable"
        case .timer: return "timer"
        case .update: return "arrow.up.circle.fill"
        case .camera: return "camera.fill"
        case .image: return "photo.fill"
        case .inputSelect, .select: return "list.bullet"
        case .number, .inputNumber: return "slider.horizontal.3"
        default: return "questionmark.circle.fill"
        }
    }

    // MARK: - Accent Color Mapping

    var accentColor: Color {
        switch self {
        case .light: return .entityLight
        case .switch, .inputBoolean, .automation: return .accent
        case .fan: return .entitySwitch
        case .cover: return .entityCool
        case .climate: return .entityHeat
        case .mediaPlayer: return .entityMedia
        case .sensor, .binarySensor: return .entitySwitch
        case .scene, .script, .button, .inputButton: return .accent
        case .timer: return .accent
        case .update: return .success
        default: return .accent
        }
    }

    var fillColor: Color {
        switch self {
        case .light: return .fillLight
        case .switch, .inputBoolean, .automation: return .accentDim
        case .fan: return .fillSwitch
        case .cover: return .fillCool
        case .climate: return .fillHeat
        case .mediaPlayer: return .fillMedia
        case .sensor, .binarySensor: return .fillSwitch
        default: return .accentDim
        }
    }
}

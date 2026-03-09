import SwiftUI

// MARK: - Entity Category (transit-map–inspired grouping)

enum EntityCategory: String, CaseIterable, Identifiable {
    case control
    case sensor
    case input
    case automation
    case presence

    var id: String { rawValue }

    // MARK: - Section Display

    var sectionNumber: String {
        switch self {
        case .control: return "01"
        case .sensor: return "02"
        case .input: return "03"
        case .automation: return "04"
        case .presence: return "05"
        }
    }

    var title: String {
        switch self {
        case .control: return "Control Entities"
        case .sensor: return "Sensor Entities"
        case .input: return "Input & Helper Entities"
        case .automation: return "Automation & Logic"
        case .presence: return "Camera & Presence"
        }
    }

    var subtitle: String {
        switch self {
        case .control:
            return "light · switch · fan · climate · cover · lock · media_player · input_boolean"
        case .sensor:
            return "sensor · binary_sensor — read-only"
        case .input:
            return "input_number · input_select · input_text · input_datetime · button · number · select · text"
        case .automation:
            return "automation · script · scene · timer"
        case .presence:
            return "camera · person · device_tracker · image"
        }
    }

    var sidebarLabel: String {
        switch self {
        case .control: return "Control Entities"
        case .sensor: return "Sensor Entities"
        case .input: return "Input Entities"
        case .automation: return "Logic Entities"
        case .presence: return "Camera & Presence"
        }
    }

    var sidebarHeader: String {
        switch self {
        case .control: return "Control"
        case .sensor: return "Sensor"
        case .input: return "Input / Helper"
        case .automation: return "Automation"
        case .presence: return "Presence"
        }
    }

    // MARK: - Category Line Colors

    var color: Color {
        switch self {
        case .control: return .categoryControl
        case .sensor: return .categorySensor
        case .input: return .categoryInput
        case .automation: return .categoryAutomation
        case .presence: return .categoryPresence
        }
    }
}

// MARK: - Domain → Category Mapping

extension DomainType {
    var category: EntityCategory {
        switch self {
        case .light, .switch, .fan, .cover, .climate, .mediaPlayer, .inputBoolean:
            return .control
        case .sensor, .binarySensor:
            return .sensor
        case .inputSelect, .select, .number, .inputNumber, .button, .inputButton:
            return .input
        case .automation, .script, .scene, .timer:
            return .automation
        case .camera, .image, .person, .deviceTracker:
            return .presence
        default:
            return .control
        }
    }
}

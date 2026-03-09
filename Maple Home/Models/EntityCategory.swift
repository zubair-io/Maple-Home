import SwiftUI

// MARK: - Domain → Category Mapping

extension DomainType {
    var category: HACategory {
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
            return .camera
        default:
            return .control
        }
    }
}

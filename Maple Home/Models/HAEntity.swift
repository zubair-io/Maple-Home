import Foundation

// MARK: - HAEntity

struct HAEntity: Identifiable, Equatable {
    let id: String          // entity_id e.g. "light.desk_lamp"
    let name: String        // friendly name
    let domain: DomainType  // parsed from entity_id prefix
    let areaId: String?     // nil if not assigned to an area
    var state: String       // raw state string: "on", "off", "22.5", etc.
    var attributes: HAAttributes
    let isExposed: Bool     // from entity registry / expose list

    var isAvailable: Bool {
        state != "unavailable" && state != "unknown"
    }

    var isOn: Bool {
        state == "on"
    }

    static func == (lhs: HAEntity, rhs: HAEntity) -> Bool {
        lhs.id == rhs.id &&
        lhs.state == rhs.state &&
        lhs.name == rhs.name &&
        lhs.areaId == rhs.areaId &&
        lhs.isExposed == rhs.isExposed
    }
}

// MARK: - HAAttributes

struct HAAttributes: Equatable {
    let raw: [String: AnyCodable]

    init(raw: [String: AnyCodable] = [:]) {
        self.raw = raw
    }

    // MARK: Light
    var brightness: Int? { raw["brightness"]?.intValue }
    var colorTempKelvin: Int? { raw["color_temp_kelvin"]?.intValue }
    var supportedColorModes: [String]? { raw["supported_color_modes"]?.arrayStringValue }

    // MARK: Climate
    var currentTemperature: Double? { raw["current_temperature"]?.doubleValue }
    var targetTemperature: Double? { raw["temperature"]?.doubleValue }
    var hvacModes: [String]? { raw["hvac_modes"]?.arrayStringValue }
    var hvacAction: String? { raw["hvac_action"]?.stringValue }

    // MARK: Media Player
    var mediaTitle: String? { raw["media_title"]?.stringValue }
    var mediaArtist: String? { raw["media_artist"]?.stringValue }
    var volumeLevel: Double? { raw["volume_level"]?.doubleValue }
    var isVolumeMuted: Bool? { raw["is_volume_muted"]?.boolValue }

    // MARK: Cover
    var currentPosition: Int? { raw["current_position"]?.intValue }

    // MARK: Sensor
    var unitOfMeasurement: String? { raw["unit_of_measurement"]?.stringValue }
    var deviceClass: String? { raw["device_class"]?.stringValue }

    // MARK: Select
    var options: [String]? { raw["options"]?.arrayStringValue }

    // MARK: Generic
    var friendlyName: String? { raw["friendly_name"]?.stringValue }

    // MARK: Raw key-values for detail sheet
    var rawKeyValues: [(key: String, value: String)] {
        raw.map { (key: $0.key, value: $0.value.description) }
    }

    static func == (lhs: HAAttributes, rhs: HAAttributes) -> Bool {
        // Simplified equality check
        lhs.raw.keys.sorted() == rhs.raw.keys.sorted()
    }
}

// MARK: - AnyCodable

struct AnyCodable: Codable, Equatable, CustomStringConvertible {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            value = NSNull()
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            value = dict.mapValues { $0.value }
        } else {
            value = NSNull()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case is NSNull:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dict as [String: Any]:
            try container.encode(dict.mapValues { AnyCodable($0) })
        default:
            try container.encodeNil()
        }
    }

    // MARK: - Value Accessors

    var stringValue: String? { value as? String }
    var intValue: Int? {
        if let i = value as? Int { return i }
        if let d = value as? Double { return Int(d) }
        if let s = value as? String { return Int(s) }
        return nil
    }
    var doubleValue: Double? {
        if let d = value as? Double { return d }
        if let i = value as? Int { return Double(i) }
        if let s = value as? String { return Double(s) }
        return nil
    }
    var boolValue: Bool? { value as? Bool }
    var arrayStringValue: [String]? {
        if let arr = value as? [String] { return arr }
        if let arr = value as? [Any] { return arr.compactMap { $0 as? String } }
        return nil
    }

    var description: String {
        switch value {
        case is NSNull: return "null"
        case let bool as Bool: return bool ? "true" : "false"
        case let int as Int: return "\(int)"
        case let double as Double: return String(format: "%.2f", double)
        case let string as String: return string
        case let array as [Any]: return "\(array)"
        case let dict as [String: Any]: return "\(dict)"
        default: return "\(value)"
        }
    }

    static func == (lhs: AnyCodable, rhs: AnyCodable) -> Bool {
        lhs.description == rhs.description
    }
}

import Foundation

// MARK: - Outgoing Messages

struct HAAuthMessage: Encodable {
    let type = "auth"
    let accessToken: String

    enum CodingKeys: String, CodingKey {
        case type
        case accessToken = "access_token"
    }
}

struct HACommandMessage: Encodable {
    let id: Int
    let type: String
}

struct HASubscribeEventsMessage: Encodable {
    let id: Int
    let type = "subscribe_events"
    let eventType: String

    enum CodingKeys: String, CodingKey {
        case id, type
        case eventType = "event_type"
    }
}

struct HACallServiceMessage: Encodable {
    let id: Int
    let type = "call_service"
    let domain: String
    let service: String
    let serviceData: [String: AnyCodable]

    enum CodingKeys: String, CodingKey {
        case id, type, domain, service
        case serviceData = "service_data"
    }
}

// MARK: - Incoming Messages

struct HAIncomingMessage: Decodable {
    let id: Int?
    let type: String
    let success: Bool?
    let result: AnyCodable?
    let haVersion: String?
    let event: HAEventData?

    enum CodingKeys: String, CodingKey {
        case id, type, success, result, event
        case haVersion = "ha_version"
    }
}

struct HAEventData: Decodable {
    let eventType: String?
    let data: HAStateChangedData?

    enum CodingKeys: String, CodingKey {
        case eventType = "event_type"
        case data
    }
}

struct HAStateChangedData: Decodable {
    let entityId: String?
    let newState: HAStatePayload?

    enum CodingKeys: String, CodingKey {
        case entityId = "entity_id"
        case newState = "new_state"
    }
}

struct HAStatePayload: Decodable {
    let entityId: String
    let state: String
    let attributes: [String: AnyCodable]
    let lastChanged: String?

    enum CodingKeys: String, CodingKey {
        case entityId = "entity_id"
        case state, attributes
        case lastChanged = "last_changed"
    }
}

// MARK: - State Changed Event (for stream)

struct StateChangedEvent {
    let entityId: String
    let newState: String
    let attributes: HAAttributes
}

// MARK: - Entity Registry Entry

struct HAEntityRegistryEntry: Decodable {
    let entityId: String
    let name: String?
    let areaId: String?
    let disabledBy: String?
    let hiddenBy: String?
    let options: HAEntityOptions?

    enum CodingKeys: String, CodingKey {
        case entityId = "entity_id"
        case name
        case areaId = "area_id"
        case disabledBy = "disabled_by"
        case hiddenBy = "hidden_by"
        case options
    }
}

struct HAEntityOptions: Decodable {
    let conversation: HAConversationOptions?
}

struct HAConversationOptions: Decodable {
    let shouldExpose: Bool?

    enum CodingKeys: String, CodingKey {
        case shouldExpose = "should_expose"
    }
}

// MARK: - Exposed Entity List Entry

struct HAExposedEntityEntry: Decodable {
    let entityId: String
    let assistants: [String: HAExposureInfo]?

    enum CodingKeys: String, CodingKey {
        case entityId = "entity_id"
        case assistants
    }
}

struct HAExposureInfo: Decodable {
    let shouldExpose: Bool?

    enum CodingKeys: String, CodingKey {
        case shouldExpose = "should_expose"
    }
}

// MARK: - Token Response

struct HATokenResponse: Decodable {
    let accessToken: String
    let tokenType: String
    let refreshToken: String?
    let expiresIn: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
    }
}

// MARK: - HA Instance Info

struct HAInstanceInfo {
    let version: String
    let baseURL: URL
}

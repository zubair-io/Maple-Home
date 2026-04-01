import Foundation
import os

private let logger = Logger(subsystem: "com.maple.home", category: "StateCache")

// MARK: - CachedState

struct CachedState: Codable {
    static let currentVersion = 2

    let version: Int
    let entities: [String: HAEntity]
    let areas: [HAArea]
    let floors: [HAFloor]
    let exposedEntityIds: [String]
    let cachedAt: Date

    init(entities: [String: HAEntity], areas: [HAArea], floors: [HAFloor], exposedEntityIds: Set<String>) {
        self.version = Self.currentVersion
        self.entities = entities
        self.areas = areas
        self.floors = floors
        self.exposedEntityIds = Array(exposedEntityIds)
        self.cachedAt = Date()
    }
}

// MARK: - StateCache

actor StateCache {
    private static let fileName = "maple_state_cache.json"
    private var pendingSaveTask: Task<Void, Never>?

    private var cacheURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent(Self.fileName)
    }

    func load() -> CachedState? {
        guard FileManager.default.fileExists(atPath: cacheURL.path) else {
            logger.info("No cache file found")
            return nil
        }

        do {
            let data = try Data(contentsOf: cacheURL)
            let cached = try JSONDecoder().decode(CachedState.self, from: data)
            guard cached.version == CachedState.currentVersion else {
                logger.warning("Cache version mismatch (\(cached.version) vs \(CachedState.currentVersion)), ignoring")
                return nil
            }
            logger.info("Loaded cache: \(cached.entities.count) entities, \(cached.areas.count) areas")
            return cached
        } catch {
            logger.error("Failed to load cache: \(error.localizedDescription)")
            return nil
        }
    }

    func scheduleSave(_ state: CachedState) {
        pendingSaveTask?.cancel()
        pendingSaveTask = Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            guard !Task.isCancelled else { return }
            write(state)
        }
    }

    func saveImmediately(_ state: CachedState) {
        pendingSaveTask?.cancel()
        pendingSaveTask = nil
        write(state)
    }

    private func write(_ state: CachedState) {
        do {
            let data = try JSONEncoder().encode(state)
            try data.write(to: cacheURL, options: .atomic)
            logger.info("Cache saved: \(state.entities.count) entities, \(state.areas.count) areas")
        } catch {
            logger.error("Failed to save cache: \(error.localizedDescription)")
        }
    }
}

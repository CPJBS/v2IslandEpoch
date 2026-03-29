//
//  Building.swift
//  IslandEpoch
//

import Foundation
import OSLog

/// Building instance (runtime object)
struct Building: Identifiable, Codable, Equatable {
    let id: UUID
    let type: BuildingType
    var level: Int = 1
    var assignedWorkers: Int = 0  // Number of workers currently assigned to this building
    var constructionStartTime: Date?  // nil means fully built
    var constructionDuration: TimeInterval = 0  // 0 for legacy/instant builds

    // MARK: - Construction Computed Properties

    var isUnderConstruction: Bool {
        guard let start = constructionStartTime else { return false }
        return Date().timeIntervalSince(start) < constructionDuration
    }

    var constructionProgress: Double {
        guard let start = constructionStartTime else { return 1.0 }
        guard constructionDuration > 0 else { return 1.0 }
        return min(max(Date().timeIntervalSince(start) / constructionDuration, 0), 1.0)
    }

    var constructionTimeRemaining: TimeInterval {
        guard let start = constructionStartTime else { return 0 }
        return max(constructionDuration - Date().timeIntervalSince(start), 0)
    }

    mutating func completeConstruction() {
        constructionStartTime = nil
    }

    init(id: UUID = UUID(), type: BuildingType, assignedWorkers: Int = 0, constructionStartTime: Date? = nil, constructionDuration: TimeInterval = 0) {
        self.id = id
        self.type = type
        self.assignedWorkers = assignedWorkers
        self.constructionStartTime = constructionStartTime
        self.constructionDuration = constructionDuration
    }

    // MARK: - Codable with migration support

    enum CodingKeys: String, CodingKey {
        case id, type, level, assignedWorkers, constructionStartTime, constructionDuration
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        type = try container.decode(BuildingType.self, forKey: .type)
        level = try container.decodeIfPresent(Int.self, forKey: .level) ?? 1
        // Default to 0 for backwards compatibility
        assignedWorkers = try container.decodeIfPresent(Int.self, forKey: .assignedWorkers) ?? 0
        constructionStartTime = try container.decodeIfPresent(Date.self, forKey: .constructionStartTime)
        constructionDuration = (try? container.decodeIfPresent(TimeInterval.self, forKey: .constructionDuration)) ?? 0
    }
}

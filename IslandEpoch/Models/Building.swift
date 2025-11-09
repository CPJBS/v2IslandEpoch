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

    init(id: UUID = UUID(), type: BuildingType, assignedWorkers: Int = 0) {
        self.id = id
        self.type = type
        self.assignedWorkers = assignedWorkers
    }

    // MARK: - Codable with migration support

    enum CodingKeys: String, CodingKey {
        case id, type, level, assignedWorkers
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        type = try container.decode(BuildingType.self, forKey: .type)
        level = try container.decode(Int.self, forKey: .level)
        // Default to 0 for backwards compatibility
        assignedWorkers = try container.decodeIfPresent(Int.self, forKey: .assignedWorkers) ?? 0
    }
}

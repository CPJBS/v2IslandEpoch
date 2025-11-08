//
//  Island.swift
//  IslandEpoch
//

import Foundation
import OSLog

/// Island territory (pure data, no logic)
struct Island: Identifiable, Codable {
    // MARK: - Identity
    var id = UUID()
    var name: String

    // MARK: - Resources & Workers
    var inventory: Inventory = [:]
    var workersAvailable: Int

    // MARK: - Buildings
    var buildings: [Building?] = []
    let maxSlots: Int

    // MARK: - Initialization
    init(name: String, workersAvailable: Int, maxSlots: Int) {
        self.name = name
        self.workersAvailable = workersAvailable
        self.maxSlots = maxSlots
        // Initialize with fixed number of empty slots
        self.buildings = Array(repeating: nil, count: maxSlots)
    }

    // MARK: - Computed Properties

    var hasAvailableSlots: Bool {
        buildings.contains(where: { $0 == nil })
    }

    var availableSlots: Int {
        buildings.filter { $0 == nil }.count
    }

    var totalWorkersAssigned: Int {
        buildings.compactMap { $0 }.reduce(0) { $0 + $1.type.workers }
    }

    // MARK: - Codable (with migration support)

    enum CodingKeys: String, CodingKey {
        case id, name, inventory, workersAvailable, buildings, maxSlots
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        inventory = try container.decode(Inventory.self, forKey: .inventory)
        workersAvailable = try container.decode(Int.self, forKey: .workersAvailable)
        maxSlots = try container.decode(Int.self, forKey: .maxSlots)

        // Try to decode as new format [Building?] first
        if let optionalBuildings = try? container.decode([Building?].self, forKey: .buildings) {
            // New format - use as is, but ensure it has the right size
            if optionalBuildings.count == maxSlots {
                buildings = optionalBuildings
            } else {
                // Migrate to correct size
                var fixedBuildings = Array(repeating: nil as Building?, count: maxSlots)
                let actualBuildings = optionalBuildings.compactMap { $0 }
                for (index, building) in actualBuildings.enumerated() {
                    if index < maxSlots {
                        fixedBuildings[index] = building
                    }
                }
                buildings = fixedBuildings
            }
        } else if let oldBuildings = try? container.decode([Building].self, forKey: .buildings) {
            // Old format - migrate to new format
            var fixedBuildings = Array(repeating: nil as Building?, count: maxSlots)
            for (index, building) in oldBuildings.enumerated() {
                if index < maxSlots {
                    fixedBuildings[index] = building
                }
            }
            buildings = fixedBuildings
        } else {
            // No buildings or failed to decode - initialize with empty slots
            buildings = Array(repeating: nil, count: maxSlots)
        }
    }
}

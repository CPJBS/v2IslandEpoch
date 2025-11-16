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

    // MARK: - Fertilities
    var fertilities: [FertilityType] = []

    // MARK: - Unlock Requirements
    var unlockRequirements: [String] = [] // Research IDs required to unlock this island

    // MARK: - Buildings
    var buildings: [Building?] = []
    let maxSlots: Int

    // MARK: - Initialization
    init(name: String, maxSlots: Int, fertilities: [FertilityType] = [], unlockRequirements: [String] = []) {
        self.name = name
        self.maxSlots = maxSlots
        self.fertilities = fertilities
        self.unlockRequirements = unlockRequirements
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

    /// Workers provided by housing buildings (tents, houses, etc.)
    var workersAvailable: Int {
        buildings.compactMap { $0 }.reduce(0) { $0 + $1.type.providesWorkers }
    }

    /// Total workers currently assigned to buildings
    var totalWorkersAssigned: Int {
        buildings.compactMap { $0 }.reduce(0) { $0 + $1.assignedWorkers }
    }

    /// Unassigned workers available for assignment
    var unassignedWorkers: Int {
        workersAvailable - totalWorkersAssigned
    }

    /// Check if this island is unlocked based on research requirements
    func isUnlocked(completedResearch: [CompletedResearch]) -> Bool {
        // For playtesting: all islands unlocked by default
        // TODO: Enable when research system is ready
        return true

        // Production code (commented out for playtesting):
        // if unlockRequirements.isEmpty {
        //     return true // No requirements means always unlocked
        // }
        // let completedIds = Set(completedResearch.map { $0.researchId })
        // return unlockRequirements.allSatisfy { completedIds.contains($0) }
    }

    // MARK: - Codable (with migration support)

    enum CodingKeys: String, CodingKey {
        case id, name, inventory, buildings, maxSlots, fertilities, unlockRequirements
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        inventory = try container.decode(Inventory.self, forKey: .inventory)
        maxSlots = try container.decode(Int.self, forKey: .maxSlots)

        // Decode new fields with defaults for migration
        fertilities = (try? container.decode([FertilityType].self, forKey: .fertilities)) ?? []
        unlockRequirements = (try? container.decode([String].self, forKey: .unlockRequirements)) ?? []

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

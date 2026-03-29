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

    // MARK: - Storage
    var storageLevels: [String: Int] = [:]  // Keyed by ResourceCategory rawValue

    // MARK: - Unlock Requirements
    var unlockRequirements: [String] = [] // Research IDs required to unlock this island

    // MARK: - Status
    var isHungry: Bool = false

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

    /// Workers provided by housing buildings (tents, houses, etc.), scaling with level
    /// Note: For research-boosted worker count, use workersAvailable(bonuses:) instead.
    var workersAvailable: Int {
        workersAvailable(extraPerHousing: 0, housingBonusPercent: 0)
    }

    /// Workers provided by housing buildings, including research bonuses
    func workersAvailable(extraPerHousing: Int, housingBonusPercent: Int) -> Int {
        let baseWorkers = buildings.compactMap { $0 }.filter { !$0.isUnderConstruction }.reduce(0) { total, building in
            if building.type.providesWorkers > 0 {
                let fromBuilding = building.type.providesWorkers + (building.level - 1) * building.type.workerGrowthRate
                return total + fromBuilding + extraPerHousing
            }
            return total
        }
        if housingBonusPercent > 0 {
            return Int(Double(baseWorkers) * (1.0 + Double(housingBonusPercent) / 100.0))
        }
        return baseWorkers
    }

    /// Total workers currently assigned to buildings
    var totalWorkersAssigned: Int {
        buildings.compactMap { $0 }.reduce(0) { $0 + $1.assignedWorkers }
    }

    /// Unassigned workers available for assignment
    var unassignedWorkers: Int {
        workersAvailable - totalWorkersAssigned
    }

    // MARK: - Storage

    static func storageCapacity(level: Int) -> Int {
        Int(100.0 * pow(1.6, Double(level - 1)))
    }

    func storageCapForCategory(_ category: ResourceCategory) -> Int {
        storageCapForCategory(category, bonusPercent: 0)
    }

    func storageCapForCategory(_ category: ResourceCategory, bonusPercent: Int) -> Int {
        let level = storageLevels[category.rawValue] ?? 1
        let base = Island.storageCapacity(level: level)
        if bonusPercent > 0 {
            return Int(Double(base) * (1.0 + Double(bonusPercent) / 100.0))
        }
        return base
    }

    func isResourceAtCap(_ type: ResourceType) -> Bool {
        let cap = storageCapForCategory(type.category)
        return (inventory[type] ?? 0) >= cap
    }

    mutating func upgradeStorage(category: ResourceCategory) {
        let key = category.rawValue
        storageLevels[key] = (storageLevels[key] ?? 1) + 1
    }

    func storageUpgradeCost(category: ResourceCategory) -> Int {
        let level = storageLevels[category.rawValue] ?? 1
        let costs = [0, 200, 500, 1200, 3000, 7500, 18000, 45000]
        return level < costs.count ? costs[level] : 99999
    }

    /// Check if this island is unlocked based on research requirements
    func isUnlocked(completedResearch: [CompletedResearch]) -> Bool {
        if unlockRequirements.isEmpty {
            return true // No requirements means always unlocked
        }
        let completedIds = Set(completedResearch.map { $0.researchId })
        return unlockRequirements.allSatisfy { completedIds.contains($0) }
    }

    // MARK: - Codable (with migration support)

    enum CodingKeys: String, CodingKey {
        case id, name, inventory, buildings, maxSlots, fertilities, unlockRequirements, isHungry, storageLevels
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
        isHungry = (try? container.decode(Bool.self, forKey: .isHungry)) ?? false
        storageLevels = (try? container.decodeIfPresent([String: Int].self, forKey: .storageLevels)) ?? [:]

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

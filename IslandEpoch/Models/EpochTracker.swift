//
//  EpochTracker.swift
//  IslandEpoch
//

import Foundation

/// Represents a game epoch/era
struct Epoch: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String
    let advancementResearchId: String?

    // MARK: - Codable with migration support

    enum CodingKeys: String, CodingKey {
        case id, name, description, advancementResearchId
    }

    init(id: Int, name: String, description: String = "", advancementResearchId: String? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.advancementResearchId = advancementResearchId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        advancementResearchId = try container.decodeIfPresent(String.self, forKey: .advancementResearchId)
    }
}

/// Manages game epochs and progression
struct EpochTracker: Codable {

    // MARK: - Properties

    /// Current epoch the player is in (1-10)
    var currentEpoch: Int = 1

    // MARK: - Static Catalog

    /// All available epochs in the game
    static let allEpochs: [Epoch] = [
        Epoch(id: 1, name: "Dawn", description: "The first settlers arrive on unknown shores.", advancementResearchId: "e1_agriculture"),
        Epoch(id: 2, name: "Settlement", description: "With agriculture comes permanence.", advancementResearchId: "e2_construction"),
        Epoch(id: 3, name: "Crafting", description: "Hands learn to shape the world.", advancementResearchId: "e3_prospecting"),
        Epoch(id: 4, name: "Mining", description: "Deep beneath the earth, riches await.", advancementResearchId: "e4_smelting"),
        Epoch(id: 5, name: "Metalworking", description: "Fire transforms ore into power.", advancementResearchId: "e5_engineering"),
        Epoch(id: 6, name: "Trade", description: "Goods flow between islands.", advancementResearchId: "e6_architecture"),
        Epoch(id: 7, name: "Fortification", description: "Stone walls rise to protect what was built.", advancementResearchId: "e7_industrialization"),
        Epoch(id: 8, name: "Scholarship", description: "Knowledge becomes the greatest resource.", advancementResearchId: "e8_enlightenment_dawn"),
        Epoch(id: 9, name: "Industry", description: "Machines multiply the work of hands.", advancementResearchId: "e9_enlightenment"),
        Epoch(id: 10, name: "Enlightenment", description: "A civilization reaches its zenith.", advancementResearchId: nil)
    ]

    // MARK: - Helpers

    /// Get the current epoch object
    var currentEpochData: Epoch? {
        EpochTracker.allEpochs.first { $0.id == currentEpoch }
    }

    /// Returns the full Epoch struct for the current epoch
    func currentEpochStruct() -> Epoch {
        EpochTracker.allEpochs.first { $0.id == currentEpoch }
            ?? Epoch(id: currentEpoch, name: "Unknown", description: "Unknown epoch.", advancementResearchId: nil)
    }

    /// Check if the advancement research for current epoch is completed
    func canAdvanceEpoch(completedResearchIds: [String]) -> Bool {
        guard currentEpoch < 10 else { return false }
        guard let epoch = EpochTracker.allEpochs.first(where: { $0.id == currentEpoch }),
              let requiredResearchId = epoch.advancementResearchId else {
            return false
        }
        return completedResearchIds.contains(requiredResearchId)
    }

    /// Check if a building is available in the current epoch
    func isBuildingAvailable(_ buildingType: BuildingType) -> Bool {
        return buildingType.availableFromEpoch <= currentEpoch
    }

    /// Get all buildings available in current and previous epochs
    func availableBuildings() -> [BuildingType] {
        BuildingType.all.filter { $0.availableFromEpoch <= currentEpoch }
    }

    /// Advance to the next epoch
    mutating func advanceEpoch() {
        if currentEpoch < 10 {
            currentEpoch += 1
        }
    }

    /// Check if player can advance to next epoch (simple check, no research requirement)
    var canAdvanceEpoch: Bool {
        currentEpoch < 10
    }
}

//
//  EpochTracker.swift
//  IslandEpoch
//

import Foundation

/// Represents a game epoch/era
struct Epoch: Codable, Identifiable {
    let id: Int
    let name: String
    // Future: Add epoch-specific data like unlockable technologies, events, etc.
}

/// Manages game epochs and progression
struct EpochTracker: Codable {

    // MARK: - Properties

    /// Current epoch the player is in (1-10)
    var currentEpoch: Int = 1

    // MARK: - Static Catalog

    /// All available epochs in the game
    static let allEpochs: [Epoch] = [
        Epoch(id: 1, name: "Epoch 1"),
        Epoch(id: 2, name: "Epoch 2"),
        Epoch(id: 3, name: "Epoch 3"),
        Epoch(id: 4, name: "Epoch 4"),
        Epoch(id: 5, name: "Epoch 5"),
        Epoch(id: 6, name: "Epoch 6"),
        Epoch(id: 7, name: "Epoch 7"),
        Epoch(id: 8, name: "Epoch 8"),
        Epoch(id: 9, name: "Epoch 9"),
        Epoch(id: 10, name: "Epoch 10")
    ]

    // MARK: - Helpers

    /// Get the current epoch object
    var currentEpochData: Epoch? {
        EpochTracker.allEpochs.first { $0.id == currentEpoch }
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

    /// Check if player can advance to next epoch
    var canAdvanceEpoch: Bool {
        currentEpoch < 10
    }
}

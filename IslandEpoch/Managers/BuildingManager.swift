//
//  BuildingManager.swift
//  IslandEpoch
//

import Foundation

@MainActor
class BuildingManager {
    
    // MARK: - Dependencies
    private let gameState: GameState
    
    init(gameState: GameState) {
        self.gameState = gameState
    }
    
    // MARK: - Public API
    
    /// Build a building on specified island
    func build(
        _ type: BuildingType,
        onIslandIndex islandIndex: Int,
        gameState: inout GameState
    ) -> Result<UUID, BuildError> {

        // Validate island index
        guard islandIndex < gameState.islands.count else {
            return .failure(.buildingNotFound)
        }

        // 1. Check gold
        guard gameState.gold >= type.goldCost else {
            return .failure(.insufficientGold(
                required: type.goldCost,
                available: gameState.gold
            ))
        }

        // 2. Check building slots
        guard gameState.islands[islandIndex].hasAvailableSlots else {
            return .failure(.noSlots)
        }

        // 3. Check workers
        guard gameState.islands[islandIndex].workersAvailable >= type.workers else {
            return .failure(.insufficientWorkers(
                required: type.workers,
                available: gameState.islands[islandIndex].workersAvailable
            ))
        }

        // 4. Create building
        let buildingId = UUID()
        let building = Building(id: buildingId, type: type)

        // 5. Update state
        gameState.gold -= type.goldCost
        gameState.islands[islandIndex].buildings.append(building)

        AppLogger.building.info("Built \(type.name) for \(type.goldCost) gold")

        return .success(buildingId)
    }
    
    /// Demolish a building
    func demolish(
        buildingId: UUID,
        fromIslandIndex islandIndex: Int,
        gameState: inout GameState
    ) -> Result<Void, BuildError> {

        // Validate island index
        guard islandIndex < gameState.islands.count else {
            return .failure(.buildingNotFound)
        }

        guard let index = gameState.islands[islandIndex].buildings.firstIndex(where: { $0.id == buildingId }) else {
            return .failure(.buildingNotFound)
        }

        let building = gameState.islands[islandIndex].buildings[index]

        // Remove building
        gameState.islands[islandIndex].buildings.remove(at: index)

        // Refund 50% gold
        let refund = building.type.goldCost / 2
        gameState.gold += refund

        AppLogger.building.info("Demolished \(building.type.name), refunded \(refund) gold")

        return .success(())
    }
}

// MARK: - Errors

enum BuildError: Error, LocalizedError {
    case insufficientGold(required: Int, available: Int)
    case noSlots
    case insufficientWorkers(required: Int, available: Int)
    case buildingNotFound
    
    var errorDescription: String? {
        switch self {
        case .insufficientGold(let required, let available):
            return "Need \(required) gold (have \(available))"
        case .noSlots:
            return "No building slots available"
        case .insufficientWorkers(let required, let available):
            return "Need \(required) workers (have \(available))"
        case .buildingNotFound:
            return "Building not found"
        }
    }
}

//
//  BuildingManager.swift
//  IslandEpoch
//

import Foundation
import OSLog

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
        atSlotIndex slotIndex: Int? = nil,
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

        // 2. Check fertility requirements
        if let requiredFertility = type.requiredFertility {
            let island = gameState.islands[islandIndex]
            guard island.fertilities.contains(requiredFertility) else {
                return .failure(.lacksFertility(required: requiredFertility))
            }
        }

        // 3. Check building slots
        guard gameState.islands[islandIndex].hasAvailableSlots else {
            return .failure(.noSlots)
        }

        // 4. Create building (no worker check - workers are assigned later)
        let buildingId = UUID()
        let building = Building(id: buildingId, type: type)

        // 5. Determine target slot index
        let targetSlotIndex: Int
        if let slotIndex = slotIndex {
            // Use specific slot if provided
            guard slotIndex >= 0 && slotIndex < gameState.islands[islandIndex].buildings.count else {
                return .failure(.buildingNotFound)
            }
            guard gameState.islands[islandIndex].buildings[slotIndex] == nil else {
                return .failure(.noSlots) // Slot is already occupied
            }
            targetSlotIndex = slotIndex
        } else {
            // Find first empty slot
            guard let emptySlotIndex = gameState.islands[islandIndex].buildings.firstIndex(where: { $0 == nil }) else {
                return .failure(.noSlots)
            }
            targetSlotIndex = emptySlotIndex
        }

        // 6. Update state
        gameState.gold -= type.goldCost
        var placedBuilding = building
        placedBuilding.constructionStartTime = Date()
        let bonuses = ResearchEffectResolver.resolve(completedResearches: gameState.completedResearches)
        placedBuilding.constructionDuration = type.constructionTime * bonuses.constructionTimeMultiplier
        gameState.islands[islandIndex].buildings[targetSlotIndex] = placedBuilding

        AppLogger.building.info("Built \(type.name) for \(type.goldCost) gold at slot \(targetSlotIndex) (construction: \(type.constructionTime)s)")

        return .success(buildingId)
    }
    
    // MARK: - Cost & Time Formulas

    /// Calculate the gold cost to upgrade a building to its next level
    static func upgradeCost(for building: Building) -> Int {
        let level = building.level
        let tier = (level - 1) / 10 + 1
        let withinTier = (level - 1) % 10
        let tierMult = pow(3.5, Double(tier - 1))
        return Int(Double(building.type.goldCost) * tierMult * pow(1.12, Double(withinTier)))
    }

    /// Calculate the construction time for upgrading a building to its next level
    static func upgradeTime(for building: Building) -> TimeInterval {
        let level = building.level
        let tier = (level - 1) / 10 + 1
        let withinTier = (level - 1) % 10
        let tierTimeMultipliers: [Double] = [1, 2, 4, 8, 15, 30, 60, 120, 240, 480]
        let tierTimeMult = tier <= tierTimeMultipliers.count ? tierTimeMultipliers[tier - 1] : 480
        return building.type.constructionTime * (1.0 + 0.5 * Double(withinTier)) * tierTimeMult
    }

    /// Upgrade a building to the next level
    func upgrade(
        buildingId: UUID,
        on islandIndex: Int,
        maxLevel: Int,
        in gameState: inout GameState
    ) -> Result<Void, BuildError> {

        // 1. Validate island index
        guard islandIndex >= 0 && islandIndex < gameState.islands.count else {
            return .failure(.buildingNotFound)
        }

        // 2. Find the building
        guard let slotIndex = gameState.islands[islandIndex].buildings.firstIndex(where: { $0?.id == buildingId }),
              let building = gameState.islands[islandIndex].buildings[slotIndex] else {
            return .failure(.buildingNotFound)
        }

        // 3. Check max level (tier-research & epoch gated)
        guard building.level < maxLevel else {
            return .failure(.maxLevelReached)
        }

        // 4. Calculate upgrade cost
        let upgradeCost = BuildingManager.upgradeCost(for: building)

        // 5. Check gold
        guard gameState.gold >= upgradeCost else {
            return .failure(.insufficientGold(required: upgradeCost, available: gameState.gold))
        }

        // 6. Deduct gold and upgrade
        gameState.gold -= upgradeCost
        gameState.islands[islandIndex].buildings[slotIndex]?.level += 1

        // 7. Set construction timer for upgrade (apply research speed bonus)
        let upgradeTime = BuildingManager.upgradeTime(for: building)
        let bonuses = ResearchEffectResolver.resolve(completedResearches: gameState.completedResearches)
        gameState.islands[islandIndex].buildings[slotIndex]?.constructionStartTime = Date()
        gameState.islands[islandIndex].buildings[slotIndex]?.constructionDuration = upgradeTime * bonuses.constructionTimeMultiplier

        AppLogger.building.info("Upgraded \(building.type.name) to level \(building.level + 1) for \(upgradeCost) gold (construction: \(upgradeTime)s)")

        return .success(())
    }

    /// Complete construction of a building
    func completeConstruction(buildingId: UUID, on islandIndex: Int, in gameState: inout GameState) {
        guard islandIndex >= 0 && islandIndex < gameState.islands.count else { return }
        for i in 0..<gameState.islands[islandIndex].buildings.count {
            if gameState.islands[islandIndex].buildings[i]?.id == buildingId {
                gameState.islands[islandIndex].buildings[i]?.completeConstruction()
                return
            }
        }
    }

    /// Speed up construction with gems (returns gem cost, 0 if free)
    func speedUpConstruction(buildingId: UUID, on islandIndex: Int, in gameState: inout GameState) -> Int {
        guard islandIndex >= 0 && islandIndex < gameState.islands.count else { return 0 }
        for i in 0..<gameState.islands[islandIndex].buildings.count {
            if let building = gameState.islands[islandIndex].buildings[i], building.id == buildingId, building.isUnderConstruction {
                let remaining = building.constructionTimeRemaining
                if remaining <= 30 { // Free complete
                    gameState.islands[islandIndex].buildings[i]?.completeConstruction()
                    return 0
                }
                let gemCost = max(1, Int(ceil(remaining / 60.0)))
                guard gameState.gems >= gemCost else { return gemCost } // Return cost even if can't afford
                gameState.gems -= gemCost
                gameState.islands[islandIndex].buildings[i]?.completeConstruction()
                return gemCost
            }
        }
        return 0
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

        // Find building index
        guard let index = gameState.islands[islandIndex].buildings.firstIndex(where: { $0?.id == buildingId }) else {
            return .failure(.buildingNotFound)
        }

        // Get building for refund calculation
        guard let building = gameState.islands[islandIndex].buildings[index] else {
            return .failure(.buildingNotFound)
        }

        // Prevent demolishing the last tent
        if building.type.id == "tent" {
            let tentCount = gameState.islands[islandIndex].buildings.compactMap { $0 }.filter { $0.type.id == "tent" }.count
            if tentCount <= 1 {
                return .failure(.cannotDemolishLastTent)
            }
        }

        // Clear the slot (set to nil instead of removing)
        gameState.islands[islandIndex].buildings[index] = nil

        // Refund 50% gold
        let refund = building.type.goldCost / 2
        gameState.gold += refund

        AppLogger.building.info("Demolished \(building.type.name) from slot \(index), refunded \(refund) gold")

        return .success(())
    }
}

// MARK: - Errors

enum BuildError: Error, LocalizedError {
    case insufficientGold(required: Int, available: Int)
    case noSlots
    case buildingNotFound
    case cannotDemolishLastTent
    case lacksFertility(required: FertilityType)
    case maxLevelReached

    var errorDescription: String? {
        switch self {
        case .insufficientGold(let required, let available):
            return "Need \(required) gold (have \(available))"
        case .noSlots:
            return "No building slots available"
        case .buildingNotFound:
            return "Building not found"
        case .cannotDemolishLastTent:
            return "Cannot demolish the last tent - you need at least one for housing"
        case .lacksFertility(let required):
            return "Lacks fertility: \(required.displayName)"
        case .maxLevelReached:
            return "Building is already at maximum level"
        }
    }
}

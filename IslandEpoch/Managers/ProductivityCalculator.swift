//
//  ProductivityCalculator.swift
//  IslandEpoch
//

import Foundation

/// Modular system for calculating building productivity based on various factors
struct ProductivityCalculator {

    /// Calculate the productivity multiplier for a building
    /// - Parameters:
    ///   - building: The building to calculate productivity for
    ///   - island: The island the building is on (for hunger penalty)
    ///   - gameState: The current game state (for research bonuses, etc.)
    /// - Returns: A multiplier representing productivity percentage
    static func calculateProductivity(for building: Building, island: Island? = nil, gameState: GameState? = nil) -> Double {
        var productivity: Double = 1.0

        // 1. Worker-based productivity
        productivity *= workerProductivityMultiplier(for: building)

        // 2. Research bonuses
        productivity *= researchProductivityMultiplier(for: building, gameState: gameState)

        // 3. Building level bonuses (soft-exponential curve for deep progression)
        let lvl = Double(building.level - 1)
        let levelMultiplier = 1.0 + 0.10 * lvl + 0.002 * pow(lvl, 1.5)
        productivity *= levelMultiplier

        // 4. Hunger penalty
        if let island = island, island.isHungry {
            productivity *= 0.5
        }

        return productivity
    }

    // MARK: - Worker Productivity

    /// Calculate productivity multiplier based on assigned workers
    /// Formula: assignedWorkers / maxWorkers
    /// - Parameter building: The building to calculate for
    /// - Returns: Productivity multiplier (0.0 to 1.0)
    private static func workerProductivityMultiplier(for building: Building) -> Double {
        // Housing buildings don't need workers to operate
        guard building.type.workers > 0 else {
            return 1.0
        }

        // Calculate ratio of assigned workers to max workers
        let maxWorkers = building.type.workers
        let assignedWorkers = building.assignedWorkers

        guard maxWorkers > 0 else {
            return 1.0
        }

        return Double(assignedWorkers) / Double(maxWorkers)
    }

    // MARK: - Research Productivity

    /// Calculate productivity multiplier from completed research effects
    private static func researchProductivityMultiplier(for building: Building, gameState: GameState?) -> Double {
        guard let gameState = gameState else { return 1.0 }

        var multiplier: Double = 1.0

        // Walk all completed researches and apply matching effects
        for completedResearch in gameState.completedResearches {
            guard let researchType = ResearchType.all.first(where: { $0.id == completedResearch.researchId }) else { continue }
            for effect in researchType.effects {
                switch effect {
                case .productionBonus(let buildingId, let bonus):
                    if building.type.id == buildingId {
                        multiplier *= bonus
                    }
                case .allProductionBonus(let bonus):
                    multiplier *= bonus
                case .insightProductionBonus(let bonus):
                    // Apply to buildings that produce insight (library, university)
                    if building.type.produces[.insight] != nil {
                        multiplier *= bonus
                    }
                case .foodProductionBonus(let bonus):
                    // Apply to buildings that produce food (farm, bakery, forager, smokehouse)
                    let producesFood = building.type.produces[.wheat] != nil
                        || building.type.produces[.bread] != nil
                        || building.type.produces[.berries] != nil
                    if producesFood {
                        multiplier *= bonus
                    }
                default:
                    break
                }
            }
        }

        return multiplier
    }

    // MARK: - Helpers

    /// Get productivity as a percentage string for display
    static func productivityPercentage(for building: Building, island: Island? = nil, gameState: GameState? = nil) -> String {
        let productivity = calculateProductivity(for: building, island: island, gameState: gameState)
        return String(format: "%.0f%%", productivity * 100)
    }

    /// Calculate actual production amount based on productivity
    static func calculateActualProduction(_ baseAmount: Int, productivity: Double) -> Int {
        return Int(round(Double(baseAmount) * productivity))
    }

    /// Calculate actual consumption amount based on productivity
    static func calculateActualConsumption(_ baseAmount: Int, productivity: Double) -> Int {
        return Int(round(Double(baseAmount) * productivity))
    }
}

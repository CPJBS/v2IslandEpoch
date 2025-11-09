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
    ///   - gameState: The current game state (for future research bonuses, etc.)
    /// - Returns: A multiplier between 0.0 and 1.0 representing productivity percentage
    static func calculateProductivity(for building: Building, gameState: GameState? = nil) -> Double {
        var productivity: Double = 1.0

        // 1. Worker-based productivity
        productivity *= workerProductivityMultiplier(for: building)

        // 2. STUB: Research bonuses (to be implemented later)
        // productivity *= researchProductivityMultiplier(gameState: gameState)

        // 3. STUB: Building level bonuses (to be implemented later)
        // productivity *= levelProductivityMultiplier(building.level)

        // 4. STUB: Island bonuses (to be implemented later)
        // productivity *= islandProductivityMultiplier(gameState: gameState)

        return min(productivity, 1.0) // Cap at 100%
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

    // MARK: - Future Productivity Factors (Stubs)

    /// STUB: Calculate productivity multiplier from research
    /// To be implemented when research system is added
    private static func researchProductivityMultiplier(gameState: GameState?) -> Double {
        // TODO: Implement research-based productivity bonuses
        // Example: gameState?.activeResearches.contains(.improvedFarming) ? 1.2 : 1.0
        return 1.0
    }

    /// STUB: Calculate productivity multiplier from building level
    /// To be implemented when building upgrade system is enhanced
    private static func levelProductivityMultiplier(_ level: Int) -> Double {
        // TODO: Implement level-based productivity bonuses
        // Example: 1.0 + (Double(level - 1) * 0.1) // +10% per level
        return 1.0
    }

    /// STUB: Calculate productivity multiplier from island bonuses
    /// To be implemented when island-specific bonuses are added
    private static func islandProductivityMultiplier(gameState: GameState?) -> Double {
        // TODO: Implement island-specific productivity bonuses
        // Example: Check for island traits, nearby buildings, etc.
        return 1.0
    }

    // MARK: - Helpers

    /// Get productivity as a percentage string for display
    static func productivityPercentage(for building: Building, gameState: GameState? = nil) -> String {
        let productivity = calculateProductivity(for: building, gameState: gameState)
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

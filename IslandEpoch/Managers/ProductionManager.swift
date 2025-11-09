//
//  ProductionManager.swift
//  IslandEpoch
//

import Foundation
import OSLog

@MainActor
class ProductionManager {
    
    // MARK: - Dependencies
    private let gameState: GameState
    
    init(gameState: GameState) {
        self.gameState = gameState
    }
    
    // MARK: - Public API
    
    /// Process one tick for all islands
    func processTick(gameState: inout GameState) {
        for index in gameState.islands.indices {
            processIslandTick(island: &gameState.islands[index])
        }
    }
    
    /// Calculate total production across all islands
    func totalProduction(gameState: GameState) -> Inventory {
        var total: Inventory = [:]

        for island in gameState.islands {
            for building in island.buildings.compactMap({ $0 }) {
                for (resource, amount) in building.type.produces {
                    total.add(resource, amount: amount)
                }
            }
        }

        return total
    }

    /// Calculate total consumption across all islands
    func totalConsumption(gameState: GameState) -> Inventory {
        var total: Inventory = [:]

        for island in gameState.islands {
            for building in island.buildings.compactMap({ $0 }) {
                for (resource, amount) in building.type.consumes {
                    total.add(resource, amount: amount)
                }
            }
        }

        return total
    }

    /// Calculate actual production per second across all islands (based on productivity and resource availability)
    func actualProductionRate(gameState: GameState) -> Inventory {
        var total: Inventory = [:]

        for island in gameState.islands {
            for building in island.buildings.compactMap({ $0 }) {
                // Calculate productivity based on assigned workers
                let productivity = ProductivityCalculator.calculateProductivity(for: building, gameState: gameState)

                // Skip if productivity is 0 (no workers assigned)
                guard productivity > 0 else {
                    continue
                }

                // Check if building has required input resources
                var canRun = true
                for (resource, baseAmount) in building.type.consumes {
                    let actualAmount = ProductivityCalculator.calculateActualConsumption(baseAmount, productivity: productivity)
                    if !island.inventory.has(resource, amount: actualAmount) {
                        canRun = false
                        break
                    }
                }

                // Only count production if building can actually run
                if canRun {
                    for (resource, baseAmount) in building.type.produces {
                        let actualAmount = ProductivityCalculator.calculateActualProduction(baseAmount, productivity: productivity)
                        total.add(resource, amount: actualAmount)
                    }
                }
            }
        }

        return total
    }

    /// Calculate actual consumption per second across all islands (based on productivity and resource availability)
    func actualConsumptionRate(gameState: GameState) -> Inventory {
        var total: Inventory = [:]

        for island in gameState.islands {
            for building in island.buildings.compactMap({ $0 }) {
                // Calculate productivity based on assigned workers
                let productivity = ProductivityCalculator.calculateProductivity(for: building, gameState: gameState)

                // Skip if productivity is 0 (no workers assigned)
                guard productivity > 0 else {
                    continue
                }

                // Check if building has required input resources
                var canRun = true
                for (resource, baseAmount) in building.type.consumes {
                    let actualAmount = ProductivityCalculator.calculateActualConsumption(baseAmount, productivity: productivity)
                    if !island.inventory.has(resource, amount: actualAmount) {
                        canRun = false
                        break
                    }
                }

                // Only count consumption if building can actually run
                if canRun {
                    for (resource, baseAmount) in building.type.consumes {
                        let actualAmount = ProductivityCalculator.calculateActualConsumption(baseAmount, productivity: productivity)
                        total.add(resource, amount: actualAmount)
                    }
                }
            }
        }

        return total
    }

    // MARK: - Private Methods
    
    private func processIslandTick(island: inout Island) {
        for building in island.buildings.compactMap({ $0 }) {
            // 1. Calculate productivity based on assigned workers and other factors
            let productivity = ProductivityCalculator.calculateProductivity(for: building, gameState: gameState)

            // Skip if productivity is 0 (no workers assigned)
            guard productivity > 0 else {
                continue
            }

            // 2. Calculate actual consumption based on productivity
            var actualConsumption: Inventory = [:]
            for (resource, baseAmount) in building.type.consumes {
                let actualAmount = ProductivityCalculator.calculateActualConsumption(baseAmount, productivity: productivity)
                actualConsumption[resource] = actualAmount
            }

            // 3. Check if we have enough input resources
            var canRun = true
            for (resource, amount) in actualConsumption {
                if !island.inventory.has(resource, amount: amount) {
                    canRun = false
                    break
                }
            }

            guard canRun else { continue }

            // 4. Consume inputs (productivity-adjusted)
            for (resource, amount) in actualConsumption {
                island.inventory.remove(resource, amount: amount)
            }

            // 5. Produce outputs (productivity-adjusted)
            for (resource, baseAmount) in building.type.produces {
                let actualAmount = ProductivityCalculator.calculateActualProduction(baseAmount, productivity: productivity)
                island.inventory.add(resource, amount: actualAmount)
            }
        }
    }
}

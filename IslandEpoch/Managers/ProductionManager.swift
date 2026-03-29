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
        // 1. Resource production per island
        for index in gameState.islands.indices {
            processIslandTick(island: &gameState.islands[index], gameState: gameState)
        }

        // 2. Gold production from buildings (apply gold income multiplier from research)
        let bonuses = ResearchEffectResolver.resolve(completedResearches: gameState.completedResearches)
        for island in gameState.islands {
            for building in island.buildings.compactMap({ $0 }) {
                guard !building.isUnderConstruction else { continue }
                guard building.type.goldProduction > 0 else { continue }

                let productivity = ProductivityCalculator.calculateProductivity(for: building, island: island, gameState: gameState)
                guard productivity > 0 else { continue }

                // Check if building has enough input resources
                var canRun = true
                for (resource, baseAmount) in building.type.consumes {
                    let actualAmount = ProductivityCalculator.calculateActualConsumption(baseAmount, productivity: productivity)
                    if !island.inventory.has(resource, amount: actualAmount) {
                        canRun = false
                        break
                    }
                }

                guard canRun else { continue }

                // Note: inputs already deducted in processIslandTick for buildings that also produce resources
                // For gold-only buildings (no resource output), we need to deduct inputs here
                if building.type.produces.isEmpty {
                    // Find island index to mutate
                    if let islandIdx = gameState.islands.firstIndex(where: { $0.id == island.id }) {
                        for (resource, baseAmount) in building.type.consumes {
                            let actualAmount = ProductivityCalculator.calculateActualConsumption(baseAmount, productivity: productivity)
                            gameState.islands[islandIdx].inventory.remove(resource, amount: actualAmount)
                        }
                    }
                }

                let goldAmount = Int(Double(building.type.goldProduction) * productivity * bonuses.goldIncomeMultiplier)
                gameState.gold += goldAmount
            }
        }

        // 3. Food consumption
        for i in 0..<gameState.islands.count {
            let assignedWorkers = gameState.islands[i].totalWorkersAssigned
            guard assignedWorkers > 0 else {
                gameState.islands[i].isHungry = false
                continue
            }

            var foodNeeded = Int(ceil(Double(assignedWorkers) / 5.0))

            // Consume bread first (2 food value each)
            let breadAvailable = gameState.islands[i].inventory[.bread] ?? 0
            let breadToConsume = min(breadAvailable, Int(ceil(Double(foodNeeded) / 2.0)))
            if breadToConsume > 0 {
                gameState.islands[i].inventory.remove(.bread, amount: breadToConsume)
                foodNeeded -= breadToConsume * 2
            }

            // Then berries (1 food value each)
            if foodNeeded > 0 {
                let berriesAvailable = gameState.islands[i].inventory[.berries] ?? 0
                let berriesToConsume = min(berriesAvailable, foodNeeded)
                if berriesToConsume > 0 {
                    gameState.islands[i].inventory.remove(.berries, amount: berriesToConsume)
                    foodNeeded -= berriesToConsume
                }
            }

            gameState.islands[i].isHungry = foodNeeded > 0
        }

        // 4. Enforce storage caps (with research bonus)
        for i in 0..<gameState.islands.count {
            for resourceType in ResourceType.allCases {
                let cap = gameState.islands[i].storageCapForCategory(resourceType.category, bonusPercent: bonuses.storageBonusPercent)
                let current = gameState.islands[i].inventory[resourceType] ?? 0
                if current > cap {
                    gameState.islands[i].inventory[resourceType] = cap
                }
            }
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
                let productivity = ProductivityCalculator.calculateProductivity(for: building, island: island, gameState: gameState)

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
                let productivity = ProductivityCalculator.calculateProductivity(for: building, island: island, gameState: gameState)

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
    
    private func processIslandTick(island: inout Island, gameState: GameState) {
        for building in island.buildings.compactMap({ $0 }) {
            // Skip buildings under construction
            guard !building.isUnderConstruction else { continue }

            // 1. Calculate productivity based on assigned workers and other factors
            let productivity = ProductivityCalculator.calculateProductivity(for: building, island: island, gameState: gameState)

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

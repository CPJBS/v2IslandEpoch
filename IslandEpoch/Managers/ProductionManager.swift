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
            for building in island.buildings {
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
            for building in island.buildings {
                for (resource, amount) in building.type.consumes {
                    total.add(resource, amount: amount)
                }
            }
        }

        return total
    }
    
    // MARK: - Private Methods
    
    private func processIslandTick(island: inout Island) {
        for building in island.buildings {
            // 1. Check worker requirement
            guard island.workersAvailable >= building.type.workers else {
                continue
            }
            
            // 2. Check input resources
            var canRun = true
            for (resource, amount) in building.type.consumes {
                if !island.inventory.has(resource, amount: amount) {
                    canRun = false
                    break
                }
            }
            
            guard canRun else { continue }
            
            // 3. Consume inputs
            for (resource, amount) in building.type.consumes {
                island.inventory.remove(resource, amount: amount)
            }
            
            // 4. Produce outputs
            for (resource, amount) in building.type.produces {
                island.inventory.add(resource, amount: amount)
            }
        }
    }
}

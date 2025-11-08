//
//  Island.swift
//  IslandEpoch
//
//  Created by Casper Stienstra on 13/05/2025.
//

import Foundation

/// One placed building on an island
struct BuildingInstance: Identifiable, Codable {
    var id = UUID()
    let type: BuildingType
}

/// Represents a single island with its own workers, inventory and buildings
struct Island: Identifiable, Codable {
    var id = UUID()
    var name: String
    
    // Core resources & workers
    var inventory: Inventory = [:]
    var workersAvailable: Int
    
    // Construction slots
    var buildings: [BuildingInstance] = []
    let maxSlots: Int
    
    // MARK: - Build / Tick helpers
    
    /// Tries to add a building; returns success
    mutating func addBuilding(_ type: BuildingType) -> Bool {
        guard buildings.count < maxSlots else { return false }
        buildings.append(BuildingInstance(type: type))
        return true
    }
    
    /// Runs one “tick”—returns produced & consumed totals (debug use)
    mutating func processTick() -> (produced: Inventory, consumed: Inventory) {
        var produced: Inventory = [:]
        var consumed: Inventory = [:]
        
        for building in buildings {
            // 1. Check worker requirement
            guard workersAvailable >= building.type.workers else { continue }
            
            // 2. Check input resources
            var canRun = true
            for (rid, qty) in building.type.consumes {
                if inventory[rid, default: 0] < qty { canRun = false; break }
            }
            if !canRun { continue }
            
            // 3. Consume inputs
            for (rid, qty) in building.type.consumes {
                inventory.consume(rid, qty)
                consumed.add(rid, qty)
            }
            // 4. Produce outputs
            for (rid, qty) in building.type.produces {
                inventory.add(rid, qty)
                produced.add(rid, qty)
            }
        }
        return (produced, consumed)
    }
}

//  GameBrain.swift
//  IslandEpoch
//
//  Very first, super‑simple simulation engine.
//  One tick (we'll call it a "day") grows wheat
//  and counts how many ticks have passed.

import Foundation

struct GameBrain: Codable {
    var tick: Int = 0
    var gold: Int = 0
    var hasResearchedTrade: Bool = false
    var islands: [Island] = []
    
    static func demo() -> GameBrain {
        var main = Island(name: "Main Isle",
                          workersAvailable: 6,
                          maxSlots: 4)
        var iron = Island(name: "Ironcliff",
                          workersAvailable: 5,
                          maxSlots: 4)
        
        _ = main.addBuilding(.farm)
        _ = main.addBuilding(.forester)
        _ = iron.addBuilding(.mine)
        main.inventory = [.wheat: 10, .wood: 5]
        
        return GameBrain(
            tick: 0,
            gold: 300,
            hasResearchedTrade: false,
            islands: [main, iron]
        )
    }
    
    mutating func advanceOneTick() {
        tick += 1
        // Example: award 1 gold per tick
        gold += 1
        for idx in islands.indices {
            _ = islands[idx].processTick()
        }
    }
}

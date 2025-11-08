//
//  GameState.swift
//  IslandEpoch
//

import Foundation
import OSLog

/// Single source of truth for all game data
struct GameState: Codable {
    
    // MARK: - Time Tracking
    var tick: Int = 0
    var totalGameTime: TimeInterval = 0
    var gameStartTime: Date = Date()
    var lastUpdateTime: Date = Date()
    
    // MARK: - Economy
    var gold: Int = 0
    
    // MARK: - Territory
    var islands: [Island] = []
    
    // MARK: - Progression
    var hasResearchedTrade: Bool = false
    
    // MARK: - Computed Properties
    
    var mainIsland: Island? {
        islands.first
    }
    
    var totalPopulation: Int {
        islands.reduce(0) { $0 + $1.workersAvailable }
    }
    
    var totalGoldIncome: Int {
        // Future: calculate from buildings
        return 1
    }
    
    // MARK: - Demo/Initial State
    
    static func demo() -> GameState {
        var state = GameState()
        
        // Create main island
        var mainIsland = Island(
            name: "Main Isle",
            workersAvailable: 10,
            maxSlots: 6
        )
        mainIsland.inventory = [.wheat: 0, .wood: 0, .ironOre: 0]
        
        // Create secondary island
        var ironIsland = Island(
            name: "Ironcliff",
            workersAvailable: 5,
            maxSlots: 4
        )
        ironIsland.inventory = [.wheat: 0, .wood: 0, .ironOre: 0]
        
        state.islands = [mainIsland, ironIsland]
        state.gold = 500
        state.gameStartTime = Date()
        state.lastUpdateTime = Date()
        
        return state
    }
    
    // MARK: - Initialization
    
    mutating func reset() {
        self = GameState.demo()
        AppLogger.general.info("GameState reset to demo state")
    }
}

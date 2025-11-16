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
    var epochTracker: EpochTracker = EpochTracker()
    var hasResearchedTrade: Bool = false
    var completedResearches: [CompletedResearch] = []
    
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

    /// Check if a specific research has been completed
    func hasCompletedResearch(_ researchId: String) -> Bool {
        return completedResearches.contains { $0.researchId == researchId }
    }
    
    // MARK: - Demo/Initial State
    
    static func demo() -> GameState {
        var state = GameState()

        // Create main island with starting tent
        var mainIsland = Island(
            name: "Main Isle",
            maxSlots: 6,
            fertilities: [.grainland, .forest, .wildlife]
        )
        mainIsland.inventory = [.wheat: 0, .wood: 0, .ironOre: 0]
        // Add starting tent at first slot
        mainIsland.buildings[0] = Building(id: UUID(), type: .tent)

        // Create secondary island with starting tent
        // Note: Unlock requirements stubbed for playtesting (would require "exploration" research)
        var ironIsland = Island(
            name: "Ironcliff",
            maxSlots: 4,
            fertilities: [.ironDeposits, .forest],
            unlockRequirements: ["exploration"] // Stubbed for future use
        )
        ironIsland.inventory = [.wheat: 0, .wood: 0, .ironOre: 0]
        // Add starting tent at first slot
        ironIsland.buildings[0] = Building(id: UUID(), type: .tent)

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

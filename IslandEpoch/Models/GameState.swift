//
//  GameState.swift
//  IslandEpoch
//

import Foundation
import OSLog

/// Active research timer state
struct ActiveResearch: Codable {
    let researchId: String
    let startTime: Date
    let duration: TimeInterval

    var isComplete: Bool { Date().timeIntervalSince(startTime) >= duration }
    var timeRemaining: TimeInterval { max(duration - Date().timeIntervalSince(startTime), 0) }
    var progress: Double { min(Date().timeIntervalSince(startTime) / duration, 1.0) }
}

/// Player settings
struct GameSettings: Codable {
    var notificationsEnabled: Bool = true
    var constructionNotifications: Bool = true
    var researchNotifications: Bool = true
    var storageNotifications: Bool = true
    var idleReminders: Bool = true
    var hapticsEnabled: Bool = true
    var soundEnabled: Bool = true
    var confirmDemolish: Bool = true
    var compactNumbers: Bool = false
}

/// Lifetime statistics
struct GameStatistics: Codable {
    var totalTicksPlayed: Int = 0
    var totalBuildingsConstructed: Int = 0
    var totalBuildingsDemolished: Int = 0
    var totalResearchCompleted: Int = 0
    var totalGoldEarned: Int = 0
    var totalGoldSpent: Int = 0
    var totalGemsEarned: Int = 0
    var totalGemsSpent: Int = 0
    var totalResourcesProduced: [String: Int] = [:]
    var totalResourcesConsumed: [String: Int] = [:]
    var totalOfflineSeconds: Double = 0
    var highestPopulation: Int = 0
    var sessionsCount: Int = 0
}

/// Daily login tracking
struct DailyLoginState: Codable {
    var lastClaimDate: Date? = nil
    var currentStreak: Int = 0
    var totalDaysClaimed: Int = 0
}

/// Single source of truth for all game data
struct GameState: Codable {

    // MARK: - Time Tracking
    var tick: Int = 0
    var totalGameTime: TimeInterval = 0
    var gameStartTime: Date = Date()
    var lastUpdateTime: Date = Date()

    // MARK: - Economy
    var gold: Int = 0
    var gems: Int = 0

    // MARK: - Territory
    var islands: [Island] = []

    // MARK: - Progression
    var epochTracker: EpochTracker = EpochTracker()
    var completedResearches: [CompletedResearch] = []
    var activeResearch: ActiveResearch? = nil

    // MARK: - Meta
    var settings: GameSettings = GameSettings()
    var statistics: GameStatistics = GameStatistics()
    var dailyLogin: DailyLoginState = DailyLoginState()
    var completedAchievements: Set<String> = []
    var tutorialStep: Int = 0

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
    
    // MARK: - Codable with migration support

    enum CodingKeys: String, CodingKey {
        case tick, totalGameTime, gameStartTime, lastUpdateTime
        case gold, gems
        case islands
        case epochTracker, completedResearches, activeResearch
        case settings, statistics, dailyLogin, completedAchievements, tutorialStep
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Time Tracking
        tick = try container.decode(Int.self, forKey: .tick)
        totalGameTime = try container.decode(TimeInterval.self, forKey: .totalGameTime)
        gameStartTime = try container.decode(Date.self, forKey: .gameStartTime)
        lastUpdateTime = try container.decode(Date.self, forKey: .lastUpdateTime)

        // Economy
        gold = try container.decode(Int.self, forKey: .gold)
        gems = (try? container.decodeIfPresent(Int.self, forKey: .gems)) ?? 0

        // Territory
        islands = try container.decode([Island].self, forKey: .islands)

        // Progression
        epochTracker = try container.decode(EpochTracker.self, forKey: .epochTracker)
        completedResearches = try container.decode([CompletedResearch].self, forKey: .completedResearches)
        activeResearch = try container.decodeIfPresent(ActiveResearch.self, forKey: .activeResearch)

        // Meta (all new, all with defaults)
        settings = (try? container.decodeIfPresent(GameSettings.self, forKey: .settings)) ?? GameSettings()
        statistics = (try? container.decodeIfPresent(GameStatistics.self, forKey: .statistics)) ?? GameStatistics()
        dailyLogin = (try? container.decodeIfPresent(DailyLoginState.self, forKey: .dailyLogin)) ?? DailyLoginState()
        completedAchievements = (try? container.decodeIfPresent(Set<String>.self, forKey: .completedAchievements)) ?? []
        tutorialStep = (try? container.decodeIfPresent(Int.self, forKey: .tutorialStep)) ?? 0
    }

    // MARK: - Demo/Initial State

    static func demo() -> GameState {
        var state = GameState()

        let defaultInventory: Inventory = [
            .wheat: 0, .wood: 0, .ironOre: 0, .bread: 0, .berries: 0, .insight: 0,
            .stone: 0, .planks: 0, .ironBars: 0, .tools: 0, .herbs: 0, .coal: 0
        ]

        // Island 1: Main Isle
        var mainIsland = Island(
            name: "Main Isle",
            maxSlots: 8,
            fertilities: [.grainland, .forest, .wildlife]
        )
        mainIsland.inventory = defaultInventory
        mainIsland.buildings[0] = Building(id: UUID(), type: .tent)

        // Island 2: Ironcliff
        var ironcliff = Island(
            name: "Ironcliff",
            maxSlots: 6,
            fertilities: [.ironDeposits, .forest, .stoneDeposits],
            unlockRequirements: ["e3_exploration"]
        )
        ironcliff.inventory = defaultInventory

        // Island 3: Coral Atoll
        var coralAtoll = Island(
            name: "Coral Atoll",
            maxSlots: 5,
            fertilities: [.wildlife, .grainland],
            unlockRequirements: ["e4_navigation"]
        )
        coralAtoll.inventory = defaultInventory

        // Island 4: Stormwatch
        var stormwatch = Island(
            name: "Stormwatch",
            maxSlots: 7,
            fertilities: [.stoneDeposits, .coalVeins, .forest],
            unlockRequirements: ["e6_cartography"]
        )
        stormwatch.inventory = defaultInventory

        // Island 5: Frostveil
        var frostveil = Island(
            name: "Frostveil",
            maxSlots: 8,
            fertilities: [.coalVeins, .ironDeposits],
            unlockRequirements: ["e7_expedition"]
        )
        frostveil.inventory = defaultInventory

        state.islands = [mainIsland, ironcliff, coralAtoll, stormwatch, frostveil]
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

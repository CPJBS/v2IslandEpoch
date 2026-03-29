//
//  AchievementManager.swift
//  IslandEpoch
//

import Foundation

class AchievementManager {

    /// Check all achievements and return newly earned IDs
    static func checkAchievements(gameState: GameState) -> [String] {
        var newlyEarned: [String] = []

        let completed = gameState.completedAchievements
        let totalBuildings = gameState.islands.reduce(0) { count, island in
            count + island.buildings.compactMap({ $0 }).filter({ !$0.isUnderConstruction }).count
        }
        let totalWorkers = gameState.islands.reduce(0) { $0 + $1.workersAvailable }
        let completedResearchCount = gameState.completedResearches.count
        let unlockedIslands = gameState.islands.filter {
            $0.unlockRequirements.isEmpty || $0.unlockRequirements.allSatisfy { req in
                gameState.completedResearches.contains(where: { $0.researchId == req })
            }
        }.count
        let currentEpoch = gameState.epochTracker.currentEpoch
        let maxBuildingLevel = gameState.islands.flatMap { $0.buildings.compactMap { $0 } }.map { $0.level }.max() ?? 0
        let totalPlaySeconds = Double(gameState.statistics.totalTicksPlayed)

        // Building achievements
        if totalBuildings >= 1 { check("build_first", &newlyEarned, completed) }
        if totalBuildings >= 10 { check("build_10", &newlyEarned, completed) }
        if totalBuildings >= 20 { check("build_20", &newlyEarned, completed) }
        if maxBuildingLevel >= 2 { check("upgrade_first", &newlyEarned, completed) }
        if maxBuildingLevel >= 3 { check("max_level", &newlyEarned, completed) }

        // Resource achievements
        if gameState.gold >= 1000 { check("gold_1000", &newlyEarned, completed) }
        if gameState.gold >= 10000 { check("gold_10000", &newlyEarned, completed) }
        if gameState.gold >= 100000 { check("gold_100000", &newlyEarned, completed) }

        // Epoch achievements
        if currentEpoch >= 2 { check("epoch_2", &newlyEarned, completed) }
        if currentEpoch >= 5 { check("epoch_5", &newlyEarned, completed) }
        if currentEpoch >= 8 { check("epoch_8", &newlyEarned, completed) }
        if currentEpoch >= 10 { check("epoch_10", &newlyEarned, completed) }

        // Island achievements
        if unlockedIslands >= 2 { check("island_2", &newlyEarned, completed) }
        if unlockedIslands >= 5 { check("island_all", &newlyEarned, completed) }

        // Worker achievements
        if totalWorkers >= 10 { check("workers_10", &newlyEarned, completed) }
        if totalWorkers >= 50 { check("workers_50", &newlyEarned, completed) }
        if totalWorkers >= 100 { check("workers_100", &newlyEarned, completed) }

        // Research achievements
        if completedResearchCount >= 1 { check("research_first", &newlyEarned, completed) }
        if completedResearchCount >= 5 { check("research_5", &newlyEarned, completed) }
        if completedResearchCount >= 15 { check("research_all", &newlyEarned, completed) }

        // Engagement achievements
        if totalPlaySeconds >= 3600 { check("play_1h", &newlyEarned, completed) }
        if totalPlaySeconds >= 36000 { check("play_10h", &newlyEarned, completed) }
        if gameState.dailyLogin.currentStreak >= 7 { check("login_7", &newlyEarned, completed) }

        return newlyEarned
    }

    private static func check(_ id: String, _ newlyEarned: inout [String], _ completed: Set<String>) {
        if !completed.contains(id) {
            newlyEarned.append(id)
        }
    }
}

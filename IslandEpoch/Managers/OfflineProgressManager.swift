//
//  OfflineProgressManager.swift
//  IslandEpoch
//

import Foundation

struct OfflineReport {
    var resourcesGained: [ResourceType: Int] = [:]
    var goldEarned: Int = 0
    var completedBuildings: [(islandIndex: Int, buildingName: String)] = []
    var completedResearch: String? = nil
    var storageFullWarnings: [String] = []
    var timeAway: TimeInterval = 0
}

class OfflineProgressManager {

    static func calculateOfflineProgress(gameState: inout GameState, elapsedSeconds: TimeInterval) -> OfflineReport {
        var report = OfflineReport()
        report.timeAway = elapsedSeconds

        // Cap at 8 hours
        let cappedElapsed = min(elapsedSeconds, 28800)

        // 1. Complete construction timers
        for islandIdx in 0..<gameState.islands.count {
            for slotIdx in 0..<gameState.islands[islandIdx].buildings.count {
                if let building = gameState.islands[islandIdx].buildings[slotIdx],
                   building.constructionStartTime != nil && !building.isUnderConstruction {
                    gameState.islands[islandIdx].buildings[slotIdx]?.completeConstruction()
                    report.completedBuildings.append((islandIdx, building.type.name))
                }
            }
        }

        // 2. Complete research timer
        if let research = gameState.activeResearch, research.isComplete {
            let researchId = research.researchId
            gameState.activeResearch = nil
            if let researchType = ResearchType.all.first(where: { $0.id == researchId }) {
                report.completedResearch = researchType.name
            }
            gameState.completedResearches.append(CompletedResearch(researchId: researchId))

            // Check epoch advancement
            let completedIds = gameState.completedResearches.map { $0.researchId }
            if gameState.epochTracker.canAdvanceEpoch(completedResearchIds: completedIds) {
                gameState.epochTracker.advanceEpoch()
            }
        }

        // 3. Calculate offline production (0.5x multiplier)
        let offlineMultiplier = 0.5
        let bonuses = ResearchEffectResolver.resolve(completedResearches: gameState.completedResearches)

        for islandIdx in 0..<gameState.islands.count {
            let island = gameState.islands[islandIdx]

            // Calculate net production rates for this island
            var netRates: [ResourceType: Double] = [:]

            for building in island.buildings.compactMap({ $0 }) {
                // Skip under-construction buildings
                guard !building.isUnderConstruction else { continue }
                guard building.type.workers == 0 || building.assignedWorkers > 0 else { continue }

                // Use ProductivityCalculator for consistent level/research multiplier
                let effectiveProductivity = ProductivityCalculator.calculateProductivity(for: building, island: island, gameState: gameState)

                // Production
                for (resource, amount) in building.type.produces {
                    netRates[resource, default: 0] += Double(amount) * effectiveProductivity
                }

                // Consumption
                for (resource, amount) in building.type.consumes {
                    netRates[resource, default: 0] -= Double(amount) * effectiveProductivity
                }
            }

            // Apply rates with offline multiplier and storage caps
            for (resource, rate) in netRates {
                let netGain = rate * offlineMultiplier * cappedElapsed
                if netGain > 0 {
                    let cap = island.storageCapForCategory(resource.category, bonusPercent: bonuses.storageBonusPercent)
                    let current = island.inventory[resource] ?? 0
                    let maxGain = max(0, cap - current)
                    let actualGain = min(Int(netGain), maxGain)
                    if actualGain > 0 {
                        gameState.islands[islandIdx].inventory.add(resource, amount: actualGain)
                        report.resourcesGained[resource, default: 0] += actualGain
                    }
                    if maxGain == 0 {
                        report.storageFullWarnings.append("\(resource.displayName) on \(island.name)")
                    }
                } else if netGain < 0 {
                    let current = gameState.islands[islandIdx].inventory[resource] ?? 0
                    let loss = min(current, Int(abs(netGain)))
                    gameState.islands[islandIdx].inventory.remove(resource, amount: loss)
                }
            }

            // Gold from buildings
            for building in island.buildings.compactMap({ $0 }) {
                guard !building.isUnderConstruction else { continue }
                guard building.type.goldProduction > 0 else { continue }
                guard building.assignedWorkers > 0 else { continue }
                let productivity = Double(building.assignedWorkers) / max(Double(building.type.workers), 1)
                let goldGain = Int(Double(building.type.goldProduction) * productivity * offlineMultiplier * cappedElapsed * bonuses.goldIncomeMultiplier)
                report.goldEarned += goldGain
            }
        }

        // Passive gold (with research bonuses)
        let basePassiveGold = 1 + bonuses.extraGoldPerTick
        let passiveGold = Int(Double(basePassiveGold) * bonuses.goldIncomeMultiplier * offlineMultiplier * cappedElapsed)
        report.goldEarned += passiveGold
        gameState.gold += report.goldEarned

        // Update statistics
        gameState.statistics.totalOfflineSeconds += cappedElapsed
        gameState.statistics.totalGoldEarned += report.goldEarned

        return report
    }
}

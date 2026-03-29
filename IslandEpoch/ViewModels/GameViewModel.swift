//
//  GameViewModel.swift
//  IslandEpoch
//

import Foundation
import Combine
import SwiftUI
import OSLog

@MainActor
final class GameViewModel: ObservableObject {
    
    // MARK: - Published State
    @Published var gameState: GameState
    @Published var currentIslandIndex: Int = 0

    // MARK: - Managers
    private let buildingManager: BuildingManager
    private let productionManager: ProductionManager
    private let saveManager: SaveManager
    
    // MARK: - Timer
    private var timer: AnyCancellable?
    
    // MARK: - Initialization
    
    init() {
        let saveManager = SaveManager()
        
        let loadedGameState: GameState
        switch saveManager.load() {
        case .success(let state):
            loadedGameState = state
            AppLogger.general.info("Loaded existing game (tick: \(state.tick))")
        case .failure:
            loadedGameState = GameState.demo()
            AppLogger.general.info("Created new game")
        }
        
        self.gameState = loadedGameState
        self.saveManager = saveManager
        self.buildingManager = BuildingManager(gameState: loadedGameState)
        self.productionManager = ProductionManager(gameState: loadedGameState)
    }
    
    // MARK: - Game Control
    
    func start() {
        guard timer == nil else { return }
        
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
        
        AppLogger.gameLoop.info("Game loop started")
    }
    
    func stop() {
        timer?.cancel()
        timer = nil
        AppLogger.gameLoop.info("Game loop stopped")
    }
    
    private func tick() {
        // 1. Update time
        gameState.tick += 1
        let now = Date()
        let delta = now.timeIntervalSince(gameState.lastUpdateTime)
        gameState.totalGameTime += delta
        gameState.lastUpdateTime = now

        // 2. Check construction timers
        for islandIdx in 0..<gameState.islands.count {
            for slotIdx in 0..<gameState.islands[islandIdx].buildings.count {
                if let building = gameState.islands[islandIdx].buildings[slotIdx],
                   building.constructionStartTime != nil && !building.isUnderConstruction {
                    // Timer expired -- complete construction
                    gameState.islands[islandIdx].buildings[slotIdx]?.completeConstruction()
                    gameState.statistics.totalBuildingsConstructed += 1
                }
            }
        }

        // 3. Check research timer
        if let research = gameState.activeResearch, research.isComplete {
            let researchId = research.researchId
            gameState.activeResearch = nil
            gameState.completedResearches.append(CompletedResearch(researchId: researchId))
            gameState.statistics.totalResearchCompleted += 1

            // Check epoch advancement
            let completedIds = gameState.completedResearches.map { $0.researchId }
            if gameState.epochTracker.canAdvanceEpoch(completedResearchIds: completedIds) {
                gameState.epochTracker.advanceEpoch()
            }
        }

        // 4. Passive gold income (building gold handled in ProductionManager)
        let bonuses = ResearchEffectResolver.resolve(completedResearches: gameState.completedResearches)
        let baseGold = 1 + bonuses.extraGoldPerTick
        let totalPassiveGold = Int(Double(baseGold) * bonuses.goldIncomeMultiplier)
        gameState.gold += totalPassiveGold

        // 5. Production
        productionManager.processTick(gameState: &gameState)

        // 6. Update statistics
        gameState.statistics.totalTicksPlayed += 1
        gameState.statistics.totalGoldEarned += totalPassiveGold
        let totalPop = gameState.islands.reduce(0) { $0 + $1.workersAvailable(extraPerHousing: bonuses.extraWorkersPerHousing, housingBonusPercent: bonuses.housingCapacityBonusPercent) }
        gameState.statistics.highestPopulation = max(gameState.statistics.highestPopulation, totalPop)

        // 7. Check achievements every 10 ticks
        if gameState.tick % 10 == 0 {
            let newAchievements = AchievementManager.checkAchievements(gameState: gameState)
            for achievementId in newAchievements {
                gameState.completedAchievements.insert(achievementId)
                if let def = AchievementCatalog.all.first(where: { $0.id == achievementId }) {
                    awardGems(def.gemReward, source: "achievement_\(achievementId)")
                }
                HapticManager.success()
            }
        }

        // 8. Auto-save every 10 ticks
        if gameState.tick % 10 == 0 {
            saveGame()
        }

        // 9. Trigger UI update
        objectWillChange.send()
    }
    
    // MARK: - Research Actions

    func completeResearch(_ researchId: String) -> Result<Void, ResearchError> {
        // Check if research already active
        guard gameState.activeResearch == nil else {
            return .failure(.researchAlreadyActive)
        }

        // Find the research
        guard let research = ResearchType.all.first(where: { $0.id == researchId }) else {
            return .failure(.researchNotFound)
        }

        // Check if already completed
        let completedIds = gameState.completedResearches.map { $0.researchId }
        guard !completedIds.contains(researchId) else {
            return .failure(.alreadyCompleted)
        }

        // Check epoch requirement
        guard gameState.epochTracker.currentEpoch >= research.requiredEpoch else {
            return .failure(.epochRequirementNotMet)
        }

        // Check prerequisites
        for prereq in research.prerequisiteIds {
            if !completedIds.contains(prereq) {
                return .failure(.prerequisiteNotMet)
            }
        }

        // Check costs (from main island)
        for (resource, amount) in research.cost {
            guard (gameState.islands.first?.inventory[resource] ?? 0) >= amount else {
                return .failure(.insufficientResources)
            }
        }

        // Deduct costs
        for (resource, amount) in research.cost {
            gameState.islands[0].inventory.remove(resource, amount: amount)
        }

        // Start research timer (apply research speed bonus)
        let researchBonuses = ResearchEffectResolver.resolve(completedResearches: gameState.completedResearches)
        let adjustedDuration = research.researchTime * researchBonuses.researchTimeMultiplier
        gameState.activeResearch = ActiveResearch(
            researchId: researchId,
            startTime: Date(),
            duration: adjustedDuration
        )

        objectWillChange.send()
        return .success(())
    }

    // MARK: - Building Actions

    func buildBuilding(
        _ type: BuildingType,
        onIslandIndex index: Int,
        atSlotIndex slotIndex: Int? = nil
    ) -> Result<UUID, BuildError> {
        guard index < gameState.islands.count else {
            return .failure(.buildingNotFound)
        }

        let result = buildingManager.build(
            type,
            onIslandIndex: index,
            atSlotIndex: slotIndex,
            gameState: &gameState
        )
        if case .success = result { HapticManager.success() }
        return result
    }

    func demolishBuilding(
        _ buildingId: UUID,
        fromIslandIndex index: Int
    ) -> Result<Void, BuildError> {
        guard index < gameState.islands.count else {
            return .failure(.buildingNotFound)
        }

        return buildingManager.demolish(
            buildingId: buildingId,
            fromIslandIndex: index,
            gameState: &gameState
        )
    }

    func upgradeBuilding(buildingId: UUID, on islandIndex: Int) -> Result<Void, BuildError> {
        // Find the building to calculate its max level
        guard islandIndex < gameState.islands.count,
              let building = gameState.islands[islandIndex].buildings.first(where: { $0?.id == buildingId }) ?? nil else {
            return .failure(.buildingNotFound)
        }
        let maxLevel = maxLevelForBuilding(building)
        let result = buildingManager.upgrade(buildingId: buildingId, on: islandIndex, maxLevel: maxLevel, in: &gameState)
        if case .success = result { HapticManager.success() }
        objectWillChange.send()
        return result
    }

    /// Calculate the maximum level a building can reach based on epoch and tier research
    func maxLevelForBuilding(_ building: Building) -> Int {
        // Epoch-based cap: (currentEpoch - buildingEpoch + 1) * 10
        let epochCap = (gameState.epochTracker.currentEpoch - building.type.availableFromEpoch + 1) * 10

        // Tier research cap: starts at 10 (base), increases by 10 per completed tier research
        let tierResearchIds = [
            "e1_shelter", "e2_settlement_walls", "e3_fortification", "e4_ore_refinement",
            "e5_metalworking_tiers", "e6_colonial_mastery", "e7_blast_furnace",
            "e8_mass_production", "e9_logistics_mastery", "e10_master_builders"
        ]
        var tierCap = 10 // Base: levels 1-10 always available
        for researchId in tierResearchIds {
            if completedResearchIds.contains(researchId) {
                tierCap += 10
            } else {
                break // Must be sequential
            }
        }

        return min(epochCap, min(tierCap, 100))
    }

    // MARK: - Speed Up & Gems

    func speedUpConstruction(buildingId: UUID, on islandIndex: Int) -> (cost: Int, success: Bool) {
        let cost = buildingManager.speedUpConstruction(buildingId: buildingId, on: islandIndex, in: &gameState)
        objectWillChange.send()
        return (cost, cost == 0 || gameState.gems >= 0) // Already deducted if successful
    }

    func speedUpResearch() -> (cost: Int, success: Bool) {
        guard let research = gameState.activeResearch else { return (0, false) }
        let remaining = research.timeRemaining
        if remaining <= 30 {
            // Free complete
            let researchId = research.researchId
            gameState.activeResearch = nil
            gameState.completedResearches.append(CompletedResearch(researchId: researchId))
            let completedIds = gameState.completedResearches.map { $0.researchId }
            if gameState.epochTracker.canAdvanceEpoch(completedResearchIds: completedIds) {
                gameState.epochTracker.advanceEpoch()
            }
            gameState.statistics.totalResearchCompleted += 1
            objectWillChange.send()
            return (0, true)
        }
        let gemCost = max(1, Int(ceil(remaining / 60.0)))
        guard gameState.gems >= gemCost else { return (gemCost, false) }
        gameState.gems -= gemCost
        gameState.statistics.totalGemsSpent += gemCost
        // Complete research
        let researchId = research.researchId
        gameState.activeResearch = nil
        gameState.completedResearches.append(CompletedResearch(researchId: researchId))
        let completedIds = gameState.completedResearches.map { $0.researchId }
        if gameState.epochTracker.canAdvanceEpoch(completedResearchIds: completedIds) {
            gameState.epochTracker.advanceEpoch()
        }
        gameState.statistics.totalResearchCompleted += 1
        objectWillChange.send()
        return (gemCost, true)
    }

    func awardGems(_ amount: Int, source: String = "") {
        gameState.gems += amount
        gameState.statistics.totalGemsEarned += amount
        objectWillChange.send()
    }

    // MARK: - Storage

    func upgradeStorage(on islandIndex: Int, category: ResourceCategory) -> Bool {
        guard islandIndex >= 0 && islandIndex < gameState.islands.count else { return false }
        let cost = gameState.islands[islandIndex].storageUpgradeCost(category: category)
        guard gameState.gold >= cost else { return false }
        gameState.gold -= cost
        gameState.statistics.totalGoldSpent += cost
        gameState.islands[islandIndex].upgradeStorage(category: category)
        objectWillChange.send()
        return true
    }

    // MARK: - Worker Assignment

    /// Assign a worker to a building
    func assignWorker(to buildingId: UUID, onIslandIndex islandIndex: Int) -> Result<Void, WorkerAssignmentError> {
        guard islandIndex < gameState.islands.count else {
            return .failure(.invalidIsland)
        }

        guard let buildingIndex = gameState.islands[islandIndex].buildings.firstIndex(where: { $0?.id == buildingId }) else {
            return .failure(.buildingNotFound)
        }

        guard var building = gameState.islands[islandIndex].buildings[buildingIndex] else {
            return .failure(.buildingNotFound)
        }

        // Check if building can accept more workers
        guard building.assignedWorkers < building.type.workers else {
            return .failure(.buildingFull)
        }

        // Check if island has unassigned workers
        guard gameState.islands[islandIndex].unassignedWorkers > 0 else {
            return .failure(.noWorkersAvailable)
        }

        // Assign the worker
        building.assignedWorkers += 1
        gameState.islands[islandIndex].buildings[buildingIndex] = building

        return .success(())
    }

    /// Unassign a worker from a building
    func unassignWorker(from buildingId: UUID, onIslandIndex islandIndex: Int) -> Result<Void, WorkerAssignmentError> {
        guard islandIndex < gameState.islands.count else {
            return .failure(.invalidIsland)
        }

        guard let buildingIndex = gameState.islands[islandIndex].buildings.firstIndex(where: { $0?.id == buildingId }) else {
            return .failure(.buildingNotFound)
        }

        guard var building = gameState.islands[islandIndex].buildings[buildingIndex] else {
            return .failure(.buildingNotFound)
        }

        // Check if building has workers to unassign
        guard building.assignedWorkers > 0 else {
            return .failure(.noWorkersAssigned)
        }

        // Unassign the worker
        building.assignedWorkers -= 1
        gameState.islands[islandIndex].buildings[buildingIndex] = building

        return .success(())
    }

    /// Get productivity percentage for a building
    func getProductivity(for buildingId: UUID, onIslandIndex islandIndex: Int) -> Double {
        guard islandIndex < gameState.islands.count else {
            return 0.0
        }

        guard let building = gameState.islands[islandIndex].buildings.first(where: { $0?.id == buildingId }) else {
            return 0.0
        }

        guard let actualBuilding = building else {
            return 0.0
        }

        let island = gameState.islands[islandIndex]
        return ProductivityCalculator.calculateProductivity(for: actualBuilding, island: island, gameState: gameState)
    }
    
    // MARK: - Save/Load
    
    func saveGame() {
        _ = saveManager.save(gameState)
    }
    
    func loadGame() {
        switch saveManager.load() {
        case .success(let loaded):
            self.gameState = loaded
            AppLogger.general.info("Game loaded manually")
        case .failure(let error):
            AppLogger.general.error("Load failed: \(error.localizedDescription)")
        }
    }
    
    func startNewGame() {
        gameState = GameState.demo()
        AppLogger.general.info("New game started")
    }
    
    func deleteSave() {
        _ = saveManager.deleteSave()
        startNewGame()
    }
    
    // MARK: - Convenience Accessors

    var mainIsland: Island? {
        gameState.mainIsland
    }

    var currentIsland: Island? {
        guard currentIslandIndex < gameState.islands.count else {
            return nil
        }
        return gameState.islands[currentIslandIndex]
    }

    var emptySlots: Int {
        mainIsland?.availableSlots ?? 0
    }
    
    func hasSaveFile() -> Bool {
        saveManager.saveExists()
    }
    
    func totalProduction() -> Inventory {
        productionManager.totalProduction(gameState: gameState)
    }

    func totalConsumption() -> Inventory {
        productionManager.totalConsumption(gameState: gameState)
    }

    func actualProductionRate() -> Inventory {
        productionManager.actualProductionRate(gameState: gameState)
    }

    func actualConsumptionRate() -> Inventory {
        productionManager.actualConsumptionRate(gameState: gameState)
    }

    // MARK: - Progression Helpers

    /// Get completed research IDs
    var completedResearchIds: [String] {
        gameState.completedResearches.map { $0.researchId }
    }

    /// Check if island is unlocked
    func isIslandUnlocked(_ island: Island) -> Bool {
        island.isUnlocked(completedResearch: gameState.completedResearches)
    }

    /// Check if research can be started
    func canStartResearch(_ research: ResearchType) -> Bool {
        // Not already completed
        guard !completedResearchIds.contains(research.id) else { return false }
        // Epoch requirement met
        guard gameState.epochTracker.currentEpoch >= research.requiredEpoch else { return false }
        // Prerequisites met
        for prereq in research.prerequisiteIds {
            guard completedResearchIds.contains(prereq) else { return false }
        }
        return true
    }

    /// Current epoch name
    var currentEpochName: String {
        gameState.epochTracker.currentEpochStruct().name
    }

    /// Current epoch description
    var currentEpochDescription: String {
        gameState.epochTracker.currentEpochStruct().description
    }

    /// Current epoch number
    var currentEpoch: Int {
        gameState.epochTracker.currentEpoch
    }
}

// MARK: - Research Errors

enum ResearchError: Error, LocalizedError {
    case researchNotFound
    case alreadyCompleted
    case insufficientResources
    case noIsland
    case researchAlreadyActive
    case epochRequirementNotMet
    case prerequisiteNotMet

    var errorDescription: String? {
        switch self {
        case .researchNotFound:
            return "Research not found"
        case .alreadyCompleted:
            return "Research already completed"
        case .insufficientResources:
            return "Insufficient resources"
        case .noIsland:
            return "No island available"
        case .researchAlreadyActive:
            return "Another research is already in progress"
        case .epochRequirementNotMet:
            return "Epoch requirement not met"
        case .prerequisiteNotMet:
            return "Prerequisite research not completed"
        }
    }
}

// MARK: - Worker Assignment Errors

enum WorkerAssignmentError: Error, LocalizedError {
    case invalidIsland
    case buildingNotFound
    case buildingFull
    case noWorkersAvailable
    case noWorkersAssigned

    var errorDescription: String? {
        switch self {
        case .invalidIsland:
            return "Invalid island"
        case .buildingNotFound:
            return "Building not found"
        case .buildingFull:
            return "Building already has maximum workers"
        case .noWorkersAvailable:
            return "No unassigned workers available"
        case .noWorkersAssigned:
            return "No workers assigned to this building"
        }
    }
}

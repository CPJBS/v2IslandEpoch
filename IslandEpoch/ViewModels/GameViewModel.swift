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
        
        // 2. Passive gold income
        gameState.gold += gameState.totalGoldIncome
        
        // 3. Production
        productionManager.processTick(gameState: &gameState)
        
        // 4. Auto-save every 30 ticks
        if gameState.tick % 10 == 0 {
            saveGame()
        }
        
        // 5. Trigger UI update
        objectWillChange.send()
    }
    
    // MARK: - Research Actions

    func completeResearch(_ researchId: String) -> Result<Void, ResearchError> {
        // Check if already completed
        if gameState.hasCompletedResearch(researchId) {
            return .failure(.alreadyCompleted)
        }

        // Get research type
        guard let research = ResearchType.all.first(where: { $0.id == researchId }) else {
            return .failure(.researchNotFound)
        }

        // Check if we can afford it (from main island)
        guard let islandIndex = gameState.islands.indices.first else {
            return .failure(.noIsland)
        }

        // Verify resources
        for (resource, amount) in research.cost {
            if !gameState.islands[islandIndex].inventory.has(resource, amount: amount) {
                return .failure(.insufficientResources)
            }
        }

        // Deduct resources
        for (resource, amount) in research.cost {
            gameState.islands[islandIndex].inventory.remove(resource, amount: amount)
        }

        // Complete the research
        let completedResearch = CompletedResearch(researchId: researchId)
        gameState.completedResearches.append(completedResearch)

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

        return buildingManager.build(
            type,
            onIslandIndex: index,
            atSlotIndex: slotIndex,
            gameState: &gameState
        )
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

        return ProductivityCalculator.calculateProductivity(for: actualBuilding, gameState: gameState)
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
}

// MARK: - Research Errors

enum ResearchError: Error, LocalizedError {
    case researchNotFound
    case alreadyCompleted
    case insufficientResources
    case noIsland

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

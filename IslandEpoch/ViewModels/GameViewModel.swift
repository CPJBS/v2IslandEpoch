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
        
        // 4. Auto-save every 10 ticks
        if gameState.tick % 10 == 0 {
            saveGame()
        }
        
        // 5. Trigger UI update
        objectWillChange.send()
    }
    
    // MARK: - Building Actions
    
    func buildBuilding(
        _ type: BuildingType,
        onIslandIndex index: Int
    ) -> Result<UUID, BuildError> {
        guard index < gameState.islands.count else {
            return .failure(.buildingNotFound)
        }
        
        return buildingManager.build(
            type,
            onIslandIndex: index,
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
    
    var emptySlots: Int {
        mainIsland?.availableSlots ?? 0
    }
    
    func hasSaveFile() -> Bool {
        saveManager.saveExists()
    }
    
    func totalProduction() -> Inventory {
        productionManager.totalProduction(gameState: gameState)
    }
}

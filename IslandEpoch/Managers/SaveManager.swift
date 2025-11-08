//
//  SaveManager.swift
//  IslandEpoch
//

import Foundation

@MainActor
class SaveManager {
    
    // MARK: - Properties
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let fileName = "islandepoch_save.json"
    
    // MARK: - Initialization
    init() {
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        
        // Pretty print for debugging
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - Save
    
    func save(_ gameState: GameState) -> Result<Void, Error> {
        do {
            let data = try encoder.encode(gameState)
            try data.write(to: fileURL())
            
            AppLogger.saveLoad.info("Game saved (\(data.count) bytes)")
            return .success(())
        } catch {
            AppLogger.saveLoad.error("Save failed: \(error.localizedDescription)")
            return .failure(error)
        }
    }
    
    // MARK: - Load
    
    func load() -> Result<GameState, Error> {
        do {
            let data = try Data(contentsOf: fileURL())
            let gameState = try decoder.decode(GameState.self, from: data)
            
            AppLogger.saveLoad.info("Game loaded (\(data.count) bytes)")
            return .success(gameState)
        } catch {
            AppLogger.saveLoad.error("Load failed: \(error.localizedDescription)")
            return .failure(error)
        }
    }
    
    // MARK: - Delete
    
    func deleteSave() -> Result<Void, Error> {
        do {
            let fileManager = FileManager.default
            let url = fileURL()
            
            if fileManager.fileExists(atPath: url.path) {
                try fileManager.removeItem(at: url)
                AppLogger.saveLoad.info("Save deleted")
            }
            
            return .success(())
        } catch {
            AppLogger.saveLoad.error("Delete failed: \(error.localizedDescription)")
            return .failure(error)
        }
    }
    
    // MARK: - Helpers
    
    func saveExists() -> Bool {
        FileManager.default.fileExists(atPath: fileURL().path)
    }
    
    private func fileURL() -> URL {
        let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
        return documentsDirectory.appendingPathComponent(fileName)
    }
}

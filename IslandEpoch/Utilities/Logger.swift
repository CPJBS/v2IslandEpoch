//
//  Logger.swift
//  IslandEpoch
//

import OSLog

/// Centralized logging using OSLog
struct AppLogger {
    
    static let general = Logger(
        subsystem: "com.cstotaal.IslandEpoch",
        category: "General"
    )
    
    static let gameLoop = Logger(
        subsystem: "com.cstotaal.IslandEpoch",
        category: "GameLoop"
    )
    
    static let building = Logger(
        subsystem: "com.cstotaal.IslandEpoch",
        category: "Building"
    )
    
    static let production = Logger(
        subsystem: "com.cstotaal.IslandEpoch",
        category: "Production"
    )
    
    static let saveLoad = Logger(
        subsystem: "com.cstotaal.IslandEpoch",
        category: "SaveLoad"
    )
}

// MARK: - Usage Examples
/*
 AppLogger.general.info("App launched")
 AppLogger.building.info("Building constructed: \(type.name)")
 AppLogger.production.debug("Tick \(tick): Produced \(amount) wheat")
 AppLogger.saveLoad.error("Save failed: \(error.localizedDescription)")
 */

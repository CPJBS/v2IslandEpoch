//
//  Island.swift
//  IslandEpoch
//

import Foundation
import OSLog

/// Island territory (pure data, no logic)
struct Island: Identifiable, Codable {
    // MARK: - Identity
    var id = UUID()
    var name: String
    
    // MARK: - Resources & Workers
    var inventory: Inventory = [:]
    var workersAvailable: Int
    
    // MARK: - Buildings
    var buildings: [Building] = []
    let maxSlots: Int
    
    // MARK: - Initialization
    init(name: String, workersAvailable: Int, maxSlots: Int) {
        self.name = name
        self.workersAvailable = workersAvailable
        self.maxSlots = maxSlots
    }
    
    // MARK: - Computed Properties
    
    var hasAvailableSlots: Bool {
        buildings.count < maxSlots
    }
    
    var availableSlots: Int {
        maxSlots - buildings.count
    }
    
    var totalWorkersAssigned: Int {
        buildings.reduce(0) { $0 + $1.type.workers }
    }
}

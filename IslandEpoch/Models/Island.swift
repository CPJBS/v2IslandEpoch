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
    var buildings: [Building?] = []
    let maxSlots: Int

    // MARK: - Initialization
    init(name: String, workersAvailable: Int, maxSlots: Int) {
        self.name = name
        self.workersAvailable = workersAvailable
        self.maxSlots = maxSlots
        // Initialize with fixed number of empty slots
        self.buildings = Array(repeating: nil, count: maxSlots)
    }

    // MARK: - Computed Properties

    var hasAvailableSlots: Bool {
        buildings.contains(where: { $0 == nil })
    }

    var availableSlots: Int {
        buildings.filter { $0 == nil }.count
    }

    var totalWorkersAssigned: Int {
        buildings.compactMap { $0 }.reduce(0) { $0 + $1.type.workers }
    }
}

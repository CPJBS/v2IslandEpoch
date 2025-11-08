//
//  Resource.swift
//  IslandEpoch
//
//  Created by Casper Stienstra on 13/05/2025.
//

import Foundation

/// All raw & processed resources used in this MVP
enum ResourceID: String, Codable, CaseIterable {
    case wheat
    case wood
    case ironOre
}

/// Convenient type alias for any storage dictionary
typealias Inventory = [ResourceID: Int]

// MARK: - Inventory helpers

extension Inventory {
    /// Adds quantity (creates the key if missing)
    mutating func add(_ id: ResourceID, _ qty: Int) {
        self[id, default: 0] += qty
    }
    
    /// Consumes quantity if available; returns success / failure
    @discardableResult
    mutating func consume(_ id: ResourceID, _ qty: Int) -> Bool {
        let current = self[id, default: 0]
        guard current >= qty else { return false }
        self[id] = current - qty
        return true
    }
}

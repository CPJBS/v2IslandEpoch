//
//  Resource.swift
//  IslandEpoch
//

import Foundation
import OSLog

/// All resources in the game
enum ResourceType: String, Codable, CaseIterable {
    case wheat
    case wood
    case ironOre
    case bread
    
    var displayName: String {
        switch self {
        case .wheat: return "Wheat"
        case .wood: return "Wood"
        case .ironOre: return "Iron Ore"
        case .bread: return "Bread"
        }
    }
    
    var icon: String {
        switch self {
        case .wheat: return "leaf.fill"
        case .wood: return "tree.fill"
        case .ironOre: return "cube.box.fill"
        case .bread: return "basket.fill"
        }
    }
}

/// Type alias for inventory storage
typealias Inventory = [ResourceType: Int]

// MARK: - Inventory Helpers

extension Inventory {
    /// Add resources to inventory
    mutating func add(_ type: ResourceType, amount: Int) {
        self[type, default: 0] += amount
    }
    
    /// Remove resources from inventory (returns false if insufficient)
    @discardableResult
    mutating func remove(_ type: ResourceType, amount: Int) -> Bool {
        let current = self[type, default: 0]
        guard current >= amount else { return false }
        self[type] = current - amount
        return true
    }
    
    /// Check if inventory has sufficient resources
    func has(_ type: ResourceType, amount: Int) -> Bool {
        return (self[type, default: 0]) >= amount
    }
}

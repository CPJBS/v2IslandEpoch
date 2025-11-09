//
//  Resource.swift
//  IslandEpoch
//

import Foundation
import OSLog

/// Resource categories for grouping similar resources
enum ResourceCategory: String, Codable, CaseIterable, Hashable {
    case food
    case material
    case ore

    var displayName: String {
        switch self {
        case .food: return "Food"
        case .material: return "Material"
        case .ore: return "Ore"
        }
    }

    var icon: String {
        switch self {
        case .food: return "basket.fill"
        case .material: return "tree.fill"
        case .ore: return "cube.box.fill"
        }
    }
}

/// All resources in the game
enum ResourceType: String, Codable, CaseIterable {
    case wheat
    case wood
    case ironOre
    case bread
    case berries

    var displayName: String {
        switch self {
        case .wheat: return "Wheat"
        case .wood: return "Wood"
        case .ironOre: return "Iron Ore"
        case .bread: return "Bread"
        case .berries: return "Berries"
        }
    }

    /// Display name with category (e.g., "Bread (Food)")
    var displayNameWithCategory: String {
        return "\(displayName) (\(category.displayName))"
    }

    var icon: String {
        switch self {
        case .wheat: return "leaf.fill"
        case .wood: return "tree.fill"
        case .ironOre: return "cube.box.fill"
        case .bread: return "basket.fill"
        case .berries: return "leaf.circle.fill"
        }
    }

    var category: ResourceCategory {
        switch self {
        case .bread, .berries:
            return .food
        case .wood:
            return .material
        case .ironOre:
            return .ore
        case .wheat:
            return .material // Wheat is a raw material for bread
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

    /// Get total amount for a specific category
    func categoryTotal(_ category: ResourceCategory) -> Int {
        return self.reduce(0) { total, entry in
            let (resourceType, amount) = entry
            return resourceType.category == category ? total + amount : total
        }
    }

    /// Get all categories present in this inventory
    var categories: Set<ResourceCategory> {
        return Set(self.keys.map { $0.category })
    }

    /// Get resources grouped by category
    func resourcesByCategory(_ category: ResourceCategory) -> [(ResourceType, Int)] {
        return self.filter { $0.key.category == category }
            .map { ($0.key, $0.value) }
            .sorted { $0.0.displayName < $1.0.displayName }
    }
}

//
//  BuildingType.swift
//  IslandEpoch
//

import Foundation

/// Building blueprint (static definition)
struct BuildingType: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let workers: Int              // Required workers to operate
    let produces: Inventory       // Output per tick
    let consumes: Inventory       // Input per tick
    let goldCost: Int             // Cost to build
    
    // MARK: - Static Catalog
    
    static let farm = BuildingType(
        id: "farm",
        name: "Farm",
        workers: 2,
        produces: [.wheat: 2],
        consumes: [:],
        goldCost: 50
    )
    
    static let forester = BuildingType(
        id: "forester",
        name: "Forester",
        workers: 2,
        produces: [.wood: 2],
        consumes: [:],
        goldCost: 40
    )
    
    static let mine = BuildingType(
        id: "mine",
        name: "Mine",
        workers: 3,
        produces: [.ironOre: 1],
        consumes: [:],
        goldCost: 80
    )
    
    /// All available building types
    static let all: [BuildingType] = [.farm, .forester, .mine]
    
    // MARK: - Helpers
    
    var icon: String {
        switch id {
        case "farm": return "leaf.fill"
        case "forester": return "tree.fill"
        case "mine": return "cube.box.fill"
        default: return "building.2"
        }
    }
    
    var productionDescription: String {
        guard let (resource, amount) = produces.first else {
            return "No production"
        }
        return "+\(amount) \(resource.displayName)/tick"
    }
}

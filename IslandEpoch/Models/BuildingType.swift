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
    let providesWorkers: Int      // Workers provided (for housing)
    let produces: Inventory       // Output per tick
    let consumes: Inventory       // Input per tick
    let goldCost: Int             // Cost to build
    
    // MARK: - Static Catalog

    // Housing
    static let tent = BuildingType(
        id: "tent",
        name: "Tent",
        workers: 0,
        providesWorkers: 5,
        produces: [:],
        consumes: [:],
        goldCost: 30
    )

    // Production Buildings
    static let farm = BuildingType(
        id: "farm",
        name: "Farm",
        workers: 2,
        providesWorkers: 0,
        produces: [.wheat: 2],
        consumes: [:],
        goldCost: 50
    )

    static let forester = BuildingType(
        id: "forester",
        name: "Forester",
        workers: 2,
        providesWorkers: 0,
        produces: [.wood: 2],
        consumes: [:],
        goldCost: 40
    )

    static let mine = BuildingType(
        id: "mine",
        name: "Mine",
        workers: 3,
        providesWorkers: 0,
        produces: [.ironOre: 1],
        consumes: [:],
        goldCost: 80
    )

    static let bakery = BuildingType(
        id: "bakery",
        name: "Bakery",
        workers: 1,
        providesWorkers: 0,
        produces: [.bread: 1],
        consumes: [.wheat: 1, .wood: 1],
        goldCost: 100
    )

    /// All available building types
    static let all: [BuildingType] = [.tent, .farm, .forester, .mine, .bakery]
    
    // MARK: - Helpers
    
    var icon: String {
        switch id {
        case "tent": return "house.fill"
        case "farm": return "leaf.fill"
        case "forester": return "tree.fill"
        case "mine": return "cube.box.fill"
        case "bakery": return "basket.fill"
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

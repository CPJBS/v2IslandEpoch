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
    let availableFromEpoch: Int   // Epoch when this building becomes available
    
    // MARK: - Static Catalog

    // Housing
    static let tent = BuildingType(
        id: "tent",
        name: "Tent",
        workers: 0,
        providesWorkers: 5,
        produces: [:],
        consumes: [:],
        goldCost: 30,
        availableFromEpoch: 1
    )

    // Production Buildings
    static let farm = BuildingType(
        id: "farm",
        name: "Farm",
        workers: 2,
        providesWorkers: 0,
        produces: [.wheat: 2],
        consumes: [:],
        goldCost: 50,
        availableFromEpoch: 1
    )

    static let forester = BuildingType(
        id: "forester",
        name: "Forester",
        workers: 2,
        providesWorkers: 0,
        produces: [.wood: 2],
        consumes: [:],
        goldCost: 40,
        availableFromEpoch: 1
    )

    static let mine = BuildingType(
        id: "mine",
        name: "Mine",
        workers: 3,
        providesWorkers: 0,
        produces: [.ironOre: 1],
        consumes: [:],
        goldCost: 80,
        availableFromEpoch: 1
    )

    static let bakery = BuildingType(
        id: "bakery",
        name: "Bakery",
        workers: 2,
        providesWorkers: 0,
        produces: [.bread: 4],
        consumes: [.wheat: 1],
        goldCost: 100,
        availableFromEpoch: 1
    )

    static let forager = BuildingType(
        id: "forager",
        name: "Forager",
        workers: 1,
        providesWorkers: 0,
        produces: [.berries: 1],
        consumes: [:],
        goldCost: 20,
        availableFromEpoch: 1
    )

    static let library = BuildingType(
        id: "library",
        name: "Library",
        workers: 3,
        providesWorkers: 0,
        produces: [.insight: 1],
        consumes: [:],
        goldCost: 150,
        availableFromEpoch: 1
    )

    /// All available building types
    static let all: [BuildingType] = [.tent, .farm, .forester, .mine, .bakery, .forager, .library]
    
    // MARK: - Helpers
    
    var icon: String {
        switch id {
        case "tent": return "house.fill"
        case "farm": return "leaf.fill"
        case "forester": return "tree.fill"
        case "mine": return "cube.box.fill"
        case "bakery": return "basket.fill"
        case "forager": return "leaf.circle.fill"
        case "library": return "book.fill"
        default: return "building.2"
        }
    }
    
    var productionDescription: String {
        guard let (resource, amount) = produces.first else {
            return "No production"
        }
        return "+\(amount) \(resource.displayNameWithCategory)/tick"
    }
}

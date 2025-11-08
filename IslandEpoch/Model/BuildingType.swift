//
//  BuildingType.swift
//  IslandEpoch
//
//  Created by Casper Stienstra on 13/05/2025.
//

import Foundation

/// Blueprint describing how a building behaves every tick
struct BuildingType: Codable, Identifiable {
    let id: String
    let name: String
    let workers: Int              // required to operate one instance
    let produces: Inventory       // output per tick
    let consumes: Inventory       // input per tick (can be empty)
    
    // MARK: - Static “catalog” definitions
    static let farm = BuildingType(
        id: "farm",
        name: "Farm",
        workers: 2,
        produces: [.wheat: 2],
        consumes: [:])
    
    static let forester = BuildingType(
        id: "forester",
        name: "Forester",
        workers: 2,
        produces: [.wood: 2],
        consumes: [:])
    
    static let mine = BuildingType(
        id: "mine",
        name: "Mine",
        workers: 3,
        produces: [.ironOre: 1],
        consumes: [:])
    
    /// Convenience array if you ever need to iterate
    static let all: [BuildingType] = [.farm, .forester, .mine]
}

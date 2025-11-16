//
//  Fertility.swift
//  IslandEpoch
//
//  Island fertility types that determine what can be built
//

import Foundation

enum FertilityType: String, Codable, CaseIterable, Identifiable {
    case grainland
    case forest
    case ironDeposits
    case wildlife

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .grainland:
            return "Grainland"
        case .forest:
            return "Forest"
        case .ironDeposits:
            return "Iron Deposits"
        case .wildlife:
            return "Wildlife"
        }
    }

    var icon: String {
        switch self {
        case .grainland:
            return "leaf.fill"
        case .forest:
            return "tree.fill"
        case .ironDeposits:
            return "mountain.2.fill"
        case .wildlife:
            return "hare.fill"
        }
    }

    var description: String {
        switch self {
        case .grainland:
            return "Fertile soil suitable for growing crops"
        case .forest:
            return "Dense woodland for lumber harvesting"
        case .ironDeposits:
            return "Rich mineral deposits for mining"
        case .wildlife:
            return "Natural habitat with abundant wildlife"
        }
    }
}

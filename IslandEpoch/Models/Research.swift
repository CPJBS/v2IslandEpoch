//
//  Research.swift
//  IslandEpoch
//

import Foundation

/// Research blueprint (static definition)
struct ResearchType: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let description: String
    let cost: Inventory

    // MARK: - Static Catalog

    static let metalHatchets = ResearchType(
        id: "metalHatchets",
        name: "Metal Hatchets",
        description: "Equip foresters with metal tools. +15% wood production.",
        cost: [.bread: 50, .wood: 45, .insight: 10]
    )

    /// All available researches
    static let all: [ResearchType] = [.metalHatchets]
}

/// Instance of a completed research
struct CompletedResearch: Codable, Identifiable {
    let id: String
    let researchId: String
    let completedAt: Date

    init(researchId: String) {
        self.id = UUID().uuidString
        self.researchId = researchId
        self.completedAt = Date()
    }
}

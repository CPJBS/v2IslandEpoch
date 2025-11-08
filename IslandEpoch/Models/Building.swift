//
//  Building.swift
//  IslandEpoch
//

import Foundation
import OSLog

/// Building instance (runtime object)
struct Building: Identifiable, Codable, Equatable {
    let id: UUID
    let type: BuildingType
    var level: Int = 1
    
    init(id: UUID = UUID(), type: BuildingType) {
        self.id = id
        self.type = type
    }
}

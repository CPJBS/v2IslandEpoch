//
//  Prestige.swift
//  IslandEpoch
//
//  Prestige system: players voluntarily reset progress for permanent multipliers.
//  "Epoch Stars" are the prestige currency, earned based on lifetime gold earned.
//

import Foundation

/// Persistent prestige state that survives resets
struct PrestigeState: Codable {
    /// Total epoch stars earned across all prestiges
    var totalStars: Int = 0
    /// Number of times the player has prestiged
    var timesPrestiged: Int = 0
    /// Highest epoch reached before any prestige
    var highestEpochReached: Int = 1
    /// Total lifetime gold earned across all runs (drives star calculation)
    var lifetimeGoldEarned: Int = 0

    // MARK: - Star Calculation

    /// Stars that would be earned if prestiging right now
    static func starsForPrestige(currentRunGold: Int, currentEpoch: Int) -> Int {
        // Base stars from gold: sqrt(totalGold / 1000), so 1M gold ≈ 31 stars
        let goldStars = Int(sqrt(Double(currentRunGold) / 1000.0))
        // Bonus stars per epoch reached beyond 3
        let epochBonus = max(0, currentEpoch - 3) * 2
        return max(0, goldStars + epochBonus)
    }

    /// Minimum epoch required to prestige
    static let minimumEpochToPrestige: Int = 4

    // MARK: - Bonuses from Stars

    /// Global production multiplier from prestige stars: 1.0 + 0.05 per star (5% each)
    var productionMultiplier: Double {
        1.0 + Double(totalStars) * 0.05
    }

    /// Gold income multiplier from prestige stars: 1.0 + 0.03 per star (3% each)
    var goldMultiplier: Double {
        1.0 + Double(totalStars) * 0.03
    }

    /// Offline income multiplier bonus: base 0.5x + 0.02 per star
    var offlineMultiplier: Double {
        0.5 + Double(totalStars) * 0.02
    }

    /// Starting gold bonus after prestige: 500 + 100 per star
    var startingGoldBonus: Int {
        totalStars > 0 ? 500 + totalStars * 100 : 0
    }
}

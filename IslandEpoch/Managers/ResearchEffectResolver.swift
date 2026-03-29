//
//  ResearchEffectResolver.swift
//  IslandEpoch
//
//  Resolves cumulative research effects from completed researches.
//  Called by game systems that need to apply bonuses (production, gold, construction, etc.)
//

import Foundation

/// Aggregated bonuses from all completed researches
struct ResearchBonuses {
    /// Extra gold per tick from goldIncomeBonus effects
    var extraGoldPerTick: Int = 0
    /// Multiplicative gold income multiplier (product of all goldIncomeMultiplier effects)
    var goldIncomeMultiplier: Double = 1.0
    /// Extra workers per housing building from workerCapacityBonus effects
    var extraWorkersPerHousing: Int = 0
    /// Additive storage bonus percent from storageBonusPercent effects
    var storageBonusPercent: Int = 0
    /// Additive construction speed bonus percent from constructionSpeedBonus effects
    var constructionSpeedPercent: Int = 0
    /// Additive research speed bonus percent from researchSpeedBonus effects
    var researchSpeedPercent: Int = 0
    /// Multiplicative insight production bonus (product of all insightProductionBonus effects)
    var insightProductionMultiplier: Double = 1.0
    /// Multiplicative food production bonus (product of all foodProductionBonus effects)
    var foodProductionMultiplier: Double = 1.0
    /// Extra building slots per island from buildingSlotsBonus effects
    var extraBuildingSlotsPerIsland: Int = 0
    /// Additive housing capacity bonus percent from housingCapacityBonus effects
    var housingCapacityBonusPercent: Int = 0

    /// Multiplier applied to construction time (lower = faster)
    var constructionTimeMultiplier: Double {
        1.0 / (1.0 + Double(constructionSpeedPercent) / 100.0)
    }

    /// Multiplier applied to research time (lower = faster)
    var researchTimeMultiplier: Double {
        1.0 / (1.0 + Double(researchSpeedPercent) / 100.0)
    }
}

/// Resolves cumulative research effects from completed researches
struct ResearchEffectResolver {

    /// Calculate all aggregated bonuses from completed researches
    static func resolve(completedResearches: [CompletedResearch]) -> ResearchBonuses {
        var bonuses = ResearchBonuses()

        for completed in completedResearches {
            guard let researchType = ResearchType.all.first(where: { $0.id == completed.researchId }) else { continue }
            for effect in researchType.effects {
                switch effect {
                case .goldIncomeBonus(let perTick):
                    bonuses.extraGoldPerTick += perTick
                case .goldIncomeMultiplier(let multiplier):
                    bonuses.goldIncomeMultiplier *= multiplier
                case .workerCapacityBonus(let perHousing):
                    bonuses.extraWorkersPerHousing += perHousing
                case .storageBonusPercent(let percent):
                    bonuses.storageBonusPercent += percent
                case .constructionSpeedBonus(let percent):
                    bonuses.constructionSpeedPercent += percent
                case .researchSpeedBonus(let percent):
                    bonuses.researchSpeedPercent += percent
                case .insightProductionBonus(let multiplier):
                    bonuses.insightProductionMultiplier *= multiplier
                case .foodProductionBonus(let multiplier):
                    bonuses.foodProductionMultiplier *= multiplier
                case .buildingSlotsBonus(let perIsland):
                    bonuses.extraBuildingSlotsPerIsland += perIsland
                case .housingCapacityBonus(let percent):
                    bonuses.housingCapacityBonusPercent += percent
                default:
                    break // advanceEpoch, unlockBuildingTier, unlockIsland, productionBonus, allProductionBonus handled elsewhere
                }
            }
        }

        return bonuses
    }
}

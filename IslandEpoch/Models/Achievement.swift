//
//  Achievement.swift
//  IslandEpoch
//

import Foundation

struct AchievementDefinition: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let gemReward: Int
}

struct AchievementCatalog {
    static let all: [AchievementDefinition] = [
        // Building
        AchievementDefinition(id: "build_first", name: "First Foundation", description: "Build your first building", icon: "hammer", gemReward: 2),
        AchievementDefinition(id: "build_10", name: "Growing Settlement", description: "Own 10 buildings", icon: "building.2", gemReward: 3),
        AchievementDefinition(id: "build_20", name: "Urban Planner", description: "Own 20 buildings", icon: "building.2.fill", gemReward: 5),
        AchievementDefinition(id: "upgrade_first", name: "Renovator", description: "Upgrade a building", icon: "arrow.up.circle", gemReward: 2),
        AchievementDefinition(id: "max_level", name: "Master Builder", description: "Upgrade a building to Level 3", icon: "star.fill", gemReward: 5),
        // Resources
        AchievementDefinition(id: "gold_1000", name: "Prosperous", description: "Accumulate 1,000 gold", icon: "dollarsign.circle", gemReward: 2),
        AchievementDefinition(id: "gold_10000", name: "Wealthy", description: "Accumulate 10,000 gold", icon: "dollarsign.circle.fill", gemReward: 5),
        AchievementDefinition(id: "gold_100000", name: "Magnate", description: "Accumulate 100,000 gold", icon: "crown", gemReward: 10),
        // Epochs
        AchievementDefinition(id: "epoch_2", name: "Settled", description: "Reach Epoch 2", icon: "leaf", gemReward: 2),
        AchievementDefinition(id: "epoch_5", name: "Metalworker", description: "Reach Epoch 5", icon: "flame", gemReward: 5),
        AchievementDefinition(id: "epoch_8", name: "Scholar", description: "Reach Epoch 8", icon: "graduationcap", gemReward: 5),
        AchievementDefinition(id: "epoch_10", name: "Enlightened", description: "Reach Epoch 10", icon: "star.circle.fill", gemReward: 10),
        // Islands
        AchievementDefinition(id: "island_2", name: "Explorer", description: "Unlock a second island", icon: "map", gemReward: 3),
        AchievementDefinition(id: "island_all", name: "Archipelago", description: "Unlock all 5 islands", icon: "globe", gemReward: 10),
        // Workers
        AchievementDefinition(id: "workers_10", name: "Small Crew", description: "Have 10 workers", icon: "person.2", gemReward: 2),
        AchievementDefinition(id: "workers_50", name: "Workforce", description: "Have 50 workers", icon: "person.3", gemReward: 3),
        AchievementDefinition(id: "workers_100", name: "Population Boom", description: "Have 100 workers", icon: "person.3.fill", gemReward: 5),
        // Research
        AchievementDefinition(id: "research_first", name: "Curious Mind", description: "Complete first research", icon: "lightbulb", gemReward: 2),
        AchievementDefinition(id: "research_5", name: "Studious", description: "Complete 5 researches", icon: "book", gemReward: 3),
        AchievementDefinition(id: "research_all", name: "Polymath", description: "Complete all research", icon: "brain", gemReward: 10),
        // Engagement
        AchievementDefinition(id: "play_1h", name: "Dedicated", description: "Play for 1 hour", icon: "clock", gemReward: 2),
        AchievementDefinition(id: "play_10h", name: "Committed", description: "Play for 10 hours", icon: "clock.fill", gemReward: 5),
        AchievementDefinition(id: "login_7", name: "Weekly Regular", description: "7-day login streak", icon: "calendar", gemReward: 5),
    ]
}

//
//  AchievementsView.swift
//  IslandEpoch
//

import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject var vm: GameViewModel

    var body: some View {
        List {
            // Summary header
            Section {
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(completedCount) / \(AchievementCatalog.all.count)")
                            .font(.title2.bold())
                        Text("Achievements Completed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        HStack {
                            Image(systemName: "diamond.fill")
                                .foregroundColor(.cyan)
                            Text("\(totalGemsEarned)")
                                .font(.title2.bold())
                        }
                        Text("Gems Earned")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Achievement list
            ForEach(AchievementCatalog.all) { achievement in
                let isCompleted = vm.gameState.completedAchievements.contains(achievement.id)
                HStack {
                    Image(systemName: achievement.icon)
                        .font(.title2)
                        .foregroundColor(isCompleted ? .green : .gray)
                        .frame(width: 40)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(achievement.name)
                            .font(.headline)
                            .foregroundColor(isCompleted ? .primary : .secondary)
                        Text(achievement.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else {
                        HStack(spacing: 2) {
                            Image(systemName: "diamond.fill")
                                .font(.caption)
                                .foregroundColor(.cyan)
                            Text("\(achievement.gemReward)")
                                .font(.caption)
                                .foregroundColor(.cyan)
                        }
                    }
                }
                .opacity(isCompleted ? 1.0 : 0.6)
            }
        }
        .navigationTitle("Achievements")
    }

    var completedCount: Int {
        AchievementCatalog.all.filter { vm.gameState.completedAchievements.contains($0.id) }.count
    }

    var totalGemsEarned: Int {
        AchievementCatalog.all
            .filter { vm.gameState.completedAchievements.contains($0.id) }
            .reduce(0) { $0 + $1.gemReward }
    }
}

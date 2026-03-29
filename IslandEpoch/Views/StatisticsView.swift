//
//  StatisticsView.swift
//  IslandEpoch
//

import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var vm: GameViewModel

    var stats: GameStatistics { vm.gameState.statistics }

    var body: some View {
        List {
            // MARK: - Overview
            Section("Overview") {
                StatRow(label: "Play Time", value: formatDuration(Double(stats.totalTicksPlayed)))
                StatRow(label: "Offline Time", value: formatDuration(stats.totalOfflineSeconds))
                StatRow(label: "Sessions", value: "\(stats.sessionsCount)")
            }

            // MARK: - Economy
            Section("Economy") {
                StatRow(label: "Total Gold Earned", value: "\(stats.totalGoldEarned)")
                StatRow(label: "Total Gold Spent", value: "\(stats.totalGoldSpent)")
                StatRow(label: "Current Gold", value: "\(vm.gameState.gold)")
                StatRow(label: "Total Gems Earned", value: "\(stats.totalGemsEarned)")
                StatRow(label: "Total Gems Spent", value: "\(stats.totalGemsSpent)")
                StatRow(label: "Current Gems", value: "\(vm.gameState.gems)")
            }

            // MARK: - Population
            Section("Population") {
                StatRow(label: "Current Workers", value: "\(vm.gameState.totalPopulation)")
                StatRow(label: "Highest Population", value: "\(stats.highestPopulation)")
            }

            // MARK: - Progression
            Section("Progression") {
                StatRow(label: "Current Epoch", value: "\(vm.currentEpoch): \(vm.currentEpochName)")
                StatRow(label: "Buildings Constructed", value: "\(stats.totalBuildingsConstructed)")
                StatRow(label: "Buildings Demolished", value: "\(stats.totalBuildingsDemolished)")
                StatRow(label: "Research Completed", value: "\(stats.totalResearchCompleted) / \(ResearchType.all.count)")
            }
        }
        .navigationTitle("Statistics")
    }

    func formatDuration(_ seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        if hours > 0 { return "\(hours)h \(minutes)m" }
        return "\(minutes)m"
    }
}

struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value).foregroundColor(.secondary)
        }
    }
}

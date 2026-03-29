//
//  WelcomeBackView.swift
//  IslandEpoch
//

import SwiftUI

struct WelcomeBackView: View {
    let report: OfflineReport
    let onCollect: () -> Void
    let onCollectDouble: () -> Void  // costs 5 gems
    @EnvironmentObject var vm: GameViewModel

    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Header
                VStack(spacing: 8) {
                    Image(systemName: "sun.horizon.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.yellow)

                    Text("Welcome Back!")
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(.white)

                    Text("You were away for \(formatDuration(report.timeAway))")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                }

                // Gold earned
                if report.goldEarned > 0 {
                    HStack(spacing: 8) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.yellow)
                        Text("+\(report.goldEarned) Gold")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(.yellow)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.yellow.opacity(0.15))
                    .cornerRadius(12)
                }

                // Resources gained
                let gained = report.resourcesGained.filter { $0.value > 0 }
                    .sorted(by: { $0.key.displayName < $1.key.displayName })
                if !gained.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Resources Gained")
                            .font(.headline)
                            .foregroundStyle(.white)

                        ForEach(gained, id: \.key) { resource, amount in
                            HStack(spacing: 8) {
                                Image(systemName: resource.icon)
                                    .foregroundStyle(.green)
                                    .frame(width: 20)
                                Text(resource.displayName)
                                    .foregroundStyle(.white)
                                Spacer()
                                Text("+\(amount)")
                                    .foregroundStyle(.green)
                                    .bold()
                            }
                        }
                    }
                    .padding()
                    .background(.white.opacity(0.08))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                // Completed buildings
                if !report.completedBuildings.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Buildings Completed")
                            .font(.headline)
                            .foregroundStyle(.white)

                        ForEach(report.completedBuildings.indices, id: \.self) { index in
                            let entry = report.completedBuildings[index]
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                Text(entry.buildingName)
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .padding()
                    .background(.white.opacity(0.08))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                // Completed research
                if let research = report.completedResearch {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Research Complete: \(research)")
                            .foregroundStyle(.white)
                            .bold()
                    }
                    .padding()
                    .background(.green.opacity(0.15))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                // Storage warnings
                if !report.storageFullWarnings.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            Text("Storage Full")
                                .font(.headline)
                                .foregroundStyle(.orange)
                        }

                        ForEach(report.storageFullWarnings, id: \.self) { warning in
                            Text(warning)
                                .font(.subheadline)
                                .foregroundStyle(.orange.opacity(0.8))
                        }
                    }
                    .padding()
                    .background(.orange.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                Spacer()

                // Buttons
                VStack(spacing: 12) {
                    Button {
                        onCollect()
                    } label: {
                        Text("Collect")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .padding(.horizontal)

                    if vm.gameState.gems >= 5 {
                        Button {
                            onCollectDouble()
                        } label: {
                            HStack(spacing: 6) {
                                Text("Collect 2x")
                                    .font(.headline)
                                Image(systemName: "diamond.fill")
                                    .font(.caption)
                                Text("5")
                                    .font(.subheadline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.purple)
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 32)
            }
        }
    }

    func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        if hours > 0 { return "\(hours)h \(minutes)m" }
        return "\(minutes)m"
    }
}

#Preview {
    let report = OfflineReport(
        resourcesGained: [.wheat: 120, .wood: 80, .ironOre: 45],
        goldEarned: 340,
        completedBuildings: [(islandIndex: 0, buildingName: "Farm")],
        completedResearch: "Agriculture",
        storageFullWarnings: ["Wood on Main Isle"],
        timeAway: 9240
    )

    return WelcomeBackView(
        report: report,
        onCollect: {},
        onCollectDouble: {}
    )
    .environmentObject(GameViewModel())
}

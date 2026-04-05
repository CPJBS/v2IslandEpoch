//
//  PrestigeView.swift
//  IslandEpoch
//
//  Prestige screen: shows current bonuses, potential stars, and reset button.
//

import SwiftUI

struct PrestigeView: View {
    @EnvironmentObject var vm: GameViewModel
    @State private var showConfirm = false
    @State private var showFinalConfirm = false

    private var prestige: PrestigeState { vm.gameState.prestige }
    private var starsAvailable: Int { vm.prestigeStarsAvailable }

    var body: some View {
        List {
            // MARK: - Current Bonuses
            Section {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.title)
                    VStack(alignment: .leading) {
                        Text("\(prestige.totalStars) Epoch Stars")
                            .font(.title2.bold())
                        Text("Prestiged \(prestige.timesPrestiged) time\(prestige.timesPrestiged == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }

            if prestige.totalStars > 0 {
                Section("Active Bonuses") {
                    bonusRow(icon: "arrow.up.right", label: "Production", value: "+\(Int((prestige.productionMultiplier - 1) * 100))%")
                    bonusRow(icon: "dollarsign.circle", label: "Gold Income", value: "+\(Int((prestige.goldMultiplier - 1) * 100))%")
                    bonusRow(icon: "moon.zzz", label: "Offline Income", value: "\(String(format: "%.0f", prestige.offlineMultiplier * 100))%")
                    bonusRow(icon: "banknote", label: "Starting Gold", value: "\(prestige.startingGoldBonus)")
                }
            }

            // MARK: - Prestige Preview
            Section("New Prestige") {
                if vm.canPrestige {
                    HStack {
                        Image(systemName: "star.circle.fill")
                            .foregroundColor(.orange)
                        Text("Stars available")
                        Spacer()
                        Text("+\(starsAvailable)")
                            .font(.title3.bold())
                            .foregroundColor(.yellow)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("After prestige:")
                            .font(.subheadline.bold())
                        let newTotal = prestige.totalStars + starsAvailable
                        Text("Production: +\(Int(Double(newTotal) * 5))%")
                            .font(.caption)
                            .foregroundColor(.green)
                        Text("Gold: +\(Int(Double(newTotal) * 3))%")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        Text("Starting gold: \(500 + newTotal * 100)")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }

                    Button {
                        showConfirm = true
                    } label: {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Prestige Now")
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Reach Epoch \(PrestigeState.minimumEpochToPrestige) to unlock prestige")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Current: Epoch \(vm.currentEpoch)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // MARK: - Info
            Section("How Prestige Works") {
                VStack(alignment: .leading, spacing: 8) {
                    infoRow("Reset your islands, buildings, research, and gold")
                    infoRow("Keep: settings, daily login streak, achievements, gems")
                    infoRow("Earn Epoch Stars based on gold earned and epoch reached")
                    infoRow("Each star gives permanent bonuses to all future runs")
                    infoRow("Higher epochs and more gold = more stars")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Prestige")
        .alert("Prestige Reset", isPresented: $showConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Continue", role: .destructive) { showFinalConfirm = true }
        } message: {
            Text("You will earn \(starsAvailable) Epoch Stars. All buildings, research, and resources will be reset. Settings, gems, achievements, and daily login are kept.")
        }
        .alert("Are you sure?", isPresented: $showFinalConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Prestige", role: .destructive) {
                vm.performPrestige()
            }
        } message: {
            Text("This cannot be undone. Your civilization will start over with permanent bonuses.")
        }
    }

    private func bonusRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.yellow)
                .frame(width: 24)
            Text(label)
            Spacer()
            Text(value)
                .bold()
                .foregroundColor(.green)
        }
    }

    private func infoRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: "circle.fill")
                .font(.system(size: 4))
                .padding(.top, 5)
            Text(text)
        }
    }
}

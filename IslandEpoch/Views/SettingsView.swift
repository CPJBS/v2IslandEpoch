//
//  SettingsView.swift
//  IslandEpoch
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var vm: GameViewModel
    @State private var showResetConfirm = false
    @State private var showResetFinal = false

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Notifications
                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: $vm.gameState.settings.notificationsEnabled)
                    if vm.gameState.settings.notificationsEnabled {
                        Toggle("Construction Complete", isOn: $vm.gameState.settings.constructionNotifications)
                        Toggle("Research Complete", isOn: $vm.gameState.settings.researchNotifications)
                        Toggle("Storage Full", isOn: $vm.gameState.settings.storageNotifications)
                        Toggle("Idle Reminders", isOn: $vm.gameState.settings.idleReminders)
                    }
                }

                // MARK: - Feedback
                Section("Feedback") {
                    Toggle("Haptic Feedback", isOn: $vm.gameState.settings.hapticsEnabled)
                    Toggle("Sound Effects", isOn: $vm.gameState.settings.soundEnabled)
                }

                // MARK: - Game
                Section("Game") {
                    Toggle("Confirm Demolish", isOn: $vm.gameState.settings.confirmDemolish)
                    Toggle("Compact Numbers", isOn: $vm.gameState.settings.compactNumbers)
                }

                // MARK: - Info
                Section("Info") {
                    NavigationLink("Statistics") { StatisticsView() }
                    NavigationLink("Achievements") { AchievementsView().environmentObject(vm) }
                    NavigationLink {
                        PrestigeView().environmentObject(vm)
                    } label: {
                        HStack {
                            Text("Prestige")
                            Spacer()
                            if vm.gameState.prestige.totalStars > 0 {
                                HStack(spacing: 2) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                        .font(.caption)
                                    Text("\(vm.gameState.prestige.totalStars)")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }

                // MARK: - Danger Zone
                Section("Danger Zone") {
                    Button("Reset Game", role: .destructive) {
                        showResetConfirm = true
                    }
                }

                // MARK: - About
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("2.0.0").foregroundColor(.secondary)
                    }
                }

                // MARK: - Debug
                #if DEBUG
                Section("Debug") {
                    Button("Add 100 Gems") { vm.awardGems(100, source: "debug") }
                    Button("Add 10000 Gold") { vm.gameState.gold += 10000 }
                    Button("Complete Current Research") {
                        let _ = vm.speedUpResearch()
                    }
                    Button("Advance Epoch") {
                        vm.gameState.epochTracker.advanceEpoch()
                    }
                }
                #endif
            }
            .navigationTitle("Settings")
            .alert("Reset Game?", isPresented: $showResetConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) { showResetFinal = true }
            } message: {
                Text("This will delete all progress. This cannot be undone.")
            }
            .alert("Are you absolutely sure?", isPresented: $showResetFinal) {
                Button("Cancel", role: .cancel) {}
                Button("Delete Everything", role: .destructive) {
                    vm.startNewGame()
                }
            }
        }
    }
}

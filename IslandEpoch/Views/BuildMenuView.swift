//
//  BuildMenuView.swift
//  IslandEpoch
//
//  Shared component for building construction across all views
//

import SwiftUI

/// Reusable view for selecting and building structures in a specific slot
struct BuildMenuView: View {
    @EnvironmentObject var vm: GameViewModel
    @Environment(\.dismiss) var dismiss

    let slotIndex: Int

    // Local state for alert handling
    @State private var showAlert = false
    @State private var alertMessage = ""

    private func formatTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }

    private var busyBuilding: Building? {
        vm.currentIsland?.buildings.compactMap({ $0 }).first(where: { $0.isUnderConstruction })
    }

    var body: some View {
        NavigationStack {
            List {
                // Builder busy warning
                if let busy = busyBuilding {
                    Section {
                        HStack {
                            Image(systemName: "hammer.fill")
                            Text("Builder busy — \(busy.type.name) completing in \(formatTime(busy.constructionTimeRemaining))")
                        }
                        .foregroundColor(.orange)
                    }
                }

                Section {
                    ForEach(availableBuildings, id: \.id) { type in
                        let canBuild = canBuildOnCurrentIsland(type)
                        let lacksFertility = !canBuild && type.requiredFertility != nil

                        Button {
                            buildBuilding(type)
                        } label: {
                            HStack {
                                Image(systemName: type.icon)
                                    .font(.title2)
                                    .frame(width: 40)
                                    .foregroundColor(canBuild && busyBuilding == nil ? .blue : .gray)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(type.name)
                                        .font(.headline)
                                    if type.providesWorkers > 0 {
                                        Text("\(type.goldCost) gold • Provides \(type.providesWorkers) workers")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    } else if type.workers > 0 {
                                        Text("\(type.goldCost) gold • Max \(type.workers) workers")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    } else {
                                        Text("\(type.goldCost) gold")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    Text("Build time: \(formatTime(type.constructionTime))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    // Show fertility warning
                                    if lacksFertility, let fertility = type.requiredFertility {
                                        Text("⚠️ Lacks fertility: \(fertility.displayName)")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                    }
                                }

                                Spacer()
                            }
                        }
                        .opacity(canBuild && busyBuilding == nil ? 1.0 : 0.5)
                        .disabled(!canBuild || busyBuilding != nil)
                    }
                }

                if !upcomingBuildings.isEmpty {
                    Section("Coming in next epoch") {
                        ForEach(upcomingBuildings, id: \.id) { building in
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.gray)
                                Text(building.name)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("Epoch \(building.availableFromEpoch)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Build on Slot \(slotIndex + 1)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Build Result", isPresented: $showAlert) {
                Button("OK") {
                    // If successful, dismiss the menu after user sees the alert
                    if alertMessage.contains("successfully") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }

    // MARK: - Private Helpers

    private var availableBuildings: [BuildingType] {
        BuildingType.all.filter { $0.availableFromEpoch <= vm.currentEpoch }
    }

    private var upcomingBuildings: [BuildingType] {
        BuildingType.all.filter { $0.availableFromEpoch == vm.currentEpoch + 1 }
    }

    private func canBuildOnCurrentIsland(_ buildingType: BuildingType) -> Bool {
        guard let island = vm.currentIsland else {
            return false
        }

        // Check fertility requirement
        if let requiredFertility = buildingType.requiredFertility {
            return island.fertilities.contains(requiredFertility)
        }

        // No fertility requirement
        return true
    }

    private func buildBuilding(_ type: BuildingType) {
        let result = vm.buildBuilding(type, onIslandIndex: vm.currentIslandIndex, atSlotIndex: slotIndex)

        switch result {
        case .success:
            alertMessage = "\(type.name) built successfully!"
        case .failure(let error):
            alertMessage = error.localizedDescription
        }

        showAlert = true
    }
}

// MARK: - Preview
#Preview {
    BuildMenuView(slotIndex: 2)
        .environmentObject(GameViewModel())
}

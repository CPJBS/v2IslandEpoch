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

    var body: some View {
        NavigationStack {
            List {
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
                                .foregroundColor(canBuild ? .blue : .gray)

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
                    .opacity(canBuild ? 1.0 : 0.5)
                    .disabled(!canBuild)
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
        BuildingType.all.filter { buildingType in
            buildingType.availableFromEpoch <= vm.gameState.epochTracker.currentEpoch
        }
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

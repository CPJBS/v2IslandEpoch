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
                    Button {
                        buildBuilding(type)
                    } label: {
                        HStack {
                            Image(systemName: type.icon)
                                .font(.title2)
                                .frame(width: 40)
                                .foregroundColor(.blue)

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
                            }

                            Spacer()
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
        BuildingType.all.filter { buildingType in
            buildingType.availableFromEpoch <= vm.gameState.epochTracker.currentEpoch
        }
    }

    private func buildBuilding(_ type: BuildingType) {
        let result = vm.buildBuilding(type, onIslandIndex: 0, atSlotIndex: slotIndex)

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

//
//  BuildingDetailView.swift
//  IslandEpoch
//

import SwiftUI

struct BuildingDetailView: View {
    @EnvironmentObject var vm: GameViewModel
    @Environment(\.dismiss) var dismiss

    let building: Building
    let islandIndex: Int

    @State private var showAlert = false
    @State private var alertMessage = ""

    var refundAmount: Int {
        building.type.goldCost / 2
    }

    var body: some View {
        NavigationStack {
            List {
                // Building Info Section
                Section("Building Information") {
                    HStack {
                        Image(systemName: building.type.icon)
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                            .frame(width: 60)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(building.type.name)
                                .font(.title2)
                                .bold()
                            Text("Level \(building.level)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }

                // Production Section
                Section("Production") {
                    Text(building.type.productionDescription)
                        .foregroundColor(.secondary)
                }

                // Details Section
                Section("Details") {
                    LabeledContent("Workers", value: "\(building.type.workers)")
                    LabeledContent("Build Cost", value: "\(building.type.goldCost) gold")
                }

                // Actions Section
                Section("Actions") {
                    // Upgrade Button (Stub)
                    Button {
                        alertMessage = "Upgrade feature coming soon!"
                        showAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.up.circle.fill")
                            Text("Upgrade Building")
                            Spacer()
                            Text("Coming Soon")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .disabled(true)

                    // Demolish Button
                    Button(role: .destructive) {
                        demolishBuilding()
                    } label: {
                        HStack {
                            Image(systemName: "trash.circle.fill")
                            Text("Demolish Building")
                            Spacer()
                            Text("Refund: \(refundAmount) gold")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Building Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert("Action Result", isPresented: $showAlert) {
                Button("OK") {
                    if alertMessage.contains("demolished") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }

    // MARK: - Actions

    private func demolishBuilding() {
        let result = vm.demolishBuilding(building.id, fromIslandIndex: islandIndex)

        switch result {
        case .success:
            alertMessage = "Building demolished! Refunded \(refundAmount) gold."
            showAlert = true
        case .failure(let error):
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }
}

#Preview {
    let vm = GameViewModel()
    let building = Building(id: UUID(), type: BuildingType.all[0])

    return BuildingDetailView(building: building, islandIndex: 0)
        .environmentObject(vm)
}

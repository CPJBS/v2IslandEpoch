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
                    // Production Overview
                    if !building.type.produces.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Overview")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            HStack(spacing: 8) {
                                // Input side
                                if building.type.consumes.isEmpty {
                                    Text("None")
                                        .foregroundColor(.secondary)
                                } else {
                                    HStack(spacing: 4) {
                                        ForEach(Array(building.type.consumes.keys.sorted(by: { $0.displayName < $1.displayName })), id: \.self) { resource in
                                            if let amount = building.type.consumes[resource] {
                                                Text("\(amount) \(resource.displayName)")
                                            }
                                        }
                                    }
                                }

                                // Arrow
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.blue)

                                // Output side
                                HStack(spacing: 4) {
                                    ForEach(Array(building.type.produces.keys.sorted(by: { $0.displayName < $1.displayName })), id: \.self) { resource in
                                        if let amount = building.type.produces[resource] {
                                            Text("\(amount) \(resource.displayNameWithCategory)")
                                        }
                                    }
                                }
                            }
                            .font(.headline)
                        }
                        .padding(.vertical, 4)
                    }

                    // Input Details
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Input")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        if building.type.consumes.isEmpty {
                            Text("None")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(Array(building.type.consumes.keys.sorted(by: { $0.displayName < $1.displayName })), id: \.self) { resource in
                                if let amount = building.type.consumes[resource] {
                                    HStack {
                                        Image(systemName: resource.icon)
                                            .foregroundColor(.orange)
                                        Text("\(amount) × \(resource.displayName)")
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)

                    // Output Details
                    if !building.type.produces.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Output")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            ForEach(Array(building.type.produces.keys.sorted(by: { $0.displayName < $1.displayName })), id: \.self) { resource in
                                if let amount = building.type.produces[resource] {
                                    HStack {
                                        Image(systemName: resource.icon)
                                            .foregroundColor(.green)
                                        Text("\(amount) × \(resource.displayNameWithCategory)")
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // Details Section
                Section("Details") {
                    if building.type.providesWorkers > 0 {
                        LabeledContent("Provides Workers", value: "\(building.type.providesWorkers)")
                    } else if building.type.workers > 0 {
                        LabeledContent("Requires Workers", value: "\(building.type.workers)")
                    }
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

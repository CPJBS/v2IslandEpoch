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

    var island: Island? {
        guard islandIndex < vm.gameState.islands.count else { return nil }
        return vm.gameState.islands[islandIndex]
    }

    var productivity: Double {
        vm.getProductivity(for: building.id, onIslandIndex: islandIndex)
    }

    var productivityPercentage: String {
        String(format: "%.0f%%", productivity * 100)
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

                // Worker Assignment Section (for production buildings)
                if building.type.workers > 0 {
                    Section("Worker Assignment") {
                        // Worker Status
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Workers Assigned")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("\(building.assignedWorkers) / \(building.type.workers)")
                                    .font(.title2)
                                    .bold()
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Productivity")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(productivityPercentage)
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(productivity > 0.66 ? .green : (productivity > 0.33 ? .orange : .red))
                            }
                        }
                        .padding(.vertical, 4)

                        // Unassigned Workers Info
                        if let island = island {
                            LabeledContent("Unassigned Workers", value: "\(island.unassignedWorkers)")
                        }

                        // Assignment Controls
                        HStack(spacing: 12) {
                            // Unassign Worker Button
                            Button {
                                unassignWorker()
                            } label: {
                                HStack {
                                    Image(systemName: "minus.circle.fill")
                                    Text("Unassign Worker")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .disabled(building.assignedWorkers == 0)

                            // Assign Worker Button
                            Button {
                                assignWorker()
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Assign Worker")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(
                                building.assignedWorkers >= building.type.workers ||
                                (island?.unassignedWorkers ?? 0) == 0
                            )
                        }
                    }
                }

                // Production Section
                Section("Production") {
                    // Production Overview
                    if !building.type.produces.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Overview (at current productivity)")
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
                                            if let baseAmount = building.type.consumes[resource] {
                                                let actualAmount = ProductivityCalculator.calculateActualConsumption(baseAmount, productivity: productivity)
                                                Text("\(actualAmount) \(resource.displayName)")
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
                                        if let baseAmount = building.type.produces[resource] {
                                            let actualAmount = ProductivityCalculator.calculateActualProduction(baseAmount, productivity: productivity)
                                            Text("\(actualAmount) \(resource.displayNameWithCategory)")
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
                        Text("Input (Max / Current)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        if building.type.consumes.isEmpty {
                            Text("None")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(Array(building.type.consumes.keys.sorted(by: { $0.displayName < $1.displayName })), id: \.self) { resource in
                                if let baseAmount = building.type.consumes[resource] {
                                    let actualAmount = ProductivityCalculator.calculateActualConsumption(baseAmount, productivity: productivity)
                                    HStack {
                                        Image(systemName: resource.icon)
                                            .foregroundColor(.orange)
                                        Text("\(baseAmount) × \(resource.displayName)")
                                        if actualAmount != baseAmount {
                                            Text("→ \(actualAmount)")
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)

                    // Output Details
                    if !building.type.produces.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Output (Max / Current)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            ForEach(Array(building.type.produces.keys.sorted(by: { $0.displayName < $1.displayName })), id: \.self) { resource in
                                if let baseAmount = building.type.produces[resource] {
                                    let actualAmount = ProductivityCalculator.calculateActualProduction(baseAmount, productivity: productivity)
                                    HStack {
                                        Image(systemName: resource.icon)
                                            .foregroundColor(.green)
                                        Text("\(baseAmount) × \(resource.displayNameWithCategory)")
                                        if actualAmount != baseAmount {
                                            Text("→ \(actualAmount)")
                                                .foregroundColor(.secondary)
                                        }
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
                        LabeledContent("Max Workers", value: "\(building.type.workers)")
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

    private func assignWorker() {
        let result = vm.assignWorker(to: building.id, onIslandIndex: islandIndex)

        switch result {
        case .success:
            // Success - no alert needed, UI will update automatically
            break
        case .failure(let error):
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }

    private func unassignWorker() {
        let result = vm.unassignWorker(from: building.id, onIslandIndex: islandIndex)

        switch result {
        case .success:
            // Success - no alert needed, UI will update automatically
            break
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

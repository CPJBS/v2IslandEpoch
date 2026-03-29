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

    private func formatTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }

    var refundAmount: Int {
        building.type.goldCost / 2
    }

    var island: Island? {
        guard islandIndex < vm.gameState.islands.count else { return nil }
        return vm.gameState.islands[islandIndex]
    }

    // Get the current building from game state (updates when workers are assigned/unassigned)
    var currentBuilding: Building {
        guard islandIndex < vm.gameState.islands.count else { return building }
        guard let updatedBuilding = vm.gameState.islands[islandIndex].buildings.first(where: { $0?.id == building.id }) else {
            return building
        }
        return updatedBuilding ?? building
    }

    var productivity: Double {
        vm.getProductivity(for: building.id, onIslandIndex: islandIndex)
    }

    var productivityPercentage: String {
        String(format: "%.0f%%", productivity * 100)
    }

    var body: some View {
        NavigationStack {
            if currentBuilding.isUnderConstruction {
                VStack(spacing: 16) {
                    Spacer()

                    Text("Under Construction")
                        .font(.headline)
                        .foregroundColor(.orange)

                    ProgressView(value: currentBuilding.constructionProgress)
                        .progressViewStyle(.linear)
                        .padding(.horizontal, 40)

                    Text(formatTime(currentBuilding.constructionTimeRemaining))
                        .font(.title2.monospacedDigit())

                    // Speed up button
                    let remaining = currentBuilding.constructionTimeRemaining
                    if remaining <= 30 {
                        Button("Finish Now (Free)") {
                            let _ = vm.speedUpConstruction(buildingId: currentBuilding.id, on: islandIndex)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    } else {
                        let gemCost = max(1, Int(ceil(remaining / 60.0)))
                        Button("Speed Up (\(gemCost) \u{1F48E})") {
                            let _ = vm.speedUpConstruction(buildingId: currentBuilding.id, on: islandIndex)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.cyan)
                        .disabled(vm.gameState.gems < gemCost)
                    }

                    Spacer()
                }
                .padding()
                .navigationTitle(currentBuilding.type.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }
            } else {
            List {
                // Building Info Section
                Section("Building Information") {
                    HStack {
                        Image(systemName: currentBuilding.type.icon)
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                            .frame(width: 60)

                        VStack(alignment: .leading, spacing: 4) {
                            let tierNum = BuildingTierCatalog.tierNumber(for: currentBuilding.level)
                            let tierInfo = BuildingTierCatalog.tier(for: currentBuilding.type.id, tierNumber: tierNum)
                            let levelInTier = BuildingTierCatalog.levelWithinTier(for: currentBuilding.level)
                            Text("\(tierInfo.name) (\(levelInTier)/10)")
                                .font(.title2)
                                .bold()
                            Text(tierInfo.flavorText)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                    .padding(.vertical, 8)

                    if currentBuilding.type.goldProduction > 0 {
                        HStack {
                            Image(systemName: "dollarsign.circle")
                                .foregroundColor(.yellow)
                            Text("+\(currentBuilding.type.goldProduction) gold/tick")
                        }
                    }
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
                                Text("\(currentBuilding.assignedWorkers) / \(building.type.workers)")
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
                                    Text("Worker")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .disabled(currentBuilding.assignedWorkers == 0)

                            // Assign Worker Button
                            Button {
                                assignWorker()
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Worker")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(
                                currentBuilding.assignedWorkers >= building.type.workers ||
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
                    // Upgrade Button
                    if currentBuilding.level < vm.maxLevelForBuilding(currentBuilding) {
                        let upgradeCost = BuildingManager.upgradeCost(for: currentBuilding)
                        Button {
                            let result = vm.upgradeBuilding(buildingId: building.id, on: islandIndex)
                            switch result {
                            case .success:
                                alertMessage = "Building upgraded successfully!"
                                showAlert = true
                            case .failure(let error):
                                alertMessage = error.localizedDescription
                                showAlert = true
                            }
                        } label: {
                            HStack {
                                Image(systemName: "arrow.up.circle.fill")
                                let nextTierNum = BuildingTierCatalog.tierNumber(for: currentBuilding.level + 1)
                                let nextTierInfo = BuildingTierCatalog.tier(for: currentBuilding.type.id, tierNumber: nextTierNum)
                                let nextLevelInTier = BuildingTierCatalog.levelWithinTier(for: currentBuilding.level + 1)
                                Text("Upgrade to \(nextTierInfo.name) (\(nextLevelInTier)/10)")
                                Spacer()
                                Text("\(upgradeCost) gold")
                                    .foregroundColor(vm.gameState.gold >= upgradeCost ? .primary : .red)
                            }
                        }
                        .disabled(vm.gameState.gold < upgradeCost)
                    } else {
                        HStack {
                            Image(systemName: "arrow.up.circle.fill")
                                .foregroundColor(.secondary)
                            Text("Max Level (\(vm.maxLevelForBuilding(currentBuilding)))")
                                .foregroundColor(.secondary)
                        }
                    }

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
            } // end else (not under construction)
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

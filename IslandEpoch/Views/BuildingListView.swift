//
//  BuildingListView.swift
//  IslandEpoch
//

import SwiftUI
import OSLog

struct BuildingListView: View {
    @EnvironmentObject var vm: GameViewModel
    @State private var selectedBuilding: Building?
    @State private var selectedSlotIndex: Int?
    @State private var showBuildMenu = false

    private func fmt(_ value: Int) -> String {
        GameNumberFormatter.format(value, compact: vm.gameState.settings.compactNumbers)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Island Selector
                if vm.gameState.islands.count > 1 {
                    Picker("Island", selection: $vm.currentIslandIndex) {
                        ForEach(vm.gameState.islands.indices, id: \.self) { index in
                            Text(vm.gameState.islands[index].name)
                                .tag(index)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }

                List {
                    // Game Stats Section
                    Section("Resources") {
                        HStack {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(.yellow)
                            Text("Gold")
                            Spacer()
                            HStack(spacing: 4) {
                                Text(fmt(vm.gameState.gold))
                                    .bold()
                                let income = vm.gameState.totalGoldIncome
                                if income > 0 {
                                    Text("+\(fmt(income))/s")
                                        .font(.caption)
                                        .foregroundColor(.yellow)
                                }
                            }
                        }

                        if let island = vm.currentIsland {
                        // Group resources by category
                        let categories = ResourceCategory.allCases

                        ForEach(categories, id: \.self) { category in
                            let resources = ResourceType.allCases.filter { $0.category == category }
                            let categoryTotal = island.inventory.categoryTotal(category)

                            // Only show category if we have resources in it
                            if !resources.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    // Category header
                                    HStack {
                                        Image(systemName: category.icon)
                                            .foregroundColor(.green)
                                        Text(category.displayName)
                                            .font(.headline)
                                        Spacer()
                                        VStack(alignment: .trailing, spacing: 2) {
                                            let cap = island.storageCapForCategory(category)
                                            Text("\(fmt(categoryTotal))/\(fmt(cap))")
                                                .bold()
                                                .foregroundColor(categoryTotal >= cap ? .red : (Double(categoryTotal) >= Double(cap) * 0.8 ? .orange : .primary))
                                        }
                                    }

                                    // Individual resource breakdown (if category has items)
                                    if categoryTotal > 0 {
                                        ForEach(resources, id: \.self) { resource in
                                            let amount = island.inventory[resource, default: 0]
                                            if amount > 0 {
                                                HStack {
                                                    Text("  • \(resource.displayName)")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                    Spacer()
                                                    VStack(alignment: .trailing, spacing: 2) {
                                                        Text(fmt(amount))
                                                            .font(.caption)
                                                            .foregroundColor(.secondary)
                                                        resourceRateTicker(for: resource)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Buildings Section
                Section("Buildings") {
                    if let island = vm.currentIsland {
                        // Render all slots in order
                        ForEach(Array(island.buildings.enumerated()), id: \.offset) { index, building in
                            if let building = building {
                                buildingRow(building)
                            } else {
                                emptySlotRow(atIndex: index)
                            }
                        }
                    }
                }
                
                // Info Section
                Section("Island Info") {
                    if let island = vm.currentIsland {
                        LabeledContent("Island", value: island.name)
                        LabeledContent("Total Workers", value: "\(island.workersAvailable)")
                        LabeledContent("Assigned Workers", value: "\(island.totalWorkersAssigned)")
                        LabeledContent("Unassigned Workers", value: "\(island.unassignedWorkers)")
                        LabeledContent("Slots Used", value: "\(island.buildings.compactMap { $0 }.count)/\(island.maxSlots)")
                    }
                }
                }
                .navigationTitle(vm.currentIsland?.name ?? "Island")
                .sheet(item: $selectedBuilding) { building in
                    BuildingDetailView(building: building, islandIndex: vm.currentIslandIndex)
                        .environmentObject(vm)
                }
                .sheet(isPresented: $showBuildMenu) {
                    if let slotIndex = selectedSlotIndex {
                        BuildMenuView(slotIndex: slotIndex)
                            .environmentObject(vm)
                    }
                }
            }
        }
    }
    
    // MARK: - Helpers

    private func formatTime(_ s: TimeInterval) -> String {
        let m = Int(s) / 60
        let sec = Int(s) % 60
        return String(format: "%d:%02d", m, sec)
    }

    // MARK: - Resource Rate Ticker

    @ViewBuilder
    private func resourceRateTicker(for resource: ResourceType) -> some View {
        let production = vm.actualProductionRate()[resource, default: 0]
        let consumption = vm.actualConsumptionRate()[resource, default: 0]
        let netChange = production - consumption

        if netChange != 0 {
            Text("(\(netChange > 0 ? "+" : "")\(netChange)/s)")
                .font(.caption)
                .foregroundColor(netChange > 0 ? .green : .red)
        }
    }

    @ViewBuilder
    private func categoryRateTicker(for category: ResourceCategory) -> some View {
        let production = vm.actualProductionRate()
        let consumption = vm.actualConsumptionRate()

        // Calculate net change for all resources in this category
        let categoryProduction = ResourceType.allCases
            .filter { $0.category == category }
            .reduce(0) { total, resource in
                total + production[resource, default: 0]
            }

        let categoryConsumption = ResourceType.allCases
            .filter { $0.category == category }
            .reduce(0) { total, resource in
                total + consumption[resource, default: 0]
            }

        let netChange = categoryProduction - categoryConsumption

        if netChange != 0 {
            Text("(\(netChange > 0 ? "+" : "")\(netChange)/s)")
                .font(.caption)
                .foregroundColor(netChange > 0 ? .green : .red)
        }
    }

    // MARK: - Building Row

    /// Get the actual production description based on current productivity
    private func actualProductionDescription(for building: Building) -> String {
        // If building doesn't produce anything, return "No production"
        guard let (resource, baseAmount) = building.type.produces.first else {
            return "No production"
        }

        // Calculate actual production based on productivity
        let productivity = vm.getProductivity(for: building.id, onIslandIndex: vm.currentIslandIndex)
        let actualAmount = ProductivityCalculator.calculateActualProduction(baseAmount, productivity: productivity)

        return "+\(actualAmount) \(resource.displayNameWithCategory)/tick"
    }

    private func buildingRow(_ building: Building) -> some View {
        HStack {
            Image(systemName: building.type.icon)
                .font(.title2)
                .frame(width: 40)
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 4) {
                let tierNum = BuildingTierCatalog.tierNumber(for: building.level)
                let tierInfo = BuildingTierCatalog.tier(for: building.type.id, tierNumber: tierNum)
                let levelInTier = BuildingTierCatalog.levelWithinTier(for: building.level)
                Text("\(tierInfo.name) \(levelInTier)/10")
                    .font(.headline)
                if building.isUnderConstruction {
                    Text("Building... \(formatTime(building.constructionTimeRemaining))")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }
                Text(actualProductionDescription(for: building))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if building.type.goldProduction > 0 {
                    Text("+\(building.type.goldProduction) gold/s")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
                HStack(spacing: 4) {
                    Image(systemName: "person.3")
                        .font(.caption)
                    if building.type.providesWorkers > 0 {
                        Text("Provides \(building.type.providesWorkers) workers")
                            .font(.caption)
                    } else if building.type.workers > 0 {
                        let productivity = vm.getProductivity(for: building.id, onIslandIndex: vm.currentIslandIndex)
                        let productivityStr = String(format: "%.0f%%", productivity * 100)
                        Text("\(building.assignedWorkers)/\(building.type.workers) workers (\(productivityStr))")
                            .font(.caption)
                            .foregroundColor(productivity > 0.66 ? .green : (productivity > 0.33 ? .orange : .red))
                    }
                }
                .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            selectedBuilding = building
        }
    }
    
    // MARK: - Empty Slot Row

    private func emptySlotRow(atIndex index: Int) -> some View {
        Button {
            selectedSlotIndex = index
            showBuildMenu = true
        } label: {
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)

                VStack(alignment: .leading) {
                    Text("Empty Slot")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("Tap to build")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }

                Spacer()

                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
    }
}

#Preview {
    BuildingListView()
        .environmentObject(GameViewModel())
}

//
//  BuildingListView.swift
//  IslandEpoch
//

import SwiftUI
import OSLog

struct BuildingListView: View {
    @EnvironmentObject var vm: GameViewModel
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var selectedBuilding: Building?

    var body: some View {
        NavigationStack {
            List {
                // Game Stats Section
                Section("Resources") {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.yellow)
                        Text("Gold")
                        Spacer()
                        Text("\(vm.gameState.gold)")
                            .bold()
                    }

                    if let island = vm.mainIsland {
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
                                            Text("\(categoryTotal)")
                                                .bold()
                                            categoryRateTicker(for: category)
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
                                                    Text("\(amount)")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
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
                    if let island = vm.mainIsland {
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
                    if let island = vm.mainIsland {
                        LabeledContent("Island", value: island.name)
                        LabeledContent("Available Workers", value: "\(island.workersAvailable - island.totalWorkersAssigned)")
                        LabeledContent("Slots Used", value: "\(island.buildings.compactMap { $0 }.count)/\(island.maxSlots)")
                    }
                }
            }
            .navigationTitle("Main Isle")
            .alert("Action Result", isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            .sheet(item: $selectedBuilding) { building in
                BuildingDetailView(building: building, islandIndex: 0)
                    .environmentObject(vm)
            }
        }
    }
    
    // MARK: - Resource Rate Ticker

    @ViewBuilder
    private func resourceRateTicker(for resource: ResourceType) -> some View {
        let production = vm.totalProduction()[resource, default: 0]
        let consumption = vm.totalConsumption()[resource, default: 0]
        let netChange = production - consumption

        if netChange != 0 {
            Text("(\(netChange > 0 ? "+" : "")\(netChange)/s)")
                .font(.caption)
                .foregroundColor(netChange > 0 ? .green : .red)
        }
    }

    @ViewBuilder
    private func categoryRateTicker(for category: ResourceCategory) -> some View {
        let production = vm.totalProduction()
        let consumption = vm.totalConsumption()

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

    private func buildingRow(_ building: Building) -> some View {
        HStack {
            Image(systemName: building.type.icon)
                .font(.title2)
                .frame(width: 40)
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 4) {
                Text(building.type.name)
                    .font(.headline)
                Text(building.type.productionDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                HStack(spacing: 4) {
                    Image(systemName: "person.3")
                        .font(.caption)
                    if building.type.providesWorkers > 0 {
                        Text("Provides \(building.type.providesWorkers) workers")
                            .font(.caption)
                    } else if building.type.workers > 0 {
                        Text("Requires \(building.type.workers) workers")
                            .font(.caption)
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
        // Filter buildings based on current epoch
        let availableBuildings = BuildingType.all.filter { buildingType in
            buildingType.availableFromEpoch <= vm.gameState.epochTracker.currentEpoch
        }

        return Menu {
            ForEach(availableBuildings, id: \.id) { type in
                Button {
                    buildBuilding(type, atSlotIndex: index)
                } label: {
                    Label {
                        VStack(alignment: .leading) {
                            Text(type.name)
                            if type.providesWorkers > 0 {
                                Text("\(type.goldCost) gold • Provides \(type.providesWorkers) workers")
                                    .font(.caption)
                            } else if type.workers > 0 {
                                Text("\(type.goldCost) gold • Requires \(type.workers) workers")
                                    .font(.caption)
                            } else {
                                Text("\(type.goldCost) gold")
                                    .font(.caption)
                            }
                        }
                    } icon: {
                        Image(systemName: type.icon)
                    }
                }
            }
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
    
    // MARK: - Actions

    private func buildBuilding(_ type: BuildingType, atSlotIndex slotIndex: Int) {
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

#Preview {
    BuildingListView()
        .environmentObject(GameViewModel())
}

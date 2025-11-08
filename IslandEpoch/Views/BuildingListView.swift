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
                        ForEach(ResourceType.allCases, id: \.self) { resource in
                            HStack {
                                Image(systemName: resource.icon)
                                    .foregroundColor(.green)
                                Text(resource.displayName)
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("\(island.inventory[resource, default: 0])")
                                        .bold()
                                    resourceRateTicker(for: resource)
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
                        LabeledContent("Workers", value: "\(island.workersAvailable)")
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
                    Text("\(building.type.workers) workers")
                        .font(.caption)
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
        Menu {
            ForEach(BuildingType.all, id: \.id) { type in
                Button {
                    buildBuilding(type, atSlotIndex: index)
                } label: {
                    Label {
                        VStack(alignment: .leading) {
                            Text(type.name)
                            Text("\(type.goldCost) gold • \(type.workers) workers")
                                .font(.caption)
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

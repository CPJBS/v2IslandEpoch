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
                                Text("\(island.inventory[resource, default: 0])")
                                    .bold()
                            }
                        }
                    }
                }
                
                // Buildings Section
                Section("Buildings") {
                    if let island = vm.mainIsland {
                        // Existing buildings
                        ForEach(island.buildings) { building in
                            buildingRow(building)
                        }
                        
                        // Empty slots
                        ForEach(0..<vm.emptySlots, id: \.self) { _ in
                            emptySlotRow()
                        }
                    }
                }
                
                // Info Section
                Section("Island Info") {
                    if let island = vm.mainIsland {
                        LabeledContent("Island", value: island.name)
                        LabeledContent("Workers", value: "\(island.workersAvailable)")
                        LabeledContent("Slots Used", value: "\(island.buildings.count)/\(island.maxSlots)")
                    }
                }
            }
            .navigationTitle("Main Isle")
            .alert("Action Result", isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
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
        }
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                demolishBuilding(building.id)
            } label: {
                Label("Demolish", systemImage: "trash")
            }
        }
    }
    
    // MARK: - Empty Slot Row
    
    private func emptySlotRow() -> some View {
        Menu {
            ForEach(BuildingType.all, id: \.id) { type in
                Button {
                    buildBuilding(type)
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
    
    private func buildBuilding(_ type: BuildingType) {
        let result = vm.buildBuilding(type, onIslandIndex: 0)
        
        switch result {
        case .success:
            alertMessage = "\(type.name) built successfully!"
        case .failure(let error):
            alertMessage = error.localizedDescription
        }
        
        showAlert = true
    }
    
    private func demolishBuilding(_ buildingId: UUID) {
        let result = vm.demolishBuilding(buildingId, fromIslandIndex: 0)
        
        switch result {
        case .success:
            alertMessage = "Building demolished"
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

//
//  ContentView.swift
//  IslandEpoch
//

import SwiftUI
import OSLog

struct ContentView: View {
    @StateObject private var vm = GameViewModel()
    
    var body: some View {
        TabView {
            IslandTabView()
                .tabItem {
                    Label("Island", systemImage: "map")
                }

            BuildingListView()
                .tabItem {
                    Label("Buildings", systemImage: "building.2")
                }

            ResearchView()
                .tabItem {
                    Label("Research", systemImage: "flask")
                }

            DebugView()
                .tabItem {
                    Label("Debug", systemImage: "ladybug")
                }
        }
        .environmentObject(vm)
        .onAppear {
            vm.start()
        }
    }
}

// MARK: - Island Tab Wrapper
struct IslandTabView: View {
    @EnvironmentObject var vm: GameViewModel
    @State private var selectedBuilding: Building?
    @State private var selectedSlotIndex: Int?
    @State private var showBuildMenu = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        ZStack {
            IslandMapView(
                gold: vm.gameState.gold,
                wheat: vm.mainIsland?.inventory[.wheat, default: 0] ?? 0,
                workers: vm.mainIsland?.unassignedWorkers ?? 0,
                buildings: vm.mainIsland?.buildings ?? []
            ) { slotIndex in
                handleSlotTap(slotIndex)
            }
        }
        .sheet(item: $selectedBuilding) { building in
            BuildingDetailView(building: building, islandIndex: 0)
                .environmentObject(vm)
        }
        .sheet(isPresented: $showBuildMenu) {
            if let slotIndex = selectedSlotIndex {
                BuildMenuView(slotIndex: slotIndex, onBuild: { type in
                    buildBuilding(type, atSlotIndex: slotIndex)
                })
                .environmentObject(vm)
            }
        }
        .alert("Action Result", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }

    private func handleSlotTap(_ slotIndex: Int) {
        guard let island = vm.mainIsland, slotIndex < island.buildings.count else { return }

        if let building = island.buildings[slotIndex] {
            // Occupied slot - view building details
            selectedBuilding = building
        } else {
            // Empty slot - show build menu
            selectedSlotIndex = slotIndex
            showBuildMenu = true
        }
    }

    private func buildBuilding(_ type: BuildingType, atSlotIndex slotIndex: Int) {
        let result = vm.buildBuilding(type, onIslandIndex: 0, atSlotIndex: slotIndex)

        switch result {
        case .success:
            alertMessage = "\(type.name) built successfully!"
            showBuildMenu = false
        case .failure(let error):
            alertMessage = error.localizedDescription
        }

        showAlert = true
    }
}

// MARK: - Build Menu View
struct BuildMenuView: View {
    @EnvironmentObject var vm: GameViewModel
    let slotIndex: Int
    let onBuild: (BuildingType) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(availableBuildings, id: \.id) { type in
                    Button {
                        onBuild(type)
                        dismiss()
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
        }
    }

    private var availableBuildings: [BuildingType] {
        BuildingType.all.filter { buildingType in
            buildingType.availableFromEpoch <= vm.gameState.epochTracker.currentEpoch
        }
    }
}

#Preview {
    ContentView()
}

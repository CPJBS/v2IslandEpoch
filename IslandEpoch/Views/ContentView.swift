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

    var body: some View {
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

            // Island Map
            IslandMapView(
                gold: vm.gameState.gold,
                wheat: vm.currentIsland?.inventory[.wheat, default: 0] ?? 0,
                workers: vm.currentIsland?.unassignedWorkers ?? 0,
                knowledge: vm.currentIsland?.inventory[.insight, default: 0] ?? 0,
                buildings: vm.currentIsland?.buildings ?? []
            ) { slotIndex in
                handleSlotTap(slotIndex)
            }
        }
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

    private func handleSlotTap(_ slotIndex: Int) {
        guard let island = vm.currentIsland, slotIndex < island.buildings.count else { return }

        if let building = island.buildings[slotIndex] {
            // Occupied slot - view building details
            selectedBuilding = building
        } else {
            // Empty slot - show build menu
            selectedSlotIndex = slotIndex
            showBuildMenu = true
        }
    }
}

#Preview {
    ContentView()
}

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
        ZStack {
            IslandMapView(
                gold: vm.gameState.gold,
                wheat: vm.mainIsland?.inventory[.wheat, default: 0] ?? 0,
                workers: vm.mainIsland?.unassignedWorkers ?? 0,
                knowledge: vm.mainIsland?.inventory[.insight, default: 0] ?? 0,
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
                BuildMenuView(slotIndex: slotIndex)
                    .environmentObject(vm)
            }
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
}

#Preview {
    ContentView()
}

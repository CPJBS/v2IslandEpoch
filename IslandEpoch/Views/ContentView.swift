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

    var body: some View {
        IslandMapView(
            gold: vm.gameState.gold,
            wheat: vm.mainIsland?.inventory[.wheat, default: 0] ?? 0,
            workers: vm.mainIsland?.unassignedWorkers ?? 0,
            tradingResearched: vm.gameState.hasCompletedResearch("trading")
        ) { kind in
            // Handle spot tap - for now just log it
            print("Tapped spot: \(kind)")
        }
    }
}

#Preview {
    ContentView()
}

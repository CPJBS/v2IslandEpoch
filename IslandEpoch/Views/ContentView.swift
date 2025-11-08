//
//  ContentView.swift
//  IslandEpoch
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = GameViewModel()
    
    var body: some View {
        TabView {
            BuildingListView()
                .tabItem {
                    Label("Buildings", systemImage: "building.2")
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

#Preview {
    ContentView()
}

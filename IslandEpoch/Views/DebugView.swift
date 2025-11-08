//
//  DebugView.swift
//  IslandEpoch
//

import SwiftUI

struct DebugView: View {
    @EnvironmentObject var vm: GameViewModel
    
    var body: some View {
        NavigationStack {
            List {
                // Time Section
                Section {
                    LabeledContent("Ticks", value: "\(vm.gameState.tick)")
                    LabeledContent("Total Time", value: formatTime(vm.gameState.totalGameTime))
                    LabeledContent("Started", value: vm.gameState.gameStartTime, format: .dateTime)
                } header: {
                    Text("Game Time")
                }
                
                // Production Section
                Section {
                    let production = vm.totalProduction()
                    
                    if production.isEmpty {
                        Text("No production yet")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(ResourceType.allCases, id: \.self) { resource in
                            if let amount = production[resource], amount > 0 {
                                HStack {
                                    Image(systemName: resource.icon)
                                    Text(resource.displayName)
                                    Spacer()
                                    Text("+\(amount)/tick")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Production")
                }
                
                // Save Management Section
                Section {
                    Button {
                        vm.saveGame()
                    } label: {
                        Label("Save Game", systemImage: "square.and.arrow.down")
                    }
                    
                    Button {
                        vm.loadGame()
                    } label: {
                        Label("Load Game", systemImage: "square.and.arrow.up")
                    }
                    .disabled(!vm.hasSaveFile())
                    
                    Button(role: .destructive) {
                        vm.deleteSave()
                    } label: {
                        Label("Delete Save", systemImage: "trash")
                    }
                    .disabled(!vm.hasSaveFile())
                } header: {
                    Text("Save Management")
                } footer: {
                    Text(vm.hasSaveFile() ? "Save file exists" : "No save file")
                }
                
                // Game Control Section
                Section {
                    Button {
                        vm.startNewGame()
                    } label: {
                        Label("New Game", systemImage: "plus.circle")
                    }
                } header: {
                    Text("Game Control")
                } footer: {
                    Text("This will reset all progress")
                }
            }
            .navigationTitle("Debug Console")
        }
    }
    
    // MARK: - Helpers
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        
        if hours > 0 {
            return String(format: "%dh %dm %ds", hours, minutes, seconds)
        } else {
            return String(format: "%dm %ds", minutes, seconds)
        }
    }
}

#Preview {
    DebugView()
        .environmentObject(GameViewModel())
}

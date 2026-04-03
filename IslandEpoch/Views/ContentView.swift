//
//  ContentView.swift
//  IslandEpoch
//

import SwiftUI
import OSLog

struct ContentView: View {
    @StateObject private var vm = GameViewModel()
    @Environment(\.scenePhase) var scenePhase
    @State private var showWelcomeBack = false
    @State private var offlineReport: OfflineReport?
    @State private var showDailyLogin = false
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            IslandTabView()
                .tabItem {
                    Label("Island", systemImage: "map")
                }
                .tag(0)

            BuildingListView()
                .tabItem {
                    Label("Buildings", systemImage: "building.2")
                }
                .tag(1)

            ResearchView()
                .tabItem {
                    Label("Research", systemImage: "flask")
                }
                .tag(2)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(3)

            #if DEBUG
            DebugView()
                .tabItem {
                    Label("Debug", systemImage: "ladybug")
                }
                .tag(4)
            #endif
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                HStack(spacing: 4) {
                    Image(systemName: "diamond.fill").foregroundColor(.cyan).font(.caption)
                    Text("\(vm.gameState.gems)").font(.callout.bold())
                }
            }
        }
        .sheet(isPresented: $showWelcomeBack) {
            if let report = offlineReport {
                WelcomeBackView(report: report, onCollect: { showWelcomeBack = false }, onCollectDouble: {
                    if vm.gameState.gems >= 5 {
                        vm.gameState.gems -= 5
                        vm.gameState.gold += report.goldEarned
                    }
                    showWelcomeBack = false
                }).environmentObject(vm)
            }
        }
        .sheet(isPresented: $showDailyLogin) {
            DailyLoginView { gold, gems in
                vm.gameState.gold += gold
                vm.awardGems(gems, source: "daily_login")
                
                // Update streak logic
                let calendar = Calendar.current
                if let lastClaim = vm.gameState.dailyLogin.lastClaimDate {
                    // Check if last claim was yesterday (continue streak) or earlier (reset to 1)
                    if calendar.isDateInYesterday(lastClaim) {
                        vm.gameState.dailyLogin.currentStreak += 1
                    } else {
                        // Missed one or more days, reset streak to 1
                        vm.gameState.dailyLogin.currentStreak = 1
                    }
                } else {
                    // First time claiming
                    vm.gameState.dailyLogin.currentStreak = 1
                }
                
                vm.gameState.dailyLogin.lastClaimDate = Date()
                vm.gameState.dailyLogin.totalDaysClaimed += 1
                showDailyLogin = false
            }.environmentObject(vm)
        }
        .overlay {
            if vm.gameState.tutorialStep > 0 {
                TutorialOverlayView(tutorialStep: $vm.gameState.tutorialStep).environmentObject(vm)
            }
        }
        .onChange(of: vm.gameState.tutorialStep) { _, newStep in
            // Auto-switch to Research tab for step 7, back to Island for other steps
            if newStep == 7 {
                selectedTab = 2
            } else if newStep > 0 && newStep != 7 {
                selectedTab = 0
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .background:
                vm.saveGame()
                if vm.gameState.settings.notificationsEnabled {
                    NotificationManager.shared.scheduleAllPending(gameState: vm.gameState)
                }
            case .active:
                NotificationManager.shared.cancelAll()
                let elapsed = Date().timeIntervalSince(vm.gameState.lastUpdateTime)
                if elapsed > 10 {
                    let report = OfflineProgressManager.calculateOfflineProgress(gameState: &vm.gameState, elapsedSeconds: elapsed)
                    offlineReport = report
                    showWelcomeBack = true
                }
                vm.gameState.statistics.sessionsCount += 1
            default: break
            }
        }
        .environmentObject(vm)
        .onAppear {
            NotificationManager.shared.requestPermission()
            vm.start()

            // Start tutorial for new players
            if vm.gameState.tutorialStep == 0 {
                vm.gameState.tutorialStep = 1
            }
            // Check daily login
            let calendar = Calendar.current
            if let lastClaim = vm.gameState.dailyLogin.lastClaimDate {
                // Show dialog if not claimed today
                if !calendar.isDateInToday(lastClaim) {
                    // If last claim was not yesterday, reset streak (but don't claim yet)
                    if !calendar.isDateInYesterday(lastClaim) {
                        vm.gameState.dailyLogin.currentStreak = 0
                    }
                    showDailyLogin = true
                }
            } else {
                // First time - initialize streak to 0 (will become 1 on first claim)
                vm.gameState.dailyLogin.currentStreak = 0
                showDailyLogin = true
            }
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
        NavigationStack {
            VStack(spacing: 0) {
                // Island Selector with lock support
                if vm.gameState.islands.count > 1 {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(vm.gameState.islands.indices, id: \.self) { index in
                                let island = vm.gameState.islands[index]
                                let isUnlocked = vm.isIslandUnlocked(island)

                                Button {
                                    if isUnlocked {
                                        vm.currentIslandIndex = index
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        if !isUnlocked {
                                            Image(systemName: "lock.fill")
                                                .font(.caption2)
                                        }
                                        Text(island.name)
                                            .font(.subheadline)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        isUnlocked
                                            ? (vm.currentIslandIndex == index ? Color.blue : Color.blue.opacity(0.15))
                                            : Color.gray.opacity(0.15)
                                    )
                                    .foregroundColor(
                                        isUnlocked
                                            ? (vm.currentIslandIndex == index ? .white : .blue)
                                            : .gray
                                    )
                                    .cornerRadius(8)
                                }
                                .disabled(!isUnlocked)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                }

                // Island Map
                if let island = vm.currentIsland {
                    IslandMapView(
                        gold: vm.gameState.gold,
                        island: island,
                        epochNumber: vm.currentEpoch,
                        epochName: vm.currentEpochName,
                        epochDescription: vm.currentEpochDescription,
                        tutorialStep: vm.gameState.tutorialStep
                    ) { slotIndex in
                        handleSlotTap(slotIndex)
                    }
                }
            }
            .navigationTitle("Epoch \(vm.currentEpoch): \(vm.currentEpochName)")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
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

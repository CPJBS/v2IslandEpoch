//
//  ResearchView.swift
//  IslandEpoch
//

import SwiftUI

struct ResearchView: View {
    @EnvironmentObject var vm: GameViewModel
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            List {
                // Active research banner
                if let active = vm.gameState.activeResearch {
                    let researchType = ResearchType.all.first(where: { $0.id == active.researchId })
                    Section("Active Research") {
                        VStack(spacing: 12) {
                            Text(researchType?.name ?? active.researchId)
                                .font(.headline)

                            ProgressView(value: active.progress)
                                .progressViewStyle(.linear)

                            Text(formatTime(active.timeRemaining))
                                .font(.title3.monospacedDigit())

                            // Speed up
                            let remaining = active.timeRemaining
                            if remaining <= 30 {
                                Button("Finish Now (Free)") {
                                    let _ = vm.speedUpResearch()
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.green)
                            } else {
                                let gemCost = max(1, Int(ceil(remaining / 60.0)))
                                Button("Speed Up (\(gemCost) \u{1F48E})") {
                                    let _ = vm.speedUpResearch()
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.cyan)
                                .disabled(vm.gameState.gems < gemCost)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }

                ForEach(1...10, id: \.self) { epoch in
                    let epochResearch = ResearchType.all.filter { $0.requiredEpoch == epoch }
                    if !epochResearch.isEmpty {
                        Section(header: epochSectionHeader(epoch)) {
                            ForEach(epochResearch, id: \.id) { research in
                                ResearchRowView(research: research, vm: vm) {
                                    performResearch(research)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Research")
            .alert("Research", isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    // MARK: - Section Header

    private func epochSectionHeader(_ epoch: Int) -> some View {
        HStack(spacing: 6) {
            if epoch <= vm.currentEpoch {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.green)
                    .font(.caption)
            } else if epoch == vm.currentEpoch + 1 {
                Image(systemName: "lock.open.fill")
                    .foregroundColor(.orange)
                    .font(.caption)
            } else {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            Text("Epoch \(epoch)")
        }
    }

    // MARK: - Actions

    private func performResearch(_ research: ResearchType) {
        let result = vm.completeResearch(research.id)

        switch result {
        case .success:
            alertMessage = "\(research.name) research started! Time: \(formatTime(research.researchTime))"
        case .failure(let error):
            alertMessage = error.localizedDescription
        }

        showAlert = true
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let mins = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        if hours > 0 { return String(format: "%d:%02d:%02d", hours, mins, secs) }
        return String(format: "%d:%02d", mins, secs)
    }
}

// MARK: - Research Row View

private struct ResearchRowView: View {
    let research: ResearchType
    let vm: GameViewModel
    let onResearch: () -> Void

    private var isCompleted: Bool {
        vm.gameState.hasCompletedResearch(research.id)
    }

    private var canStart: Bool {
        vm.canStartResearch(research)
    }

    private var canAfford: Bool {
        guard let island = vm.mainIsland else { return false }
        for (resource, amount) in research.cost {
            if !island.inventory.has(resource, amount: amount) {
                return false
            }
        }
        return true
    }

    private var isEpochLocked: Bool {
        vm.currentEpoch < research.requiredEpoch
    }

    private var isPrerequisiteMet: Bool {
        guard !research.prerequisiteIds.isEmpty else { return true }
        return research.prerequisiteIds.allSatisfy { vm.completedResearchIds.contains($0) }
    }

    private var isEpochAdvancer: Bool {
        research.effects.contains(.advanceEpoch)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Name and status checkmark
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        if isEpochAdvancer {
                            Image(systemName: "star.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                        }
                        Text(research.name)
                            .font(.headline)
                    }

                    Text(research.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                }
            }

            // Effect badge
            if let effect = effectLabel(for: research) {
                HStack(spacing: 4) {
                    Image(systemName: effectIcon(for: research))
                        .font(.caption2)
                    Text(effect.text)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(effect.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(effect.color.opacity(0.12))
                .cornerRadius(6)
            }

            // Prerequisite indicator
            if !research.prerequisiteIds.isEmpty {
                let prereqNames = research.prerequisiteIds.compactMap { pid in
                    ResearchType.all.first(where: { $0.id == pid })?.name
                }
                if !prereqNames.isEmpty {
                    HStack(spacing: 4) {
                        if isPrerequisiteMet {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption2)
                            Text("Requires: \(prereqNames.joined(separator: ", "))")
                                .font(.caption)
                                .foregroundColor(.green)
                        } else {
                            Image(systemName: "exclamationmark.circle")
                                .foregroundColor(.gray)
                                .font(.caption2)
                            Text("Requires: \(prereqNames.joined(separator: ", "))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }

            // Cost display
            VStack(alignment: .leading, spacing: 4) {
                Text("Cost:")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 12) {
                    ForEach(Array(research.cost.keys.sorted(by: { $0.displayName < $1.displayName })), id: \.self) { resource in
                        if let amount = research.cost[resource] {
                            HStack(spacing: 4) {
                                Image(systemName: resource.icon)
                                    .font(.caption)
                                Text("\(amount) \(resource.displayName)")
                                    .font(.caption)
                            }
                            .foregroundColor(hasEnoughResource(resource, amount: amount) ? .primary : .red)
                        }
                    }
                }
            }

            // Status / action
            if isCompleted {
                // Already completed -- no button needed
            } else if isEpochLocked {
                Text("Available in Epoch \(research.requiredEpoch)")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            } else if !isPrerequisiteMet {
                let prereqNames = research.prerequisiteIds.compactMap { pid in
                    ResearchType.all.first(where: { $0.id == pid })?.name
                }
                Text("Requires \(prereqNames.joined(separator: " & ")) first")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            } else if vm.gameState.activeResearch != nil {
                Text("Research in progress...")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            } else {
                Button(action: onResearch) {
                    Text("Start Research (\(formatDuration(research.researchTime)))")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(canAfford ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(!canAfford)
            }
        }
        .padding(.vertical, 8)
        .listRowBackground(rowBackground)
        .opacity(isEpochLocked ? 0.5 : (isCompleted ? 0.7 : 1.0))
    }

    // MARK: - Row Background

    private var rowBackground: Color? {
        if isCompleted {
            return Color.green.opacity(0.08)
        }
        return nil
    }

    // MARK: - Helpers

    private func hasEnoughResource(_ resource: ResourceType, amount: Int) -> Bool {
        guard let island = vm.mainIsland else { return false }
        return island.inventory.has(resource, amount: amount)
    }

    // MARK: - Effect Label

    private func effectLabel(for research: ResearchType) -> (text: String, color: Color)? {
        for effect in research.effects {
            switch effect {
            case .advanceEpoch:
                return ("Advances to next epoch", .orange)
            case .unlockIsland(let name):
                return ("Unlocks \(name)", .blue)
            case .unlockBuildingTier(let epoch):
                return ("Unlocks epoch \(epoch) buildings", .purple)
            case .productionBonus(let buildingId, let multiplier):
                let pct = Int((multiplier - 1.0) * 100)
                return ("+\(pct)% \(buildingId) production", .green)
            case .allProductionBonus(let multiplier):
                let pct = Int((multiplier - 1.0) * 100)
                return ("+\(pct)% all production", .green)
            case .goldIncomeBonus(let perTick):
                return ("+\(perTick) gold per tick", .yellow)
            case .goldIncomeMultiplier(let multiplier):
                let pct = Int((multiplier - 1.0) * 100)
                return ("+\(pct)% gold income", .yellow)
            case .workerCapacityBonus(let perHousing):
                return ("+\(perHousing) workers per housing", .cyan)
            case .storageBonusPercent(let percent):
                return ("+\(percent)% storage capacity", .teal)
            case .constructionSpeedBonus(let percent):
                return ("+\(percent)% construction speed", .mint)
            case .researchSpeedBonus(let percent):
                return ("+\(percent)% research speed", .indigo)
            case .insightProductionBonus(let multiplier):
                let pct = Int((multiplier - 1.0) * 100)
                return ("+\(pct)% insight production", .indigo)
            case .foodProductionBonus(let multiplier):
                let pct = Int((multiplier - 1.0) * 100)
                return ("+\(pct)% food production", .green)
            case .buildingSlotsBonus(let perIsland):
                return ("+\(perIsland) building slots per island", .purple)
            case .housingCapacityBonus(let percent):
                return ("+\(percent)% housing capacity", .cyan)
            }
        }
        return nil
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let mins = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        if hours > 0 { return String(format: "%d:%02d:%02d", hours, mins, secs) }
        return String(format: "%d:%02d", mins, secs)
    }

    private func effectIcon(for research: ResearchType) -> String {
        for effect in research.effects {
            switch effect {
            case .advanceEpoch:
                return "arrow.right.circle.fill"
            case .unlockIsland:
                return "map.fill"
            case .unlockBuildingTier:
                return "hammer.fill"
            case .productionBonus, .allProductionBonus, .foodProductionBonus:
                return "arrow.up.right.circle.fill"
            case .goldIncomeBonus, .goldIncomeMultiplier:
                return "dollarsign.circle.fill"
            case .workerCapacityBonus, .housingCapacityBonus:
                return "person.2.fill"
            case .storageBonusPercent:
                return "archivebox.fill"
            case .constructionSpeedBonus:
                return "wrench.and.screwdriver.fill"
            case .researchSpeedBonus, .insightProductionBonus:
                return "lightbulb.fill"
            case .buildingSlotsBonus:
                return "square.grid.2x2.fill"
            }
        }
        return "sparkles"
    }
}

#Preview {
    ResearchView()
        .environmentObject(GameViewModel())
}

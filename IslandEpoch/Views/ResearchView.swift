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
                Section("Available Research") {
                    ForEach(ResearchType.all) { research in
                        researchRow(research)
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

    // MARK: - Research Row

    private func researchRow(_ research: ResearchType) -> some View {
        let isCompleted = vm.gameState.hasCompletedResearch(research.id)
        let canAfford = canAffordResearch(research)

        return VStack(alignment: .leading, spacing: 12) {
            // Name and Status
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(research.name)
                        .font(.headline)
                    Text(research.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                }
            }

            // Cost
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

            // Research Button
            if !isCompleted {
                Button(action: {
                    performResearch(research)
                }) {
                    Text("Research")
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
        .opacity(isCompleted ? 0.6 : 1.0)
    }

    // MARK: - Helpers

    private func canAffordResearch(_ research: ResearchType) -> Bool {
        guard let island = vm.mainIsland else { return false }

        for (resource, amount) in research.cost {
            // Insight is a shared resource
            if resource == .insight {
                if vm.gameState.insight < amount {
                    return false
                }
            } else {
                if !island.inventory.has(resource, amount: amount) {
                    return false
                }
            }
        }

        return true
    }

    private func hasEnoughResource(_ resource: ResourceType, amount: Int) -> Bool {
        // Insight is a shared resource
        if resource == .insight {
            return vm.gameState.insight >= amount
        }

        guard let island = vm.mainIsland else { return false }
        return island.inventory.has(resource, amount: amount)
    }

    // MARK: - Actions

    private func performResearch(_ research: ResearchType) {
        let result = vm.completeResearch(research.id)

        switch result {
        case .success:
            alertMessage = "\(research.name) completed successfully!"
        case .failure(let error):
            alertMessage = error.localizedDescription
        }

        showAlert = true
    }
}

#Preview {
    ResearchView()
        .environmentObject(GameViewModel())
}

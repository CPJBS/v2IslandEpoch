//
//  IslandMapView.swift
//  IslandEpoch
//
//  Created by Casper Stienstra on 14/05/2025.
//

import SwiftUI

// ─────────────────────────────────────────────────────────────────
// IslandMapView — Dynamic grid layout with epoch + hunger display
// ─────────────────────────────────────────────────────────────────
struct IslandMapView: View {
    // Injected state
    let gold: Int
    let island: Island
    let epochNumber: Int
    let epochName: String
    let epochDescription: String
    let tutorialStep: Int
    let onSlotTap: (Int) -> Void

    private var buildings: [Building?] { island.buildings }

    /// Whether empty slots should be highlighted for the current tutorial step
    private var highlightEmptySlots: Bool {
        [3, 6].contains(tutorialStep)
    }

    /// Whether a specific occupied building slot should be highlighted
    private func shouldHighlightBuilding(_ building: Building) -> Bool {
        if tutorialStep == 4 {
            return building.type.id == "forager" && !building.isUnderConstruction
        }
        return false
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }

    var body: some View {
        ZStack {
            // Island background
            Color.blue.opacity(0.1)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 12) {
                // Epoch display
                VStack(spacing: 2) {
                    Text("Epoch \(epochNumber): \(epochName)")
                        .font(.headline)
                    Text(epochDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)

                // Resource bar
                resourceBar

                // Food status indicator
                if island.isHungry {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text("Workers are hungry! Production halved.")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    .padding(.horizontal)
                }

                // Dynamic building grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                    ForEach(0..<buildings.count, id: \.self) { index in
                        Button {
                            onSlotTap(index)
                        } label: {
                            if let building = buildings[index] {
                                // Occupied slot - show building
                                let highlighted = shouldHighlightBuilding(building)
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(building.isUnderConstruction ? Color.orange.opacity(0.3) : (highlighted ? Color.yellow.opacity(0.15) : Color.blue.opacity(0.3)))
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(highlighted ? Color.yellow : (building.isUnderConstruction ? Color.orange : Color.blue), lineWidth: highlighted ? 3 : 2)
                                    if highlighted {
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.yellow, lineWidth: 2)
                                            .shadow(color: .yellow, radius: 6)
                                    }
                                    VStack(spacing: 4) {
                                        if building.isUnderConstruction {
                                            Image(systemName: "hammer.fill")
                                                .font(.title)
                                                .foregroundColor(.orange)
                                            ProgressView(value: building.constructionProgress)
                                                .progressViewStyle(.circular)
                                                .scaleEffect(0.7)
                                            Text(formatTime(building.constructionTimeRemaining))
                                                .font(.caption2.monospacedDigit())
                                                .foregroundColor(.orange)
                                        } else {
                                            Image(systemName: building.type.icon)
                                                .font(.title)
                                                .foregroundColor(.white)
                                            let tierNum = BuildingTierCatalog.tierNumber(for: building.level)
                                            let tierInfo = BuildingTierCatalog.tier(for: building.type.id, tierNumber: tierNum)
                                            Text(tierInfo.name)
                                                .font(.caption2)
                                                .foregroundColor(.white)
                                                .lineLimit(1)
                                        }
                                    }
                                }
                                .frame(height: 70)
                            } else {
                                // Empty slot
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(highlightEmptySlots ? Color.yellow : Color.gray.opacity(0.5), lineWidth: highlightEmptySlots ? 3 : 2)
                                        .background(highlightEmptySlots ? Color.yellow.opacity(0.15) : Color.clear)
                                    if highlightEmptySlots {
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.yellow, lineWidth: 2)
                                            .shadow(color: .yellow, radius: 6)
                                    }
                                    Image(systemName: "plus")
                                        .font(.title2)
                                        .foregroundColor(highlightEmptySlots ? .yellow : .gray.opacity(0.5))
                                }
                                .frame(height: 70)
                            }
                        }
                    }
                }
                .padding()

                Spacer()
            }
        }
    }

    // MARK: - Resource Bar

    private var resourceBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Gold always shown
                Label("\(gold)", systemImage: "dollarsign.circle")

                // Workers always shown
                Label("\(island.unassignedWorkers)/\(island.workersAvailable)", systemImage: "person.3.sequence")
                    .foregroundColor(island.unassignedWorkers == 0 && island.workersAvailable > 0 ? .red : .primary)

                // Dynamic resources: show all with amount > 0
                ForEach(resourcesWithStock, id: \.0) { resource, amount in
                    let cap = island.storageCapForCategory(resource.category)
                    Label("\(amount)/\(cap)", systemImage: resource.icon)
                        .foregroundColor(amount >= cap ? .red : (Double(amount) >= Double(cap) * 0.8 ? .orange : resourceColor(for: resource)))
                }
            }
            .font(.headline)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemBackground).opacity(0.9))
            .cornerRadius(8)
        }
        .padding(.horizontal)
    }

    /// Resources that have stock > 0, sorted by category then name
    private var resourcesWithStock: [(ResourceType, Int)] {
        island.inventory
            .filter { $0.value > 0 }
            .sorted { lhs, rhs in
                if lhs.key.category != rhs.key.category {
                    return lhs.key.category.rawValue < rhs.key.category.rawValue
                }
                return lhs.key.displayName < rhs.key.displayName
            }
            .map { ($0.key, $0.value) }
    }

    private func resourceColor(for resource: ResourceType) -> Color {
        switch resource.category {
        case .food: return .green
        case .material: return .brown
        case .ore: return .gray
        case .knowledge: return .purple
        }
    }
}

// ─────────────────────────────────────────────────────────────────
// Preview
// ─────────────────────────────────────────────────────────────────
struct IslandMapView_Previews: PreviewProvider {
    static var previews: some View {
        let island = {
            var i = Island(name: "Main Isle", maxSlots: 8, fertilities: [.grainland, .forest])
            i.buildings[0] = Building(type: .tent)
            i.buildings[1] = Building(type: .farm)
            i.buildings[3] = Building(type: .forester)
            i.inventory = [.wheat: 25, .wood: 40, .bread: 10, .insight: 5]
            return i
        }()

        IslandMapView(
            gold: 500,
            island: island,
            epochNumber: 2,
            epochName: "Settlement",
            epochDescription: "With agriculture comes permanence.",
            tutorialStep: -1,
            onSlotTap: { slotIndex in
                print("Tapped slot:", slotIndex)
            }
        )
        .frame(width: 375, height: 667)
    }
}

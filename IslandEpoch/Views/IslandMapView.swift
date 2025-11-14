//
//  IslandMapView.swift
//  IslandEpoch
//
//  Created by Casper Stienstra on 14/05/2025.
//

import SwiftUI

// ─────────────────────────────────────────────────────────────────
// 1️⃣ Define BuildingSlotData for display
// ─────────────────────────────────────────────────────────────────
struct BuildingSlotData: Identifiable {
    let id: Int  // Slot index
    let building: Building?
    let position: CGPoint
}

// ─────────────────────────────────────────────────────────────────
// 2️⃣ The IslandMapView itself
// ─────────────────────────────────────────────────────────────────
struct IslandMapView: View {
    // Injected state from your GameViewModel
    let gold: Int
    let wheat: Int
    let workers: Int
    let knowledge: Int
    let buildings: [Building?]
    let onSlotTap: (Int) -> Void  // Passes slot index

    // Fixed spot positions (matching array indices)
    private let positions: [CGPoint] = [
        CGPoint(x: 0.25, y: 0.30),  // Slot 0
        CGPoint(x: 0.50, y: 0.30),  // Slot 1
        CGPoint(x: 0.75, y: 0.30),  // Slot 2
        CGPoint(x: 0.25, y: 0.50),  // Slot 3
        CGPoint(x: 0.50, y: 0.50),  // Slot 4
        CGPoint(x: 0.75, y: 0.50),  // Slot 5
    ]

    // Map buildings to slots with positions
    private var slots: [BuildingSlotData] {
        buildings.enumerated().map { index, building in
            BuildingSlotData(
                id: index,
                building: building,
                position: index < positions.count ? positions[index] : CGPoint(x: 0.5, y: 0.8)
            )
        }
    }

    var body: some View {
        ZStack {
            // Island background
            Color.blue.opacity(0.1)
                .edgesIgnoringSafeArea(.all)

            // Building spots
            GeometryReader { geo in
                ForEach(slots) { slot in
                    Button {
                        onSlotTap(slot.id)
                    } label: {
                        if let building = slot.building {
                            // Occupied slot - show building
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.blue.opacity(0.3))
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.blue, lineWidth: 2)
                                Image(systemName: building.type.icon)
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 60, height: 60)
                        } else {
                            // Empty slot
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                                    .background(Color.clear)
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .foregroundColor(.gray.opacity(0.5))
                            }
                            .frame(width: 60, height: 60)
                        }
                    }
                    .position(
                        x: geo.size.width  * slot.position.x,
                        y: geo.size.height * slot.position.y
                    )
                }
            }

            // Top resource bar
            VStack {
                HStack {
                    Spacer()
                    HStack(spacing: 16) {
                        Label("\(gold)", systemImage: "dollarsign.circle")
                        Label("\(wheat)", systemImage: "leaf.fill")
                        Label("\(knowledge)", systemImage: "lightbulb.fill")
                        Label("\(workers)", systemImage: "person.3.sequence")
                            .foregroundColor(workers < 10 ? .primary : .red)
                    }
                    .font(.headline)
                    .padding(8)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(8)
                }
                .padding()
                Spacer()
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────────
// 3️⃣ Preview to verify build
// ─────────────────────────────────────────────────────────────────
struct IslandMapView_Previews: PreviewProvider {
    static var previews: some View {
        IslandMapView(
            gold: 500,
            wheat: 45,
            workers: 8,
            knowledge: 12,
            buildings: [
                Building(type: .tent),
                Building(type: .farm),
                nil,
                Building(type: .forester),
                nil,
                Building(type: .mine)
            ]
        ) { slotIndex in
            print("Tapped slot:", slotIndex)
        }
        .frame(width: 375, height: 667)
    }
}

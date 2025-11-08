//
//  IslandMapView.swift
//  IslandEpoch
//
//  Created by Casper Stienstra on 14/05/2025.
//

import SwiftUI

// ─────────────────────────────────────────────────────────────────
// 1️⃣ Define BuildingSpot so ForEach can find it
// ─────────────────────────────────────────────────────────────────
struct BuildingSpot: Identifiable {
    enum Kind {
        case empty, harbor
    }
    let id = UUID()
    let kind: Kind
    /// Relative position in [0…1] × [0…1] coordinate space
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
    let tradingResearched: Bool
    let onSpotTap: (BuildingSpot.Kind) -> Void

    // Hard-coded spot layout (you can move to your model later)
    private let spots: [BuildingSpot] = [
        .init(kind: .empty,  position: CGPoint(x: 0.25, y: 0.30)),
        .init(kind: .empty,  position: CGPoint(x: 0.50, y: 0.30)),
        .init(kind: .empty,  position: CGPoint(x: 0.75, y: 0.30)),
        .init(kind: .empty,  position: CGPoint(x: 0.25, y: 0.50)),
        .init(kind: .empty,  position: CGPoint(x: 0.50, y: 0.50)),
        .init(kind: .empty,  position: CGPoint(x: 0.75, y: 0.50)),
        .init(kind: .empty,  position: CGPoint(x: 0.25, y: 0.70)),
        .init(kind: .empty,  position: CGPoint(x: 0.50, y: 0.70)),
        // Harbor slot
        .init(kind: .harbor, position: CGPoint(x: 0.15, y: 0.85)),
    ]

    var body: some View {
        ZStack {
            // Island background
            Color.blue.opacity(0.1)
                .edgesIgnoringSafeArea(.all)

            // Building spots
            GeometryReader { geo in
                ForEach(spots) { spot in
                    // Harbor only visible once researched
                    if spot.kind == .empty || tradingResearched {
                        Button {
                            onSpotTap(spot.kind)
                        } label: {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(spot.kind == .harbor ? Color.teal : Color.primary, lineWidth: 2)
                                .background(spot.kind == .harbor ? Color.teal.opacity(0.2) : Color.clear)
                                .frame(width: 50, height: 50)
                        }
                        .position(
                            x: geo.size.width  * spot.position.x,
                            y: geo.size.height * spot.position.y
                        )
                    }
                }
            }

            // Top resource bar
            VStack {
                HStack {
                    Spacer()
                    HStack(spacing: 16) {
                        Label("\(gold)", systemImage: "dollarsign.circle")
                        Label("\(wheat)", systemImage: "leaf.fill")
                        Label("\(workers)", systemImage: "person.3.sequence")
                            .foregroundColor(workers < 10 ? .primary : .red)
                    }
                    .font(.headline)
                    .padding(8)
                }
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
            gold: 123,
            wheat: 45,
            workers: 8,
            tradingResearched: true
        ) { kind in
            print("Tapped:", kind)
        }
        .frame(width: 375, height: 667)
    }
}

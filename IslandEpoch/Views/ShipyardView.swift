//
//  ShipyardView.swift
//  IslandEpoch
//
//  Created by Casper Stienstra on 14/05/2025.
//

import SwiftUI

struct ShipyardView: View {
    let onMenuTap: () -> Void
    let onIslandTap: () -> Void

    @EnvironmentObject var vm: GameViewModel

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(
                title: "Shipyard",
                onMenuTap: onMenuTap,
                onIslandTap: onIslandTap
            )

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(vm.ships) { ship in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(ship.name).font(.headline)
                            Text("Capacity: \(ship.capacity)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("Speed: \(ship.speed)")
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            HStack(spacing: 12) {
                                ForEach(ship.cost, id: \.resource) { cost in
                                    HStack(spacing: 4) {
                                        Text("\(cost.amount)")
                                        Image(systemName: {
                                            switch cost.resource {
                                            case .wheat:   return "leaf.fill"
                                            case .wood:    return "leaf.arrow.circlepath"
                                            case .ironOre: return "cube.box.fill"
                                            }
                                        }())
                                    }
                                }
                            }
                            .font(.subheadline)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .onTapGesture {
                            print("Ship tapped:", ship.name)
                        }
                    }
                }
                .padding(.top, 16)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct ShipyardView_Previews: PreviewProvider {
    static var previews: some View {
        ShipyardView(onMenuTap: {}, onIslandTap: {})
            .environmentObject(GameViewModel())
    }
}

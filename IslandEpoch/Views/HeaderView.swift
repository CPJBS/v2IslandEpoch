//
//  HeaderView.swift
//  IslandEpoch
//
//  Created by Casper Stienstra on 14/05/2025.
//

import SwiftUI

struct HeaderView: View {
    let title: String
    let onMenuTap: () -> Void
    let onIslandTap: () -> Void

    @EnvironmentObject var vm: GameViewModel

    var body: some View {
        VStack(spacing: 4) {
            // Top row: ☰ and 🏝️
            HStack {
                Button(action: onMenuTap) {
                    Image(systemName: "line.3.horizontal")
                        .font(.title2)
                }
                .padding(.leading)
                Spacer()
                Button(action: onIslandTap) {
                    Image(systemName: "island.tropical")
                        .font(.title2)
                }
                .padding(.trailing)
            }
            .padding(.top, 8)

            // Title
            Text(title)
                .font(.headline)
                .padding(.bottom, 4)

            // Resource bar
            HStack(spacing: 24) {
                Label("\(vm.brain.gold)", systemImage: "dollarsign.circle")
                Label(
                    "\(vm.brain.islands.first?.inventory[.wheat, default: 0] ?? 0)",
                    systemImage: "leaf.fill"
                )
                Label(
                    "\(vm.brain.islands.first?.workersAvailable ?? 0)",
                    systemImage: "person.3.sequence"
                )
                .foregroundColor(
                    (vm.brain.islands.first?.workersAvailable ?? 0) > 0
                        ? .primary : .red
                )
            }
            .font(.subheadline)
            .padding(.bottom, 8)

            Divider()
        }
        .background(Color.white)
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(
            title: "Preview",
            onMenuTap: {},
            onIslandTap: {}
        )
        .environmentObject(GameViewModel())
    }
}

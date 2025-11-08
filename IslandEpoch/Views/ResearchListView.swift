//
//  ResearchListView.swift
//  IslandEpoch
//
//  Created by Casper Stienstra on 14/05/2025.
//

import SwiftUI

struct ResearchItem: Identifiable {
    let id = UUID()
    let name: String
    let effect: String
    let cost: [(resource: ResourceID, amount: Int)]
}

struct ResearchListView: View {
    let onMenuTap: () -> Void
    let onIslandTap: () -> Void

    @EnvironmentObject var vm: GameViewModel

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(
                title: "Research",
                onMenuTap: onMenuTap,
                onIslandTap: onIslandTap
            )

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(vm.researchItems) { item in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(item.name).font(.headline)
                            Text(item.effect)
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            HStack(spacing: 12) {
                                ForEach(item.cost, id: \.resource) { cost in
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
                            print("Tapped research:", item.name)
                        }
                    }
                }
                .padding(.top, 16)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct ResearchListView_Previews: PreviewProvider {
    static var previews: some View {
        ResearchListView(onMenuTap: {}, onIslandTap: {})
            .environmentObject(GameViewModel())
    }
}

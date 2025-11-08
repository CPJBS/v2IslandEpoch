//
//  BuildingListView.swift
//  IslandEpoch
//
//  Created by Casper Stienstra on 14/05/2025.
//

import SwiftUI

struct BuildingSlot: Identifiable {
    let id = UUID()
    let name: String
    let iconName: String?
    let level: Int?
    let production: String?
    let workers: Int?
}

struct BuildingListView: View {
    let onMenuTap: () -> Void
    let onIslandTap: () -> Void

    @EnvironmentObject var vm: GameViewModel

    // Placeholder slots; later bind to `vm.brain`
    let slots: [BuildingSlot] = [
        .init(name: "Farm",        iconName: "leaf.fill",            level: 1, production: "2 wheat/sec", workers: 2),
        .init(name: "Lumber Mill", iconName: "leaf.arrow.circlepath", level: 1, production: "2 wood/sec",  workers: 2),
        .init(name: "Mine",        iconName: "cube.box.fill",         level: 1, production: "1 ore/sec",   workers: 3),
        .init(name: "Empty Slot",  iconName: nil,                     level: nil, production: nil,           workers: nil),
        .init(name: "Empty Slot",  iconName: nil,                     level: nil, production: nil,           workers: nil),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(
                title: "Buildings",
                onMenuTap: onMenuTap,
                onIslandTap: onIslandTap
            )

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(slots) { slot in
                        HStack(spacing: 12) {
                            if let icon = slot.iconName {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .frame(width: 40, height: 40)
                            } else {
                                RoundedRectangle(cornerRadius: 4)
                                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5]))
                                    .frame(width: 40, height: 40)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(slot.name).font(.headline)
                                    if let lvl = slot.level {
                                        Text("Lv\(lvl)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                                if let prod = slot.production, let wk = slot.workers {
                                    Text(prod)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    HStack(spacing: 4) {
                                        Text("-\(wk)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        Image(systemName: "person.3.sequence")
                                            .foregroundColor(.gray)
                                    }
                                } else {
                                    Text("Tap to build")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .onTapGesture {
                            print("Tapped slot:", slot.name)
                        }
                    }
                }
                .padding(.top, 16)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct BuildingListView_Previews: PreviewProvider {
    static var previews: some View {
        BuildingListView(onMenuTap: {}, onIslandTap: {})
            .environmentObject(GameViewModel())
    }
}

//
//  IslandDetailview.swift
//  IslandEpoch
//
//  Created by Casper Stienstra on 13/05/2025.
//

import SwiftUI

struct IslandDetailView: View {
    let island: Island   // snapshot (read‑only for now)
    
    var body: some View {
        List {
            Section("Inventory") {
                ForEach(ResourceID.allCases, id: \.self) { rid in
                    HStack {
                        Text(rid.rawValue.capitalized)
                        Spacer()
                        Text("\(island.inventory[rid, default: 0])")
                    }
                }
            }
            Section("Buildings") {
                ForEach(island.buildings) { b in
                    Text(b.type.name)
                }
            }
        }
        .navigationTitle(island.name)
    }
}

#Preview {
    IslandDetailView(island: GameBrain.demo().islands[0])
}

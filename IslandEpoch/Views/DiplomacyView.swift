//
//  DiplomacyView.swift
//  IslandEpoch
//
//  Created by Casper Stienstra on 14/05/2025.
//

import SwiftUI

struct DiplomacyView: View {
    let onMenuTap: () -> Void
    let onIslandTap: () -> Void

    @EnvironmentObject var vm: GameViewModel

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(
                title: "Diplomacy",
                onMenuTap: onMenuTap,
                onIslandTap: onIslandTap
            )

            List(vm.diplomaticPorts) { port in
                HStack {
                    Text(port.name).font(.headline)
                    Spacer()
                    Text(port.status)
                        .foregroundColor(port.status == "Ally" ? .green : .gray)
                }
                .padding(.vertical, 8)
                .onTapGesture {
                    print("Diplomacy tapped:", port.name)
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct DiplomacyView_Previews: PreviewProvider {
    static var previews: some View {
        DiplomacyView(onMenuTap: {}, onIslandTap: {})
            .environmentObject(GameViewModel())
    }
}

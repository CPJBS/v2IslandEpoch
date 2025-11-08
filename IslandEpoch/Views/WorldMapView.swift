//
//  WorldMapView.swift
//  IslandEpoch
//
//  Created by Casper Stienstra on 14/05/2025.
//

import SwiftUI

struct WorldMapView: View {
    let onMenuTap: () -> Void
    let onIslandTap: () -> Void

    @EnvironmentObject var vm: GameViewModel

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(
                title: "World Map",
                onMenuTap: onMenuTap,
                onIslandTap: onIslandTap
            )

            GeometryReader { geo in
                Color.white.edgesIgnoringSafeArea(.all)
                Color.blue.opacity(0.1)

                ForEach(vm.mapIslands) { island in
                    Circle()
                        .fill(Color.green)
                        .frame(width: 24, height: 24)
                        .position(
                            x: geo.size.width  * island.position.x,
                            y: geo.size.height * island.position.y
                        )
                        .onTapGesture {
                            print("World island tapped:", island.id)
                        }
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct WorldMapView_Previews: PreviewProvider {
    static var previews: some View {
        WorldMapView(onMenuTap: {}, onIslandTap: {})
            .environmentObject(GameViewModel())
    }
}

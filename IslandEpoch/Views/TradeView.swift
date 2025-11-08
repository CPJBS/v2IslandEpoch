//
//  TradeView.swift
//  IslandEpoch
//
//  Created by Casper Stienstra on 14/05/2025.
//

import SwiftUI

struct TradeView: View {
    let onMenuTap: () -> Void
    let onIslandTap: () -> Void

    @EnvironmentObject var vm: GameViewModel

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(
                title: "Trade",
                onMenuTap: onMenuTap,
                onIslandTap: onIslandTap
            )

            List(vm.tradeGoods) { good in
                HStack {
                    Text(good.name).font(.headline)
                    Spacer()
                    Text("Buy: \(good.buy)")
                    Text("Sell: \(good.sell)")
                }
                .padding(.vertical, 8)
                .onTapGesture {
                    print("Trade tapped:", good.name)
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct TradeView_Previews: PreviewProvider {
    static var previews: some View {
        TradeView(onMenuTap: {}, onIslandTap: {})
            .environmentObject(GameViewModel())
    }
}

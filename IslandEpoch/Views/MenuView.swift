//
//  MenuView.swift
//  IslandEpoch
//
//  Created by Casper Stienstra on 14/05/2025.
//

import SwiftUI

/// The various menu sections active in your app
enum MenuOption: String, CaseIterable, Identifiable {
    case buildings   = "Buildings"
    case research    = "Research"
    case map         = "World Map"
    case trade       = "Trade"
    case shipyard    = "Shipyard"
    case diplomacy   = "Diplomacy"
    
    var id: String { rawValue }
}

/// A full-screen, scrollable list of menu buttons
struct MenuView: View {
    /// Called when the user taps an item
    var didSelect: (MenuOption) -> Void
    
    var body: some View {
        ZStack {
            // dark overlay behind the menu
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            // vertical list of options
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(MenuOption.allCases) { option in
                        Button {
                            didSelect(option)
                        } label: {
                            Text(option.rawValue)
                                .font(.title2.weight(.semibold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(.ultraThinMaterial)
                                .cornerRadius(8)
                        }
                    }
                    
                    // a spacer to push bottom bar items to the bottom
                    Spacer(minLength: 32)
                    
                    // bottom row icons
                    HStack(spacing: 32) {
                        Button {
                            print("Socials tapped")
                        } label: {
                            Image(systemName: "person.3.fill")
                                .font(.title)
                        }
                        Button {
                            print("Settings tapped")
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.title)
                        }
                        Button {
                            print("FAQ tapped")
                        } label: {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.title)
                        }
                    }
                    .padding(.bottom, 32)
                }
                .padding(.top, 100)       // below the resource bar
                .padding(.horizontal, 24)
                .frame(maxWidth: 300)     // lock menu width
            }
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView { _ in }
    }
}

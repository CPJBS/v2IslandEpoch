//
//  IslandEpochApp.swift
//  IslandEpoch
//
//  Created by Casper Stienstra on 08/11/2025.
//

import SwiftUI
import CoreData

@main
struct IslandEpochApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

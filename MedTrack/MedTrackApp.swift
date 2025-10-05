//
//  MedTrackApp.swift
//  MedTrack
//
//  Created by Janhavi Jagtap on 5/10/2025.
//

import SwiftUI

@main
struct MedTrackApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

//
//  MedTrackApp.swift
//  MedTrack
//
//  Created by Janhavi Jagtap on 5/10/2025.
//

import SwiftUI

@main
struct MedTrackApp: App {
    let coreDataManager = CoreDataManager.shared
    
    init() {
        // Request notification permission
        NotificationManager.shared.requestPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, coreDataManager.context)
        }
    }
}

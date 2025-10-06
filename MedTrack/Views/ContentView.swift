//
//  ContentView.swift
//  MedTrack
//
//  Created by Janhavi Jagtap on 20/9/2025.
//

import SwiftUI
import CoreData

// Main entry view containing the tabbed navigation.
struct ContentView: View {
    // Current selected tab index.
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            MedicationListView()
                .tabItem {
                    Label("Medications", systemImage: "pills.fill")
                }
                .tag(1)
            
            SymptomListView()
                .tabItem {
                    Label("Symptoms", systemImage: "heart.text.square.fill")
                }
                .tag(2)
            
            AppointmentListView()
                .tabItem {
                    Label("Appointments", systemImage: "calendar")
                }
                .tag(3)
            
            PharmacyMapView()
                .tabItem {
                    Label("Pharmacies", systemImage: "map.fill")
                }
                .tag(4)
        }
    }
}

#Preview {
    ContentView()
}

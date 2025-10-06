//
//  MedicationListView.swift
//  MedTrack
//
//  Created by Janhavi Jagtap on 20/9/2025.
//

import SwiftUI

// Displays a list of medications with add and delete functionality.
struct MedicationListView: View {
    // Fetches medications sorted alphabetically by name.
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Medication.name, ascending: true)],
        animation: .default)
    private var medications: FetchedResults<Medication>
    
    // Controls presentation of add medication sheet.
    @State private var showingAddMedication = false
    
    var body: some View {
        NavigationView {
            List {
                if medications.isEmpty {
                    // Placeholder UI when no medications exist
                    VStack(spacing: 16) {
                        Image(systemName: "pills")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Medications")
                            .font(.headline)
                        
                        Text("Tap + to add your first medication")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                } else {
                    // List medications with navigation to detail and swipe to delete
                    ForEach(medications) { medication in
                        NavigationLink(destination: MedicationDetailView(medication: medication)) {
                            MedicationRow(medication: medication)
                        }
                    }
                    .onDelete(perform: deleteMedications)
                }
            }
            .navigationTitle("Medications")
            .toolbar {
                // Add medication button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddMedication = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddMedication) {
                AddMedicationView()
            }
        }
    }
    
    // Deletes selected medications from Core Data.
    private func deleteMedications(offsets: IndexSet) {
        withAnimation {
            offsets.map { medications[$0] }.forEach { medication in
                CoreDataManager.shared.deleteMedication(medication)
            }
        }
    }
}

// Row view representing a medication item in the list.
struct MedicationRow: View {
    let medication: Medication
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(medication.name ?? "Unknown")
                .font(.headline)
            
            Text(medication.dosage ?? "")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Text(medication.frequency ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if medication.reminderEnabled {
                    Image(systemName: "bell.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Text("\(medication.pillsRemaining) pills")
                    .font(.caption)
                    .foregroundColor(medication.pillsRemaining < 10 ? .red : .secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

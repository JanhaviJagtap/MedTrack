//
//  MedicationDetailView.swift
//  MedTrack
//
//  Created by Janhavi Jagtap on 20/9/2025.
//


import SwiftUI

struct MedicationDetailView: View {
    @ObservedObject var medication: Medication
    @Environment(\.managedObjectContext) private var context
    @State private var isEditing = false
    
    var body: some View {
        List {
            Section("Details") {
                DetailRow(label: "Name", value: medication.name ?? "")
                DetailRow(label: "Dosage", value: medication.dosage ?? "")
                DetailRow(label: "Frequency", value: medication.frequency ?? "")
                DetailRow(label: "Pills Remaining", value: "\(medication.pillsRemaining)")
            }
            
            Section("Schedule") {
                if let timesData = medication.timesToTake?.data(using: .utf8),
                   let decodedData = Data(base64Encoded: timesData),
                   let times = try? JSONDecoder().decode([String].self, from: decodedData) {
                    ForEach(times, id: \.self) { time in
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.blue)
                            Text(time)
                        }
                    }
                }
                
                HStack {
                    Image(systemName: medication.reminderEnabled ? "bell.fill" : "bell.slash.fill")
                        .foregroundColor(medication.reminderEnabled ? .blue : .gray)
                    Text(medication.reminderEnabled ? "Reminders Enabled" : "Reminders Disabled")
                }
            }
            
            if let notes = medication.notes, !notes.isEmpty {
                Section("Notes") {
                    Text(notes)
                }
            }
            
            Section("Started") {
                if let startDate = medication.startDate {
                    Text(startDate, style: .date)
                }
            }
            
            Section {
                Button(role: .destructive, action: decrementPills) {
                    Label("Take Medication", systemImage: "checkmark.circle")
                }
                
                Button(action: { isEditing = true }) {
                    Label("Edit", systemImage: "pencil")
                }
            }
        }
        .navigationTitle(medication.name ?? "Medication")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isEditing) {
            EditMedicationView(medication: medication)
        }
    }
    
    private func decrementPills() {
        if medication.pillsRemaining > 0 {
            medication.pillsRemaining -= 1
            CoreDataManager.shared.save()
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
        }
    }
}

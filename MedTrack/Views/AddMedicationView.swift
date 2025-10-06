//
//  AddMedicationView.swift
//  MedTrack
//
//  Created by Janhavi Jagtap on 20/9/2025.
//

import SwiftUI

// View to add a new medication with details and reminders.
struct AddMedicationView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var context
    
    // MARK: - Form state properties
    
    @State private var name = ""
    @State private var dosage = ""
    @State private var frequency = "Once daily"
    @State private var pillsRemaining = 30
    @State private var reminderEnabled = true
    @State private var notes = ""
    @State private var selectedTimes: [Date] = [Date()]
    @State private var showingDrugInfo = false
    
    // Common frequency options
    let frequencies = ["Once daily", "Twice daily", "Three times daily", "As needed"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Medication Information") {
                    TextField("Medication Name", text: $name)
                    TextField("Dosage (e.g., 500mg)", text: $dosage)
                    
                    Picker("Frequency", selection: $frequency) {
                        ForEach(frequencies, id: \.self) { freq in
                            Text(freq).tag(freq)
                        }
                    }
                    
                    // Show drug info button if name length is sufficient
                    if name.count > 2 {
                        Button(action: { showingDrugInfo = true }) {
                            Label("View Drug Information", systemImage: "info.circle")
                        }
                    }
                }
                
                Section("Reminder Times") {
                    Toggle("Enable Reminders", isOn: $reminderEnabled)
                    
                    if reminderEnabled {
                        // Show a date picker for each selected time
                        ForEach(selectedTimes.indices, id: \.self) { index in
                            DatePicker("Time \(index + 1)", selection: $selectedTimes[index], displayedComponents: .hourAndMinute)
                        }
                        
                        // Add another reminder time up to max 5
                        Button(action: addTimeSlot) {
                            Label("Add Another Time", systemImage: "plus.circle")
                        }
                        .disabled(selectedTimes.count >= 5)
                    }
                }
                
                Section("Supply") {
                    Stepper("Pills Remaining: \(pillsRemaining)", value: $pillsRemaining, in: 0...1000, step: 5)
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Add Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveMedication()
                    }
                    .disabled(name.isEmpty || dosage.isEmpty)  // Disable save if required fields empty
                }
            }
            .sheet(isPresented: $showingDrugInfo) {
                DrugInfoView(drugName: name)
            }
        }
    }
    
    /// Adds a new time slot for reminders.
    private func addTimeSlot() {
        selectedTimes.append(Date())
    }
    
    /// Saves medication data to CoreData.
    private func saveMedication() {
        let timeStrings = selectedTimes.map { time in
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: time)
        }
        
        CoreDataManager.shared.addMedication(
            name: name,
            dosage: dosage,
            frequency: frequency,
            timesToTake: timeStrings,
            pillsRemaining: pillsRemaining,
            reminderEnabled: reminderEnabled,
            notes: notes.isEmpty ? nil : notes
        )
        
        dismiss()
    }
}

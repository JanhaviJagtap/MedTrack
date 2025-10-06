//
//  EditMedicationView.swift
//  MedTrack
//
//  Created by Janhavi Jagtap on 20/9/2025.
//

import SwiftUI

// View for editing an existing medication's details.
struct EditMedicationView: View {
    @ObservedObject var medication: Medication                // Medication object to modify
    @Environment(\.dismiss) var dismiss                        // Dismiss view action
    @Environment(\.managedObjectContext) private var context     // Core Data context
    
    // State variables initialized with current medication data
    @State private var name: String
    @State private var dosage: String
    @State private var frequency: String
    @State private var pillsRemaining: Int
    @State private var reminderEnabled: Bool
    @State private var notes: String
    
    // Initialize state variables with existing medication data for editing.
    init(medication: Medication) {
        self.medication = medication
        _name = State(initialValue: medication.name ?? "")
        _dosage = State(initialValue: medication.dosage ?? "")
        _frequency = State(initialValue: medication.frequency ?? "Once daily")
        _pillsRemaining = State(initialValue: Int(medication.pillsRemaining))
        _reminderEnabled = State(initialValue: medication.reminderEnabled)
        _notes = State(initialValue: medication.notes ?? "")
    }
    
    var body: some View {
        NavigationView {
            // Form to edit medication details
            Form {
                // Section for basic info
                Section("Information") {
                    TextField("Name", text: $name)
                    TextField("Dosage", text: $dosage)
                    Picker("Frequency", selection: $frequency) {
                        Text("Once daily").tag("Once daily")
                        Text("Twice daily").tag("Twice daily")
                        Text("Three times daily").tag("Three times daily")
                        Text("As needed").tag("As needed")
                    }
                }
                
                // Section to set remaining pills count
                Section("Supply") {
                    Stepper("Pills: \(pillsRemaining)", value: $pillsRemaining, in: 0...1000, step: 5)
                }
                
                // Section to toggle reminders
                Section("Reminders") {
                    Toggle("Enable Reminders", isOn: $reminderEnabled)
                }
                
                // Section for additional notes
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Edit Medication")
            .navigationBarTitleDisplayMode(.inline)
            // Toolbar with Cancel and Save buttons
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss() // Dismiss without saving
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveMedication() // Save modifications
                    }
                }
            }
        }
    }
    
    // Save the edited medication data into Core Data
    private func saveMedication() {
        medication.name = name
        medication.dosage = dosage
        medication.frequency = frequency
        medication.pillsRemaining = Int16(pillsRemaining)
        medication.reminderEnabled = reminderEnabled
        medication.notes = notes.isEmpty ? nil : notes
        // Persist changes in Core Data
        CoreDataManager.shared.save()
        dismiss() // Close view
    }
}

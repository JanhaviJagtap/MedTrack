//
//  AppointmentListView.swift
//  MedTrack
//
//  Created by Janhavi Jagtap on 20/9/2025.
//

import SwiftUI

// Displays a list of medical appointments.
struct AppointmentListView: View {
    // Fetches appointments sorted by ascending date.
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Appointment.date, ascending: true)],
        animation: .default)
    private var appointments: FetchedResults<Appointment>
    
    // State to control display of Add Appointment sheet.
    @State private var showingAddAppointment = false
    
    var body: some View {
        NavigationView {
            List {
                if appointments.isEmpty {
                    // Placeholder when no appointments exist
                    VStack(spacing: 16) {
                        Image(systemName: "calendar")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Appointments")
                            .font(.headline)
                        
                        Text("Schedule your medical appointments")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                } else {
                    // Display each appointment in a row with delete support
                    ForEach(appointments) { appointment in
                        AppointmentRow(appointment: appointment)
                    }
                    .onDelete(perform: deleteAppointments)
                }
            }
            .navigationTitle("Appointments")
            .toolbar {
                // Button to add new appointment
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddAppointment = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddAppointment) {
                AddAppointmentView()
            }
        }
    }
    
    // Deletes selected appointments using Core Data manager.
    private func deleteAppointments(offsets: IndexSet) {
        withAnimation {
            offsets.map { appointments[$0] }.forEach { appointment in
                CoreDataManager.shared.deleteAppointment(appointment)
            }
        }
    }
}

// View representing a single appointment row in the list.
struct AppointmentRow: View {
    let appointment: Appointment
    
    var body: some View {
        HStack(spacing: 12) {
            VStack {
                if let date = appointment.date {
                    Text(date, format: .dateTime.day())
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(date, format: .dateTime.month(.abbreviated))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 50)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(appointment.doctorName ?? "Doctor")
                    .font(.headline)
                
                if let specialty = appointment.specialty {
                    Text(specialty)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let date = appointment.date {
                    Text(date, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// View to add new appointment details.
struct AddAppointmentView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var doctorName = ""
    @State private var specialty = ""
    @State private var date = Date()
    @State private var location = ""
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Appointment Details") {
                    TextField("Doctor Name", text: $doctorName)
                    TextField("Specialty (optional)", text: $specialty)
                    DatePicker("Date & Time", selection: $date)
                    TextField("Location", text: $location)
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("New Appointment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveAppointment()
                    }
                    .disabled(doctorName.isEmpty || location.isEmpty)
                }
            }
        }
    }
    
    // Saves the new appointment using Core Data manager.
    private func saveAppointment() {
        CoreDataManager.shared.addAppointment(
            doctorName: doctorName,
            specialty: specialty.isEmpty ? nil : specialty,
            date: date,
            location: location,
            notes: notes.isEmpty ? nil : notes
        )
        dismiss()
    }
}

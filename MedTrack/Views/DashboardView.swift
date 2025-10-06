//
//  DashboardView.swift
//  MedTrack
//
//  Created by Janhavi Jagtap on 20/9/2025.
//

import SwiftUI

// Main dashboard view showing app overview, medication summary, upcoming appointments, and quick action buttons.
struct DashboardView: View {
    // Fetch all medications, sorted alphabetically.
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Medication.name, ascending: true)],
        animation: .default)
    private var medications: FetchedResults<Medication>
    
    // Fetch upcoming appointments that are not completed and have a date in the future.
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Appointment.date, ascending: true)],
        predicate: NSPredicate(format: "date >= %@ AND isCompleted == NO", Date() as NSDate),
        animation: .default)
    private var upcomingAppointments: FetchedResults<Appointment>
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    HeaderCard()   // Greeting and date header
                    
                    MedicationsSummaryCard(count: medications.count)  // Summary of active medications
                    
                    // Show up to three upcoming appointments if available
                    if !upcomingAppointments.isEmpty {
                        UpcomingAppointmentsCard(appointments: Array(upcomingAppointments.prefix(3)))
                    }
                    
                    QuickActionsGrid()  // Navigation buttons for common tasks
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("MediTrack")
        }
    }
}

// Header card with welcome message and current date.
struct HeaderCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hello!")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(Date(), style: .date)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Stay healthy today")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            LinearGradient(
                colors: [.blue.opacity(0.6), .purple.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .foregroundColor(.white)
        .cornerRadius(16)
    }
}

// Card displaying the count of active medications with an icon.
struct MedicationsSummaryCard: View {
    let count: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Active Medications")
                    .font(.headline)
                
                Text("\(count) medications")
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            Image(systemName: "pills.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

// Card listing upcoming medical appointments with a navigation indicator.
struct UpcomingAppointmentsCard: View {
    let appointments: [Appointment]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upcoming Appointments")
                .font(.headline)
            
            ForEach(appointments, id: \.id) { appointment in
                HStack {
                    VStack(alignment: .leading) {
                        Text(appointment.doctorName ?? "Doctor")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        if let date = appointment.date {
                            Text(date, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
                
                if appointment != appointments.last {
                    Divider()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

// Grid of quick action buttons for adding medication, symptoms, appointments, and searching drugs.
struct QuickActionsGrid: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                NavigationLink(destination: AddMedicationView()) {
                    QuickActionButton(icon: "plus.circle.fill", title: "Add Medication", color: .blue)
                }
                NavigationLink(destination: AddSymptomView()) {
                    QuickActionButton(icon: "heart.text.square.fill", title: "Log Symptom", color: .red)
                }
                NavigationLink(destination: AddAppointmentView()) {
                    QuickActionButton(icon: "calendar.badge.plus", title: "New Appointment", color: .green)
                }
                NavigationLink(destination: DrugSearchView()) {
                    QuickActionButton(icon: "magnifyingglass", title: "Drug Info", color: .orange)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

// Button showing an icon and title for quick actions.
struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

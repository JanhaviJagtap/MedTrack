//
//  CoreDataManager.swift
//  MedTrack
//
//  Created by Janhavi Jagtap on 20/9/2025.
//

import CoreData

// Class managing Core Data stack and CRUD operations.
class CoreDataManager {
    static let shared = CoreDataManager()
    
    // Persistent container for Core Data stack.
    let container: NSPersistentContainer
    
    // Initializes Core Data stack with model named 'MedTrack'.
    init() {
        container = NSPersistentContainer(name: "MedTrack")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("CoreData failed to load: \(error.localizedDescription)")
            }
        }
    }
    
    // Returns main context for Core Data operations.
    var context: NSManagedObjectContext {
        return container.viewContext
    }
    
    // Saves changes in the context if any exist.
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
    
    
    
    
    // Adds a medication entity with specified details.
    func addMedication(name: String, dosage: String, frequency: String,
                       timesToTake: [String], pillsRemaining: Int,
                       reminderEnabled: Bool, notes: String?) {
        let medication = Medication(context: context)
        medication.id = UUID()
        medication.name = name
        medication.dosage = dosage
        medication.frequency = frequency
        medication.timesToTake = try? JSONEncoder().encode(timesToTake).base64EncodedString()
        medication.startDate = Date()
        medication.pillsRemaining = Int16(pillsRemaining)
        medication.reminderEnabled = reminderEnabled
        medication.notes = notes
        medication.createdAt = Date()
        
        save()
        
        // Schedule reminders if enabled
        if reminderEnabled {
            NotificationManager.shared.scheduleMedicationReminders(
                medicationId: medication.id?.uuidString ?? "",
                medicationName: name,
                times: timesToTake
            )
        }
    }
    
    // Fetches all medications sorted by name.
    func fetchMedications() -> [Medication] {
        let request = Medication.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch medications: \(error)")
            return []
        }
    }
    
    // Deletes the specified medication and cancels related notifications.
    func deleteMedication(_ medication: Medication) {
        if let id = medication.id?.uuidString {
            NotificationManager.shared.cancelNotifications(for: id)
        }
        
        context.delete(medication)
        save()
    }
    
    // Saves any updates to a medication entity.
    func updateMedication(_ medication: Medication) {
        save()
    }
    
    
    
    // Adds a symptom entity with details.
    func addSymptom(name: String, severity: Int, notes: String?) {
        let symptom = Symptom(context: context)
        symptom.id = UUID()
        symptom.name = name
        symptom.severity = Int16(severity)
        symptom.date = Date()
        symptom.notes = notes
        symptom.createdAt = Date()
        
        save()
    }
    
    // Fetches all symptoms sorted by most recent date.
    func fetchSymptoms() -> [Symptom] {
        let request = Symptom.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch symptoms: \(error)")
            return []
        }
    }
    
    // Deletes the specified symptom entity.
    func deleteSymptom(_ symptom: Symptom) {
        context.delete(symptom)
        save()
    }
    
    
    
    // Adds an appointment entity and schedules a reminder.
    func addAppointment(doctorName: String, specialty: String?,
                        date: Date, location: String, notes: String?) {
        let appointment = Appointment(context: context)
        appointment.id = UUID()
        appointment.doctorName = doctorName
        appointment.specialty = specialty
        appointment.date = date
        appointment.location = location
        appointment.notes = notes
        appointment.isCompleted = false
        appointment.createdAt = Date()
        
        save()
        
        // Schedule reminder 1 day before appointment
        NotificationManager.shared.scheduleAppointmentReminder(
            appointmentId: appointment.id?.uuidString ?? "",
            doctorName: doctorName,
            date: date
        )
    }
    
    // Fetches all upcoming appointments, sorted by date.
    func fetchAppointments() -> [Appointment] {
        let request = Appointment.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch appointments: \(error)")
            return []
        }
    }
    
    // Deletes the specified appointment and cancels related notifications.
    func deleteAppointment(_ appointment: Appointment) {
        if let id = appointment.id?.uuidString {
            NotificationManager.shared.cancelNotifications(for: id)
        }
        
        context.delete(appointment)
        save()
    }
}

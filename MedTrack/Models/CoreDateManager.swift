//
//  CoreDateManager.swift
//  MedTrack
//
//  Created by Janhavi Jagtap on 20/9/2025.
//

import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "MedTrack")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("CoreData failed to load: \(error.localizedDescription)")
            }
        }
    }
    
    var context: NSManagedObjectContext {
        return container.viewContext
    }
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
    
    // MARK: - Medication Methods
    
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
        
        // Schedule notifications if enabled
        if reminderEnabled {
            NotificationManager.shared.scheduleMedicationReminders(
                medicationId: medication.id?.uuidString ?? "",
                medicationName: name,
                times: timesToTake
            )
        }
    }
    
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
    
    func deleteMedication(_ medication: Medication) {
        // Cancel notifications
        if let id = medication.id?.uuidString {
            NotificationManager.shared.cancelNotifications(for: id)
        }
        
        context.delete(medication)
        save()
    }
    
    func updateMedication(_ medication: Medication) {
        save()
    }
    
    // MARK: - Symptom Methods
    
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
    
    func deleteSymptom(_ symptom: Symptom) {
        context.delete(symptom)
        save()
    }
    
    // MARK: - Appointment Methods
    
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
        
        // Schedule reminder 1 day before
        NotificationManager.shared.scheduleAppointmentReminder(
            appointmentId: appointment.id?.uuidString ?? "",
            doctorName: doctorName,
            date: date
        )
    }
    
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
    
    func deleteAppointment(_ appointment: Appointment) {
        if let id = appointment.id?.uuidString {
            NotificationManager.shared.cancelNotifications(for: id)
        }
        
        context.delete(appointment)
        save()
    }
}

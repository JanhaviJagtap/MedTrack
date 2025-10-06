//
//  NotificationManager.swift
//  MedTrack
//
//  Created by Janhavi Jagtap on 20/9/2025.
//

import UserNotifications
import UIKit

// Manages all local notification scheduling and permission requests.
class NotificationManager {
    static let shared = NotificationManager()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    // Requests user permission for alerts, sounds, and badges.
    func requestPermission() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    
    
    // Schedules repeating notifications for medication times.
    func scheduleMedicationReminders(medicationId: String, medicationName: String, times: [String]) {
        for time in times {
            let components = time.components(separatedBy: ":")
            guard components.count == 2,
                  let hour = Int(components[0]),
                  let minute = Int(components[1]) else { continue }
            
            let content = UNMutableNotificationContent()
            content.title = "Time for Medication"
            content.body = "Don't forget to take \(medicationName)"
            content.sound = .default
            content.badge = 1
            
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            let identifier = "med_\(medicationId)_\(time)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            notificationCenter.add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                }
            }
        }
    }
    
    
    
    // Schedules a one-time notification 24 hours before an appointment.
    func scheduleAppointmentReminder(appointmentId: String, doctorName: String, date: Date) {
        guard let reminderDate = Calendar.current.date(byAdding: .day, value: -1, to: date) else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Appointment Reminder"
        content.body = "You have an appointment with \(doctorName) tomorrow"
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let identifier = "appt_\(appointmentId)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request)
    }
    
    
    
    // Cancels pending notifications matching an id.
    func cancelNotifications(for id: String) {
        notificationCenter.getPendingNotificationRequests { requests in
            // Find all identifiers containing this id and remove them
            let identifiers = requests.filter { $0.identifier.contains(id) }.map { $0.identifier }
            self.notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
}

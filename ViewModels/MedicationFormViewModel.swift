import Foundation
import SwiftData
import SwiftUI

/// Temporary struct for form editing (not persisted directly)
struct TempReminderTime: Identifiable {
    let id = UUID()
    var hour: Int = 8
    var minute: Int = 0

    var formattedTime: String {
        String(format: "%02d:%02d", hour, minute)
    }
}

@MainActor
final class MedicationFormViewModel: ObservableObject {
    @Published var name = ""
    @Published var dosage = ""
    @Published var selectedIcon = "pills.fill"
    @Published var selectedColorHex = "#4A90D9"
    @Published var reminderTimes: [TempReminderTime] = [TempReminderTime(hour: 8, minute: 0)]
    @Published var notes = ""
    @Published var isActive = true

    var existingMedication: Medication?

    var isEditing: Bool { existingMedication != nil }
    var navigationTitle: String {
        isEditing ? String(localized: "编辑药品") : String(localized: "添加药品")
    }

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !dosage.trimmingCharacters(in: .whitespaces).isEmpty &&
        !reminderTimes.isEmpty
    }

    /// Load data from an existing medication for editing
    func loadFrom(_ medication: Medication) {
        self.existingMedication = medication
        self.name = medication.name
        self.dosage = medication.dosage
        self.selectedIcon = medication.iconName
        self.selectedColorHex = medication.colorHex
        self.notes = medication.notes
        self.isActive = medication.isActive
        self.reminderTimes = medication.sortedReminderTimes.map {
            TempReminderTime(hour: $0.hour, minute: $0.minute)
        }
    }

    func addReminderTime() {
        reminderTimes.append(TempReminderTime(hour: 8, minute: 0))
    }

    func removeReminderTime(at index: Int) {
        guard reminderTimes.count > 1 else { return }
        reminderTimes.remove(at: index)
    }

    func save(context: ModelContext) {
        if let existing = existingMedication {
            // Update existing medication
            existing.name = name
            existing.dosage = dosage
            existing.iconName = selectedIcon
            existing.colorHex = selectedColorHex
            existing.notes = notes
            existing.isActive = isActive
            existing.updatedAt = Date()

            // Replace reminder times: delete old, insert new
            for oldTime in existing.reminderTimes {
                context.delete(oldTime)
            }
            existing.reminderTimes = reminderTimes.map {
                ReminderTime(hour: $0.hour, minute: $0.minute, medication: existing)
            }

            try? context.save()

            // Re-schedule notifications
            NotificationManager.shared.scheduleNotifications(for: existing)
        } else {
            // Create new medication
            let medication = Medication(
                name: name,
                dosage: dosage,
                iconName: selectedIcon,
                colorHex: selectedColorHex,
                notes: notes,
                isActive: isActive
            )

            medication.reminderTimes = reminderTimes.map {
                ReminderTime(hour: $0.hour, minute: $0.minute, medication: medication)
            }

            context.insert(medication)
            try? context.save()

            // Schedule notifications for new medication
            NotificationManager.shared.scheduleNotifications(for: medication)
        }
    }

    func deleteMedication(_ medication: Medication, context: ModelContext) {
        NotificationManager.shared.cancelNotifications(for: medication)
        context.delete(medication)
        try? context.save()
    }
}

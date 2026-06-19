import Foundation
import SwiftData
import SwiftUI

@Model
final class Medication {
    var id: UUID
    var name: String
    var dosage: String
    var iconName: String
    var colorHex: String
    var notes: String
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \ReminderTime.medication)
    var reminderTimes: [ReminderTime] = []

    @Relationship(deleteRule: .cascade, inverse: \MedicationRecord.medication)
    var records: [MedicationRecord] = []

    init(
        id: UUID = UUID(),
        name: String = "",
        dosage: String = "",
        iconName: String = "pills.fill",
        colorHex: String = "#4A90D9",
        notes: String = "",
        isActive: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.dosage = dosage
        self.iconName = iconName
        self.colorHex = colorHex
        self.notes = notes
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // Computed: convert hex to SwiftUI Color
    var color: Color {
        Color(hex: colorHex) ?? .blue
    }

    // Sorted reminder times for display
    var sortedReminderTimes: [ReminderTime] {
        reminderTimes.sorted { lhs, rhs in
            if lhs.hour == rhs.hour {
                return lhs.minute < rhs.minute
            }
            return lhs.hour < rhs.hour
        }
    }

    // Formatted reminder times string for display
    var reminderTimesDisplay: String {
        sortedReminderTimes.map { $0.formattedTime }.joined(separator: ", ")
    }
}

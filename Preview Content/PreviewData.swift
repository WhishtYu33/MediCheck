import Foundation
import SwiftData

/// Sample data for SwiftUI previews
@MainActor
final class PreviewData {
    static let shared = PreviewData()

    let container: ModelContainer

    init() {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            container = try ModelContainer(
                for: Medication.self, ReminderTime.self, MedicationRecord.self,
                configurations: config
            )
            insertSampleData()
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }

    private func insertSampleData() {
        let context = container.mainContext

        // Medication 1: Amoxicillin
        let med1 = Medication(
            name: "阿莫西林",
            dosage: "500mg, 1粒",
            iconName: "pills.fill",
            colorHex: "#4A90D9"
        )
        let time1a = ReminderTime(hour: 8, minute: 0, medication: med1)
        let time1b = ReminderTime(hour: 20, minute: 0, medication: med1)
        med1.reminderTimes = [time1a, time1b]
        context.insert(med1)

        // Medication 2: Vitamin C
        let med2 = Medication(
            name: "维生素C",
            dosage: "100mg, 1片",
            iconName: "leaf.fill",
            colorHex: "#4CD964"
        )
        let time2 = ReminderTime(hour: 9, minute: 0, medication: med2)
        med2.reminderTimes = [time2]
        context.insert(med2)

        // Medication 3: Ibuprofen
        let med3 = Medication(
            name: "布洛芬",
            dosage: "200mg, 1粒",
            iconName: "cross.case.fill",
            colorHex: "#FF9500"
        )
        let time3a = ReminderTime(hour: 8, minute: 0, medication: med3)
        let time3b = ReminderTime(hour: 14, minute: 0, medication: med3)
        let time3c = ReminderTime(hour: 20, minute: 0, medication: med3)
        med3.reminderTimes = [time3a, time3b, time3c]
        context.insert(med3)

        // Sample records for today
        let today = Calendar.current.startOfDay(for: Date())
        let record1 = MedicationRecord(
            scheduledDate: today,
            scheduledTime: "08:00",
            status: .taken,
            actualTakenDate: Calendar.current.date(byAdding: .hour, value: -2, to: Date()),
            medication: med1
        )
        context.insert(record1)

        let record2 = MedicationRecord(
            scheduledDate: today,
            scheduledTime: "09:00",
            status: .taken,
            actualTakenDate: Calendar.current.date(byAdding: .hour, value: -1, to: Date()),
            medication: med2
        )
        context.insert(record2)

        let record3 = MedicationRecord(
            scheduledDate: today,
            scheduledTime: "08:00",
            status: .pending,
            medication: med3
        )
        context.insert(record3)

        let record4 = MedicationRecord(
            scheduledDate: today,
            scheduledTime: "20:00",
            status: .pending,
            medication: med1
        )
        context.insert(record4)

        let record5 = MedicationRecord(
            scheduledDate: today,
            scheduledTime: "14:00",
            status: .pending,
            medication: med3
        )
        context.insert(record5)

        let record6 = MedicationRecord(
            scheduledDate: today,
            scheduledTime: "20:00",
            status: .pending,
            medication: med3
        )
        context.insert(record6)

        try? context.save()
    }
}

// MARK: - Sample Medication for static previews
extension Medication {
    static var sample: Medication {
        let med = Medication(
            name: "阿莫西林",
            dosage: "500mg, 1粒",
            iconName: "pills.fill",
            colorHex: "#4A90D9"
        )
        med.reminderTimes = [
            ReminderTime(hour: 8, minute: 0),
            ReminderTime(hour: 20, minute: 0),
        ]
        return med
    }
}

extension MedicationRecord {
    static var sampleTaken: MedicationRecord {
        MedicationRecord(
            scheduledDate: Date(),
            scheduledTime: "08:00",
            status: .taken,
            actualTakenDate: Date(),
            medication: .sample
        )
    }

    static var samplePending: MedicationRecord {
        MedicationRecord(
            scheduledDate: Date(),
            scheduledTime: "14:00",
            status: .pending,
            medication: .sample
        )
    }

    static var sampleSkipped: MedicationRecord {
        MedicationRecord(
            scheduledDate: Date(),
            scheduledTime: "20:00",
            status: .skipped,
            medication: .sample
        )
    }
}

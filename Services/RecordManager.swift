import Foundation
import SwiftData

/// Manages generation of daily MedicationRecord entries.
/// Called when TodayView appears to ensure records exist for today.
final class RecordManager {
    /// Ensure MedicationRecord entries exist for today for all active medications.
    func ensureTodayRecordsExist(
        medications: [Medication],
        existingRecords: [MedicationRecord],
        context: ModelContext
    ) {
        let today = Calendar.current.startOfDay(for: Date())

        for medication in medications where medication.isActive {
            for reminderTime in medication.reminderTimes {
                let timeString = reminderTime.formattedTime

                // Check if a record already exists for today + this medication + this time
                let exists = existingRecords.contains { record in
                    record.medication?.id == medication.id &&
                    Calendar.current.isDate(record.scheduledDate, inSameDayAs: today) &&
                    record.scheduledTime == timeString
                }

                if !exists {
                    let newRecord = MedicationRecord(
                        scheduledDate: today,
                        scheduledTime: timeString,
                        status: .pending,
                        medication: medication
                    )
                    context.insert(newRecord)
                }
            }
        }

        try? context.save()
    }
}

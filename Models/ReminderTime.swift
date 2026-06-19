import Foundation
import SwiftData

@Model
final class ReminderTime {
    var id: UUID
    var hour: Int
    var minute: Int
    var medication: Medication?

    init(
        id: UUID = UUID(),
        hour: Int = 8,
        minute: Int = 0,
        medication: Medication? = nil
    ) {
        self.id = id
        self.hour = max(0, min(23, hour))
        self.minute = max(0, min(59, minute))
        self.medication = medication
    }

    // Formatted time string e.g. "08:30"
    var formattedTime: String {
        String(format: "%02d:%02d", hour, minute)
    }

    // Formatted for display e.g. "上午 8:30" or "8:30 AM"
    var displayTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        if let date = calendar.date(from: components) {
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        return formattedTime
    }

    // DateComponents for UNCalendarNotificationTrigger
    var dateComponents: DateComponents {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        return components
    }
}

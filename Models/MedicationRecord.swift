import Foundation
import SwiftData

@Model
final class MedicationRecord {
    var id: UUID
    var scheduledDate: Date       // Normalized to start of day
    var scheduledTime: String     // "HH:mm" — the time slot this record is for
    var statusRaw: String         // Raw value for RecordStatus
    var actualTakenDate: Date?    // When user checked in (nil if not taken)
    var createdAt: Date
    var medication: Medication?

    init(
        id: UUID = UUID(),
        scheduledDate: Date = Calendar.current.startOfDay(for: Date()),
        scheduledTime: String = "08:00",
        status: RecordStatus = .pending,
        actualTakenDate: Date? = nil,
        createdAt: Date = Date(),
        medication: Medication? = nil
    ) {
        self.id = id
        self.scheduledDate = scheduledDate
        self.scheduledTime = scheduledTime
        self.statusRaw = status.rawValue
        self.actualTakenDate = actualTakenDate
        self.createdAt = createdAt
        self.medication = medication
    }

    // Computed property for status enum
    var status: RecordStatus {
        get { RecordStatus(rawValue: statusRaw) ?? .pending }
        set { statusRaw = newValue.rawValue }
    }

    // Whether the scheduled time has passed today
    var isOverdue: Bool {
        guard status == .pending else { return false }

        let calendar = Calendar.current
        let now = Date()

        // Parse scheduledTime "HH:mm"
        let parts = scheduledTime.split(separator: ":").compactMap { Int($0) }
        guard parts.count == 2 else { return false }

        var components = calendar.dateComponents([.year, .month, .day], from: scheduledDate)
        components.hour = parts[0]
        components.minute = parts[1]

        guard let scheduledDateTime = calendar.date(from: components) else { return false }

        return now > scheduledDateTime
    }

    // Formatted actual taken time
    var takenTimeDisplay: String? {
        guard let date = actualTakenDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

enum RecordStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case taken = "taken"
    case skipped = "skipped"

    var displayName: String {
        switch self {
        case .pending: return String(localized: "待服用")
        case .taken: return String(localized: "已服用")
        case .skipped: return String(localized: "已跳过")
        }
    }

    var iconName: String {
        switch self {
        case .pending: return "circle"
        case .taken: return "checkmark.circle.fill"
        case .skipped: return "slash.circle"
        }
    }
}

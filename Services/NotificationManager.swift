import Foundation
import UIKit
import UserNotifications
import SwiftData

/// Manages all local notification scheduling and handling.
/// Wraps UNUserNotificationCenter.
final class NotificationManager: NSObject, ObservableObject, @unchecked Sendable {
    static let shared = NotificationManager()

    /// Maximum number of reminder attempts per time slot (original + re-reminders)
    static let maxReminderAttempts = 3
    /// Minutes between re-reminders when user hasn't acted
    static let reminderIntervalMinutes = 10

    private let center = UNUserNotificationCenter.current()

    override private init() {
        super.init()
        center.delegate = self
    }

    // MARK: - Permission

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }

    // MARK: - Category Registration

    /// Register notification categories with actions (e.g., "Mark as Taken")
    static func registerCategories() {
        let markAsTakenAction = UNNotificationAction(
            identifier: NotificationAction.markAsTaken.rawValue,
            title: String(localized: "标记已服用"),
            options: .foreground
        )

        let category = UNNotificationCategory(
            identifier: NotificationCategory.medicationReminder.rawValue,
            actions: [markAsTakenAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    // MARK: - Scheduling

    /// Schedule notifications for a single medication.
    /// Creates up to `maxReminderAttempts` staggered notifications per reminder time:
    /// the original at the scheduled time, then re-reminders spaced by `reminderIntervalMinutes`.
    func scheduleNotifications(for medication: Medication) {
        cancelNotifications(for: medication)

        guard medication.isActive else { return }

        let notificationsEnabled = UserDefaults.standard.bool(forKey: UserSettingsKeys.notificationsEnabled)
        guard notificationsEnabled else { return }

        for reminderTime in medication.reminderTimes {
            let timeString = reminderTime.formattedTime
            let soundEnabled = UserDefaults.standard.bool(forKey: UserSettingsKeys.soundEnabled)

            for attempt in 0..<Self.maxReminderAttempts {
                let content = UNMutableNotificationContent()
                content.title = medication.name
                content.body = String(localized: "该服用 \(medication.dosage) 了")
                content.sound = soundEnabled ? .default : nil
                content.categoryIdentifier = NotificationCategory.medicationReminder.rawValue
                content.userInfo = [
                    "medicationID": medication.id.uuidString,
                    "medicationName": medication.name,
                    "scheduledTime": timeString,
                    "attempt": attempt,
                ]

                let totalOffsetMinutes = attempt * Self.reminderIntervalMinutes
                var dateComponents = DateComponents()
                dateComponents.hour = reminderTime.hour
                dateComponents.minute = reminderTime.minute
                let baseDate = Calendar.current.date(from: dateComponents) ?? Date()
                let triggerDate = Calendar.current.date(
                    byAdding: .minute,
                    value: totalOffsetMinutes,
                    to: baseDate
                ) ?? baseDate
                var triggerComponents = Calendar.current.dateComponents([.hour, .minute], from: triggerDate)
                triggerComponents.second = 0

                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: triggerComponents,
                    repeats: true
                )

                let identifier = notificationIdentifier(
                    medicationID: medication.id,
                    time: timeString,
                    attempt: attempt
                )

                let request = UNNotificationRequest(
                    identifier: identifier,
                    content: content,
                    trigger: trigger
                )

                center.add(request) { error in
                    if let error = error {
                        print("Failed to schedule notification: \(error)")
                    }
                }
            }
        }

        updateBadgeCount()
    }

    /// Schedule notifications for all active medications
    func scheduleAllNotifications(medications: [Medication]) {
        for medication in medications where medication.isActive {
            scheduleNotifications(for: medication)
        }
    }

    // MARK: - Cancellation

    /// Cancel all notifications for a medication
    func cancelNotifications(for medication: Medication) {
        // Remove by prefix: all notifications for this medication
        center.getPendingNotificationRequests { [weak self] requests in
            let identifiers = requests
                .filter { $0.identifier.hasPrefix("medication-\(medication.id.uuidString)-") }
                .map { $0.identifier }
            self?.center.removePendingNotificationRequests(withIdentifiers: identifiers)
        }
        updateBadgeCount()
    }

    /// Cancel a specific notification
    func cancelNotification(medicationID: UUID, time: String) {
        let identifier = notificationIdentifier(medicationID: medicationID, time: time)
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        updateBadgeCount()
    }

    /// Cancel all pending notifications for a specific medication+time slot.
    /// Called when the user marks a medication as taken.
    func cancelAllRemindersForTime(medicationID: UUID, time: String) {
        let prefix = notificationPrefix(medicationID: medicationID, time: time)
        center.getPendingNotificationRequests { [weak self] requests in
            let identifiers = requests
                .filter { $0.identifier.hasPrefix(prefix) }
                .map { $0.identifier }
            self?.center.removePendingNotificationRequests(withIdentifiers: identifiers)
        }
        updateBadgeCount()
    }

    // MARK: - Helpers

    /// Prefix for all attempts of a medication+time slot
    func notificationPrefix(medicationID: UUID, time: String) -> String {
        "medication-\(medicationID.uuidString)-\(time)-"
    }

    /// Deterministic notification identifier, includes attempt index
    func notificationIdentifier(medicationID: UUID, time: String, attempt: Int = 0) -> String {
        "medication-\(medicationID.uuidString)-\(time)-\(attempt)"
    }

    /// Update app icon badge with pending notifications count
    func updateBadgeCount() {
        guard UserDefaults.standard.bool(forKey: UserSettingsKeys.badgeEnabled) else {
            center.setBadgeCount(0) { _ in }
            return
        }

        center.getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = requests.count
            }
        }
    }

    /// Fetch all medications from context (used for re-scheduling)
    func fetchAllMedications(context: ModelContext) -> [Medication] {
        let descriptor = FetchDescriptor<Medication>(
            sortBy: [SortDescriptor(\.name)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    /// Handle mark-as-taken from notification action
    func handleMarkAsTaken(medicationID: UUID, context: ModelContext, scheduledTime: String? = nil) {
        let today = Date().startOfDay
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        let predicate = #Predicate<MedicationRecord> { record in
            record.scheduledDate >= today && record.scheduledDate < tomorrow
        }

        let descriptor = FetchDescriptor<MedicationRecord>(predicate: predicate)
        guard let records = try? context.fetch(descriptor) else { return }

        // Find the first pending record for this medication today (optionally matching scheduled time)
        if let record = records.first(where: {
            $0.medication?.id == medicationID && $0.status == .pending
                && (scheduledTime == nil || $0.scheduledTime == scheduledTime)
        }) {
            record.status = .taken
            record.actualTakenDate = Date()
            try? context.save()

            // Cancel all reminders for this medication+time slot
            let time = scheduledTime ?? record.scheduledTime
            cancelAllRemindersForTime(medicationID: medicationID, time: time)
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    /// Show notification even when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge, .list])
    }

    /// Handle notification action (e.g., "Mark as Taken" button)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        if response.actionIdentifier == NotificationAction.markAsTaken.rawValue,
           let medicationIDString = userInfo["medicationID"] as? String,
           let medicationID = UUID(uuidString: medicationIDString) {

            let scheduledTime = userInfo["scheduledTime"] as? String

            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .markMedicationAsTaken,
                    object: nil,
                    userInfo: [
                        "medicationID": medicationID,
                        "scheduledTime": scheduledTime as Any,
                    ]
                )
            }
        }

        completionHandler()
    }
}

// MARK: - Notification Names and Categories

extension Notification.Name {
    static let markMedicationAsTaken = Notification.Name("markMedicationAsTaken")
}

enum NotificationCategory: String {
    case medicationReminder = "MEDICATION_REMINDER"
}

enum NotificationAction: String {
    case markAsTaken = "MARK_AS_TAKEN"
}

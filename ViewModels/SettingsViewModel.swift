import Foundation
import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    @AppStorage(UserSettingsKeys.notificationsEnabled) var notificationsEnabled = true {
        didSet { handleNotificationToggle() }
    }
    @AppStorage(UserSettingsKeys.soundEnabled) var soundEnabled = true
    @AppStorage(UserSettingsKeys.badgeEnabled) var badgeEnabled = true
    @AppStorage(UserSettingsKeys.advanceReminderMinutes) var advanceReminderMinutes = 0

    @Published var isNotificationAuthorized = false

    func checkNotificationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        isNotificationAuthorized = settings.authorizationStatus == .authorized
            || settings.authorizationStatus == .provisional
            || settings.authorizationStatus == .ephemeral
    }

    func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    private func handleNotificationToggle() {
        if !notificationsEnabled {
            // Cancel all pending notifications
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
        // When re-enabled, notifications will be re-scheduled on next app launch / foreground
    }
}

import Foundation

/// App-global user preferences stored in UserDefaults via @AppStorage.
/// These are NOT SwiftData models — they are singletons accessed through SettingsViewModel.
enum UserSettingsKeys {
    static let notificationsEnabled = "notificationsEnabled"
    static let soundEnabled = "soundEnabled"
    static let badgeEnabled = "badgeEnabled"
    static let advanceReminderMinutes = "advanceReminderMinutes"
}

struct UserSettingsDefaults {
    static let notificationsEnabled = true
    static let soundEnabled = true
    static let badgeEnabled = true
    static let advanceReminderMinutes = 0  // 0 = at exact time
}

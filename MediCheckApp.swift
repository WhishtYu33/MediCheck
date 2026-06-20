import SwiftUI
import SwiftData

@main
struct MediCheckApp: App {
    @StateObject private var notificationManager = NotificationManager.shared

    let container: ModelContainer

    init() {
        // Register UserDefaults defaults BEFORE any other code reads them.
        // @AppStorage's inline default is not registered with the underlying
        // UserDefaults, so UserDefaults.standard.bool(forKey:) returns false
        // for a key that was never explicitly written — even though the UI
        // shows the toggle as ON. This caused notifications to never be
        // scheduled on fresh installs.
        UserDefaults.standard.register(defaults: [
            UserSettingsKeys.notificationsEnabled: UserSettingsDefaults.notificationsEnabled,
            UserSettingsKeys.soundEnabled: UserSettingsDefaults.soundEnabled,
            UserSettingsKeys.badgeEnabled: UserSettingsDefaults.badgeEnabled,
            UserSettingsKeys.advanceReminderMinutes: UserSettingsDefaults.advanceReminderMinutes,
        ])

        do {
            let schema = Schema([
                Medication.self,
                ReminderTime.self,
                MedicationRecord.self,
            ])

            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true
            )

            container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }

        // Register notification categories with actions
        NotificationManager.registerCategories()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(container: container)
                .onAppear {
                    Task {
                        _ = await notificationManager.requestAuthorization()
                        // Schedule after authorization completes so notifications
                        // are active post-grant (especially on first launch).
                        notificationManager.scheduleAllNotifications(
                            medications: notificationManager.fetchAllMedications(context: container.mainContext)
                        )
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: .markMedicationAsTaken)) { notification in
                    guard let medicationID = notification.userInfo?["medicationID"] as? UUID else {
                        return
                    }
                    notificationManager.handleMarkAsTaken(
                        medicationID: medicationID,
                        context: container.mainContext
                    )
                }
        }
        .modelContainer(container)
    }
}

/// Root view that handles scene phase changes for notification re-scheduling
struct AppRootView: View {
    @Environment(\.scenePhase) private var scenePhase

    let container: ModelContainer

    var body: some View {
        ContentView()
            .onChange(of: scenePhase) { _, newPhase in
                switch newPhase {
                case .active:
                    NotificationManager.shared.scheduleAllNotifications(
                        medications: NotificationManager.shared.fetchAllMedications(context: container.mainContext)
                    )
                    NotificationManager.shared.updateBadgeCount()
                case .background:
                    NotificationManager.shared.updateBadgeCount()
                default:
                    break
                }
            }
    }
}

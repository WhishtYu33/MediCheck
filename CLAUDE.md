# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MediCheck (用药提醒) — iOS medication reminder app. SwiftUI + SwiftData + UserNotifications, MVVM architecture. Minimum iOS 16. Chinese/English localization.

## Build & Run

- Open in Xcode, select simulator or device, **Cmd+R** to run
- No CLI build tooling (no `xcodebuild` scripts, no Fastlane)
- Requires Xcode with iOS 16+ SDK
- Notifications only fire reliably on a real device (simulator may delay/drop them)

## Architecture

```
MediCheckApp.swift          → @main entry point, ModelContainer init, notification registration
  └─ AppRootView            → scene phase observer → re-schedules notifications on foreground
      └─ ContentView        → TabView with 3 tabs: Today, History, Settings

Models/                     → @Model classes (SwiftData)
  Medication               → name, dosage, iconName, colorHex, notes, isActive
                             @Relationship → [ReminderTime], [MedicationRecord]
  ReminderTime             → hour, minute (for one daily notification slot)
  MedicationRecord          → scheduledDate, scheduledTime, status (pending/taken/skipped)
  UserSettings              → UserDefaults-backed preferences keys/helpers

ViewModels/                 → @MainActor ObservableObject classes
  TodayViewModel           → fetches today's records, markAsTaken/markAsSkipped, progress calc
  HistoryViewModel         → fetches historical records, calendar data
  MedicationFormViewModel  → add/edit medication form state
  SettingsViewModel        → notification/sound/badge toggle state

Services/                   → stateless or singleton service objects
  NotificationManager (shared singleton) → wraps UNUserNotificationCenter:
    - Request auth, register categories (with "Mark as Taken" action)
    - Schedule/cancel per-medication notifications via UNCalendarNotificationTrigger
    - Handle mark-as-taken from notification action banner
    - Update badge count
  RecordManager             → ensures MedicationRecord entries exist for today (lazy creation on view appear)

Views/
  Today/                   → TodayView, MedicationCardView, ProgressRingView, EmptyStateView
  History/                 → HistoryView, CalendarStripView, DayDetailView, AdherenceChartView
  Medication/              → AddEditMedicationView, MedicationListView, IconPickerView, ColorPickerView, TimePickerRow
  Settings/                → SettingsView

Extensions/                → Color+Hex (parse hex strings), Date+Extensions (startOfDay), View+Extensions
```

### Data flow

1. **App launch**: `MediCheckApp.init()` creates `ModelContainer` with schema. `NotificationManager.registerCategories()` registers notification action buttons.
2. **Foreground**: `AppRootView` re-schedules all notifications, updates badge.
3. **Today tab appears**: `TodayViewModel.refresh()` → `RecordManager.ensureTodayRecordsExist()` lazily creates `MedicationRecord` rows for today if missing → fetches and displays.
4. **User taps "Taken"**: `TodayViewModel.markAsTaken()` → updates record status → cancels that specific pending notification.
5. **User taps notification action**: `UNUserNotificationCenterDelegate` posts `Notification.Name.markMedicationAsTaken` → `MediCheckApp` observes and calls `NotificationManager.handleMarkAsTaken()`.
6. **Settings changes**: stored in `UserDefaults` (not SwiftData); `NotificationManager` reads them when scheduling.

### Key relationships

- `Medication` ← 1:N → `ReminderTime` (cascade delete)
- `Medication` ← 1:N → `MedicationRecord` (cascade delete)
- `ReminderTime` stores only `hour`/`minute` (Int), formatted via computed property `formattedTime`
- `MedicationRecord` is the daily "instance" — generated lazily, not pre-populated

## Notification System

- Uses `UNCalendarNotificationTrigger` with repeating date components
- Each notification has a deterministic identifier: `medication-{UUID}-{HH:mm}`
- "Mark as Taken" action button on notification banner triggers in-app handling via NotificationCenter bridge
- Badge count reflects pending notification count
- Notifications respect global on/off toggle and per-medication `isActive` flag

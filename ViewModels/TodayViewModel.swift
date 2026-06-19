import Foundation
import SwiftData
import SwiftUI

@MainActor
final class TodayViewModel: ObservableObject {
    @Published var todayRecords: [MedicationRecord] = []
    @Published var progressFraction: Double = 0.0
    @Published var progressText: String = ""

    private let recordManager = RecordManager()
    private var isProcessing = false

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12: return String(localized: "早上好 ☀️")
        case 12..<14: return String(localized: "中午好 🌤️")
        case 14..<18: return String(localized: "下午好 🌈")
        case 18..<22: return String(localized: "晚上好 🌙")
        default: return String(localized: "注意休息 🌛")
        }
    }

    func refresh(medications: [Medication], context: ModelContext) {
        // Ensure today's records exist
        recordManager.ensureTodayRecordsExist(
            medications: medications,
            existingRecords: todayRecords,
            context: context
        )
        try? context.save()

        // Fetch today's records
        fetchTodayRecords(context: context)
        updateProgress()
    }

    private func fetchTodayRecords(context: ModelContext) {
        let today = Date().startOfDay
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        let predicate = #Predicate<MedicationRecord> { record in
            record.scheduledDate >= today && record.scheduledDate < tomorrow
        }

        let descriptor = FetchDescriptor<MedicationRecord>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.scheduledTime)]
        )

        do {
            todayRecords = try context.fetch(descriptor)
        } catch {
            print("Failed to fetch today's records: \(error)")
            todayRecords = []
        }
    }

    func markAsTaken(_ record: MedicationRecord, context: ModelContext) {
        guard !isProcessing, record.status == .pending else { return }
        isProcessing = true

        record.status = .taken
        record.actualTakenDate = Date()
        try? context.save()

        // Cancel the specific notification if it hasn't fired
        if let medication = record.medication {
            let identifier = "medication-\(medication.id.uuidString)-\(record.scheduledTime)"
            UNUserNotificationCenter.current()
                .removePendingNotificationRequests(withIdentifiers: [identifier])
        }

        fetchTodayRecords(context: context)
        updateProgress()
        isProcessing = false
    }

    func markAsSkipped(_ record: MedicationRecord, context: ModelContext) {
        guard !isProcessing, record.status == .pending else { return }
        isProcessing = true

        record.status = .skipped
        try? context.save()

        fetchTodayRecords(context: context)
        updateProgress()
        isProcessing = false
    }

    private func updateProgress() {
        guard !todayRecords.isEmpty else {
            progressFraction = 0
            progressText = String(localized: "今天没有用药计划")
            return
        }
        let handled = todayRecords.filter { $0.status != .pending }.count
        progressFraction = Double(handled) / Double(todayRecords.count)
        progressText = "\(handled)/\(todayRecords.count)"
    }
}

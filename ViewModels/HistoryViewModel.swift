import Foundation
import SwiftData
import SwiftUI

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var dayRecords: [MedicationRecord] = []
    @Published var weeklyAdherenceData: [(date: Date, percentage: Double)] = []
    @Published var adherenceByDate: [Date: Double] = [:]

    func fetchRecords(for date: Date, context: ModelContext) {
        let startOfDay = date.startOfDay
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = #Predicate<MedicationRecord> { record in
            record.scheduledDate >= startOfDay && record.scheduledDate < endOfDay
        }

        let descriptor = FetchDescriptor<MedicationRecord>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.scheduledTime)]
        )

        do {
            dayRecords = try context.fetch(descriptor)
        } catch {
            print("Failed to fetch records: \(error)")
            dayRecords = []
        }
    }

    func fetchAdherenceData(context: ModelContext) {
        // Fetch last 30 days of records for the calendar strip
        let thirtyDaysAgo = Date().daysAgo(29).startOfDay
        let today = Date().startOfDay
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        let predicate = #Predicate<MedicationRecord> { record in
            record.scheduledDate >= thirtyDaysAgo && record.scheduledDate < tomorrow
        }

        let descriptor = FetchDescriptor<MedicationRecord>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.scheduledDate)]
        )

        do {
            let allRecords = try context.fetch(descriptor)
            computeAdherenceByDate(allRecords)
            computeWeeklyAdherence(allRecords)
        } catch {
            print("Failed to fetch adherence data: \(error)")
        }
    }

    private func computeAdherenceByDate(_ records: [MedicationRecord]) {
        // Group records by date
        var grouped: [Date: [MedicationRecord]] = [:]
        for record in records {
            let day = record.scheduledDate.startOfDay
            grouped[day, default: []].append(record)
        }

        var result: [Date: Double] = [:]
        for (date, dayRecords) in grouped {
            let handled = dayRecords.filter { $0.status != .pending }.count
            result[date] = dayRecords.isEmpty ? 0 : Double(handled) / Double(dayRecords.count)
        }
        adherenceByDate = result
    }

    private func computeWeeklyAdherence(_ records: [MedicationRecord]) {
        let last7Days = Date.lastNDays(7)

        var result: [(date: Date, percentage: Double)] = []
        for date in last7Days {
            let startOfDay = date.startOfDay
            let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

            let dayRecords = records.filter {
                $0.scheduledDate >= startOfDay && $0.scheduledDate < endOfDay
            }

            if dayRecords.isEmpty {
                result.append((date: date, percentage: 0))
            } else {
                let handled = dayRecords.filter { $0.status != .pending }.count
                result.append((date: date, percentage: Double(handled) / Double(dayRecords.count)))
            }
        }
        weeklyAdherenceData = result
    }
}

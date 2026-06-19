import Foundation

extension Date {
    /// Normalize to start of day (midnight)
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// Check if two dates are on the same calendar day
    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }

    /// Get a date for a specific number of days ago
    func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: self) ?? self
    }

    /// Number of days between self and another date
    func daysBetween(_ other: Date) -> Int {
        Calendar.current.dateComponents([.day], from: startOfDay, to: other.startOfDay).day ?? 0
    }

    /// Format date as relative or short date for display
    var relativeDisplay: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) {
            return String(localized: "今天")
        } else if calendar.isDateInYesterday(self) {
            return String(localized: "昨天")
        } else if calendar.isDateInTomorrow(self) {
            return String(localized: "明天")
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "M月d日"
            return formatter.string(from: self)
        }
    }

    /// Format as "yyyy年M月d日"
    var fullDateDisplay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        return formatter.string(from: self)
    }

    /// Weekday display e.g. "周一", "周二"
    var weekdayDisplay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: self)
    }

    /// Simple date string "MM/dd"
    var shortDateDisplay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: self)
    }

    /// Get the last N days as an array of dates (including today)
    static func lastNDays(_ n: Int) -> [Date] {
        let today = Date().startOfDay
        return (0..<n).map { today.daysAgo($0) }.reversed()
    }
}

extension Calendar {
    /// Get the number of days in a month for a given date
    func daysInMonth(for date: Date) -> Int {
        range(of: .day, in: .month, for: date)?.count ?? 30
    }

    /// Get the first day of the month for a given date
    func firstDayOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}

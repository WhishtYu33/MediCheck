import SwiftUI

struct CalendarStripView: View {
    @Binding var selectedDate: Date
    var adherenceData: [Date: Double]  // Date -> adherence percentage (0...1)

    private let days = Date.lastNDays(30)

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(days, id: \.timeIntervalSince1970) { date in
                        CalendarDayCell(
                            date: date,
                            isSelected: date.isSameDay(as: selectedDate),
                            adherence: adherenceData[date.startOfDay]
                        )
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedDate = date
                            }
                        }
                        .id(date.timeIntervalSince1970)
                    }
                }
                .padding(.horizontal, 16)
            }
            .onAppear {
                // Scroll to today
                if let today = days.last {
                    proxy.scrollTo(today.timeIntervalSince1970, anchor: .trailing)
                }
            }
        }
    }
}

struct CalendarDayCell: View {
    let date: Date
    let isSelected: Bool
    var adherence: Double?  // nil = no medications scheduled

    private var dotColor: Color {
        guard let adherence = adherence else { return .gray.opacity(0.3) }
        switch adherence {
        case 1.0: return .green
        case 0.01..<1.0: return .yellow
        default: return .red
        }
    }

    var body: some View {
        VStack(spacing: 6) {
            // Weekday
            Text(date.weekdayDisplay)
                .font(.caption2)
                .foregroundColor(.secondary)

            // Day number
            Text(date, format: .dateTime.day())
                .font(.system(.callout, design: .rounded))
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(isSelected ? Color.blue : Color.clear)
                )

            // Adherence dot
            Circle()
                .fill(dotColor)
                .frame(width: 6, height: 6)
        }
        .frame(width: 44)
    }
}

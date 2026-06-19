import SwiftUI

struct TimePickerRow: View {
    @Binding var time: TempReminderTime

    var body: some View {
        HStack {
            Image(systemName: "clock.fill")
                .foregroundColor(.secondary)

            DatePicker(
                String(localized: "时间"),
                selection: Binding(
                    get: {
                        let calendar = Calendar.current
                        var components = DateComponents()
                        components.hour = time.hour
                        components.minute = time.minute
                        return calendar.date(from: components) ?? Date()
                    },
                    set: { newDate in
                        let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                        time.hour = components.hour ?? 8
                        time.minute = components.minute ?? 0
                    }
                ),
                displayedComponents: .hourAndMinute
            )
            .labelsHidden()
            .datePickerStyle(.compact)

            Spacer()

            Text(time.formattedTime)
                .font(.body.monospacedDigit())
                .foregroundColor(.secondary)
        }
    }
}

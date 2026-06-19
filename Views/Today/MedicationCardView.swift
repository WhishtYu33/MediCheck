import SwiftUI

struct MedicationCardView: View {
    let medication: Medication
    let records: [MedicationRecord]
    var onMarkTaken: (MedicationRecord) -> Void
    var onMarkSkipped: (MedicationRecord) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header: icon + name + dosage
            HStack(spacing: 12) {
                Image(systemName: medication.iconName)
                    .font(.title2)
                    .foregroundColor(medication.color)
                    .frame(width: 40, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(medication.color.opacity(0.12))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(medication.name)
                        .font(.headline)
                    Text(medication.dosage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            Divider()

            // Punch card row: time buttons
            HStack(spacing: 20) {
                ForEach(records, id: \.id) { record in
                    PunchButton(
                        record: record,
                        onTap: { onMarkTaken(record) },
                        onLongPress: { onMarkSkipped(record) }
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, y: 2)
        )
    }
}

// MARK: - Punch Button (individual check-in circle)

struct PunchButton: View {
    let record: MedicationRecord
    let onTap: () -> Void
    let onLongPress: () -> Void

    @State private var isPressed = false

    var body: some View {
        VStack(spacing: 6) {
            // Time label
            Text(record.scheduledTime)
                .font(.caption)
                .foregroundColor(.secondary)

            // Circular button
            ZStack {
                Circle()
                    .strokeBorder(borderColor, lineWidth: 2.5)
                    .background(Circle().fill(backgroundColor))
                    .frame(width: 48, height: 48)

                if record.status == .taken {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .transition(.scale.combined(with: .opacity))
                } else if record.status == .skipped {
                    Image(systemName: "minus")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .onTapGesture {
                guard record.status == .pending else { return }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isPressed = false
                    }
                }
                onTap()
            }
            .onLongPressGesture(minimumDuration: 0.5) {
                guard record.status == .pending else { return }
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                onLongPress()
            }

            // Status text
            Text(statusText)
                .font(.caption2)
                .foregroundColor(statusColor)
        }
        .frame(maxWidth: .infinity)
        .opacity(record.status != .pending ? 0.7 : 1.0)
    }

    private var borderColor: Color {
        switch record.status {
        case .pending:
            return record.isOverdue ? .orange : .blue
        case .taken:
            return .green
        case .skipped:
            return .gray
        }
    }

    private var backgroundColor: Color {
        switch record.status {
        case .pending:
            return record.isOverdue
                ? Color.orange.opacity(0.08)
                : Color.blue.opacity(0.05)
        case .taken:
            return .green
        case .skipped:
            return .gray
        }
    }

    private var statusColor: Color {
        switch record.status {
        case .pending: return record.isOverdue ? .orange : .secondary
        case .taken: return .green
        case .skipped: return .gray
        }
    }

    private var statusText: String {
        switch record.status {
        case .pending:
            return record.isOverdue
                ? String(localized: "已过期")
                : String(localized: "待服")
        case .taken: return String(localized: "已服")
        case .skipped: return String(localized: "跳过")
        }
    }
}

import SwiftUI
import SwiftData

struct DayDetailView: View {
    let records: [MedicationRecord]

    // Group records by medication
    private var groupedRecords: [(Medication, [MedicationRecord])] {
        var groups: [UUID: (Medication, [MedicationRecord])] = [:]
        for record in records {
            guard let medication = record.medication else { continue }
            if var existing = groups[medication.id] {
                existing.1.append(record)
                groups[medication.id] = existing
            } else {
                groups[medication.id] = (medication, [record])
            }
        }
        return groups.values.sorted { $0.0.name < $1.0.name }
    }

    var body: some View {
        List {
            ForEach(groupedRecords, id: \.0.id) { medication, medRecords in
                Section {
                    ForEach(medRecords.sorted { $0.scheduledTime < $1.scheduledTime }) { record in
                        RecordRowView(record: record, medicationColor: medication.color)
                    }
                } header: {
                    HStack {
                        Image(systemName: medication.iconName)
                            .foregroundColor(medication.color)
                        Text(medication.name)
                        Text("·")
                        Text(medication.dosage)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

struct RecordRowView: View {
    let record: MedicationRecord
    let medicationColor: Color

    var body: some View {
        HStack {
            Image(systemName: record.status.iconName)
                .foregroundColor(statusColor)
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                Text(record.scheduledTime)
                    .font(.headline)

                if record.status == .taken, let takenTime = record.takenTimeDisplay {
                    Text("服用时间: \(takenTime)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Text(record.status.displayName)
                .font(.subheadline)
                .foregroundColor(statusColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(statusColor.opacity(0.12))
                )
        }
        .padding(.vertical, 4)
    }

    private var statusColor: Color {
        switch record.status {
        case .pending: return .orange
        case .taken: return .green
        case .skipped: return .gray
        }
    }
}

import SwiftUI
import SwiftData

struct MedicationListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Medication.createdAt) private var medications: [Medication]

    @State private var medicationToEdit: Medication?
    @State private var showEditSheet = false
    @State private var medicationToDelete: Medication?
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            List {
                if medications.isEmpty {
                    ContentUnavailableView(
                        String(localized: "暂无药品"),
                        systemImage: "pills",
                        description: Text("点击右上角 + 添加药品")
                    )
                } else {
                    ForEach(medications) { medication in
                        MedicationRowView(medication: medication)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                medicationToEdit = medication
                                showEditSheet = true
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    medicationToDelete = medication
                                    showDeleteConfirmation = true
                                } label: {
                                    Label(String(localized: "删除"), systemImage: "trash")
                                }

                                Button {
                                    medicationToEdit = medication
                                    showEditSheet = true
                                } label: {
                                    Label(String(localized: "编辑"), systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                    }
                }
            }
            .navigationTitle(String(localized: "药品管理"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        medicationToEdit = nil
                        showEditSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "完成")) {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showEditSheet) {
                AddEditMedicationView(medicationToEdit: medicationToEdit)
            }
            .confirmationDialog(
                String(localized: "确认删除"),
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button(String(localized: "删除"), role: .destructive) {
                    if let medication = medicationToDelete {
                        deleteMedication(medication)
                    }
                }
                Button(String(localized: "取消"), role: .cancel) {}
            } message: {
                Text("删除后将无法恢复，相关的服药记录也会被删除。")
            }
        }
    }

    private func deleteMedication(_ medication: Medication) {
        NotificationManager.shared.cancelNotifications(for: medication)
        modelContext.delete(medication)
        try? modelContext.save()
    }
}

// MARK: - Medication Row

struct MedicationRowView: View {
    let medication: Medication

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: medication.iconName)
                .font(.title3)
                .foregroundColor(medication.color)
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(medication.color.opacity(0.12))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(medication.name)
                    .font(.body)

                Text(medication.dosage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(medication.reminderTimesDisplay)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if !medication.isActive {
                Text(String(localized: "已暂停"))
                    .font(.caption2)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(Color.orange.opacity(0.12))
                    )
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

import SwiftUI
import SwiftData

struct AddEditMedicationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @StateObject private var viewModel = MedicationFormViewModel()

    /// Pass an existing medication to enter edit mode
    var medicationToEdit: Medication?

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Basic Info
                Section {
                    TextField(String(localized: "药品名称"), text: $viewModel.name)
                        .font(.body)

                    TextField(String(localized: "剂量 (如: 500mg, 1片, 10ml)"), text: $viewModel.dosage)
                        .font(.body)
                } header: {
                    Text("基本信息")
                }

                // MARK: - Icon Picker
                Section {
                    IconPickerView(selectedIcon: $viewModel.selectedIcon)
                } header: {
                    Text("图标")
                }

                // MARK: - Color Picker
                Section {
                    ColorPickerView(selectedColorHex: $viewModel.selectedColorHex)
                } header: {
                    Text("颜色")
                }

                // MARK: - Reminder Times
                Section {
                    ForEach($viewModel.reminderTimes.indices, id: \.self) { index in
                        TimePickerRow(time: $viewModel.reminderTimes[index])
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            viewModel.removeReminderTime(at: index)
                        }
                    }

                    Button {
                        viewModel.addReminderTime()
                    } label: {
                        Label(String(localized: "添加时间"), systemImage: "plus.circle.fill")
                    }
                } header: {
                    Text("提醒时间")
                }

                // MARK: - Notes
                Section {
                    TextField(String(localized: "备注 (可选)"), text: $viewModel.notes, axis: .vertical)
                        .lineLimit(2...4)
                } header: {
                    Text("备注")
                }

                // MARK: - Active Toggle (Edit mode only)
                if viewModel.isEditing {
                    Section {
                        Toggle(isOn: $viewModel.isActive) {
                            Label(String(localized: "启用提醒"), systemImage: "bell.fill")
                        }
                    }
                }
            }
            .navigationTitle(viewModel.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "取消")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "保存")) {
                        viewModel.save(context: modelContext)
                        dismiss()
                    }
                    .disabled(!viewModel.isValid)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                if let medication = medicationToEdit {
                    viewModel.loadFrom(medication)
                }
            }
        }
    }
}

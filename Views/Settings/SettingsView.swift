import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showMedicationList = false

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Notifications Section
                Section {
                    HStack {
                        Label("通知权限", systemImage: "bell.badge.fill")
                        Spacer()
                        if viewModel.isNotificationAuthorized {
                            Text("已授权")
                                .font(.subheadline)
                                .foregroundColor(.green)
                        } else {
                            Button("开启") {
                                viewModel.openSystemSettings()
                            }
                            .font(.subheadline)
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }
                    }

                    Toggle(isOn: $viewModel.notificationsEnabled) {
                        Label("启用提醒", systemImage: "bell.fill")
                    }

                    Toggle(isOn: $viewModel.soundEnabled) {
                        Label("提醒声音", systemImage: "speaker.wave.2.fill")
                    }
                    .disabled(!viewModel.notificationsEnabled)

                    Toggle(isOn: $viewModel.badgeEnabled) {
                        Label("应用角标", systemImage: "app.badge.fill")
                    }
                    .disabled(!viewModel.notificationsEnabled)

                } header: {
                    Text("通知设置")
                }

                // MARK: - Medications Section
                Section {
                    Button {
                        showMedicationList = true
                    } label: {
                        Label("管理药品", systemImage: "list.bullet.clipboard.fill")
                    }
                } header: {
                    Text("药品管理")
                }

                // MARK: - About Section
                Section {
                    HStack {
                        Label("版本", systemImage: "info.circle")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("关于")
                }
            }
            .navigationTitle("设置")
            .sheet(isPresented: $showMedicationList) {
                MedicationListView()
            }
            .task {
                await viewModel.checkNotificationStatus()
            }
        }
    }
}

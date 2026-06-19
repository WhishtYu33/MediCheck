import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(
        filter: #Predicate<Medication> { $0.isActive == true },
        sort: \Medication.createdAt
    ) private var activeMedications: [Medication]

    @StateObject private var viewModel = TodayViewModel()

    @State private var showAddMedication = false

    var body: some View {
        NavigationStack {
            Group {
                if activeMedications.isEmpty {
                    EmptyStateView {
                        showAddMedication = true
                    }
                } else if viewModel.todayRecords.isEmpty {
                    noMedicationsTodayView
                } else {
                    todayContent
                }
            }
            .navigationTitle("今天")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !activeMedications.isEmpty {
                        ProgressRingView(
                            progress: viewModel.progressFraction,
                            text: viewModel.progressText
                        )
                        .frame(width: 44, height: 44)
                    }
                }
            }
            .onAppear {
                viewModel.refresh(
                    medications: activeMedications,
                    context: modelContext
                )
            }
            .refreshable {
                viewModel.refresh(
                    medications: activeMedications,
                    context: modelContext
                )
            }
            .sheet(isPresented: $showAddMedication) {
                AddEditMedicationView()
            }
        }
    }

    // Today's medication cards
    private var todayContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Date greeting header
                dateHeader

                // Medication cards
                ForEach(activeMedications) { medication in
                    let records = viewModel.todayRecords.filter {
                        $0.medication?.id == medication.id
                    }
                    if !records.isEmpty {
                        MedicationCardView(
                            medication: medication,
                            records: records.sorted { $0.scheduledTime < $1.scheduledTime },
                            onMarkTaken: { record in
                                viewModel.markAsTaken(record, context: modelContext)
                            },
                            onMarkSkipped: { record in
                                viewModel.markAsSkipped(record, context: modelContext)
                            }
                        )
                    }
                }
            }
            .padding()
        }
    }

    // Date header
    private var dateHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(Date().fullDateDisplay)
                    .font(.title2.bold())
                Spacer()
                Text(viewModel.greeting)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            if viewModel.progressFraction > 0 {
                Text("已完成 \(viewModel.progressText)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 4)
    }

    // No medications scheduled for today
    private var noMedicationsTodayView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.green)
            Text("今天没有用药计划")
                .font(.title3.bold())
            Text("好好休息，保持健康！")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

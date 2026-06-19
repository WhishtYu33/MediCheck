import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = HistoryViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Calendar strip
                CalendarStripView(
                    selectedDate: $viewModel.selectedDate,
                    adherenceData: viewModel.adherenceByDate
                )
                .padding(.vertical, 8)

                Divider()

                // Day detail
                if viewModel.dayRecords.isEmpty {
                    emptyDayView
                } else {
                    DayDetailView(records: viewModel.dayRecords)
                }

                // Adherence chart
                AdherenceChartView(data: viewModel.weeklyAdherenceData)
                    .padding()
            }
            .navigationTitle("历史")
            .onAppear {
                viewModel.fetchRecords(
                    for: viewModel.selectedDate,
                    context: modelContext
                )
                viewModel.fetchAdherenceData(context: modelContext)
            }
            .onChange(of: viewModel.selectedDate) { _, newDate in
                viewModel.fetchRecords(for: newDate, context: modelContext)
            }
        }
    }

    private var emptyDayView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "pills.fill")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.5))
            Text("当天没有用药记录")
                .font(.headline)
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

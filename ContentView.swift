import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showAddMedication = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $selectedTab) {
                TodayView()
                    .tabItem {
                        Label("今天", systemImage: "sun.max.fill")
                    }
                    .tag(0)

                HistoryView()
                    .tabItem {
                        Label("历史", systemImage: "calendar")
                    }
                    .tag(1)

                SettingsView()
                    .tabItem {
                        Label("设置", systemImage: "gearshape.fill")
                    }
                    .tag(2)
            }

            // Floating "+" button on Today tab
            if selectedTab == 0 {
                Button {
                    showAddMedication = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(
                            Circle()
                                .fill(.blue)
                                .shadow(color: .blue.opacity(0.3), radius: 12, y: 4)
                        )
                }
                .padding(.trailing, 20)
                .padding(.bottom, 80)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .sheet(isPresented: $showAddMedication) {
            AddEditMedicationView()
        }
        .tint(.blue)
    }
}

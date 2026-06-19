import SwiftUI

struct AdherenceChartView: View {
    let data: [(date: Date, percentage: Double)]  // 0...1

    private let maxBarHeight: CGFloat = 120

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("近7天依从性")
                .font(.subheadline.bold())
                .foregroundColor(.secondary)

            if data.isEmpty {
                Text("暂无数据")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(data.indices, id: \.self) { index in
                        let item = data[index]
                        VStack(spacing: 4) {
                            // Percentage label
                            Text(String(format: "%.0f%%", item.percentage * 100))
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(barColor(item.percentage))

                            // Bar
                            RoundedRectangle(cornerRadius: 6)
                                .fill(barColor(item.percentage))
                                .frame(
                                    width: 32,
                                    height: max(4, maxBarHeight * CGFloat(item.percentage))
                                )
                                .animation(.easeInOut(duration: 0.5), value: item.percentage)

                            // Day label
                            Text(item.date.shortDateDisplay)
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        )
    }

    private func barColor(_ percentage: Double) -> Color {
        switch percentage {
        case 1.0: return .green
        case 0.5..<1.0: return .yellow
        case 0.01..<0.5: return .orange
        default: return .red
        }
    }
}

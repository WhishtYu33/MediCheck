import SwiftUI

struct ProgressRingView: View {
    let progress: Double  // 0.0 to 1.0
    let text: String

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(
                    Color(.systemGray5),
                    lineWidth: 6
                )

            // Progress ring
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    LinearGradient(
                        colors: [.green, .mint],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)

            // Center text
            VStack(spacing: 2) {
                if progress > 0 {
                    Text(String(format: "%.0f%%", progress * 100))
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.bold)
                } else {
                    Image(systemName: "pills")
                        .font(.caption2)
                }
            }
            .foregroundColor(.secondary)
        }
    }
}

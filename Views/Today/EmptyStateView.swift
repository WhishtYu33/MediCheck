import SwiftUI

struct EmptyStateView: View {
    var onAddMedication: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "pills.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue.opacity(0.6))

            VStack(spacing: 8) {
                Text("还没有添加药品")
                    .font(.title2.bold())

                Text("添加您的第一个药品，\n开始管理用药提醒")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                onAddMedication()
            } label: {
                Label("添加药品", systemImage: "plus")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.blue)
                    )
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
